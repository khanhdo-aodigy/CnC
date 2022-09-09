/*==========================================================================================================================================================================
 * Controller class for vs_UploadShipmentLineItemsController LWC
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           15 Aug 2022                       phan.thu@aodigy.com                    US-Ship-000009                                          init
 * ========================================================================================================================================================================== 
 */

public without sharing class VS_UploadShipmentLineItemsController 
{
    @AuraEnabled
    public static Integer readCSVFile(String contentDocumentId, String parentRecordId) 
    {
        ADGLIB_SObjectUnitOfWork uow;
        Map<String, Manufacturer_Invoice__c> existingInvoiceMap   = new Map<String, Manufacturer_Invoice__c>();
        Map<String, List<Shipment_Line_Item__c>> toBeCreatedItems = new Map<String, List<Shipment_Line_Item__c>>();
        Map<String, Manufacturer_Invoice__c> toBeCreatedInvoices  = new Map<String, Manufacturer_Invoice__c>();
        Map<String, HS_Type__c> hsCodeMap                         = new Map<String, HS_Type__c>();
        Map<String, Product_Code__c> productCodeMap               = new Map<String, Product_Code__c>();
        Map<String, String> itemAndHSCodeMap                      = new Map<String, String>();
        Map<String, String> itemAndProductCodeMap                 = new Map<String, String>();
        Set<String> invoiceNoSet                                  = new Set<String>();
        Set<String> hsCodeSet                                     = new Set<String>();
        Set<String> productCodeSet                                = new Set<String>();
        Integer noOfLineItemCreated = 0;

        if (contentDocumentId != null) 
        {
            // Get Content Version based on document id 
            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId];

            // Delete the uploaded CSV
            uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {ContentDocument.SObjectType});
            uow.registerDeleted(new ContentDocument(Id = contentDocumentId));
            uow.commitWork();
            
            // Split lines in CSV file
            List<String> lstCSVLines = cv.VersionData.toString().split('\n');
            if (lstCSVLines.size() == 1) 
            {
                throw new VS_UploadShipmentLineItemsControllerException().invalidCSV();
            }

            //Get Vehicle Shipment
            Vehicle_Shipment__c shipment = VehicleShipmentServices.getByIdWithInvoicesAndLineItemsAndSVMs(parentRecordId, false, false, false);

            for (Integer i = 1; i < lstCSVLines.size(); i++)
            {
                Shipment_Line_Item__c item            = new Shipment_Line_Item__c();
                Manufacturer_Invoice__c invoice       = new Manufacturer_Invoice__c();
                List<String> csvRowData               = new List<String>();
                String csvLine                        = lstCSVLines[i];
                Boolean isEmptyRow                    = true;
                String invoiceNo;   
                List<Shipment_Line_Item__c> tempItems;
                Integer startIndex;
                Integer endIndex;
                
                try 
                {
                    while (csvLine.indexOf('"') > -1) 
                    {
                        if (startIndex == null)
                        {
                            startIndex = csvLine.indexOf('"');
                            csvLine    = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex + 1, csvLine.length());
                        } 
                        else 
                        {
                            if (endIndex == null)
                            {
                                endIndex = csvLine.indexOf('"');
                                csvLine  = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex + 1, csvLine.length());
                            }
                        }
    
                        if (startIndex != null && endIndex != null)
                        {
                            String sub = csvLine.substring(startIndex, endIndex);
                            sub        = sub.replaceAll(',', ':comma:');
                            csvLine    = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                            startIndex = null;
                            endIndex   = null;
                        }
                    }
    
                    for (String column : csvLine.split(','))
                    {
                        column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                        if (String.isNotBlank(column)) isEmptyRow = false;
                        csvRowData.add(column);
                    }
                }
                catch (Exception e)
                {
                    throw new VS_UploadShipmentLineItemsControllerException().invalidRow(String.valueOf(i), e.getMessage() + ' ' + e.getLineNumber());
                }

                // Skip empty row
                if (isEmptyRow) 
                {
                    continue;
                }

                // Validate if required data are passed in
                validateInsertRow(csvRowData, String.valueOf(i + 1));

                try 
                {
                    invoiceNo = String.isNotBlank(csvRowData[16]) ? csvRowData[16].trim() : '';

                    // Get HS Codes and Product Codes
                    hsCodeSet.add(csvRowData[14]);
                    productCodeSet.add(csvRowData[15]);

                    //initiate new Manufacturer Invoice
                    if (String.isNotBlank(invoiceNo))
                    {
                        invoiceNoSet.add(invoiceNo);
                        invoice = initiateManufacturerInvoice(invoice, csvRowData, shipment.Id);
                        toBeCreatedInvoices.put(invoiceNo, invoice);
                    }
    
                    //initiate new Shipment Line Item
                    item = initiateShipmentItem(item, csvRowData, shipment, String.valueOf(i + 1));
                    noOfLineItemCreated++;

                    // Generate Shipment Line Item & HS Code Map
                    itemAndHSCodeMap.put(item.Chassis_No__c + item.Engine_No__c, csvRowData[14]);

                    // Generate Shipment Line Item & Product Code Map
                    itemAndProductCodeMap.put(item.Chassis_No__c + item.Engine_No__c, csvRowData[15]);
    
                    //Group Shipment Line Items by Invoice No
                    if (toBeCreatedItems.containsKey(invoiceNo))
                    {
                        tempItems = toBeCreatedItems.get(invoiceNo);
                        tempItems.add(item);
                        toBeCreatedItems.put(invoiceNo, tempItems);
                    }
                    else
                    {
                        toBeCreatedItems.put(invoiceNo, new List<Shipment_Line_Item__c> {item});    
                    }                   
                } 
                catch (Exception e) 
                {
                    throw new VS_UploadShipmentLineItemsControllerException().invalidRowProcessing(String.valueOf(i), e.getMessage() + ' ' + e.getLineNumber());
                }
            }

            try 
            {
                uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Manufacturer_Invoice__c.SObjectType, Shipment_Line_Item__c.SObjectType});

                // Get HS Codes
                if (hsCodeSet.size() > 0)
                {
                    hsCodeSet.remove('');
                    hsCodeSet.remove(null);

                    List<HS_Type__c> hsCodes = [SELECT Id, Name FROM HS_Type__c WHERE Name IN: hsCodeSet];

                    if (hsCodes <> null && !hsCodes.isEmpty())
                    {
                        for (HS_Type__c hsCode : hsCodes)
                        {
                            hsCodeMap.put(hsCode.Name, hsCode);
                        }
                    }
                }

                // Get Product Codes
                if (productCodeSet.size() > 0)
                {
                    productCodeSet.remove('');
                    productCodeSet.remove(null);

                    List<Product_Code__c> productCodes = [SELECT Id, Product_Code__c FROM Product_Code__c WHERE Product_Code__c IN: productCodeSet];

                    if (productCodes <> null && !productCodes.isEmpty())
                    {
                        for (Product_Code__c productCode : productCodes)
                        {
                            productCodeMap.put(productCode.Product_Code__c, productCode);
                        }
                    }
                }

                // Upsert Manufacturer Invoices
                if (toBeCreatedInvoices.size() > 0)
                {
                    List<Manufacturer_Invoice__c> existingInvoices = ManufacturerInvoiceService.getManufacturerInvoicesByInvoiceNos(invoiceNoSet);
                                                                
                    if (existingInvoices <> null && !existingInvoices.isEmpty())
                    {
                        for (Manufacturer_Invoice__c inv : existingInvoices)
                        {
                            existingInvoiceMap.put(inv.Invoice_No__c, inv);
                        }
    
                        for (String invoiceNo : toBeCreatedInvoices.keySet())
                        {
                            if (existingInvoiceMap.containsKey(invoiceNo))
                            {
                                // Update existing ones
                                Manufacturer_Invoice__c updatedInv = updateManufacturerInvoice(toBeCreatedInvoices.get(invoiceNo), existingInvoiceMap.get(invoiceNo));         
                                existingInvoiceMap.put(invoiceNo, updatedInv);            
                                toBeCreatedInvoices.remove(invoiceNo);
                            }
                        }
                        
                        uow.registerDirty(existingInvoiceMap.values());
                    }
                    
                    // Insert new ones
                    if (toBeCreatedInvoices.size() > 0)
                    {
                        uow.registerNew(toBeCreatedInvoices.values());
                    }
                }
    
                // Insert Shipment Line Items
                if (toBeCreatedItems.size() > 0)
                {
                    for (String key : toBeCreatedItems.keySet())
                    {
                        if (String.isBlank(key))
                        {
                            uow.registerNew(toBeCreatedItems.get(key));
                        }
                        else 
                        {
                            for (Shipment_Line_Item__c item : toBeCreatedItems.get(key))
                            {
                                if (existingInvoiceMap.containsKey(key))
                                {
                                    uow.registerNew(item, Shipment_Line_Item__c.Invoice_No__c, existingInvoiceMap.get(key));
                                }
                                else 
                                {
                                    uow.registerNew(item, Shipment_Line_Item__c.Invoice_No__c, toBeCreatedInvoices.get(key));
                                }
                            }
                        }

                        for (Shipment_Line_Item__c item : toBeCreatedItems.get(key))
                        {
                            if(hsCodeMap.containsKey(itemAndHSCodeMap.get(item.Chassis_No__c + item.Engine_No__c)))
                            {
                                uow.registerRelationship(item, 
                                                        Shipment_Line_Item__c.TN_HS_Code__c, 
                                                        hsCodeMap.get(itemAndHSCodeMap.get(item.Chassis_No__c + item.Engine_No__c)));
                            }

                            if (productCodeMap.containsKey(itemAndProductCodeMap.get(item.Chassis_No__c + item.Engine_No__c)))
                            {
                                uow.registerRelationship(item, 
                                                        Shipment_Line_Item__c.Product_Code_Description__c, 
                                                        productCodeMap.get(itemAndProductCodeMap.get(item.Chassis_No__c + item.Engine_No__c)));
                            }
                        }
                    }
                }

                uow.commitWork();
            } 
            catch (Exception e) 
            {
               throw new VS_UploadShipmentLineItemsControllerException().invalidUpsert(e.getMessage());
            }
        }

        return noOfLineItemCreated;
    }

    private static void validateInsertRow(List<String> csvRowData, String rowNo)
    {
        if (String.isBlank(csvRowData[0]))
        {
            throw new VS_UploadShipmentLineItemsControllerException().invalidProductionMonth(rowNo);
        }
        else 
        {
            String originalValue = csvRowData[0].trim();
            String regex         = '[0-9]{4}/[0-9]{0,2}';
            Pattern datePattern  = Pattern.compile(regex);
            Matcher matchDate    = datePattern.matcher(originalValue);
    
            String correctRegex      = '[0-9]{0,2}/[0-9]{4}';
            Pattern correctPattern   = Pattern.compile(correctRegex);
            Matcher matchCorrectDate = correctPattern.matcher(originalValue);

            // Check if Production Month is in yyyy/mm format. If yes, convert to mm/yyyy format.
            if (matchDate.matches())
            {
                csvRowData[0] = originalValue.substringAfter('/') + '/' + originalValue.substringBefore('/');
            }
            else if (matchCorrectDate.matches())
            {
                csvRowData[0] = originalValue;
            }
            else 
            {
                throw new VS_UploadShipmentLineItemsControllerException().invalidProductionMonthFormat(rowNo);
            } 
        }

        if (String.isBlank(csvRowData[1]))
        {
            throw new VS_UploadShipmentLineItemsControllerException().invalidModelCode(rowNo);
        }

        if (String.isBlank(csvRowData[2]))
        {
            throw new VS_UploadShipmentLineItemsControllerException().invalidColorCode(rowNo);
        }

        if (String.isBlank(csvRowData[3]))
        {
            throw new VS_UploadShipmentLineItemsControllerException().invalidTrimCode(rowNo);
        }

        if (String.isBlank(csvRowData[5]))
        {
            throw new VS_UploadShipmentLineItemsControllerException().invalidChasisNo(rowNo);
        }

        if (String.isBlank(csvRowData[6]))
        {
            throw new VS_UploadShipmentLineItemsControllerException().invalidEngineNo(rowNo);
        }

        if (String.isBlank(csvRowData[7]))
        {
            throw new VS_UploadShipmentLineItemsControllerException().invalidFOB(rowNo);
        }

        // If other fields are passed in, Invoice No must be passed in too
        if ((String.isNotBlank(csvRowData[17]) 
            || String.isNotBlank(csvRowData[18]) 
                || String.isNotBlank(csvRowData[19]))
                    && String.isBlank(csvRowData[16]))
        {
            throw new VS_UploadShipmentLineItemsControllerException().invalidInvoiceNo(rowNo);
        }

        // If Invoice No is passed in, other fields must be passed in too
        if (String.isNotBlank(csvRowData[16]))
        {
            if (String.isBlank(csvRowData[17]))
            {
                throw new VS_UploadShipmentLineItemsControllerException().invalidTotalInvoiceAmount(rowNo);
            }
    
            if (String.isBlank(csvRowData[18]))
            {
                throw new VS_UploadShipmentLineItemsControllerException().invalidTotalInvoiceAmtCurrencyCode(rowNo);
            }
    
            if (String.isBlank(csvRowData[19]))
            {
                throw new VS_UploadShipmentLineItemsControllerException().invalidInvoiceDate(rowNo);
            }
            else
            {
                String originalValue = csvRowData[19].trim();
                
                // Correct format: YYYY-MM-DD
                String regex        = '[0-9]{4}-[0-9]{0,2}-[0-9]{0,2}';
                Pattern datePattern = Pattern.compile(regex);
                Matcher matchDate   = datePattern.matcher(originalValue);

                // Check if Invoice Date is in YYYY-MM-DD format.
                if (matchDate.matches())
                {
                    csvRowData[19] = originalValue;
                }
                else 
                {
                    throw new VS_UploadShipmentLineItemsControllerException().invalidInvoiceDateFormat(rowNo);
                } 
            }
        }
    }

    private static Manufacturer_Invoice__c initiateManufacturerInvoice(Manufacturer_Invoice__c invoice, List<String> csvRowData, Id shipmentId)
    {
        invoice.Vehicle_Shipment__c                   = shipmentId;
        invoice.Invoice_No__c                         = csvRowData[16].trim();
        invoice.Total_Invoice_Amount__c               = Decimal.valueOf(csvRowData[17].replaceAll(',', '').trim());
        invoice.Total_Invoice_Amount_Currency_Code__c = csvRowData[18].trim();
        invoice.Invoice_Date__c                       = Date.valueOf(csvRowData[19]);

        return invoice;
    }

    private static Shipment_Line_Item__c initiateShipmentItem(Shipment_Line_Item__c item, List<String> csvRowData, Vehicle_Shipment__c shipment, String rowNo)
    {    
        item.Production_Month__c    = csvRowData[0];                                                            
        item.Model__c               = csvRowData[1].trim();                                                                          
        item.Colour_Code__c         = csvRowData[2].trim();                                                                             
        item.Trim__c                = csvRowData[3].trim();                                                                              
        item.Manufacturer_Ref_No__c = csvRowData[4].trim();                                                                                
        item.Chassis_No__c          = csvRowData[5].trim();             
        item.Engine_No__c           = csvRowData[6].trim();    
        item.Key_No__c              = csvRowData[13].trim();                                                                                
        item.Franchise_Code__c      = shipment.Franchise_Code__c;
        item.Vehicle_Shipment__c    = shipment.Id;   

        if (String.isNotBlank(csvRowData[7]))
        {
            item.FOB_Amount__c               = Decimal.valueOf(csvRowData[7].replaceAll(',','').trim());        
            item.FOB_Amount_Currency_Code__c = shipment.Currency_Code__c;
        }

        if (String.isNotBlank(csvRowData[8]))
        {
            item.Freight_Charges__c               = Decimal.valueOf(csvRowData[8].replaceAll(',','').trim());      
            item.Freight_Charges_Currency_Code__c = shipment.Currency_Code__c;
        }

        if (String.isNotBlank(csvRowData[9]))
        {
            item.Insurance_Charges__c               = Decimal.valueOf(csvRowData[9].replaceAll(',','').trim());     
            item.Insurance_Charges_Currency_Code__c = shipment.Currency_Code__c;   
        }

        if (String.isNotBlank(csvRowData[10]))
        {
            item.Transport_Charges__c               = Decimal.valueOf(csvRowData[10].replaceAll(',','').trim());      
            item.Transport_Charges_Currency_Code__c = shipment.Currency_Code__c;   
        }
      
        if (String.isNotBlank(csvRowData[11]))
        {
            item.Ex_Factory_Charges__c               = Decimal.valueOf(csvRowData[11].replaceAll(',','').trim());      
            item.Ex_Factory_Charges_Currency_Code__c = shipment.Currency_Code__c;   
        }
        
        if (String.isNotBlank(csvRowData[12]))
        {
            item.Other_Charges__c               = Decimal.valueOf(csvRowData[12].replaceAll(',','').trim());              
            item.Other_Charges_Currency_Code__c = shipment.Currency_Code__c;   
        }

        return item;
    }

    private static Manufacturer_Invoice__c updateManufacturerInvoice (Manufacturer_Invoice__c newInvoice, Manufacturer_Invoice__c currentInvoice)
    {
        currentInvoice.Total_Invoice_Amount__c               = newInvoice.Total_Invoice_Amount__c <> 0 ? newInvoice.Total_Invoice_Amount__c : currentInvoice.Total_Invoice_Amount__c;
        currentInvoice.Total_Invoice_Amount_Currency_Code__c = newInvoice.Total_Invoice_Amount_Currency_Code__c;
        currentInvoice.Invoice_Date__c                       = newInvoice.Invoice_Date__c;

        return currentInvoice;
    }

    @TestVisible
    private class VS_UploadShipmentLineItemsControllerException extends Exception
    {
        @TestVisible
        private Exception invalidProductionMonth(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Production Month. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidProductionMonthFormat(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: Production Month must be in YYYY/MM or MM/YYYY format. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidEngineNo(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Engine No. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidChasisNo(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Chasis No. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidColorCode(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Color Code. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidModelCode(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Model Code. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidTrimCode(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Trim Code. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidFOB(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no FOB. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidInvoiceNo(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Invoice No for creating Manufacturer Invoice. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidTotalInvoiceAmount(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Total Invoice Amount for creating Manufacturer Invoice. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidTotalInvoiceAmtCurrencyCode(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Total Invoice Amount Currency Code for creating Manufacturer Invoice. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidInvoiceDate(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: no Invoice Date for creating Manufacturer Invoice. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidInvoiceDateFormat(String rowNo)
        {
            this.setMessage(String.format('Row {0} in the uploaded file is invalid for creating a new Shipment Line Item. Reason: Invoice Date must be in YYYY-MM-DD format. Please check and upload again!', new List<String> { rowNo }));
            return this;
        }

        @TestVisible
        private Exception invalidCSV()
        {
            this.setMessage('This CSV is invalid for creating new Shipment Line Items. Reason: File is empty. Please check and upload again!');
            return this;
        }

        @TestVisible
        private Exception invalidUpsert(String error)
        {
            this.setMessage(String.format('An error has occurred when creating Manufacturer Invoices and Shipment Line Items. Reason: {0}. Please check and upload again!', new List<String> { error }));
            return this;
        }

        @TestVisible
        private Exception invalidRow(String rowNo, String error)
        {
            this.setMessage(String.format('An error has occured while uploading file. Row {0} in the uploaded file is not properly formatted. Reason: {1}, Please check and upload again!', new List<String> { rowNo, error }));
            return this;
        }

        @TestVisible
        private Exception invalidRowProcessing(String rowNo, String error)
        {
            this.setMessage(String.format('An error has occured while processing row {0} in the uploaded file. Reason: {1}, Please check and upload again!', new List<String> { rowNo, error }));
            return this;
        }
    }
}
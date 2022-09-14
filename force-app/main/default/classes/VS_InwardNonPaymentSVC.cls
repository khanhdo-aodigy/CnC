/** *****
 * Description : Service Clsas 
 *               - To orchestrate common logic check 
 *               - To perform callout to getsAsia for Inward Non Payment (INP) submission
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                          Ticket                  Description
 * 20220818             HS@aodigy.com            US-Ship-000027         Created Initial Version. 
 * 20220825             phan.thu@aodigy.com      US-Ship-000027         Added methods for generating Request Payload
** *****/
public class VS_InwardNonPaymentSVC 
{
    private static Integer UNIQUE_REF_NO_DATE = 0;
    private static String SEQ_NO              = '';
    
    public static Boolean submitINP(String recordId, Map<String, List<String>> grouppedLineItems) 
    {
        List<serviceDataPool.ServiceDataPoolWrapper> serviceWrapper = new List<serviceDataPool.ServiceDataPoolWrapper>();
        Boolean result = false;

        if (String.isBlank(recordId))
        {
            throw new VS_InwardNonPaymentSVCException().invalidRecordId();
        }

        try 
        {
            Inward_Declaration__c inpDec                  = InwardDeclarationService.getByRecordTypeAndVehicleShipmentId('Inward_Non_Payment', recordId);
            String inpHttpReqWrapper                      = generateHttpRequestPayload(inpDec, grouppedLineItems);
            VS_HttpCalloutUtil.ResponseWrapper wrapperRes = VS_HttpCalloutUtil.invokeApiCall(inpHttpReqWrapper, recordId, 'INP'); 
            HttpResponse httpResp                         = wrapperRes.res;
            Map<String, Object> res                       = (Map<String, Object>) JSON.deserializeUntyped(httpResp.getBody());

            serviceWrapper.add(wrapperRes.serviceDataPoolWrapper);

            if (res.get('status') == 'S001')
            {
                String transactionId                       = ((Map<String, Object>)res.get('data'))?.get('documentRefNo').toString();
                VS_HttpCalloutUtil.ResponseWrapper wrapper = VS_HttpCalloutUtil.invokeApiCallToGetResponse(VS_HttpCalloutUtil.generateHttpRequestPayloadForResponseAPI(transactionId), transactionId);
                HttpResponse httpRes                       = wrapper.res;
                Map<String, Object> response               = (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());

                serviceWrapper.add(wrapper.serviceDataPoolWrapper);

                if (response.get('status') == 'S001')
                {
                    List<Object> data = (List<Object>) response.get('data');

                    if (data <> null && data.size() > 0)
                    {
                        Map<String, Object> dataMap  = (Map<String, Object>) (data[0]);
                        Map<String, Object> resMap   = (Map<String, Object>) dataMap.get('Response');
                        String status                = resMap.get('Status')?.toString();

                        if (status == 'Draft Created')
                        {
                            updateInwardDeclaration(inpDec.Id, transactionId, 'Draft');
                            result = true;
                        }
                    }
                }
            }

            serviceDataPool.buildListServiceDataPoolHttp(serviceWrapper);
        } 
        catch (Exception ex) 
        {
            System.debug('@@@@DEBUG invokeApiCall :: err = ' + ex.getCause() + ' -- ' + ex.getMessage() + ' -- ' + ex.getLineNumber());
            loggerDataPool.buildLogDataPool('VS_GetsAsia_Callout_INP', ex);
            throw new VS_InwardNonPaymentSVCException().processingError(ex.getMessage() + ' -- ' + ex.getLineNumber());
        }

        return result;
    }

    private static void updateInwardDeclaration(String recordId, String transactionId, String status)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Inward_Declaration__c.SObjectType});

        uow.registerDirty(new Inward_Declaration__c(Id = recordId, 
                                                    Transaction_ID__c = transactionId, 
                                                    Status__c = status,
                                                    Unique_Ref_No_Date__c = UNIQUE_REF_NO_DATE,
                                                    Inward_Declaration_Seq_No__c = SEQ_NO));

        uow.commitWork();
    }

    private static String generateHttpRequestPayload(Inward_Declaration__c inpDec, Map<String, List<String>> grouppedLineItems) 
    {      
        VS_InwardNonPaymentReqWrapper reqWrapper = new VS_InwardNonPaymentReqWrapper();
        
        // Generate general infor
        reqWrapper = generateConfigInfor(reqWrapper);
        
        // Generate main data
        reqWrapper.data = generateData(inpDec, grouppedLineItems);

        return JSON.serialize(reqWrapper);  
    }

    private static VS_InwardNonPaymentReqWrapper generateConfigInfor(VS_InwardNonPaymentReqWrapper reqWrapper)
    {
        GetsAsia_Callout__mdt calloutMtd = GetsAsia_Callout__mdt.getInstance('Inward_Non_Payment_Transaction');

        reqWrapper.messageType  = calloutMtd.Message_Type__c;
        reqWrapper.documentType = calloutMtd.Doc_Type__c;
        reqWrapper.routeId      = calloutMtd.Route_Id__c;

        return reqWrapper;
    }

    private static VS_InwardNonPaymentReqWrapper.Data generateData(Inward_Declaration__c inpDec, Map<String, List<String>> grouppedLineItems)
    {
        VS_InwardNonPaymentReqWrapper.Data dataWrapper = new VS_InwardNonPaymentReqWrapper.Data();

        dataWrapper.message_version = '';
        dataWrapper.sender_id       = inpDec.TN_Sender_ID__c ;
        dataWrapper.recipient_id    = inpDec.TN_Recipient_ID__c;

        // Generate Message data
        dataWrapper.message = generateMessage(inpDec, grouppedLineItems);

        return dataWrapper;
    }

    private static VS_InwardNonPaymentReqWrapper.Message generateMessage(Inward_Declaration__c inpDec, Map<String, List<String>> grouppedLineItems)
    {
        VS_InwardNonPaymentReqWrapper.Message message = new VS_InwardNonPaymentReqWrapper.Message();

        // Generate Header data
        message.header = generateHeader(inpDec);

        // Generate Cargo data
        message.cargo = generateCargo(inpDec);

        // Generate Transport data
        message.transport = generateTransport(inpDec);

        // Generate Party data
        message.party = generateParty(inpDec);

        // Generate Items
        message.item = generateItems(grouppedLineItems);

        // Generate Summary
        message.summary = generateSummary(inpDec);

        // Generate Additional Infor
        message.add_info = generateAddInfor(inpDec);

        return message;
    }

    private static VS_InwardNonPaymentReqWrapper.Header generateHeader(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Header header = new VS_InwardNonPaymentReqWrapper.Header();

        header.declarant_id = inpDec.TN_Declarant_Entity_Identifier__c;
        header.car_type     = inpDec.TN_Car_Type_Code__c;
        header.dec_type     = inpDec.TN_Declaration_Type_Code__c;
        header.dec_stmt_ind = 'false';

        // Generate Unique Ref. No. data
        header.unique_ref_no = generateUniqueRefNo(inpDec);

        // Generate Remarks
        header.remarks = generateRemarks(inpDec);

        return header;
    }

    private static VS_InwardNonPaymentReqWrapper.Unique_ref_no generateUniqueRefNo(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Unique_ref_no uniqueRefNo = new VS_InwardNonPaymentReqWrapper.Unique_ref_no();

        uniqueRefNo.cr_uei_no = inpDec.C_C_ID_on_TradeNet__c;
        uniqueRefNo.date_Z    = inpDec.Unique_Ref_No_Date__c <> null ? Integer.valueOf(inpDec.Unique_Ref_No_Date__c) : Integer.valueOf(String.valueOf(Date.today()).replace('-', ''));
        uniqueRefNo.seq_no    = String.isNotBlank(inpDec.Inward_Declaration_Seq_No__c) ? Integer.valueOf(inpDec.Inward_Declaration_Seq_No__c) : VS_HttpCalloutUtil.generateSeqNo();

        UNIQUE_REF_NO_DATE = uniqueRefNo.date_Z;
        SEQ_NO             = String.valueOf(uniqueRefNo.seq_no);

        return uniqueRefNo;
    }

    private static List<VS_InwardNonPaymentReqWrapper.Remarks> generateRemarks(Inward_Declaration__c inpDec)
    {     
        VS_InwardNonPaymentReqWrapper.Remarks remarks = new VS_InwardNonPaymentReqWrapper.Remarks();
        VS_InwardNonPaymentReqWrapper.Line lineData   = new VS_InwardNonPaymentReqWrapper.Line();
        
        lineData.line = inpDec.TN_Remarks__c;
        remarks.line  = new List<VS_InwardNonPaymentReqWrapper.Line> {lineData};

        return new List<VS_InwardNonPaymentReqWrapper.Remarks> {remarks};
    }

    private static VS_InwardNonPaymentReqWrapper.Cargo generateCargo(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Cargo cargo = new VS_InwardNonPaymentReqWrapper.Cargo();

        cargo.pack_type                   = inpDec.TN_Cargo_Pack_Type_Code__c;
        cargo.exhibit_temp_imp_start_date = null;

        // Generate Release Location
        cargo.release_loc = generateReleaseLoc(inpDec);

        // Generate Receipt Location
        cargo.receipt_loc = generateReceiptLoc(inpDec);

        // Generate Storage Location
        cargo.storage_loc = generateStorageLoc(inpDec);

        return cargo;
    }

    private static VS_InwardNonPaymentReqWrapper.Location generateReleaseLoc(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Location releaseLoc = new VS_InwardNonPaymentReqWrapper.Location();

        releaseLoc.loc_code = inpDec.TN_Release_Location_Code__c;
        releaseLoc.loc_name = inpDec.TN_Release_Location_Name__r.Name;

        return releaseLoc;
    }

    private static VS_InwardNonPaymentReqWrapper.Location generateReceiptLoc(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Location receiptLoc = new VS_InwardNonPaymentReqWrapper.Location();

        receiptLoc.loc_code = inpDec.TN_Receipt_Location_Code__c;
        receiptLoc.loc_name = inpDec.TN_Receipt_Location_Name__r.Name;

        return receiptLoc;
    }

    private static VS_InwardNonPaymentReqWrapper.Storage_loc generateStorageLoc(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Storage_loc storageLoc = new VS_InwardNonPaymentReqWrapper.Storage_loc();

        storageLoc.loc_code = inpDec.TN_Storage_Location_Code__c;

        return storageLoc;
    }

    private static VS_InwardNonPaymentReqWrapper.Transport generateTransport(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Transport transport = new VS_InwardNonPaymentReqWrapper.Transport();
        VS_InwardNonPaymentReqWrapper.In_tpt   inTPT      = new VS_InwardNonPaymentReqWrapper.In_tpt();

        inTPT.tpt_mode        = String.valueOf(inpDec.TN_Transport_Mode_Code__c);
        inTPT.cvy_ref_no      = inpDec.TN_Vessel_Code__c;
        inTPT.tpt_id          = inpDec.TN_Vessel_Name__c;
        inTPT.master_ship_doc = inpDec.TN_B_L_No__c;
        inTPT.arrival_date    = inpDec.TN_ETA__c <> null ? Integer.valueOf(String.valueOf(inpDec.TN_ETA__c).replace('-', '')) : null;
        inTPT.loading_port    = inpDec.TN_Port_of_Loading_Code__c;

        transport.in_tpt      = inTPT;

        return transport;
    }

    private static VS_InwardNonPaymentReqWrapper.Party generateParty(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Party party = new VS_InwardNonPaymentReqWrapper.Party();

        // Generate Declarant data
        party.declarant = generateDeclarant(inpDec);

        // Gererate Declaring Agent data
        party.declaring_agent = generateDeclarantAgent(inpDec);

        // Generate In-Carrier data
        party.in_carrier_agent = generateInCarrierAgent(inpDec);

        // Generate Importer data
        party.importer = generateImporter(inpDec);

        return party;
    }

    private static VS_InwardNonPaymentReqWrapper.Declarant generateDeclarant(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Declarant declarant = new VS_InwardNonPaymentReqWrapper.Declarant();

        declarant.person_code  = inpDec.TN_Declarant_Person_Code__c;
        declarant.person_name  = inpDec.Declarant_Person__r.Name;
        declarant.person_phone = inpDec.TN_Declarant_Person_Phone__c; 

        return declarant;
    }

    private static VS_InwardNonPaymentReqWrapper.Agent generateDeclarantAgent(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Agent declaringAgent = new VS_InwardNonPaymentReqWrapper.Agent();
        VS_InwardNonPaymentReqWrapper.Name nameData        = new VS_InwardNonPaymentReqWrapper.Name();

        nameData.name            = inpDec.TN_Declarant_Name__r.Name;
        declaringAgent.name      = new List<VS_InwardNonPaymentReqWrapper.Name> {nameData};
        declaringAgent.cr_uei_no = inpDec.C_C_ID_on_TradeNet__c;

        return declaringAgent;
    }

    private static VS_InwardNonPaymentReqWrapper.Agent generateInCarrierAgent(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Agent inCarrierAgent = new VS_InwardNonPaymentReqWrapper.Agent();
        VS_InwardNonPaymentReqWrapper.Name nameData          = new VS_InwardNonPaymentReqWrapper.Name();

        nameData.name            = inpDec.TN_Inward_Carrier_Name__r.Name;
        inCarrierAgent.name      = new List<VS_InwardNonPaymentReqWrapper.Name> {nameData};
        inCarrierAgent.cr_uei_no = inpDec.TN_Inward_Carrier_Entity_Identifier__c;

        return inCarrierAgent;
    }

    private static VS_InwardNonPaymentReqWrapper.Agent generateImporter(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Agent importer = new VS_InwardNonPaymentReqWrapper.Agent();
        VS_InwardNonPaymentReqWrapper.Name nameData  = new VS_InwardNonPaymentReqWrapper.Name();

        nameData.name      = inpDec.TN_Importer_Name__r.Name;
        importer.name      = new List<VS_InwardNonPaymentReqWrapper.Name> {nameData};
        importer.cr_uei_no = inpDec.TN_Importer_Entity_Identifier__c;

        return importer;
    }

    private static List<VS_InwardNonPaymentReqWrapper.Item> generateItems(Map<String, List<String>> grouppedLineItems)
    {
        List<VS_InwardNonPaymentReqWrapper.Item> items = new List<VS_InwardNonPaymentReqWrapper.Item>();
        Set<String> shipmentIdSet                      = new Set<String>();
        VS_InwardNonPaymentReqWrapper.Item item;
        Shipment_Line_Item__c tempShipmentItem;

        if (grouppedLineItems <> null && grouppedLineItems.size() > 0)
        {
            for (List<String> shipmentIds : grouppedLineItems.values())
            {
                shipmentIdSet.addAll(shipmentIds);
            }

            Map<Id, Shipment_Line_Item__c> shipmentItems =  new Map<Id, Shipment_Line_Item__c>(VehicleShipmentLineItemService.getLineItemsByIds(shipmentIdSet));
            Integer currentInvoiceNo                     = 1;

            for (String itemGroupCode : grouppedLineItems.keySet())
            {
                item             = new VS_InwardNonPaymentReqWrapper.Item();
                tempShipmentItem = shipmentItems.get(grouppedLineItems.get(itemGroupCode)?.get(0));
    
                item.seq_no             = currentInvoiceNo;
                item.item_inv_no        = tempShipmentItem.Invoice_No__r.Invoice_No__c;
                item.hs_code            = tempShipmentItem.TN_HS_Code__r.Name;
                item.item_desc          = tempShipmentItem.TN_Item_Description__c;
                item.cty_origin         = tempShipmentItem.Vehicle_Shipment__r.Country_of_Origin_Code__c;
                item.brand              = tempShipmentItem.Vehicle_Shipment__r.Brand__c;

                // Generate Item Quantity
                item.item_qty = generateItemQuantity(tempShipmentItem);

                // Generate Transaction Value
                item.transaction_value = generateTransactionValue(tempShipmentItem);

                // Generate Out Pack Quantity
                item.out_pack_qty = generateOutPackQuantity(tempShipmentItem);

                // Generate Duty Tax
                //item.duty_tax = generateDutyTax(tempShipmentItem);

                // Generate CASC Product
                item.casc_product = generateCASCProduct(grouppedLineItems.get(itemGroupCode), shipmentItems);

                items.add(item);

                currentInvoiceNo++;
            }
        }

        return items;
    }

    private static VS_InwardNonPaymentReqWrapper.Item_qty generateItemQuantity(Shipment_Line_Item__c shipmentItem)
    {
        VS_InwardNonPaymentReqWrapper.Item_qty itemQuantity = new VS_InwardNonPaymentReqWrapper.Item_qty();
        VS_InwardNonPaymentReqWrapper.Quantity hsQty        = new VS_InwardNonPaymentReqWrapper.Quantity();

        hsQty.qty_value = shipmentItem.TN_HS_Qty__c <> null ? Integer.valueOf(shipmentItem.TN_HS_Qty__c) : null;
        hsQty.qty_uom   = shipmentItem.TN_HS_Qty_UOM__c;

        itemQuantity.hs_qty = hsQty;

        return itemQuantity;
    }

    private static VS_InwardNonPaymentReqWrapper.Transaction_value generateTransactionValue(Shipment_Line_Item__c shipmentItem)
    {
        VS_InwardNonPaymentReqWrapper.Transaction_value transactionVal = new VS_InwardNonPaymentReqWrapper.Transaction_value();
        VS_InwardNonPaymentReqWrapper.Value cifFOBFC                   = new VS_InwardNonPaymentReqWrapper.Value();
        VS_InwardNonPaymentReqWrapper.Value unitPrice                  = new VS_InwardNonPaymentReqWrapper.Value();

        cifFOBFC.amt       = shipmentItem.TN_CIF_FOB_Amount__c <> null ? String.valueOf(shipmentItem.TN_CIF_FOB_Amount__c) : null;
        cifFOBFC.curr_code = shipmentItem.TN_CIF_FOB_Currency_Code__c;

        unitPrice.amt       = shipmentItem.FOB_Amount__c <> null ? String.valueOf(shipmentItem.FOB_Amount__c) : null;
        unitPrice.curr_code = shipmentItem.FOB_Amount_Currency_Code__c;

        transactionVal.cif_fob_fc = cifFOBFC;
        transactionVal.unit_price = unitPrice;

        return transactionVal;
    }

    private static VS_InwardNonPaymentReqWrapper.Out_pack_qty generateOutPackQuantity(Shipment_Line_Item__c shipmentItem)
    {
        VS_InwardNonPaymentReqWrapper.Out_pack_qty outPackQty = new VS_InwardNonPaymentReqWrapper.Out_pack_qty();

        outPackQty.qty = shipmentItem.Invoice_No__r?.TN_Total_Outer_Pack__c <> null ? Integer.valueOf(shipmentItem.Invoice_No__r?.TN_Total_Outer_Pack__c) : null;
        outPackQty.uom = shipmentItem.Invoice_No__r?.TN_Total_Outer_Pack_UOM__c;

        return outPackQty;
    }

    private static VS_InwardNonPaymentReqWrapper.Duty_tax generateDutyTax(Shipment_Line_Item__c shipmentItem)
    {
        VS_InwardNonPaymentReqWrapper.Duty_tax dutyTax = new VS_InwardNonPaymentReqWrapper.Duty_tax();

        dutyTax.gst_rate = shipmentItem.TN_GST__c <> null ? Integer.valueOf(shipmentItem.TN_GST__c) : null;
        dutyTax.gst_amt  = shipmentItem.TN_GST_Amount__c <> null ? Integer.valueOf(shipmentItem.TN_GST_Amount__c) : null;

        return dutyTax;
    }

    private static VS_InwardNonPaymentReqWrapper.Casc_product generateCASCProduct(List<String> shipmentItemIds, Map<Id, Shipment_Line_Item__c> shipmentItems)
    {
        VS_InwardNonPaymentReqWrapper.Casc_product cascProduct = new VS_InwardNonPaymentReqWrapper.Casc_product();
        Shipment_Line_Item__c tempShipmentItem                 = shipmentItems.get(shipmentItemIds.get(0));

        cascProduct.prod_code    = tempShipmentItem.TN_CASC_Product_Code__c;
        cascProduct.prod_qty_uom = tempShipmentItem.TN_CASC_Product_UOM__c;     
        cascProduct.prod_qty     = shipmentItemIds.size();

        // Generate CASC Code
        cascProduct.add_casc_code = generateAddCASCCode(shipmentItemIds, shipmentItems);

        return cascProduct;
    }

    private static List<VS_InwardNonPaymentReqWrapper.Add_casc_code> generateAddCASCCode(List<String> shipmentItemIds, Map<Id, Shipment_Line_Item__c> shipmentItems)
    {
        List<VS_InwardNonPaymentReqWrapper.Add_casc_code> returnedList = new List<VS_InwardNonPaymentReqWrapper.Add_casc_code>();
        VS_InwardNonPaymentReqWrapper.Add_casc_code CASCCode;

        for (String shipmentId : shipmentItemIds)
        {
            CASCCode            = new VS_InwardNonPaymentReqWrapper.Add_casc_code();
            CASCCode.casc_code1 = shipmentItems.get(shipmentId).Engine_No__c;
            CASCCode.casc_code2 = shipmentItems.get(shipmentId).Chassis_No__c;
            CASCCode.casc_code3 = shipmentItems.get(shipmentId).TN_Vehicle_Type__c;

            returnedList.add(CASCCode);
        }

        return returnedList;
    }

    private static VS_InwardNonPaymentReqWrapper.Summary generateSummary(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Summary summary = new VS_InwardNonPaymentReqWrapper.Summary();

        // Gerenate Total Out Pack
        summary.tot_out_pack = generateTotalOutPack(inpDec);

        // Generate Total Gross WT
        summary.tot_gross_wt = generateTotalGrossWT(inpDec);

        return summary;
    }

    private static VS_InwardNonPaymentReqWrapper.Quantity generateTotalOutPack(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Quantity totalOutPack = new VS_InwardNonPaymentReqWrapper.Quantity();

        totalOutPack.qty_value = inpDec.TN_Total_Outer_Pack__c <> null ? Integer.valueOf(inpDec.TN_Total_Outer_Pack__c) : null;
        totalOutPack.qty_uom   = inpDec.TN_Total_Outer_Pack_UOM__c;

        return totalOutPack;
    }

    private static VS_InwardNonPaymentReqWrapper.Quantity generateTotalGrossWT(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Quantity totalGrossWT = new VS_InwardNonPaymentReqWrapper.Quantity();

        totalGrossWT.qty_value = inpDec.TN_Total_Gross_Weight__c <> null ? Integer.valueOf(inpDec.TN_Total_Gross_Weight__c) : null;
        totalGrossWT.qty_uom   = inpDec.TN_Total_Gross_Weight_UOM__c;
        
        return totalGrossWT;
    }

    private static List<VS_InwardNonPaymentReqWrapper.Add_info> generateAddInfor(Inward_Declaration__c inpDec)
    {
        VS_InwardNonPaymentReqWrapper.Add_info addInfor = new VS_InwardNonPaymentReqWrapper.Add_info();

        addInfor.info_name = 'USER_REF_NO';
        addInfor.info_text = inpDec.Franchise_Code__c;

        return new List<VS_InwardNonPaymentReqWrapper.Add_info> {addInfor};
    }

    @TestVisible
    private class VS_InwardNonPaymentSVCException extends Exception
    {
        @TestVisible
        private Exception invalidRecordId()
        {
            this.setMessage('Empty Vehicle Shipment Id');
            return this;
        }

        @TestVisible
        private Exception invalidDeclarationIndicator()
        {
            this.setMessage('Declaration Indicator checkbox must be checked');
            return this;
        }

        @TestVisible
        private Exception processingError(String error)
        {
            this.setMessage(error);
            return this;
        }
    }
}
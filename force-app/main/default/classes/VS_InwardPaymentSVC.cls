/** *****
 * Description : Util/Service Clsas 
 *               - To orchestrate common logic check 
 *               - To perform callout to getsAsia for Inward Payment (IPT) submission
 * 
 * Change History:
 * Date(YYYYMMDD)           Name                  Ticket                     Description
 * 20220818             HS@aodigy.com            US-Ship-000027         Created Initial Version. 
 * 20220824             phan.thu@aodigy.com      US-Ship-000027         Added methods for generating Request Payload
** *****/
public class VS_InwardPaymentSVC 
{   
    private static final String TRANSACTION_TYPE = 'IPT';
    private static String FRANCHISE_CODE         = '';
    private static String RECORD_ID              = '';
    private static String COUNTRY_OF_ORIGIN      = '';
    private static Integer UNIQUE_REF_NO_DATE    = 0;
    private static String SEQ_NO                 = '';

    public static Boolean submitIPT(String recordId, Map<String, List<String>> grouppedSVMs, Boolean isFromVehShipment) 
    {
        List<serviceDataPool.ServiceDataPoolWrapper> serviceWrapper = new List<serviceDataPool.ServiceDataPoolWrapper>();
        Inward_Declaration__c iptDec                                = new Inward_Declaration__c();
        Boolean result = false;

        if (String.isBlank(recordId))
        {
            throw new VS_InwardPaymentSVCException().invalidRecordId();
        }

        try 
        {
            if (isFromVehShipment)
            {
                iptDec    = InwardDeclarationService.getByRecordTypeAndVehicleShipmentId('Inward_Payment', recordId);
                RECORD_ID = iptDec.Vehicle_Shipment__r.Name;
            }
            else 
            {
                iptDec            = InwardDeclarationService.getByIdsWithInvoices(new Set<Id> {recordId}, true)?.get(0);
                RECORD_ID         = iptDec.Name;
                COUNTRY_OF_ORIGIN = iptDec.TN_Country_of_Origin_Code__c;
            }
           
            String iptHttpReqWrapper                      = generateHttpRequestPayload(iptDec, grouppedSVMs, isFromVehShipment);
            VS_HttpCalloutUtil.ResponseWrapper wrapperRes = VS_HttpCalloutUtil.invokeApiCall(iptHttpReqWrapper, recordId, 'IPT'); 
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

                serviceDataPool.buildListServiceDataPoolHttp(serviceWrapper);

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
                            updateInwardDeclaration(iptDec.Id, transactionId, 'Draft');
                            result = true;
                        }
                    }
                }
            }
        } 
        catch (Exception ex) 
        {
            System.debug('@@@@DEBUG invokeApiCall :: err = ' + ex.getCause() + ' -- ' + ex.getMessage() + ' -- ' + ex.getLineNumber());
            loggerDataPool.buildLogDataPool('VS_GetsAsia_Callout_IPT', ex);
            throw new VS_InwardPaymentSVCException().processingError(ex.getMessage() + ' -- ' + ex.getLineNumber());
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

    private static String generateHttpRequestPayload (Inward_Declaration__c iptDec, Map<String, List<String>> grouppedSVMs, Boolean isFromVehShipment) 
    {      
        VS_InwardPaymentReqWrapper reqWrapper = new VS_InwardPaymentReqWrapper();
        
        // Generate general infor
        reqWrapper = generateConfigInfor(reqWrapper);
        
        // Generate main data
        reqWrapper.data = generateData(iptDec, grouppedSVMs, isFromVehShipment);

        return JSON.serialize(reqWrapper);  
    }

    private static VS_InwardPaymentReqWrapper generateConfigInfor(VS_InwardPaymentReqWrapper reqWrapper)
    {
        GetsAsia_Callout__mdt calloutMtd = GetsAsia_Callout__mdt.getInstance('Inward_Payment_Transaction');

        reqWrapper.messageType  = calloutMtd.Message_Type__c;
        reqWrapper.documentType = calloutMtd.Doc_Type__c;
        reqWrapper.routeId      = calloutMtd.Route_Id__c;

        return reqWrapper;
    }

    private static VS_InwardPaymentReqWrapper.Data generateData(Inward_Declaration__c iptDec, Map<String, List<String>> grouppedSVMs, Boolean isFromVehShipment)
    {
        VS_InwardPaymentReqWrapper.Data dataWrapper = new VS_InwardPaymentReqWrapper.Data();

        dataWrapper.message_version = '';
        dataWrapper.sender_id       = iptDec.TN_Sender_ID__c ;
        dataWrapper.recipient_id    = iptDec.TN_Recipient_ID__c;

        // Generate Message data
        dataWrapper.message = generateMessage(iptDec, grouppedSVMs, isFromVehShipment);

        return dataWrapper;
    }

    private static VS_InwardPaymentReqWrapper.Message generateMessage(Inward_Declaration__c iptDec, Map<String, List<String>> grouppedSVMs, Boolean isFromVehShipment)
    {
        VS_InwardPaymentReqWrapper.Message message = new VS_InwardPaymentReqWrapper.Message();

        // Generate Header data
        message.header = generateHeader(iptDec);

        // Generate Cargo data
        message.cargo = generateCargo(iptDec);

        // Generate Transport data
        message.transport = generateTransport(iptDec);

        // Generate Party data
        message.party = generateParty(iptDec);

        // Generate Invoice data
        message.invoice = generateInvoices(iptDec, isFromVehShipment);

        // Generate Items
        message.item = generateItems(grouppedSVMs);

        // Generate Summary
        message.summary = generateSummary(iptDec);

        // Generate Additional Infor
        message.add_info = generateAddInfor(iptDec, isFromVehShipment);

        return message;
    }

    private static VS_InwardPaymentReqWrapper.Header generateHeader(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Header header = new VS_InwardPaymentReqWrapper.Header();

        header.msg_ref_no   = iptDec.TN_Message_Ref_No__c;
        header.declarant_id = iptDec.TN_Declarant_Entity_Identifier__c;
        header.car_type     = iptDec.TN_Car_Type_Code__c;
        header.dec_type     = iptDec.TN_Declaration_Type_Code__c;
        header.dec_stmt_ind = 'false';

        // Generate Unique Ref. No. data
        header.unique_ref_no = generateUniqueRefNo(iptDec);

        // Generate Remarks
        header.remarks = generateRemarks(iptDec);

        return header;
    }

    private static VS_InwardPaymentReqWrapper.Unique_ref_no generateUniqueRefNo(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Unique_ref_no uniqueRefNo = new VS_InwardPaymentReqWrapper.Unique_ref_no();

        uniqueRefNo.cr_uei_no = iptDec.C_C_ID_on_TradeNet__c;
        uniqueRefNo.date_Z    = iptDec.Unique_Ref_No_Date__c <> null ? Integer.valueOf(iptDec.Unique_Ref_No_Date__c) : Integer.valueOf(String.valueOf(Date.today()).replace('-', ''));
        uniqueRefNo.seq_no    = String.isNotBlank(iptDec.Inward_Declaration_Seq_No__c) ? Integer.valueOf(iptDec.Inward_Declaration_Seq_No__c) : VS_HttpCalloutUtil.generateSeqNo();

        UNIQUE_REF_NO_DATE = uniqueRefNo.date_Z;
        SEQ_NO             = String.valueOf(uniqueRefNo.seq_no);

        return uniqueRefNo;
    }

    private static List<VS_InwardPaymentReqWrapper.Remarks> generateRemarks(Inward_Declaration__c iptDec)
    {     
        VS_InwardPaymentReqWrapper.Remarks remarks = new VS_InwardPaymentReqWrapper.Remarks();
        VS_InwardPaymentReqWrapper.Line lineData   = new VS_InwardPaymentReqWrapper.Line();
        
        lineData.line = iptDec.TN_Remarks__c;
        remarks.line  = new List<VS_InwardPaymentReqWrapper.Line> {lineData};

        return new List<VS_InwardPaymentReqWrapper.Remarks> {remarks};
    }

    private static VS_InwardPaymentReqWrapper.Cargo generateCargo(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Cargo cargo = new VS_InwardPaymentReqWrapper.Cargo();

        cargo.pack_type          = iptDec.TN_Cargo_Pack_Type_Code__c;
        cargo.blanket_start_date = null;

        // Generate Release Loc
        cargo.release_loc = generateReleaseLoc(iptDec);

        // Generate Receipt Loc
        cargo.receipt_loc = generateReceiptLoc(iptDec);

        return cargo;
    }

    private static VS_InwardPaymentReqWrapper.Location generateReleaseLoc(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Location releaseLoc = new VS_InwardPaymentReqWrapper.Location();

        releaseLoc.loc_code = iptDec.TN_Release_Location_Code__c;
        releaseLoc.loc_name = iptDec.TN_Release_Location_Name__r.Name;

        return releaseLoc;
    }

    private static VS_InwardPaymentReqWrapper.Location generateReceiptLoc(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Location receiptLoc = new VS_InwardPaymentReqWrapper.Location();

        receiptLoc.loc_code = iptDec.TN_Receipt_Location_Code__c;
        receiptLoc.loc_name = iptDec.TN_Receipt_Location_Name__r.Name;

        return receiptLoc;
    }

    private static VS_InwardPaymentReqWrapper.Transport generateTransport(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Transport transport = new VS_InwardPaymentReqWrapper.Transport();
        VS_InwardPaymentReqWrapper.In_tpt   inTPT      = new VS_InwardPaymentReqWrapper.In_tpt();

        inTPT.tpt_mode        = String.valueOf(iptDec.TN_Transport_Mode_Code__c);
        inTPT.cvy_ref_no      = iptDec.TN_Vessel_Code__c;
        inTPT.tpt_id          = iptDec.TN_Vessel_Name__c;
        inTPT.master_ship_doc = iptDec.TN_B_L_No__c;
        inTPT.arrival_date    = iptDec.TN_ETA__c <> null ? Integer.valueOf(String.valueOf(iptDec.TN_ETA__c).replace('-', '')) : null;
        inTPT.loading_port    = iptDec.TN_Port_of_Loading_Code__c;

        transport.in_tpt      = inTPT;

        return transport;
    }

    private static VS_InwardPaymentReqWrapper.Party generateParty(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Party party = new VS_InwardPaymentReqWrapper.Party();

        // Generate Declarant data
        party.declarant = generateDeclarant(iptDec);

        // Gererate Declaring Agent data
        party.declaring_agent = generateDeclarantAgent(iptDec);

        // Generate In-Carrier data
        party.in_carrier_agent = generateInCarrierAgent(iptDec);

        // Generate Importer data
        party.importer = generateImporter(iptDec);

        return party;
    }

    private static VS_InwardPaymentReqWrapper.Declarant generateDeclarant(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Declarant declarant = new VS_InwardPaymentReqWrapper.Declarant();

        declarant.person_code  = iptDec.TN_Declarant_Person_Code__c;
        declarant.person_name  = iptDec.Declarant_Person__r.Name;
        declarant.person_phone = iptDec.TN_Declarant_Person_Phone__c; 

        return declarant;
    }

    private static VS_InwardPaymentReqWrapper.Agent generateDeclarantAgent(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Agent declaringAgent = new VS_InwardPaymentReqWrapper.Agent();
        VS_InwardPaymentReqWrapper.Name nameData        = new VS_InwardPaymentReqWrapper.Name();

        nameData.name            = iptDec.TN_Declarant_Name__r.Name;
        declaringAgent.name      = new List<VS_InwardPaymentReqWrapper.Name> {nameData};
        declaringAgent.cr_uei_no = iptDec.C_C_ID_on_TradeNet__c;

        return declaringAgent;
    }

    private static VS_InwardPaymentReqWrapper.Agent generateInCarrierAgent(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Agent inCarrierAgent = new VS_InwardPaymentReqWrapper.Agent();
        VS_InwardPaymentReqWrapper.Name nameData          = new VS_InwardPaymentReqWrapper.Name();

        nameData.name            = iptDec.TN_Inward_Carrier_Name__r.Name;
        inCarrierAgent.name      = new List<VS_InwardPaymentReqWrapper.Name> {nameData};
        inCarrierAgent.cr_uei_no = iptDec.TN_Inward_Carrier_Entity_Identifier__c;

        return inCarrierAgent;
    }

    private static VS_InwardPaymentReqWrapper.Agent generateImporter(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Agent importer = new VS_InwardPaymentReqWrapper.Agent();
        VS_InwardPaymentReqWrapper.Name nameData  = new VS_InwardPaymentReqWrapper.Name();

        nameData.name      = iptDec.TN_Importer_Name__r.Name;
        importer.name      = new List<VS_InwardPaymentReqWrapper.Name> {nameData};
        importer.cr_uei_no = iptDec.TN_Importer_Entity_Identifier__c;

        return importer;
    }

    private static List<VS_InwardPaymentReqWrapper.Invoice> generateInvoices(Inward_Declaration__c iptDec, Boolean isFromVehShipment)
    {
        List<VS_InwardPaymentReqWrapper.Invoice> invoices = new List<VS_InwardPaymentReqWrapper.Invoice>();
        List<Manufacturer_Invoice__c> existingInvoices    = new List<Manufacturer_Invoice__c>();
        VS_InwardPaymentReqWrapper.Invoice inv;

        if (isFromVehShipment)
        {
            existingInvoices = ManufacturerInvoiceService.getManufacturerInvoicesByVehicleShipmentIds(new Set<Id> {iptDec.Vehicle_Shipment__c});
        }
        else 
        {
            existingInvoices = iptDec.Inward_Declaration_Invoices__r;   
        }


        if (existingInvoices <> null && !existingInvoices.isEmpty())
        {
            for (Manufacturer_Invoice__c invoice : existingInvoices)
            {
                inv = new VS_InwardPaymentReqWrapper.Invoice();

                inv.inv_no        = invoice.Invoice_No__c;
                inv.inv_date      = invoice.Invoice_Date__c <> null ? String.valueOf(invoice.Invoice_Date__c).replace('-', '') : '';
                inv.inv_term_type = invoice.TN_Invoice_Term_Type_Code__c;

                // Generate Supplier Manufacturer data
                inv.sup_mfr = generateSupplierManufacturer(iptDec);

                // Generate Total Invoice Amount data
                inv.tot_inv_amt = generateTotalInvAmount(invoice);

                // Generate Freight Charge data
                inv.frc_charge = generateFreightCharge(invoice);

                // Generate Insurance Charge data
                inv.ins_charge = generateInsuranceCharge(invoice);

                invoices.add(inv);
            }
        }

        return invoices;
    }

    public static VS_InwardPaymentReqWrapper.Supplier generateSupplierManufacturer(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Supplier supplier      = new VS_InwardPaymentReqWrapper.Supplier();
        VS_InwardPaymentReqWrapper.Person_Name personName = new VS_InwardPaymentReqWrapper.Person_Name(); 

        personName.person_name = iptDec.Supplier_Account__r?.Name;

        supplier.person_name = new List<VS_InwardPaymentReqWrapper.Person_Name> {personName};

        return supplier;
    }

    public static VS_InwardPaymentReqWrapper.Charge generateTotalInvAmount(Manufacturer_Invoice__c invoice)
    {
        VS_InwardPaymentReqWrapper.Charge totalInvAmt = new VS_InwardPaymentReqWrapper.Charge();

        totalInvAmt.amt       = invoice.Total_Invoice_Amount__c;
        totalInvAmt.curr_code = invoice.Total_Invoice_Amount_Currency_Code__c;

        return totalInvAmt;
    }

    public static VS_InwardPaymentReqWrapper.Charge generateFreightCharge(Manufacturer_Invoice__c invoice)
    {
        VS_InwardPaymentReqWrapper.Charge freightCharge = new VS_InwardPaymentReqWrapper.Charge();

        freightCharge.amt       = String.isNotBlank(invoice.TN_Freight_Charges__c) ? Decimal.valueOf(invoice.TN_Freight_Charges__c) : null;
        freightCharge.curr_code = invoice.TN_Freight_Currency_Code__c;

        return freightCharge;
    }

    public static VS_InwardPaymentReqWrapper.Charge generateInsuranceCharge(Manufacturer_Invoice__c invoice)
    {
        VS_InwardPaymentReqWrapper.Charge insuranceCharge = new VS_InwardPaymentReqWrapper.Charge();

        insuranceCharge.amt       = String.isNotBlank(invoice.TN_Insurance_Charges__c) ? Decimal.valueOf(invoice.TN_Insurance_Charges__c) : null;
        insuranceCharge.curr_code = invoice.TN_Insurance_Currency_Code__c;

        return insuranceCharge;
    }

    private static List<VS_InwardPaymentReqWrapper.Item> generateItems(Map<String, List<String>> grouppedSVMs)
    {
        List<VS_InwardPaymentReqWrapper.Item> items = new List<VS_InwardPaymentReqWrapper.Item>();
        List<String> SVMIdSet                       = new List<String>();
        VS_InwardPaymentReqWrapper.Item item;
        Vehicle_Master2__c tempVehicleMaster;

        if (grouppedSVMs <> null && grouppedSVMs.size() > 0)
        {
            for (List<String> SVMIds : grouppedSVMs.values())
            {
                SVMIdSet.addAll(SVMIds);
            }

            Map<Id, Vehicle_Master2__c> vehicleMasters =  new Map<Id, Vehicle_Master2__c>(StockVehicleMasterService.selectByIds(SVMIdSet));
            Integer currentInvoiceNo                   = 1;
            FRANCHISE_CODE                             = vehicleMasters?.values()?.get(0)?.Franchise_Code__c;

            for (String itemGroupCode : grouppedSVMs.keySet())
            {
                item              = new VS_InwardPaymentReqWrapper.Item();
                tempVehicleMaster = vehicleMasters.get(grouppedSVMs.get(itemGroupCode)?.get(0));
    
                item.seq_no             = currentInvoiceNo;
                item.item_inv_no        = tempVehicleMaster.Invoice_No__c;
                item.hs_code            = tempVehicleMaster.TN_HS_Code__r?.Name;
                item.item_desc          = tempVehicleMaster.TN_Item_Description__c;
                item.cty_origin         = tempVehicleMaster.Vehicle_Shipment__r <> null && String.isNotBlank(tempVehicleMaster.Vehicle_Shipment__r?.Country_of_Origin_Code__c) ? tempVehicleMaster.Vehicle_Shipment__r?.Country_of_Origin_Code__c : COUNTRY_OF_ORIGIN;
                item.brand              = tempVehicleMaster.Vehicle_Shipment__r?.Brand__c;

                // Generate Item Quantity
                item.item_qty = generateItemQuantity(tempVehicleMaster);

                // Generate Transaction Value
                item.transaction_value = generateTransactionValue(tempVehicleMaster);

                // Generate Out Pack Quantity
                item.out_pack_qty = generateOutPackQuantity(tempVehicleMaster);

                // Generate Duty Tax
                item.duty_tax = generateDutyTax(tempVehicleMaster);

                // Generate CASC Product
                item.casc_product = generateCASCProduct(grouppedSVMs.get(itemGroupCode), vehicleMasters);

                items.add(item);

                currentInvoiceNo++;
            }
        }

        return items;
    }

    private static VS_InwardPaymentReqWrapper.Item_qty generateItemQuantity(Vehicle_Master2__c vehicleMaster)
    {
        VS_InwardPaymentReqWrapper.Item_qty itemQuantity = new VS_InwardPaymentReqWrapper.Item_qty();

        // Generate HS Quantity
        itemQuantity.hs_qty = generateHSQuantity(vehicleMaster);

        // Generate Total Duty Quantity
        itemQuantity.tot_dut_qty = generateTotalDutyQuantity(vehicleMaster);

        // Generate Duty Quantity
        itemQuantity.dut_qty = generateDutyQuantity(vehicleMaster);

        return itemQuantity;
    }

    private static VS_InwardPaymentReqWrapper.Quantity generateHSQuantity(Vehicle_Master2__c vehicleMaster)
    {
        VS_InwardPaymentReqWrapper.Quantity hsQty = new VS_InwardPaymentReqWrapper.Quantity();

        hsQty.qty_value = vehicleMaster.hs_qty_value__c <> null ? Integer.valueOf(vehicleMaster.hs_qty_value__c) : null;
        hsQty.qty_uom   = vehicleMaster.TN_HS_Unit__c;

        return hsQty;
    }

    private static VS_InwardPaymentReqWrapper.Quantity generateTotalDutyQuantity(Vehicle_Master2__c vehicleMaster)
    {
        VS_InwardPaymentReqWrapper.Quantity totalDutyQty = new VS_InwardPaymentReqWrapper.Quantity();

        totalDutyQty.qty_value = vehicleMaster.Inward_Declaration_Invoice__r?.TN_Total_Dutiable_Qty__c <> null ? Integer.valueOf(vehicleMaster.Inward_Declaration_Invoice__r.TN_Total_Dutiable_Qty__c) : null;
        totalDutyQty.qty_uom   = vehicleMaster.Inward_Declaration_Invoice__r?.TN_Total_Dutiable_Qty_UOM__c;

        return totalDutyQty;
    }

    private static VS_InwardPaymentReqWrapper.Quantity generateDutyQuantity(Vehicle_Master2__c vehicleMaster)
    {
        VS_InwardPaymentReqWrapper.Quantity dutyQty = new VS_InwardPaymentReqWrapper.Quantity();

        dutyQty.qty_value = vehicleMaster.customs_duty_amt__c <> null ? Integer.valueOf(vehicleMaster.customs_duty_amt__c) : null;
        dutyQty.qty_uom   = vehicleMaster.customs_duty_uom__c;

        return dutyQty;
    }

    private static VS_InwardPaymentReqWrapper.Transaction_value generateTransactionValue(Vehicle_Master2__c vehicleMaster)
    {
        VS_InwardPaymentReqWrapper.Transaction_value transactionVal = new VS_InwardPaymentReqWrapper.Transaction_value();
        VS_InwardPaymentReqWrapper.Value unitPrice                  = new VS_InwardPaymentReqWrapper.Value();

        unitPrice.amt       = vehicleMaster.FOB_Amount__c <> null ? String.valueOf(vehicleMaster.FOB_Amount__c) : null;
        unitPrice.curr_code = vehicleMaster.FOB_Amount_Currency_Code__c;

        transactionVal.cif_fob_amt = vehicleMaster.item_cif_fob_amt__c <> null ? Integer.valueOf(vehicleMaster.item_cif_fob_amt__c) : null;
        transactionVal.unit_price  = unitPrice;

        return transactionVal;
    }

    private static VS_InwardPaymentReqWrapper.Out_pack_qty generateOutPackQuantity(Vehicle_Master2__c vehicleMaster)
    {
        VS_InwardPaymentReqWrapper.Out_pack_qty outPackQty = new VS_InwardPaymentReqWrapper.Out_pack_qty();

        outPackQty.qty = vehicleMaster.outer_qty_value__c <> null ? Integer.valueOf(vehicleMaster.outer_qty_value__c) : null;
        outPackQty.uom = vehicleMaster.outer_qty_uom__c;

        return outPackQty;
    }

    private static VS_InwardPaymentReqWrapper.Duty_tax generateDutyTax(Vehicle_Master2__c vehicleMaster)
    {
        VS_InwardPaymentReqWrapper.Duty_tax dutyTax = new VS_InwardPaymentReqWrapper.Duty_tax();

        dutyTax.gst_rate = vehicleMaster.gst_rate__c <> null ? Integer.valueOf(vehicleMaster.gst_rate__c) : null;
        dutyTax.gst_amt  = vehicleMaster.gst_amt__c <> null ? Integer.valueOf(vehicleMaster.gst_amt__c) : null;

        // Generate Excise Duty
        dutyTax.excise_duty = generateExciseDuty(vehicleMaster);

        // Generate Customs Duty
        dutyTax.customs_duty = generateCustomsDuty(vehicleMaster);

        return dutyTax;
    }

    private static VS_InwardPaymentReqWrapper.Excise_duty generateExciseDuty(Vehicle_Master2__c vehicleMaster)
    {
        VS_InwardPaymentReqWrapper.Excise_duty exciseDuty = new VS_InwardPaymentReqWrapper.Excise_duty();

        exciseDuty.duty_rate = vehicleMaster.excise_duty_rate__c <> null ? Integer.valueOf(vehicleMaster.excise_duty_rate__c) : null;
        exciseDuty.duty_uom  = vehicleMaster.excise_duty_uom__c;
        exciseDuty.duty_amt  = vehicleMaster.excise_duty_amt__c <> null ? Integer.valueOf(vehicleMaster.excise_duty_amt__c) : null;

        return exciseDuty;
    }

    private static VS_InwardPaymentReqWrapper.Excise_duty generateCustomsDuty(Vehicle_Master2__c vehicleMaster)
    {
        VS_InwardPaymentReqWrapper.Excise_duty customsDuty = new VS_InwardPaymentReqWrapper.Excise_duty();

        customsDuty.duty_rate = vehicleMaster.customs_duty_rate__c <> null ? Integer.valueOf(vehicleMaster.customs_duty_rate__c) : null;
        customsDuty.duty_uom  = vehicleMaster.customs_duty_uom__c;
        customsDuty.duty_amt  = vehicleMaster.customs_duty_amt__c <> null ? Integer.valueOf(vehicleMaster.customs_duty_amt__c) : null;

        return customsDuty;
    }

    private static VS_InwardPaymentReqWrapper.Casc_product generateCASCProduct(List<String> vehicleMasterIds, Map<Id, Vehicle_Master2__c> vehicleMasters)
    {
        VS_InwardPaymentReqWrapper.Casc_product cascProduct = new VS_InwardPaymentReqWrapper.Casc_product();
        Vehicle_Master2__c tempVehicleMaster                = vehicleMasters.get(vehicleMasterIds.get(0));

        cascProduct.prod_code    = tempVehicleMaster.Product_Code__r?.Product_Code__c;
        cascProduct.prod_qty_uom = tempVehicleMaster.prod_qty_uom__c;     
        cascProduct.prod_qty     = vehicleMasterIds.size();

        // Generate CASC Code
        cascProduct.add_casc_code = generateAddCASCCode(vehicleMasterIds, vehicleMasters);

        return cascProduct;
    }

    private static List<VS_InwardPaymentReqWrapper.Add_casc_code> generateAddCASCCode(List<String> vehicleMasterIds, Map<Id, Vehicle_Master2__c> vehicleMasters)
    {
        List<VS_InwardPaymentReqWrapper.Add_casc_code> returnedList = new List<VS_InwardPaymentReqWrapper.Add_casc_code>();
        VS_InwardPaymentReqWrapper.Add_casc_code CASCCode;

        for (String vehicleId : vehicleMasterIds)
        {
            CASCCode            = new VS_InwardPaymentReqWrapper.Add_casc_code();
            CASCCode.casc_code1 = vehicleMasters.get(vehicleId).Engine_No__c;
            CASCCode.casc_code2 = vehicleMasters.get(vehicleId).Chassis__c;
            CASCCode.casc_code3 = vehicleMasters.get(vehicleId).Vehicle_Type__c;

            returnedList.add(CASCCode);
        }

        return returnedList;
    }

    private static VS_InwardPaymentReqWrapper.Summary generateSummary(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Summary summary = new VS_InwardPaymentReqWrapper.Summary();

        // Gerenate Total Out Pack
        summary.tot_out_pack = generateTotalOutPack(iptDec);

        // Generate Total Gross WT
        summary.tot_gross_wt = generateTotalGrossWT(iptDec);

        return summary;
    }

    private static VS_InwardPaymentReqWrapper.Quantity generateTotalOutPack(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Quantity totalOutPack = new VS_InwardPaymentReqWrapper.Quantity();

        totalOutPack.qty_value = iptDec.TN_Total_Outer_Pack__c <> null ? Integer.valueOf(iptDec.TN_Total_Outer_Pack__c) : null;
        totalOutPack.qty_uom   = iptDec.TN_Total_Outer_Pack_UOM__c;

        return totalOutPack;
    }

    private static VS_InwardPaymentReqWrapper.Quantity generateTotalGrossWT(Inward_Declaration__c iptDec)
    {
        VS_InwardPaymentReqWrapper.Quantity totalGrossWT = new VS_InwardPaymentReqWrapper.Quantity();

        totalGrossWT.qty_value = iptDec.TN_Total_Gross_Weight__c <> null ? Integer.valueOf(iptDec.TN_Total_Gross_Weight__c) : null;
        totalGrossWT.qty_uom   = iptDec.TN_Total_Gross_Weight_UOM__c;
        
        return totalGrossWT;
    }

    private static List<VS_InwardPaymentReqWrapper.Add_info> generateAddInfor(Inward_Declaration__c iptDec, Boolean isFromVehShipment)
    {
        VS_InwardPaymentReqWrapper.Add_info addInfor = new VS_InwardPaymentReqWrapper.Add_info();

        addInfor.info_name = 'USER_REF_NO';
        addInfor.info_text = FRANCHISE_CODE + ' - ' + RECORD_ID + ' - ' + TRANSACTION_TYPE;

        return new List<VS_InwardPaymentReqWrapper.Add_info> {addInfor};
    }

    @TestVisible
    private class VS_InwardPaymentSVCException extends Exception
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
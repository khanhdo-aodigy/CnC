/*==========================================================================================================================================================================
 * Test class for VS_HttpCalloutUnit.cls
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           01 Sep 2022                       dong.nguyen@aodigy.com                US-Ship-000027                                           Init
 * ========================================================================================================================================================================== 
 */

@isTest
public with sharing class VS_HttpCalloutUtilTest {
    @TestSetup
    static void makeData(){
        //create Supplier
        Account supplier = Test_DataFactory.createAccount(true, 'supplier Account');

        //create Vehicle shipment
        Vehicle_Shipment__c shipment = Test_DataFactory.createVehicleShipment(true, supplier.Id);

        //create Manufacture invoice
        Manufacturer_Invoice__c invoice = Test_DataFactory.createManufacturerInvoice(true);

        //create HS type
        HS_Type__c hs = new HS_Type__c(Name='hs-123');
        insert hs;

        //create shipment line item
        Shipment_Line_Item__c ShipmentLineItem = Test_DataFactory.createShipmentLineItem(false, shipment.Id, invoice.Id);
        ShipmentLineItem.TN_HS_Code__c = hs.Id;
        ShipmentLineItem.TN_CASC_Product_UOM__c = 'a1';
        insert ShipmentLineItem;

        //create Inward Declaration
        Inward_Declaration__c inward = new Inward_Declaration__c(Name = 'Inward Non-Payment-Vehicles',
                                                                Vehicle_Shipment__c = shipment.Id);
        insert inward;
    }
    
    @isTest
    public static void invokeApiCall_Success(){
        Test.setMock(HttpCalloutMock.class, new VS_CalloutMock());
        Shipment_Line_Item__c ShipmentLineItem = [SELECT Id ,TN_HS_Code__c FROM Shipment_Line_Item__c];
        VS_HttpCalloutUtil.invokeApiCall('{"routeId":"2021082512262426","messageType":"DEC","documentType":"DEC","data":{"sender_id":"TRW1.TRW1001","recipient_id":"TRW1.TRW1001","message_version":"","message":{"transport":{"in_tpt":{"tpt_mode":"1","tpt_id":"TORI","master_ship_doc":"OBL 3030","loading_port":"JPAH","cvy_ref_no":"TT5","arrival_date":20220929}},"summary":{"tot_out_pack":{"qty_value":5,"qty_uom":"TUB"},"tot_item":null,"tot_gross_wt":{"qty_value":400,"qty_uom":"TNE"},"tot_duty_tax":{"tot_payable_amt":null,"tot_gst_amt":null},"tot_cif_fob_amt":null},"party":{"in_carrier_agent":{"name":[{"name":"CRIMSONLOGIC ETRADE SERVICES PTE LTD"}],"cr_uei_no":"200105123R"},"importer":{"name":[{"name":"Cycle & Carriage Automotive Pte Ltd"}],"cr_uei_no":"TRW1.TRW1001"},"declaring_agent":{"name":[{"name":"Cycle & Carriage Automotive Pte Ltd"}],"cr_uei_no":"200101111R"},"declarant":{"person_phone":"68877333","person_name":"TEST THREE","person_code":"P00333333"}},"item":[],"header":{"unique_ref_no":{"seq_no":1,"date":20220907,"cr_uei_no":"200101111R"},"remarks":[{"line":[{"line":"INPDEC APS 2022083000001"}]}],"declarant_id":"TRW1.TRW1001","dec_type":"APS","dec_stmt_ind":"false","car_type":"INPDEC"},"cargo":{"storage_loc":{"loc_code":"PPZ"},"release_loc":{"loc_name":"PASIR PANJANG FTZ","loc_code":"PPZ"},"receipt_loc":{"loc_name":"PASIR PANJANG FTZ","loc_code":"PPZ"},"pack_type":"9","exhibit_temp_imp_start_date":null},"add_info":[{"info_text":"KIAPC","info_name":"USER_REF_NO"}]}}}',
        ShipmentLineItem.Id, 'INP');
        System.assertNotEquals(null,  ShipmentLineItem.Id);
    }

    @isTest
    public static void invokeApiCallToGetResponse_Success(){
        Test.setMock(HttpCalloutMock.class, new VS_CalloutMock());
        Shipment_Line_Item__c ShipmentLineItem = [SELECT Id ,TN_HS_Code__c FROM Shipment_Line_Item__c];
        VS_HttpCalloutUtil.invokeApiCallToGetResponse('{"transactionId":"2022090712403358","messageType":"RESR","documentType":"RESR"}',
        ShipmentLineItem.Id);
        System.assertNotEquals(null,  ShipmentLineItem.Id);
    }

    @isTest
    public static void generateHttpRequestPayloadForResponseAPI_Success(){
        Test.setMock(HttpCalloutMock.class, new VS_CalloutMock());
        Inward_Declaration__c inward = [SELECT Id  FROM Inward_Declaration__c];
        VS_HttpCalloutUtil.generateHttpRequestPayloadForResponseAPI(inward.Id);
        System.assertNotEquals(null, inward.Id);
    }

    @isTest
    public static void generateSeqNo_Success(){
        Test.setMock(HttpCalloutMock.class, new VS_CalloutMock());
        List<Inward_Declaration__c> inward = [SELECT Id  FROM Inward_Declaration__c];
        VS_HttpCalloutUtil.generateSeqNo();
        System.assertEquals(1, inward.size());
    }
}
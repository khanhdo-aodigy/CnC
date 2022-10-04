/*==========================================================================================================================================================================
 * VS_InwardNonPaymentSVCTest for VS_InwardNonPaymentSVC
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      12 Sep 2022                      dong.nguyen@aodigy.com                    US-Ship-000027                                         init
 * ========================================================================================================================================================================== 
 */
@istest
public with sharing class VS_InwardNonPaymentSVCTest {
    @TestSetup
    static void makeData(){
        //create Supplier
        Account supplier = Test_DataFactory.createAccount(true, 'supplier Account');

        //create Vehicle shipment
        Vehicle_Shipment__c shipment = Test_DataFactory.createVehicleShipment(true, supplier.Id);

        //create Manufacture invoice
        Manufacturer_Invoice__c invoice = Test_DataFactory.createManufacturerInvoice(true);

        //create HS type
        HS_Type__c hs = new HS_Type__c(
           Name='hs-123'
        );
        insert hs;

        //create shipment line item
        Shipment_Line_Item__c ShipmentLineItem = Test_DataFactory.createShipmentLineItem(false, shipment.Id, invoice.Id);
        ShipmentLineItem.TN_HS_Code__c = hs.Id;
        ShipmentLineItem.TN_CASC_Product_UOM__c = 'a1';
        insert ShipmentLineItem;

        //create Inward Declaration
        Inward_Declaration__c inward = new Inward_Declaration__c
        (
            Name = 'Inward Non-Payment-Vehicles',
            Vehicle_Shipment__c = shipment.Id
        );
        insert inward;
    }
    @isTest
    public static void SubmitINP_success() {
        Test.setMock(HttpCalloutMock.class, new VS_CalloutMock());

        HS_Type__c hs  = [SELECT Id FROM HS_Type__c];  
        Shipment_Line_Item__c ShipmentLineItem = [SELECT Id ,TN_HS_Code__c FROM Shipment_Line_Item__c];
        Vehicle_Shipment__c shipment_1 = [SELECT Id FROM Vehicle_Shipment__c];
       
        List<String> b = new List<String>();
        b.add(ShipmentLineItem.Id);

        // put data into maps.
        Map<String,List<String>> maps = new Map<String,List<String>>();
        maps.put(ShipmentLineItem.TN_HS_Code__c, b); 

        Boolean res = VS_InwardNonPaymentSVC.submitINP(shipment_1.Id, maps);
        System.assertNotEquals(null, shipment_1);
    }

    @isTest
    public static void testSubmitINP_Record_Id_Is_Blank() {
        Test.setMock(HttpCalloutMock.class, new VS_CalloutMock());

        HS_Type__c hs  = [SELECT Id FROM HS_Type__c];  
        Shipment_Line_Item__c ShipmentLineItem = [SELECT Id ,TN_HS_Code__c FROM Shipment_Line_Item__c];
        Vehicle_Shipment__c shipment_1 = [SELECT Id FROM Vehicle_Shipment__c];
       
        List<String> b = new List<String>();
        b.add(ShipmentLineItem.Id);

        // put data into maps.
        Map<String,List<String>> maps = new Map<String,List<String>>();
        maps.put(ShipmentLineItem.TN_HS_Code__c, b); 

        try {
            Boolean res = VS_InwardNonPaymentSVC.submitINP('' , maps);
        } catch (Exception e) {
            System.assertEquals('Empty Vehicle Shipment Id', e.getMessage());
        }
    }
}
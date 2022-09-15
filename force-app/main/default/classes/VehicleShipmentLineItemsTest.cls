/*==========================================================================================================================================================================
 * VehicleShipmentLineItemsTest for VehicleShipmentLineItems
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      7 Sep 2022                       dong.nguyen@aodigy.com                    US-Ship-000025                                           init
 * ========================================================================================================================================================================== 
 */
@istest
public with sharing class VehicleShipmentLineItemsTest {
    @isTest
    private static void defaultLineItemSeqNo_success(){
         //create Supplier
         Account supplier = Test_DataFactory.createAccount(true, 'supplier Account');

         //create Vehicle shipment
         Vehicle_Shipment__c shipment = Test_DataFactory.createVehicleShipment(true, supplier.Id);
 
         //create Manufacture invoice
         Manufacturer_Invoice__c invoice = Test_DataFactory.createManufacturerInvoice(true);
 
         //create shipment line item
         Shipment_Line_Item__c ShipmentLineItem = Test_DataFactory.createShipmentLineItem(true, shipment.Id, invoice.Id);

        Manufacturer_Invoice__c invoice_1 = new Manufacturer_Invoice__c(
            Name                     = '2345',
            Invoice_Date__c          = Date.today()
        );
        insert invoice_1;
    
        Shipment_Line_Item__c lineItem = new Shipment_Line_Item__c(
            Vehicle_Shipment__c = shipment.Id,
            Chassis_No__c  = '3423545647651',
            Engine_No__c = '1232435456542 ',
            Colour_Code__c ='rwerwett',
            Production_Month__c = '0820223',
            Invoice_No__c = invoice_1.Id
            );
        insert lineItem;

        Shipment_Line_Item__c lineItem_1 = [SELECT Id, Invoice_No__c FROM Shipment_Line_Item__c LIMIT 1];
        lineItem_1.Invoice_No__c = null;
        update lineItem_1;
        lineItem_1.Invoice_No__c = invoice_1.Id;
        update lineItem_1;
        lineItem_1.Invoice_No__c = invoice.Id;
        update lineItem_1;
        lineItem_1.Invoice_No__c = null;
        update lineItem_1;
        lineItem_1.Invoice_No__c = invoice_1.Id;
        update lineItem_1;
        System.assertNotEquals(null, lineItem_1.Invoice_No__c);
    }

}
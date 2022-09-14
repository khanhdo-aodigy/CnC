/*==========================================================================================================================================================================
 * Test service class for Shipment Line Item Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           8 Sep 2022                       nam@aodigy.com                                                                               init
 * ========================================================================================================================================================================== 
 */
@isTest
public with sharing class VehicleShipmentLineItemServiceTest 
{
    @TestSetup
    static void makeData(){
       
         // create account supplier
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        //create vehicle shipment 
        Vehicle_Shipment__c VehicleShipment         = Test_DataFactory.createVehicleShipment(true, supplier.Id);

        // create manufacturer invoice
        Manufacturer_Invoice__c manufacturerInvoice = Test_DataFactory.createManufacturerInvoice(true);

         //create shipment line item
         Shipment_Line_Item__c shipmentLineItem     = Test_DataFactory.createShipmentLineItem(true, VehicleShipment.Id, manufacturerInvoice.Id);      
    }
    
    @IsTest
    private static void getLineItemsNotTaggedToInvoicesByShipmentId_success()
    {
        Shipment_Line_Item__c shipmentLineItem = [SELECT Id FROM Shipment_Line_Item__c];
        VehicleShipmentLineItemSelector sel = new VehicleShipmentLineItemSelector();
        VehicleShipmentLineItemService.getLineItemsNotTaggedToInvoicesByShipmentId(shipmentLineItem.Id);
    }

    @IsTest
    private static void getLineItemsByVehicleShipmentIds_success()
    {
        Test.startTest();
        List<Shipment_Line_Item__c> shipmentLineItems = [SELECT Id FROM Shipment_Line_Item__c];
        Set<Id> shipmentIds = new Set<Id>();
        VehicleShipmentLineItemService.getLineItemsByVehicleShipmentIds(shipmentIds);  
        Test.stopTest();
    }
    
    @IsTest
    private static void getLineItemsByIds_success()
    {
        Test.startTest();
        List<Shipment_Line_Item__c> shipmentLineItems = [SELECT Id FROM Shipment_Line_Item__c];
        Set<String> shipmentIds = new Set<String>();
        VehicleShipmentLineItemService.getLineItemsByIds(shipmentIds);  
        Test.stopTest();
    }
}
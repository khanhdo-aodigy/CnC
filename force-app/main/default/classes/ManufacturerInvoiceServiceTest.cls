/*==========================================================================================================================================================================
 * Test service class for Manufacturer Invoice Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           14 Sep 2022                       nam@aodigy.com                                                                               init
 * ========================================================================================================================================================================== 
 */
@isTest
public with sharing class ManufacturerInvoiceServiceTest {
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
    private static void getManufacturerInvoicesByVehicleShipmentIds_success()
    {
        Test.startTest();
        List<Manufacturer_Invoice__c> manufacturerInvoices = [SELECT Id FROM Manufacturer_Invoice__c];
        Set<Id> shipmentIds = new Set<Id>();
        ManufacturerInvoiceService.getManufacturerInvoicesByVehicleShipmentIds(shipmentIds);  
        Test.stopTest();
    }
    
    @IsTest
    private static void getManufacturerInvoicesByInvoiceNos_success()
    {
        Test.startTest();
        List<Manufacturer_Invoice__c> manufacturerInvoices = [SELECT Id FROM Manufacturer_Invoice__c];
        Set<String> shipmentIds = new Set<String>();
        ManufacturerInvoiceService.getManufacturerInvoicesByInvoiceNos(shipmentIds);  
        Test.stopTest();
    }
}
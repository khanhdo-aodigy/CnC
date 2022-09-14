/*==========================================================================================================================================================================
 * Test class for Manufacturer Invoice Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           6 Sep 2022                        nam@aodigy.com                                                                               init
 * ========================================================================================================================================================================== 
 */
@isTest
public with sharing class ManufacturerInvoiceSelectorTest {
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
    /**
     * Get Manufaturer Invoice together with Shipment Line Item via correct MI Id
     * Expected: correct MI retrieved together with related SLI
     */
    @IsTest
    private static void getManufacturerInvoiceWithShipmentLineItems_success()
    {
        Manufacturer_Invoice__c invoice = [SELECT Id FROM Manufacturer_Invoice__c];

        ManufacturerInvoiceSelector selector = new ManufacturerInvoiceSelector();

        List<Manufacturer_Invoice__c> result = selector.selectManufacturerInvoiceWithSLIByIds(new Set<Id> {invoice.Id});

        // result should contain 1 invoice
        System.assert(result.size() == 1, 'Actual result size: ' + result.size());

    }
    /**
     * Get Manufaturer Invoice together with Vehicle Shipment via correct MI Id
     * Expected: correct MI retrieved together with related Vehicle Shipment
     */
    @IsTest
    private static void getManufacturerInvoicesByVehicleShipment_success()
    {
        Manufacturer_Invoice__c invoice = [SELECT Id FROM Manufacturer_Invoice__c];

        ManufacturerInvoiceSelector selector = new ManufacturerInvoiceSelector();

        List<Manufacturer_Invoice__c> result = selector.selectManufacturerInvoicesByVehicleShipmentIds(new Set<Id> {invoice.Id});

    }

    @IsTest
    private static void selectManufacturerInvoicesByInvoiceNos_success()
    {
        Manufacturer_Invoice__c invoice = [SELECT Id FROM Manufacturer_Invoice__c];

        ManufacturerInvoiceSelector selector = new ManufacturerInvoiceSelector();

        List<Manufacturer_Invoice__c> result = selector.selectManufacturerInvoicesByInvoiceNos(new Set<String> {invoice.Id});

    }

}
/*==========================================================================================================================================================================
 * VehicleShipmentSelectorTest for VehicleShipmentSelector
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *              24 Aug 2022                         dong.nguyen@aodigy.com              US-Ship-000008                                      init
 * ========================================================================================================================================================================== 
 */
@isTest
private with sharing class VehicleShipmentSelectorTest
{
    @TestSetup
    private static void makeData()
    {
        // create model master
        Model_Master__c modelMaster = Test_DataFactory.createModelCode(true, 'Model Master');

        // create color master
        Color_Master__c colorMaster = Test_DataFactory.createColorCode(true, 'Color Master', 'CM', 'KIA', 'KIAPC');

        // create trim master
        Trim_Master__c trimMaster = Test_DataFactory.createTrimCode(true, 'Trim Master');

        //create model color trim master
        Model_Color_Trim_Master__c modelColorTrimMaster = Test_DataFactory.createModelColorTrimMaster(true, colorMaster.Id, modelMaster.Id, trimMaster.Id);
      
        // create model year master
        Model_Year_Master__c modelYearMaster = Test_DataFactory.createModelYearCode(true, modelMaster.Id);

        // create Vehicle master2 
        Vehicle_Master2__c vm2 = Test_DataFactory.createVehicleMaster2(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id, 'originalCommacase', 'systemCommcase');
        vm2.ProductionMonth__c= Date.today().addDays(5);
        insert vm2;

        // create supplier account
        Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        //create Vehicle shipment
        Vehicle_Shipment__c vehicleShipment = Test_DataFactory.createVehicleShipment(true, supplier.Id);

        //create manu1facturer Invoice
        Manufacturer_Invoice__c invoice = Test_DataFactory.createManufacturerInvoice(true);
        
        //create Shipment line item
        Shipment_Line_Item__c shipmentLineItem = Test_DataFactory.createShipmentLineItem(true, vehicleShipment.Id, invoice.Id);
    }

    @IsTest
    private static void selectByIds_success()
    {
        Vehicle_Shipment__c vh = [SELECT Id, Brand__c FROM Vehicle_Shipment__c];

        VehicleShipmentSelector selector = new VehicleShipmentSelector();

        List<Vehicle_Shipment__c> listShipment = selector.selectByIds(new Set<Id>{ vh.Id }, true, true);

        System.assertEquals(1, listShipment.size());
    }

    @isTest
    private static void selectByIds_InvalidId()
    {
        Vehicle_Shipment__c vh = [SELECT Id, CreatedById FROM Vehicle_Shipment__c];

        VehicleShipmentSelector selector = new VehicleShipmentSelector();

        list<Vehicle_Shipment__c> listShipment = selector.selectByIds(new Set<Id> {vh.CreatedById}, true, true);

        System.assert(listShipment.size()== 0, listShipment.size());

        // System.assertEquals(0, listShipment.size());
    }

    @isTest
    public static void selectByIdWithInvoicesAndLineItems_success()
    {
        Vehicle_Shipment__c vh = [SELECT Id FROM Vehicle_Shipment__c];
        
        VehicleShipmentSelector selector = new VehicleShipmentSelector();

        Vehicle_Shipment__c listShipment = selector.selectByIdWithInvoicesAndLineItems(vh.Id, true, true);
        
        System.assertNotEquals(null, listShipment.Id);
    }

}
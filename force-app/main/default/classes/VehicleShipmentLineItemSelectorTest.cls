/*==========================================================================================================================================================================
 * VehicleShipmentLineItemSelectorTest for VehicleShipmentLineItemSelector
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *                DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            24 Aug 2022                        dong.nguyen@aodigy.com                 US-VPO-000023                                          init
 * ========================================================================================================================================================================== 
 */
@isTest
public with sharing class VehicleShipmentLineItemSelectorTest {
    @TestSetup
    static void makeData(){
         //create Supplier
         Account supplier = Test_DataFactory.createAccount(true, 'supplier Account');

         //create Vehicle shipment
         Vehicle_Shipment__c vehicleShipment = Test_DataFactory.createVehicleShipment(true, supplier.Id);

        //create manu1facturer Invoice
        Manufacturer_Invoice__c invoice = Test_DataFactory.createManufacturerInvoice(true);
        
         //create Shipment line item
         Shipment_Line_Item__c shipmentLineItem = Test_DataFactory.createShipmentLineItem(true, vehicleShipment.Id, invoice.Id);
    }

    @isTest
    public static void selectLineItemsNotTaggedToInvoicesByShipmentId_success() {
        Shipment_Line_Item__c sli = [SELECT Id, Vehicle_Shipment__c FROM Shipment_Line_Item__c];
        VehicleShipmentLineItemSelector selector = new VehicleShipmentLineItemSelector();
        List<Shipment_Line_Item__c> listSLI = selector.selectLineItemsNotTaggedToInvoicesByShipmentId(sli.Vehicle_Shipment__c);
        System.assertNotEquals(null, listSLI.size());
    }

    @isTest
    public static void selectByVehicleShipmentIds_success() {
        Shipment_Line_Item__c sli = [SELECT Id, Vehicle_Shipment__c FROM Shipment_Line_Item__c];
        VehicleShipmentLineItemSelector selector = new VehicleShipmentLineItemSelector();
        List<Shipment_Line_Item__c> listSLI = selector.selectByVehicleShipmentIds(new Set<Id>{sli.Vehicle_Shipment__c});
        System.assertNotEquals(null, listSLI.size());
        System.assertEquals(1, listSLI.size());

    }

    @isTest
    public static void selectByIds_success() {
        Shipment_Line_Item__c sli = [SELECT Id, Vehicle_Shipment__c FROM Shipment_Line_Item__c];
        VehicleShipmentLineItemSelector selector = new VehicleShipmentLineItemSelector();
        List<Shipment_Line_Item__c> listSLI = selector.selectByIds(new Set<String>{sli.Id});
        System.assertEquals(1, listSLI.size());
    }

}
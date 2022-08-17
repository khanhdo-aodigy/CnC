public with sharing class ShipmentLineItemsMatchingController
{
    @AuraEnabled(cacheable=true)
    public static VehicleShipmentDetail init(String vehicleShipmentId)
    {
        // TODO: use selector
        try
        {
            VehicleShipmentDetail result = new VehicleShipmentDetail();

            Vehicle_Shipment__c shipment = [SELECT Id, Name, Franchise_Code__c, Stage__c FROM Vehicle_Shipment__c WHERE Id = :vehicleShipmentId];

            List<Shipment_Line_Item__c> shipmentLineItems= [SELECT  Name, Model__c, Model_Year__c, Colour_Code__c, Trim__c, Engine_No__c, Chassis_No__c, 
                                                                    Franchise_Code__c, Manufacturer_Ref_No__c, Production_Month__c
                                                            FROM Shipment_Line_Item__c
                                                            WHERE Vehicle_Shipment__c = :shipment.Id
                                                            ORDER BY CreatedDate ASC
                                                            ];
            //
            List<Vehicle_Master2__c> shipmentMatchedStocks = [ SELECT   Name, Model_Code__c, Model_Year_Code__c, Color_Description__c, Trim_Description__c,
                                                                        Engine_No__c, Chassis__c, Franchise_Code__c, Manufacturer_Ref_No__c, ProductionMonth__c, 
                                                                        Shipment_Line_Item__c
                                                                FROM Vehicle_Master2__c
                                                                WHERE Shipment_Line_Item__r.Vehicle_Shipment__c = :shipment.Id
                                                            ];
            //
            result.shipment                 = shipment;
            result.shipmentLineItems        = shipmentLineItems;
            result.shipmentMatchedStocks    = shipmentMatchedStocks;

            return result;
        }
        catch(Exception e)
        {
            System.debug('ShipmentLineItemsMatchingController::init::Exception Message > ' + e.getMessage());
            System.debug('ShipmentLineItemsMatchingController::init::Exception Stack Trace > ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static void matchingById(String lineItemId, String stockVehicleMasterId)
    {
        // TODO: check stock vehicle master eligibility
        try
        {
            Vehicle_Master2__c stockVehicleMaster = [SELECT Id, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Id = :stockVehicleMasterId];
            
            stockVehicleMaster.Shipment_Line_Item__c = lineItemId;

            // TODO: remove before deploying
            TriggerExclusion.excludeTrigger('Vehicle_Master2__c', true);

            update stockVehicleMaster;
        } catch (Exception e)
        {
            System.debug('ShipmentLineItemsMatchingController::matchingById::Exception Message > ' + e.getMessage());
            System.debug('ShipmentLineItemsMatchingController::matchingById::Exception Stack Trace > ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void shipmentsAutoMatching(String vehicleShipmentId)
    {
        VehicleShipmentServices.shipmentsAutoMatching(new Set<String> { vehicleShipmentId });
    }

    public class VehicleShipmentDetail
    {
        @AuraEnabled
        public Vehicle_Shipment__c shipment;

        @AuraEnabled
        public List<Shipment_Line_Item__c> shipmentLineItems = new List<Shipment_Line_Item__c>();

        @AuraEnabled
        public List<Vehicle_Master2__c> shipmentMatchedStocks = new List<Vehicle_Master2__c>();
    }
}

/*==========================================================================================================================================================================
 * Controller class for Shipment Matching component
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          18 Aug 2022                         dangphap.mai@aodigy.com             US-Ship-000008                                      init
 *          13 Oct 2022                         dangphap.mai@aodigy.com             LOG-0018                                            added shipmentUnmatchingById
 * ========================================================================================================================================================================== 
 */
public with sharing class ShipmentLineItemsMatchingController
{
    /**
     * ============================================================================================
     * Get vehicle shipment details on component init
     * @param shipmentIds: target vehicle shipment ids
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    @AuraEnabled(cacheable=true)
    public static VehicleShipmentDetail init(String vehicleShipmentId)
    {
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
                                                                        Shipment_Line_Item__c, Vehicle_Status__c, Vehicle_Purchase_Status__c
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
            System.debug('ShipmentLineItemsMatchingController :: init :: Exception Message > ' + e.getMessage());
            System.debug('ShipmentLineItemsMatchingController :: init :: Exception Stack Trace > ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    /**
     * ============================================================================================
     * Manual match shipment line item and stock vehicle master by Id
     * @param shipmentLineItemId: shipment line item id for matching
     * @param stockVehicleMasterId: stock vehicle master id for matching
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    @AuraEnabled
    public static void shipmentManualMatchById(String shipmentLineItemId, String stockVehicleMasterId)
    {
        try
        {
            VehicleShipmentServices.shipmentManualMatchById(shipmentLineItemId, stockVehicleMasterId);
        }
        catch (Exception e)
        {
            System.debug('ShipmentLineItemsMatchingController :: shipmentManualMatchById :: Exception Message > ' + e.getMessage());
            System.debug('ShipmentLineItemsMatchingController :: shipmentManualMatchById :: Exception Stack Trace > ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * ============================================================================================
     * Unmatch a shipment line item from stock vehicle master and revert the post matching logic
     * @param shipmentLineItemId: shipment line item id for unmatching
     * @param stockVehicleMasterId: stockv vehicle id for unmatching
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          13 Oct 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    @AuraEnabled
    public static void shipmentUnmatchingById(String shipmentLineItemId, String stockVehicleMasterId)
    {
        try
        {
            VehicleShipmentServices.shipmentUnmatchingById(shipmentLineItemId, stockVehicleMasterId);
        }
        catch (Exception e)
        {
            System.debug('ShipmentLineItemsMatchingController :: shipmentUnmatchingById :: Exception Message > ' + e.getMessage());
            System.debug('ShipmentLineItemsMatchingController :: shipmentUnmatchingById :: Exception Stack Trace > ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * ============================================================================================
     * Auto match shipment line items
     * @param vehicleShipmentId: shipment id to match
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    @AuraEnabled
    public static String shipmentsAutoMatching(String vehicleShipmentId)
    {
        try
        {
            return VehicleShipmentServices.shipmentsAutoMatching(new Set<String> { vehicleShipmentId });
        }
        catch (Exception e)
        {
            System.debug('ShipmentLineItemsMatchingController :: shipmentsAutoMatching :: Exception Message > ' + e.getMessage());
            System.debug('ShipmentLineItemsMatchingController :: shipmentsAutoMatching :: Exception Stack Trace > ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
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
public with sharing class VehicleShipmentServices
{
    /**
     * 
     */
    public static void shipmentsAutoMatching(Set<String> shipmentIds)
    {
        System.debug('shipmentIds :: ' + shipmentIds);
        // TODO: use selector

        // get stock vehicle master that have been matched
        List<Vehicle_Master2__c> shipmentMatchedStocks = [ SELECT   Name, Model_Code__c, Model_Year_Code__c, Color_Description__c, Trim_Description__c,
                                                                    Engine_No__c, Chassis__c, Franchise_Code__c, Manufacturer_Ref_No__c, ProductionMonth__c, 
                                                                    Shipment_Line_Item__c
                                                            FROM Vehicle_Master2__c
                                                            WHERE Shipment_Line_Item__r.Vehicle_Shipment__c IN :shipmentIds
                                                        ];
        //
        // get set of line item that have been matched
        Set<Id> matchedShipmentLineItemIds = new Set<Id>();
        for (Vehicle_Master2__c shipmentMatchedStock : shipmentMatchedStocks)
        {
            matchedShipmentLineItemIds.add(shipmentMatchedStock.Shipment_Line_Item__c);
        }

        System.debug('matchedShipmentLineItemIds :: ' + matchedShipmentLineItemIds);

        // get shipment line items need to match
        List<Shipment_Line_Item__c> shipmentLineItems = [SELECT Name, Model__c, Model_Year__c, Colour_Code__c, Trim__c, Engine_No__c, Chassis_No__c, 
                                                                Franchise_Code__c, Manufacturer_Ref_No__c, Production_Month__c
                                                        FROM Shipment_Line_Item__c
                                                        WHERE Vehicle_Shipment__c IN :shipmentIds
                                                        AND Id NOT IN :matchedShipmentLineItemIds];
        //
        if (shipmentLineItems.size() == 0)
        {
            throw new AuraHandledException('There is no eligible shipment line item for matching');
        }

        // start getting eligible stocks for matching
        List<Vehicle_Master2__c> eligibleVehicleMasterStocks = [SELECT  Id, Model_Code__c, Color_Code__c, Trim_Code__c, Production_Month__c, Shipment_Line_Item__c,
                                                                        Vehicle_Purchase_Status__c, Purchase_Order_Status__c, Vehicle_Status__c, CreatedDate,
                                                                        Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name
                                                                FROM Vehicle_Master2__c
                                                                WHERE Shipment_Line_Item__c = NULL
                                                                AND (
                                                                        (
                                                                            Vehicle_Purchase_Order_Line_Items__c != NULL
                                                                            AND Vehicle_Purchase_Status__c != 'SCL_Cancel'
                                                                            AND Vehicle_Purchase_Status__c != NULL
                                                                            AND Vehicle_Purchase_Status__c != ''
                                                                        )
                                                                        OR
                                                                        (
                                                                            Vehicle_Status__c = 'RESRV'
                                                                        )
                                                                    )
                                                                ORDER BY CreatedDate ASC];
        //
        if (eligibleVehicleMasterStocks.size() == 0)
        {
            throw new AuraHandledException('There is no eligible stock vehicle master for matching');
        }

        // tier 1 eligible stocks: Vehicle_Purchase_Status__c == 'Arrived'
        // tier 2 eligible stocks: Vehicle_Purchase_Status__c == 'In Shipment'
        // tier 3 eligible stocks: Vehicle_Purchase_Status__c == 'Confirmed'
        // tier 4 eligible stocks: Vehicle_Status__c == 'RESRV'
        // tier 5 eligible stocks: remaining
        Map<Id, Vehicle_Master2__c> eligibleTier1 = new Map<Id, Vehicle_Master2__c>();
        Map<Id, Vehicle_Master2__c> eligibleTier2 = new Map<Id, Vehicle_Master2__c>();
        Map<Id, Vehicle_Master2__c> eligibleTier3 = new Map<Id, Vehicle_Master2__c>();
        Map<Id, Vehicle_Master2__c> eligibleTier4 = new Map<Id, Vehicle_Master2__c>();
        Map<Id, Vehicle_Master2__c> eligibleTier5 = new Map<Id, Vehicle_Master2__c>();

        for (Vehicle_Master2__c eligibleVehicleMasterStock : eligibleVehicleMasterStocks)
        {
            if (eligibleVehicleMasterStock.Vehicle_Purchase_Status__c == 'Arrived')
            {
                eligibleTier1.put(eligibleVehicleMasterStock.Id, eligibleVehicleMasterStock);
            }
            else if (eligibleVehicleMasterStock.Vehicle_Purchase_Status__c == 'In Shipment')
            {
                eligibleTier2.put(eligibleVehicleMasterStock.Id, eligibleVehicleMasterStock);
            }
            else if (eligibleVehicleMasterStock.Vehicle_Purchase_Status__c == 'Confirmed')
            {
                eligibleTier3.put(eligibleVehicleMasterStock.Id, eligibleVehicleMasterStock);
            }
            else if (eligibleVehicleMasterStock.Vehicle_Status__c == 'RESRV')
            {
                eligibleTier4.put(eligibleVehicleMasterStock.Id, eligibleVehicleMasterStock);
            }
            else
            {
                eligibleTier5.put(eligibleVehicleMasterStock.Id, eligibleVehicleMasterStock);
            }
        }

        if (eligibleTier1.size() == 0 && eligibleTier2.size() == 0 && eligibleTier3.size() == 0 && eligibleTier4.size() == 0 && eligibleTier5.size() == 0)
        {
            throw new AuraHandledException('There is no eligible stock vehicle master for matching');
        }

        // put in an ordered list
        List<Vehicle_Master2__c> orderedEligibleVehicleMasterStocks = new List<Vehicle_Master2__c>();
        orderedEligibleVehicleMasterStocks.addAll(eligibleTier1.values());
        orderedEligibleVehicleMasterStocks.addAll(eligibleTier2.values());
        orderedEligibleVehicleMasterStocks.addAll(eligibleTier3.values());
        orderedEligibleVehicleMasterStocks.addAll(eligibleTier4.values());
        orderedEligibleVehicleMasterStocks.addAll(eligibleTier5.values());

        // start matching
        Map<Id, Vehicle_Master2__c> updatingStockVehicleMasters = new Map<Id, Vehicle_Master2__c>();

        for (Shipment_Line_Item__c shipmentLineItem : shipmentLineItems)
        {
            for (Vehicle_Master2__c orderedEligibleVehicleMasterStock : orderedEligibleVehicleMasterStocks)
            {
                Boolean matchModel              = orderedEligibleVehicleMasterStock.Model_Code__r.Name == shipmentLineItem.Model__c;
                Boolean matchColor              = orderedEligibleVehicleMasterStock.Color_Code__r.ColorCode__c == shipmentLineItem.Colour_Code__c;
                Boolean matchTrim               = orderedEligibleVehicleMasterStock.Trim_Code__r.Name == shipmentLineItem.Trim__c;
                Boolean matchProductionMonth    = orderedEligibleVehicleMasterStock.Production_Month__c == shipmentLineItem.Production_Month__c;

                if (matchModel && matchColor && matchTrim && matchProductionMonth && !updatingStockVehicleMasters.keySet().contains(orderedEligibleVehicleMasterStock.Id))
                {
                    orderedEligibleVehicleMasterStock.Shipment_Line_Item__c = shipmentLineItem.Id;
                    updatingStockVehicleMasters.put(orderedEligibleVehicleMasterStock.Id, orderedEligibleVehicleMasterStock);
                    break;
                }
            }
        }

        if (updatingStockVehicleMasters.size() > 0)
        {
            // TODO: remove before deploying
            TriggerExclusion.excludeTrigger('Vehicle_Master2__c', true);
            update updatingStockVehicleMasters.values();
        }
    }
}

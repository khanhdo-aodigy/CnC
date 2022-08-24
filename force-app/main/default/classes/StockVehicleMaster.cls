/*==========================================================================================================================================================================
 * Domain class for Stock Vehicle Master entity
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          23 Aug 2022                         dangphap.mai@aodigy.com             US-Ship-000013                                      init
 * ========================================================================================================================================================================== 
 */
public inherited sharing class StockVehicleMaster extends ADGLIB_SObjectDomain
{
    public StockVehicleMaster(List<Vehicle_Master2__c> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new StockVehicleMaster(sObjectList);
		}
	}

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        Map<Id, Vehicle_Master2__c> beforeUpdateVehicles = (Map<Id, Vehicle_Master2__c>) existingRecords;
        
        Map<Id, Vehicle_Master2__c> afterUpdateVehicles = (Map<Id, Vehicle_Master2__c>) Trigger.newMap;

        onVehicleShipmentMatching(beforeUpdateVehicles, afterUpdateVehicles);
    }

    public override void onBeforeInsert()
    {
        List<Vehicle_Master2__c> insertingVehicles = (List<Vehicle_Master2__c>) Trigger.new;

        onVehicleShipmentMatching(insertingVehicles);
    }

    /**
     * ==================================================================================================================
     * Ensure a Shipment Line Item can have only one Stock Vehicle Master link to it.This method is invoked before update
     * @param beforeUpdateVehicles: values of records before update
     * @param afterUpdateVehicles: values of records after update
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ==================================================================================================================
     */
    private void onVehicleShipmentMatching(Map<Id, Vehicle_Master2__c> beforeUpdateVehicles, Map<Id, Vehicle_Master2__c> afterUpdateVehicles)
    {
        // get vehicles with Shipment_Line_Item__c field changed
        Map<Id, Vehicle_Master2__c> applicableVehicles = new Map<Id, Vehicle_Master2__c>();

        for (Id vehicleId : afterUpdateVehicles.keySet())
        {
            if (beforeUpdateVehicles.get(vehicleId).Shipment_Line_Item__c != afterUpdateVehicles.get(vehicleId).Shipment_Line_Item__c)
            {
                applicableVehicles.put(vehicleId, afterUpdateVehicles.get(vehicleId));
            }
        }

        if (applicableVehicles.size() == 0)
        {
            return;
        }

        // get parent shipment line item ids
        Set<Id> shipmentLineItemIds = new Set<Id>();

        for (Vehicle_Master2__c vehicle : applicableVehicles.values())
        {
            if (String.isNotBlank(vehicle.Shipment_Line_Item__c))
            {
                shipmentLineItemIds.add(vehicle.Shipment_Line_Item__c);
            }
        }

        // get all stock vehicle master link to @shipmentLineItemIds
        Map<Id, Vehicle_Master2__c> matchedVehicles = new Map<Id, Vehicle_Master2__c> ([SELECT Id, Name, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Shipment_Line_Item__c IN :shipmentLineItemIds]);

        // System.debug('matchedVehicle before ::' + JSON.serialize(matchedVehicles));

        // store the latest content for assessing
        List<Vehicle_Master2__c> updatedVehicles = new List<Vehicle_Master2__c>();

        // loop @matchedVehicles and get latest content from @afterUpdateVehicles
        for (Vehicle_Master2__c matchedVehicle : matchedVehicles.values())
        {
            Vehicle_Master2__c afterUpdateVehicle = afterUpdateVehicles.get(matchedVehicle.Id);

            if (afterUpdateVehicle != null)
            {
                matchedVehicle = afterUpdateVehicle.clone(true, false, true, true);
            }

            updatedVehicles.add(matchedVehicle);
        }

        // loop @afterUpdateVehicles to add new content (if any)
        for (Vehicle_Master2__c afterUpdateVehicle : afterUpdateVehicles.values())
        {
            if (!matchedVehicles.keySet().contains(afterUpdateVehicle.Id))
            {
                updatedVehicles.add(afterUpdateVehicle);
            }
        }

        // System.debug('matchedVehicle after ::' + JSON.serialize(matchedVehicles));

        // arrange the updated vehicles into a map by Shipment_Line_Item__c and start assessing
        Map<Id, List<Vehicle_Master2__c>> updatedVehiclesByShipmentLineItemId = this.groupVehiclesByParent(updatedVehicles, 'Shipment_Line_Item__c');

        for (List<Vehicle_Master2__c> vehicles : updatedVehiclesByShipmentLineItemId.values())
        {
            if (vehicles != null && vehicles.size() > 1)
            {
                for (Vehicle_Master2__c errorVehicle : vehicles)
                {
                    afterUpdateVehicles.get(errorVehicle.Id)?.addError(Vehicle_Master2__c.Shipment_Line_Item__c,'This shipment line item already have a linked vehicle');
                }
            }
        }
    }

    /**
     * ==================================================================================================================
     * Ensure a Shipment Line Item can have only one Stock Vehicle Master link to it.This method is invoked before insert
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ==================================================================================================================
     */
    private void onVehicleShipmentMatching(List<Vehicle_Master2__c> insertingVehicles)
    {
        // get vehicles with Shipment_Line_Item__c populated
        Map<Id, Vehicle_Master2__c> applicableVehicles = new Map<Id, Vehicle_Master2__c>();

        for (Vehicle_Master2__c insertingVehicle: insertingVehicles)
        {
            if (String.isNotBlank(insertingVehicle.Shipment_Line_Item__c))
            {
                applicableVehicles.put(insertingVehicle.Id, insertingVehicle);
            }
        }

        if (applicableVehicles.size() == 0)
        {
            return;
        }

        // arrange matching stock by shipment line item id
        Map<Id, List<Vehicle_Master2__c>> matchingStocksByShipmentLineItemId = this.groupVehiclesByParent(applicableVehicles.values(), 'Shipment_Line_Item__c');

        // check if there are any 2 inserting stocks link to same shipment line item
        for (List<Vehicle_Master2__c> matchingStocks : matchingStocksByShipmentLineItemId.values())
        {
            if (matchingStocks.size() > 1)
            {
                this.addErrorToMultipleVehicles(matchingStocks, Vehicle_Master2__c.Shipment_Line_Item__c, 'This shipment line item already have a linked vehicle');
            }
        }

        // check if inserting stock link to a matched shipment line item
        List<Shipment_Line_Item__c> matchingShipmentLineItems = [   SELECT Id, (SELECT Id FROM Stock_Vehicle_Masters__r)
                                                                    FROM Shipment_Line_Item__c
                                                                    WHERE Id IN :matchingStocksByShipmentLineItemId.keySet()
                                                                ];

        for (Shipment_Line_Item__c matchingShipmentLineItem : matchingShipmentLineItems)
        {
            // currently matched stocks
            List<Vehicle_Master2__c> matchedStocks = matchingShipmentLineItem.Stock_Vehicle_Masters__r;

            // matching new stocks
            List<Vehicle_Master2__c> matchingStocks = matchingStocksByShipmentLineItemId.get(matchingShipmentLineItem.Id);

            // if @matchedStocks already exist, add error to @matchingStocks
            if (matchedStocks != null && matchedStocks.size() > 0)
            {
                if (matchingStocks != null && matchingStocks.size() > 0)
                {
                    this.addErrorToMultipleVehicles(matchingStocks, Vehicle_Master2__c.Shipment_Line_Item__c, 'This shipment line item already have a linked vehicle');
                }
            }
        }
    }

    /**
     * ==============================================================================================================================================
     * Group @stocks by a @groupingField
     * @param stocks: stock vehicle master for grouping
     * @param groupingField: key field for grouping. Developer should make sure this is a lookup field. This method do not check for that assumption
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ===============================================================================================================================================
     */
    private Map<Id, List<Vehicle_Master2__c>> groupVehiclesByParent(List<Vehicle_Master2__c> stocks, String groupingField)
    {
        Map<Id, List<Vehicle_Master2__c>> result = new Map<Id, List<Vehicle_Master2__c>>();

        for (Vehicle_Master2__c stock : stocks)
        {
            Object groupingFieldValueAsObject = stock.get(groupingField);
            
            if (groupingFieldValueAsObject == null)
            {
                continue;
            }

            String key = String.valueOf(groupingFieldValueAsObject);
            
            if (String.isNotBlank(key))
            {
                if (result.keySet().contains(key))
                {
                    result.get(key).add(stock);
                }
                else
                {
                    result.put(key, new List<Vehicle_Master2__c> { stock });
                }
            }
        }

        return result;
    }

    /**
     * ==============================================================================================================================================
     * Add @error to @stocks
     * @param stocks: stock vehicle master for error adding
     * @param error: error message
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ===============================================================================================================================================
     */
    private void addErrorToMultipleVehicles(List<Vehicle_Master2__c> stocks, String error)
    {
        for (Vehicle_Master2__c stock : stocks)
        {
            stock.addError(error);
        }
    }

    /**
     * ==============================================================================================================================================
     * Add @error to @stocks at @field
     * @param stocks: stock vehicle master for error adding
     * @param error: error message
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ===============================================================================================================================================
     */
    private void addErrorToMultipleVehicles(List<Vehicle_Master2__c> stocks, Schema.SObjectField field, String error)
    {
        for (Vehicle_Master2__c stock : stocks)
        {
            stock.addError(field, error);
        }
    }
}

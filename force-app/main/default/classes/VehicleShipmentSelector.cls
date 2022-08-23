/*==========================================================================================================================================================================
 * Selector class for Vehicle Shipment entity
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *              21 Aug 2022                         dangphap.mai@aodigy.com             US-Ship-000008                                      init
 * ========================================================================================================================================================================== 
 */
public with sharing class VehicleShipmentSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType()
    {
        return Vehicle_Shipment__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    /**
     * Select vehicle shipments by record @withLineItems and @withMatchedVehicle as optional
     * @param orderIds: vehicle shipment ids
     * @param withLineItems: include shipment line items
     * @param withMatchedVehicle: include matched stock vehicle master
     */
    public List<Vehicle_Shipment__c> selectByIds(Set<Id> orderIds, Boolean withLineItems, Boolean withMatchedVehicle)
    {
        return new List<Vehicle_Shipment__c>();
    }
}

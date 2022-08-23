/*==========================================================================================================================================================================
 * Selector class for Shipment Line Item Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            18 Aug 2022                        phan.thu@aodigy.com                 US-VPO-000023                                              init
 * ========================================================================================================================================================================== 
 */

public inherited sharing class VehicleShipmentLineItemSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType()
    {
        return Shipment_Line_Item__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    public List<Shipment_Line_Item__c> selectLineItemsNotTaggedToInvoicesByShipmentId(String vehicleShipmentId)
    {
        adglib_QueryFactory query = newQueryFactory();      
        query.setCondition('Vehicle_Shipment__c =: vehicleShipmentId AND Invoice_No__c = NULL');
     
        return (List<Shipment_Line_Item__c>)(Database.query(query.toSOQL()));
    }
}
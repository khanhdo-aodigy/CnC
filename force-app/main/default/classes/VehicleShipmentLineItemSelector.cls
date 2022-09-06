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

    public List<Shipment_Line_Item__c> selectByVehicleShipmentIds(Set<Id> shipmentIds)
    {
        adglib_QueryFactory query = newQueryFactory();  
        query.selectField('TN_HS_Code__r.Name');    
        query.setCondition('Vehicle_Shipment__c IN: shipmentIds');
     
        return (List<Shipment_Line_Item__c>)(Database.query(query.toSOQL()));
    }

    public List<Shipment_Line_Item__c> selectByIds(Set<String> Ids)
    {
        adglib_QueryFactory query = newQueryFactory();  
        query.selectField('TN_HS_Code__r.Name');  
        query.selectField('Invoice_No__r.Invoice_No__c');  
        query.selectField('Invoice_No__r.TN_Total_Dutiable_Qty__c');
        query.selectField('Invoice_No__r.TN_Total_Dutiable_Qty_UOM__c');
        query.selectField('Invoice_No__r.Total_Outer_Pack__c');
        query.selectField('Invoice_No__r.Total_Outer_Pack_UOM__c');
        query.selectField('Vehicle_Shipment__r.Brand__c');
        query.selectField('Vehicle_Shipment__r.Country_of_Origin_Code__c');
        query.setCondition('Id IN: Ids');

        return (List<Shipment_Line_Item__c>)(Database.query(query.toSOQL()));
    }
}
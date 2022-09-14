/*==========================================================================================================================================================================
 * Selector class for Inward Declaration Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            29 Aug 2022                        phan.thu@aodigy.com                 US-VPO-000027                                              init
 * ========================================================================================================================================================================== 
 */

public inherited sharing class InwardDeclarationSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType()
    {
        return Inward_Declaration__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    public Inward_Declaration__c selectByRecordTypeAndVehicleShipmentId(String recordTypeName, Id vehicleShipmentId)
    {
        adglib_QueryFactory query = newQueryFactory();  
        query.selectField('Declarant_Person__r.Name');
        query.selectField('TN_Declarant_Name__r.Name');
        query.selectField('TN_Inward_Carrier_Name__r.Name');
        query.selectField('TN_Importer_Name__r.Name');
        query.selectField('TN_Release_Location_Name__r.Name');
        query.selectField('TN_Receipt_Location_Name__r.Name');
        query.selectField('Supplier_Account__r.Name');
        query.selectField('Vehicle_Shipment__r.Name');
        query.setCondition('Vehicle_Shipment__c =: vehicleShipmentId AND RecordType.DeveloperName =: recordTypeName');

        return Database.query(query.toSOQL()) <> null ? (Inward_Declaration__c) Database.query(query.toSOQL()).get(0) : null;
    }

    public List<Inward_Declaration__c> selectByIdsWithInvoices(Set<Id> inwardDeclarationIds, Boolean withInvoices)
    {
        adglib_QueryFactory inwardDeclarationQuery = newQueryFactory();  
        inwardDeclarationQuery.selectField('Declarant_Person__r.Name');
        inwardDeclarationQuery.selectField('TN_Declarant_Name__r.Name');
        inwardDeclarationQuery.selectField('TN_Inward_Carrier_Name__r.Name');
        inwardDeclarationQuery.selectField('TN_Importer_Name__r.Name');
        inwardDeclarationQuery.selectField('TN_Release_Location_Name__r.Name');
        inwardDeclarationQuery.selectField('TN_Receipt_Location_Name__r.Name');
        inwardDeclarationQuery.selectField('Supplier_Account__r.Name');
        inwardDeclarationQuery.setCondition('Id IN: inwardDeclarationIds');

        if (withInvoices)
        {
            ADGLIB_QueryFactory manufacturerInvoiceQueryFactory  = inwardDeclarationQuery.subselectQuery(Manufacturer_Invoice__c.sObjectType);
            manufacturerInvoiceQueryFactory.selectFields(new ManufacturerInvoiceSelector().getSObjectFieldList());               
        }

        return (List<Inward_Declaration__c>) Database.query(inwardDeclarationQuery.toSOQL());
    }

    public List<Inward_Declaration__c> selectTodayExistingInwardDeclarations()
    {
        adglib_QueryFactory inwardDeclarationQuery = newQueryFactory();  
        inwardDeclarationQuery.setOrdering('Inward_Declaration_Seq_No__c', ADGLIB_QueryFactory.SortOrder.DESCENDING, true);
        inwardDeclarationQuery.setCondition('CreatedDate = TODAY');

        return (List<Inward_Declaration__c>) Database.query(inwardDeclarationQuery.toSOQL());
    }
}
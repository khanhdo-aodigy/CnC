/*==========================================================================================================================================================================
 * Selector class for Manufacturer Invoice Entity
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           24 August 2022                      nam@aodigy.com                                                                               init
 *           25 August 2022                      phan.thu@aodigy.com                US-Ship-000027                                            Added selectManufacturerInvoicesByVehicleShipmentIds method  
 *           05 September 2022                   phan.thu@aodigy.com                US-Ship-000006                                            Added selectByInvoiceNo method
 * ========================================================================================================================================================================== 
 */
public inherited sharing class ManufacturerInvoiceSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType()
    {
        return Manufacturer_Invoice__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    /**
     * select manufacturer invoice by invoice Ids
     * @param invoiceIds: list of targeted Manufacturer Invoice's Id
     */
    public List<Manufacturer_Invoice__c> selectManufacturerInvoiceWithSLIByIds(Set<Id> invoiceIds)
    {
        Boolean assertCRUD                              = false;    // by pass CRUD
        Boolean enforceFLS                              = false;    // by pass FLS
        Boolean includeSelectorFields                   = true;     // include fields from getSObjectFieldList()
        adglib_QueryFactory invoiceQueryFactory         = this.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields).setCondition('Id IN :invoiceIds');
        
        // select shipment line items
        adglib_QueryFactory shipLineItemsQueryFactory   = invoiceQueryFactory.subselectQuery(Shipment_Line_Item__c.sObjectType);
        shipLineItemsQueryFactory.selectField('Id');
        shipLineItemsQueryFactory.selectField('Name');
        shipLineItemsQueryFactory.selectField('Shipment_Line_Item_Sequence_No__c');
        shipLineItemsQueryFactory.setOrdering('Name', ADGLIB_QueryFactory.SortOrder.ASCENDING, true);
       
        return Database.query(invoiceQueryFactory.toSOQL());
    }

    /**
     * Select Manufacturer Invoice by Vehicle Shipment Ids
     * @param shipmentIds: set of Vehicle Shipment Ids
    */
    public List<Manufacturer_Invoice__c> selectManufacturerInvoicesByVehicleShipmentIds(Set<Id> shipmentIds)
    {
        adglib_QueryFactory query = newQueryFactory();  
        query.selectField('Vehicle_Shipment__r.Supplier_Account__r.Name');    
        query.setCondition('Vehicle_Shipment__c IN: shipmentIds');
     
        return (List<Manufacturer_Invoice__c>)(Database.query(query.toSOQL()));
    }

    /**
     * Select Manufacturer Invoice by Invoice No. Set
     * @param shipmentIds: set of Invoice No.
    */
    public List<Manufacturer_Invoice__c> selectManufacturerInvoicesByInvoiceNos(Set<String> invoiceNos)
    {
        Boolean assertCRUD            = false;    // by pass CRUD
        Boolean enforceFLS            = false;    // by pass FLS
        Boolean includeSelectorFields = false;     // include fields from getSObjectFieldList()
        adglib_QueryFactory query     = this.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields).setCondition('Invoice_No__c IN: invoiceNos');
        query.selectField('Invoice_No__c');    
        query.selectField('Total_Invoice_Amount__c');
        query.selectField('Total_Invoice_Amount_Currency_Code__c');
        query.selectField('Invoice_Date__c');
     
        return (List<Manufacturer_Invoice__c>)(Database.query(query.toSOQL()));
    }
}
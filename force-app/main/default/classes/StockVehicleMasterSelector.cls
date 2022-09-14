/*==========================================================================================================================================================================
 * Selector class for Stock Vehicle Master entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *               XXX                                XXX                                   XXX                                            Init
 *           05 Sep 2022                       phan.thu@aodigy.com                    US-Ship-000035                                     Added getStockVehicleMastersForDutyRequest, getStockVehicleMastersByInvoiceIds methods
 *           29 August 2022                    nhung.cao@aodigy.com                   US-TMS-000018                                      Added selectRecordsByForUpdateER method
 *           29 August 2022                    nhung.cao@aodigy.com                   US-TMS-000018                                      Added getRecordsByIds method
 * 
 *  ========================================================================================================================================================================== 
 */

public inherited sharing class StockVehicleMasterSelector extends ADGLIB_SObjectSelector 
{
public inherited sharing class StockVehicleMasterSelector extends ADGLIB_SObjectSelector 
{
    public List<Schema.SObjectField> getSObjectFieldList() 
    
    {
        return new List<Schema.SObjectField> 
        
        {
            Vehicle_Master2__c.Id,
            Vehicle_Master2__c.Name,
            Vehicle_Master2__c.System_Commcase__c, 
            Vehicle_Master2__c.Vehicle_Purchase_Status__c,
            Vehicle_Master2__c.FOB_Done__c,
            Vehicle_Master2__c.Duty_Done__c,
            Vehicle_Master2__c.Item_Group_Code__c,
            Vehicle_Master2__c.Vessel_Code__c,
            Vehicle_Master2__c.Vessel_Name__c,
            Vehicle_Master2__c.Invoice_No__c,
            Vehicle_Master2__c.Chassis__c,
            Vehicle_Master2__c.Engine_No__c,
            Vehicle_Master2__c.Vehicle_Status__c,
            Vehicle_Master2__c.TN_Item_Description__c,
            Vehicle_Master2__c.hs_qty_value__c,
            Vehicle_Master2__c.TN_HS_Unit__c,
            Vehicle_Master2__c.tot_dutiable_qty_uom__c,
            Vehicle_Master2__c.tot_dutiable_qty_value__c,
            Vehicle_Master2__c.FOB_Amount__c,
            Vehicle_Master2__c.FOB_Amount_Currency_Code__c,
            Vehicle_Master2__c.item_cif_fob_amt__c,
            Vehicle_Master2__c.outer_qty_value__c,
            Vehicle_Master2__c.outer_qty_uom__c,
            Vehicle_Master2__c.gst_rate__c,
            Vehicle_Master2__c.gst_amt__c,
            Vehicle_Master2__c.excise_duty_uom__c,
            Vehicle_Master2__c.excise_duty_amt__c,
            Vehicle_Master2__c.excise_duty_rate__c,
            Vehicle_Master2__c.Vehicle_Type__c,
            Vehicle_Master2__c.customs_duty_amt__c,
            Vehicle_Master2__c.customs_duty_uom__c,
            Vehicle_Master2__c.Product_Code__c, 
            Vehicle_Master2__c.prod_qty_uom__c, 
            Vehicle_Master2__c.customs_duty_amt__c,
            Vehicle_Master2__c.customs_duty_uom__c,
            Vehicle_Master2__c.customs_duty_rate__c,
            Vehicle_Master2__c.Franchise_Code__c
		};
    }    
    
    public Schema.SObjectType getSObjectType() 
    
    {
        return Vehicle_Master2__c.sObjectType;
    }    
    
    public List<Vehicle_Master2__c> selectStockVehicleMastersBySystemCommcases(Set<String> systemCommcases) 
    {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Inward_Declaration_Invoice__c IN: invoiceIds');
        query.selectField('Name');
        query.selectField('Inward_Declaration_Invoice__r.Name');
        query.selectField('Vehicle_Status__c');
        query.selectField('Chassis__c');
        query.selectField('Product_Code__r.Product_Code__c');
        query.selectField('TN_HS_Code__r.Name');
        
        return Database.query(query.toSOQL());
    }

    public List<Vehicle_Master2__c> selectRecordsByForUpdateER(List<Id> fobCtrLineItemIds) 
    {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('Average_Exchange_Rate__c');
        query.setCondition('Id IN :fobCtrLineItemIds');

        FOBContractLineItemsSelector fobCtrLineItemQuery = new FOBContractLineItemsSelector();
        adglib_QueryFactory fobCtrLineItemQueryFactory = fobCtrLineItemQuery.newQueryFactory(false);
        fobCtrLineItemQueryFactory.selectField('Id');
        fobCtrLineItemQueryFactory.selectField('Average_Exchange_Rate__c');
        fobCtrLineItemQuery.addQueryFactorySubselect(query, 'Forward_Contract_FOB_Line_Items__r');
        
        return Database.query(query.toSOQL());
    }

    public List<Vehicle_Master2__c> getRecordsByIds(List<Id> Ids) 
    {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('TN_HS_Code__r.Name');
        query.selectField('Product_Code__r.Product_Code__c');
        query.selectField('Vehicle_Shipment__r.Country_of_Origin_Code__c');
        query.selectField('Vehicle_Shipment__r.Brand__c');
        query.selectField('Inward_Declaration_Invoice__r.TN_Total_Dutiable_Qty__c');
        query.selectField('Inward_Declaration_Invoice__r.TN_Total_Dutiable_Qty_UOM__c');
        query.setCondition('Id In :Ids');
        
        return Database.query(query.toSOQL());
    }

    public List<Vehicle_Master2__c> getStockVehicleMastersForDutyRequest()
    {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('(Duty_Request_Date__c = THIS_MONTH OR Duty_Request_Date__c = NEXT_MONTH) AND Inward_Declaration_Invoice__c = NULL');
        query.setOrdering('Duty_Request_Date__c', ADGLIB_QueryFactory.SortOrder.ASCENDING);
        query.selectField('Name');
        query.selectField('Duty_Request_Date__c');
        query.selectField('Inward_Declaration_Invoice__r.Name');
        query.selectField('Vehicle_Status__c');
        query.selectField('Reservation_No__c');
        query.selectField('Agreement_No__c');
        query.selectField('Chassis__c');
        query.selectField('Trim_Code__r.Name');
        query.selectField('Color_Code__r.Name');
        query.selectField('Model_Code__r.Name'); 
        
        return Database.query(query.toSOQL());
    }

    public List<Vehicle_Master2__c> getStockVehicleMastersByInvoiceIds (Set<Id> invoiceIds)
    {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Inward_Declaration_Invoice__c IN: invoiceIds');
        query.selectField('Name');
        query.selectField('Inward_Declaration_Invoice__r.Name');
        query.selectField('Vehicle_Status__c');
        query.selectField('Chassis__c');
        query.selectField('Product_Code__r.Product_Code__c');
        query.selectField('TN_HS_Code__r.Name');
        
        return Database.query(query.toSOQL());
    }
}
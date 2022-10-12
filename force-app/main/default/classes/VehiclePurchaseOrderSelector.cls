/*==========================================================================================================================================================================
 * Selector class for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      27 July 2022                        dangphap.mai@aodigy.com                 US-VPO-000016                                              init
 *      23 August 2022                      nhung.cao@aodigy.com                    US-TMS-0001
 * ========================================================================================================================================================================== 
 */
public inherited sharing class VehiclePurchaseOrderSelector extends ADGLIB_SObjectSelector
{
    public VehiclePurchaseOrderSelector()
    {

    }

    public Schema.SObjectType getSObjectType()
    {
        return Vehicle_Purchase_Order__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        // return new List<Schema.SObjectField>
        // {
        //     Vehicle_Purchase_Order__c.Currency_Code__c,
        //     Vehicle_Purchase_Order__c.Franchise_Code__c,
        //     Vehicle_Purchase_Order__c.PI_Uploaded__c,
        //     Vehicle_Purchase_Order__c.PO_Approved_Date__c,
        //     Vehicle_Purchase_Order__c.Production_Month__c,
        //     Vehicle_Purchase_Order__c.Remarks__c,
        //     Vehicle_Purchase_Order__c.Stage__c,
        //     Vehicle_Purchase_Order__c.Supplier_Account__c,
        //     Vehicle_Purchase_Order__c.Total_PO_Value__c,
        //     Vehicle_Purchase_Order__c.Total_Units_Confirmed__c,
        //     Vehicle_Purchase_Order__c.Total_Units_Ordered__c,
        //     Vehicle_Purchase_Order__c.Name,
        //     Vehicle_Purchase_Order__c.OwnerId,
        //     Vehicle_Purchase_Order__c.LastModifiedById,
        //     Vehicle_Purchase_Order__c.CreatedById
        // };

        return getSObjectType().getDescribe().fields.getMap().values();
    }

    /**
     * select vehicle purchase order together with line items by order Ids
     * @param orderIds: list of targeted Vehicle Purchase Order's Id
     */
    public List<Vehicle_Purchase_Order__c> selectByIdsWithLineItems(Set<Id> orderIds)
    {
        Boolean assertCRUD                              = false;    // by pass CRUD
        Boolean enforceFLS                              = false;    // by pass FLS
        Boolean includeSelectorFields                   = true;     // include fields from getSObjectFieldList()
        adglib_QueryFactory orderQueryFactory           = this.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields).setCondition('Id IN :orderIds');
        
        // select line items
        adglib_QueryFactory lineItemsQueryFactory       = orderQueryFactory.subselectQuery(Vehicle_Purchase_Order_Line_Items__c.sObjectType);
        lineItemsQueryFactory.selectFields(new VPOLineItemsSelector().getSObjectFieldList());

        // get POLI parents name
        lineItemsQueryFactory.selectField('Color_Master__r.Color_Description__c');
        lineItemsQueryFactory.selectField('Model_Color_Trim_Master__r.Name');
        lineItemsQueryFactory.selectField('Trim_Master__r.Trim_Description__c');
        lineItemsQueryFactory.selectField('Model_Master__r.Model_Description__c');
        lineItemsQueryFactory.selectField('Model_Year_Master__r.Name');

        // select converted stock vehicle master
        adglib_QueryFactory convertedStockQueryFactory  = orderQueryFactory.subselectQuery(Vehicle_Master2__c.sObjectType);
        convertedStockQueryFactory.selectField(Vehicle_Master2__c.Id);
        convertedStockQueryFactory.selectField(Vehicle_Master2__c.Vehicle_Purchase_Order__c);
        convertedStockQueryFactory.selectField(Vehicle_Master2__c.Vehicle_Purchase_Order_Line_Items__c);
        
        return Database.query(orderQueryFactory.toSOQL());
    }
    
    /**
     * [23082022] Added by Nhung Cao - US-TMS-0001
     */
    public List<Vehicle_Purchase_Order__c> selectVPObyFranchiseAndProductionMonth(String franchise, Date productionMonth) {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('Franchise_Code__c');
        query.selectField('Production_Month__c');
        query.selectField('Total_Units_Confirmed__c');
        query.selectField('Stage__c');
        query.selectField('Name');
        query.selectField('Id');
        String strFilter = 'Franchise_Code__c = :franchise' 
                        + ' AND Production_Month__c =: productionMonth'
                        ;

        query.setCondition(strFilter);

        StockVehicleMasterSelector svmQuery = new StockVehicleMasterSelector();
        adglib_QueryFactory svmQueryFactory = svmQuery.newQueryFactory(false);
        svmQuery.addQueryFactorySubselect(query, 'Stock_Vehicle_Masters__r');

        return Database.query(query.toSOQL());
    }

    /**
     * [23082022] Added by Nhung Cao - US-TMS-0003/0004/0005
     */
    public List<Vehicle_Purchase_Order__c> selectVPO_WithRelatedSVM(List<Id> vpoIds) {

        adglib_QueryFactory VPOqueryFactory = newQueryFactory();
        VPOqueryFactory.setCondition('Id IN :vpoIds');

        StockVehicleMasterSelector svmQuery = new StockVehicleMasterSelector();
        adglib_QueryFactory svmQueryFactory = svmQuery.newQueryFactory(false);
        svmQueryFactory.selectField('Vehicle_Purchase_Status__c');
        svmQuery.addQueryFactorySubselect(VPOqueryFactory, 'Stock_Vehicle_Masters__r');

        return Database.query(VPOqueryFactory.toSOQL());
    }

    /**
     * [24082022] Added by Nhung Cao - US-TMS-00019
     */
    public List<Vehicle_Purchase_Order__c> getRecordsByPOIds(List<Id> poIds) 
    {
        adglib_QueryFactory vpoQueryFactory = newQueryFactory();
        vpoQueryFactory.setCondition('TMS_Purchase_Order__c IN :poIds');

        return Database.query(vpoQueryFactory.toSOQL());
    }

    /**
     * [30082022] Added by Nhung Cao - US-TMS-00019
     */
    public List<Vehicle_Purchase_Order__c> getRecordsBySVMIds(Set<Id> svmIds) 
    {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :svmIds');

        return Database.query(query.toSOQL());
    }

}
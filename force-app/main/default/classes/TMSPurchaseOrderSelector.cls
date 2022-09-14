/*==========================================================================================================================================================================
 * Selector class for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: 24/08/2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *              xxxx                               xxxx                                  xxxx                                               Init
 *      24 August 2022                      nhung.cao@aodigy.com                    US-TMS-00019                            Add selectTMSPObyFranchiseAndProductionMonth method
 *      24 August 2022                      nhung.cao@aodigy.com                    US-TMS-00019                            Add getRecordsByVPOIds method
 *      24 August 2022                      nhung.cao@aodigy.com                    US-TMS-00019                            Add getRecordsBySVMIds method
 * 
 * ========================================================================================================================================================================== 
 */
public class TMSPurchaseOrderSelector extends ADGLIB_SObjectSelector {
    public TMSPurchaseOrderSelector() {

    }

    public Schema.SObjectType getSObjectType()
    {
        return Purchase_Order__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values(); 
    }

    public List<Purchase_Order__c> selectTMSPObyFranchiseAndProductionMonth(String franchise, Date productionMonth) {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('Franchise__c');
        query.selectField('Production_Month__c');
        query.selectField('Total_Quantity__c');
        query.selectField('CreatedDate');
        query.selectField('Name');
        query.selectField('Id');
        String strFilter = 'Franchise__c = :franchise AND Production_Month__c =: productionMonth';

        query.setCondition(strFilter);

        ForwardFOBContractSelector fobQuery = new ForwardFOBContractSelector();
        adglib_QueryFactory fobQueryFactory = fobQuery.newQueryFactory(false);
        fobQueryFactory.selectField('Name');
        fobQueryFactory.selectField('Quantity__c');
        fobQueryFactory.selectField('Status__c');
        fobQueryFactory.selectField('CreatedDate');
        fobQuery.addQueryFactorySubselect(query, 'Forward_Contracts_FOB__r');

        ForwardDutyContractSelector dutyQuery = new ForwardDutyContractSelector();
        adglib_QueryFactory dutyQueryFactory = dutyQuery.newQueryFactory(false);
        dutyQueryFactory.selectField('Name');
        dutyQueryFactory.selectField('Quantity__c');
        dutyQueryFactory.selectField('Status__c');
        dutyQueryFactory.selectField('CreatedDate');
        dutyQuery.addQueryFactorySubselect(query, 'Forward_Duty_Contracts__r');

        VehiclePurchaseOrderSelector vpoQuery = new VehiclePurchaseOrderSelector();
        adglib_QueryFactory vpoQueryFactory = vpoQuery.newQueryFactory(false);
        vpoQueryFactory.selectField('Name');
        vpoQueryFactory.selectField('CreatedDate');
        vpoQuery.addQueryFactorySubselect(query, 'Vehicle_Purchase_Orders__r');

        // FOBAddtionalContractSelector fobAddCtrQuery = new FOBAddtionalContractSelector();
        // adglib_QueryFactory fobAddCtrQueryFactory = fobAddCtrQuery.newQueryFactory(false);
        // fobAddCtrQueryFactory.selectField('Name');
        // fobAddCtrQueryFactory.selectField('CreatedDate');
        // fobAddCtrQuery.addQueryFactorySubselect(fobQueryFactory, 'FOB_Additional_Contracts__r');

        // DutyAddtionalContractSelector dutyAddCtrQuery = new DutyAddtionalContractSelector();
        // adglib_QueryFactory dutyAddCtrQueryFactory = dutyAddCtrQuery.newQueryFactory(false);
        // dutyAddCtrQueryFactory.selectField('Name');
        // dutyAddCtrQueryFactory.selectField('CreatedDate');
        // dutyAddCtrQuery.addQueryFactorySubselect(dutyQueryFactory, 'Duty_Additional_Contracts__r');

        return Database.query(query.toSOQL());
    }

    public List<Purchase_Order__c> getRecordsByVPOIds(Set<Id> vpoIds) 
    {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('Id');
        query.setCondition('Id IN :vpoIds');

        ForwardFOBContractSelector fobQuery = new ForwardFOBContractSelector();
        adglib_QueryFactory fobQueryFactory = fobQuery.newQueryFactory(false);
        fobQuery.addQueryFactorySubselect(query, 'Forward_Contracts_FOB__r');

        ForwardDutyContractSelector dutyQuery = new ForwardDutyContractSelector();
        adglib_QueryFactory dutyQueryFactory = dutyQuery.newQueryFactory(false);
        dutyQuery.addQueryFactorySubselect(query, 'Forward_Duty_Contracts__r');

        return Database.query(query.toSOQL());
    }

    public List<Purchase_Order__c> getRecordsBySVMIds(Set<Id> svmIds) 
    {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('Id');
        query.setCondition('Id IN :svmIds');

        ForwardFOBContractSelector fobQuery = new ForwardFOBContractSelector();
        adglib_QueryFactory fobQueryFactory = fobQuery.newQueryFactory(false);
        fobQuery.addQueryFactorySubselect(query, 'Forward_Contracts_FOB__r');

        ForwardDutyContractSelector dutyQuery = new ForwardDutyContractSelector();
        adglib_QueryFactory dutyQueryFactory = dutyQuery.newQueryFactory(false);
        dutyQuery.addQueryFactorySubselect(query, 'Forward_Duty_Contracts__r');

        return Database.query(query.toSOQL());
    }

    



}
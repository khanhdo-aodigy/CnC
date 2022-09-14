/*==========================================================================================================================================================================
 * Selector class for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: 24/08/2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      
 *      24 August 2022                      nhung.cao@aodigy.com                    US-TMS-00019                                    Add selectFOBAddContract method
 * ========================================================================================================================================================================== 
 */

public class ForwardFOBContractSelector extends ADGLIB_SObjectSelector {
    public ForwardFOBContractSelector() {

    }

    public Schema.SObjectType getSObjectType()
    {
        return Forward_FOB_Contract__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    public List<Forward_FOB_Contract__c> getRecordsByPOIds(List<Id> poIds) 
    {
        adglib_QueryFactory fobQueryFactory = newQueryFactory();
        fobQueryFactory.setCondition('Purchase_Order__c IN :poIds');

        return Database.query(fobQueryFactory.toSOQL());
    }
    
    public List<Forward_FOB_Contract__c> selectFOBAddContract(List<Id> poIds) 
    {
        adglib_QueryFactory fobQueryFactory = newQueryFactory();
        fobQueryFactory.selectField('Name');
        fobQueryFactory.selectField('Quantity__c');
        fobQueryFactory.selectField('Status__c');
        fobQueryFactory.selectField('CreatedDate');
        String strFilter = 'Purchase_Order__c IN: poIds';
        fobQueryFactory.setCondition(strFilter);

        FOBAddtionalContractSelector fobAddCtrQuery = new FOBAddtionalContractSelector();
        adglib_QueryFactory fobAddCtrQueryFactory = fobAddCtrQuery.newQueryFactory(false);
        fobAddCtrQueryFactory.selectField('Name');
        fobAddCtrQueryFactory.selectField('CreatedDate');
        fobAddCtrQuery.addQueryFactorySubselect(fobQueryFactory, 'FOB_Additional_Contracts__r');

        return Database.query(fobQueryFactory.toSOQL());
    }

}
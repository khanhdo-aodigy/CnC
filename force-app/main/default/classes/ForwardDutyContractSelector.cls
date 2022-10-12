/*==========================================================================================================================================================================
 * Selector class for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: 24/08/2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      
 *      24 August 2022                      nhung.cao@aodigy.com                    US-TMS-00019                                Add getRecordsByPOIds method
 * ========================================================================================================================================================================== 
 */
public class ForwardDutyContractSelector extends ADGLIB_SObjectSelector {
    public ForwardDutyContractSelector() {

    }

    public Schema.SObjectType getSObjectType()
    {
        return Forward_Duty_Contract__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    public List<Forward_Duty_Contract__c> getRecordsByPOIds(List<Id> poIds) 
    {
        adglib_QueryFactory dutyQueryFactory = newQueryFactory();
        dutyQueryFactory.setCondition('Purchase_Order__c IN :poIds');

        return Database.query(dutyQueryFactory.toSOQL());
    }
}
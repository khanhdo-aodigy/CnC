/*==========================================================================================================================================================================
 * Selector class for FOB Additional Contract Entity
 * Created By: Aodigy Team
 * Create Date: 28/08/2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *              xxxx                                xxxx                                    xxxx                                             Init
 *          28 August 2022                      nhung.cao@aodigy.com                    US-TMS-00018                            Add getRecordsByFOBAdditionalContractIds method
 * ========================================================================================================================================================================== 
 */
public class FOBContractLineItemsSelector extends ADGLIB_SObjectSelector {
    public FOBContractLineItemsSelector() {

    }

    public Schema.SObjectType getSObjectType()
    {
        return Forward_FOB_Contract_Line_Item__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    public List<Forward_FOB_Contract_Line_Item__c> getRecordsByFOBAdditionalContractIds(List<Id> fobAddContractIds) 
    {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('FOB_Additional_Contract__c IN :fobAddContractIds');

        return Database.query(query.toSOQL());
    }
}
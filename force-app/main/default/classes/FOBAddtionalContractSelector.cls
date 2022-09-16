/*==========================================================================================================================================================================
 * Selector class for FOB Additional Contract Entity
 * Created By: Aodigy Team
 * Create Date: 27/08/2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      
 *      27 August 2022                      nhung.cao@aodigy.com                    US-TMS-00019                            Add getRecordsByFFOBContractds method
 * ========================================================================================================================================================================== 
 */
public class FOBAddtionalContractSelector extends ADGLIB_SObjectSelector {
    public FOBAddtionalContractSelector() {

    }

    public Schema.SObjectType getSObjectType()
    {
        return FOB_Additional_Contract__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return getSObjectType().getDescribe().fields.getMap().values();
    }

    public List<FOB_Additional_Contract__c> getRecordsByFFOBContractds(List<Id> ffobIds) 
    {
        adglib_QueryFactory fobAdditionalQueryFactory = newQueryFactory();
        fobAdditionalQueryFactory.setCondition('Forward_FOB_Contract__c IN :ffobIds');

        return Database.query(fobAdditionalQueryFactory.toSOQL());
    }
}
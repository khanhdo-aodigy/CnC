/** *****
 * Description : Selector Class for Transaction Object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200623            HS@aodigy            Created Initial Version 
 * 
** *****/
public class TransactionSelector extends ADGLIB_SObjectSelector{

    public Schema.SObjectType getSObjectType(){
        return Transaction__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Transaction__c');
    }

    public List<Transaction__c> selectTransactionsByIds( Set<Id> setTrxnIds ){
        adglib_QueryFactory query = newQueryFactory();    
        query.setCondition(' ID IN :setTrxnIds ');
        return (List<Transaction__c> )Database.query(query.toSOQL()); 
    }
}
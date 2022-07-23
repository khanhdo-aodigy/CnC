/** *****
 * Description : Selector Class for Account Mapping Object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200622            HS@aodigy            Created Initial Version 
 * 
** *****/
public class AccountMappingSelector extends ADGLIB_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Account_Mapping__c');
    }
    
    public Schema.SObjectType getSObjectType() {
        return Account_Mapping__c.sObjectType;
    }

    public List<Account_Mapping__c> selectAllRecords(){
        adglib_QueryFactory query = newQueryFactory();    
        query.setLimit(1000);
        return (List<Account_Mapping__c> )Database.query(query.toSOQL()); 
    }

    public List<Account_Mapping__c> selectBySourceCode( Set<String> setSourceCodes ){
        adglib_QueryFactory query = newQueryFactory();    
        query.setCondition( 'Source_Code__c IN :setSourceCodes' ); 
        return (List<Account_Mapping__c> )Database.query(query.toSOQL()); 
    }

    public List<Account_Mapping__c> selectByDivision( Set<String> setDivisions ){
        adglib_QueryFactory query = newQueryFactory();    
        query.setCondition( 'Division__c IN :setDivisions' ); 
        return (List<Account_Mapping__c> )Database.query(query.toSOQL()); 
    }
}
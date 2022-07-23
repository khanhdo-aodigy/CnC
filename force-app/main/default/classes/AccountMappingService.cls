/** *****
 * Description : Service Class for Account Mapping Object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200622            HS@aodigy            Created Initial Version 
 * 
** *****/
public with sharing class AccountMappingService {

    private static AccountMappingSelector selector = new AccountMappingSelector();


    public static Map<String,Account_Mapping__c> getAcctMappingBySourceCode( Set<String> setSourceCodes ){
        Map<String,Account_Mapping__c> mapAcctMapping = new Map<String,Account_Mapping__c>();
        for( Account_Mapping__c actMap : selector.selectBySourceCode( setSourceCodes ) ){
            mapAcctMapping.put( actMap.Composite_Key__c , actMap );
        }
        return mapAcctMapping;
    }

    public static Map<String,Account_Mapping__c> getAllAcctMapping(){
        Map<String,Account_Mapping__c> mapAcctMapping = new Map<String,Account_Mapping__c>();
        for( Account_Mapping__c actMap : selector.selectAllRecords() ){
            mapAcctMapping.put( actMap.Composite_Key__c , actMap );
        }
        return mapAcctMapping;
    }

    //get current number

    //increment number
    
    //update new number

}
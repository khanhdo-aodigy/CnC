/** ******
 * Description : Service class for Republic Auto (RA) Person Account Profiling object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                     Description
 * 20210114            khanh.do@aodigy          Created Initial Version
 * 20210121			   hung.huynh@aodigy		Added upsertPAProfilingList method
 * 20210617            khanh.do@aodigy          Added methods getRecordTypeId() and getRecordTypeName()
 * 
** ******/
public with sharing class PersonAccountProfilingService {
    
    private static PersonAccountProfilingSelector selector = new PersonAccountProfilingSelector();

    public static Id getRecordTypeId( String recordTypeAPINAme ) {
        if( Schema.SObjectType.Person_Account_Profiling__c.getRecordTypeInfosByDeveloperName().containsKey( recordTypeAPINAme ) ) {
            return Schema.SObjectType.Person_Account_Profiling__c.getRecordTypeInfosByDeveloperName().get( recordTypeAPINAme ).getRecordTypeId(); 
        }
        return null;
    }


}
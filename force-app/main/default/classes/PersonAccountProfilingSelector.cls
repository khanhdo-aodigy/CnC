/** ******
 * Description : Service class for Republic Auto (RA) Person Account Profiling object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                     Description
 * 20210114            khanh.do@aodigy          Created Initial Version
 * 
** ******/
public with sharing class PersonAccountProfilingSelector extends ADGLIB_SObjectSelector {

    public Schema.SObjectType getSObjectType() 
    {
        return Person_Account_Profiling__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() 
    {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Person_Account_Profiling__c');
    }

    public List<Person_Account_Profiling__c> getProfilingsAccountIds(Set<Id> Ids) 
    {
        List<Person_Account_Profiling__c> profilingList = new List<Person_Account_Profiling__c>();
        if( !Ids.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();
            String filter = ' Account__c IN :Ids ';
            query.setCondition( filter );
            profilingList = Database.query( query.toSOQL() );
        }
        System.debug('profilingList = ' + profilingList);
        return profilingList;        
    }
}
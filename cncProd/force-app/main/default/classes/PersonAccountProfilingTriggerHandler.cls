/** ******
 * Description: Person Account Profiling Trigger Handler
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		    Description
 * 20210622             khanh.do               Created Initial Version.
** ******/
public with sharing class PersonAccountProfilingTriggerHandler {

    private static Boolean isRunBeforeInsert = false;
    private static Boolean isRunAfterInsert = false;
    private static Boolean isRunBeforeUpdate = false;
    private static Boolean isRunAfterUpdate = false;
    
    public static void runBeforeInsert(List<Person_Account_Profiling__c> profilingList){
        if(!isRunBeforeInsert){
            PersonAccountProfilingBL.preventDuplicateProfiling('insert', profilingList);
            isRunBeforeInsert = true;
        }
    }

    public static void runAfterInsert(List<Person_Account_Profiling__c> profilingList){
        if(!isRunAfterInsert){
            PersonAccountProfilingBL.updateAccounts(profilingList);
            isRunAfterInsert = true;
        }        
    }

    private static List<Id> dupProfileIds = new List<Id>();
    public static void runBeforeUpdate(List<Person_Account_Profiling__c> profilingList){
        if(!isRunBeforeUpdate){
            dupProfileIds = PersonAccountProfilingBL.preventDuplicateProfiling('update',profilingList);
            isRunBeforeUpdate = true;
        }        
    }

    public static void runAfterUpdate(List<Person_Account_Profiling__c> profilingList){
        if(!isRunAfterUpdate){
            PersonAccountProfilingBL.updateAccounts( profilingList);
            PersonAccountProfilingBL.deleteDupProfiles(dupProfileIds);
            isRunAfterUpdate = true;
        }        
    }

}
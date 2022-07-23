/** ******
 * Description : Apex trigger for Person Account Profiling object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name            Description
 * 20210622            Khanh Do         Created Initial Version
 * 
** ******/
trigger PersonAccountProfilingTrigger on Person_Account_Profiling__c (before insert ,after insert, before update, after update) {
    //Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if(TriggerExclusion.isTriggerExclude('Person_Account_Profiling__c')
         || TriggerExclusion.isBypassTriggerExecution('Person_Account_Profiling__c')
            //|| automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    adglib_SObjectDomain.triggerHandler(PersonAccountProfiling.class);

    
}
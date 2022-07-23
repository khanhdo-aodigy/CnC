/** ******
 * Description: Account Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * 20200228            nguyen.tho           Created Initial Version.
 * 20210510            khanh.do             Added fire Contact trigger on PA update
 * 
** ******/
trigger AccountTrigger on Account (after insert, after update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('Account') || TriggerExclusion.isBypassTriggerExecution('Account') || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    if(Trigger.isInsert || Trigger.isUpdate){
        if(Trigger.isAfter){
            AccountTriggerHandler.updatePortalUser(Trigger.newMap);
        }
    }


}
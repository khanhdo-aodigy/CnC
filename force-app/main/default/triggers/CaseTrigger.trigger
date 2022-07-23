/*
    Author: Hari Panneerselvam
*/
trigger CaseTrigger on Case (after insert, after update, before insert, before update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    if(TriggerExclusion.isTriggerExclude('Case') 
        || TriggerExclusion.isBypassTriggerExecution('Case')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
   
    TriggerHandlerCase caseTH = new TriggerHandlerCase(trigger.new, trigger.oldMap); 

}
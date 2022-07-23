/** ******
 * Description: EmailMessage Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210510            khanh.do             Added trigger exclusion
 * 
** ******/
trigger EmailMessageTrigger on EmailMessage (before insert, after insert, before update, after update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('EmailMessage')
         || TriggerExclusion.isBypassTriggerExecution('EmailMessage')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    system.debug('Trigger.New-->' + Trigger.New);
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            EmailMessageTriggerHandler.handleAfterInsert(Trigger.New);
        }
    }
    
}
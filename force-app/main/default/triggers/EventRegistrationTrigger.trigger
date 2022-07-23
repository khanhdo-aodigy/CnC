/** ******
 * Description: EmailMessage Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210510            khanh.do             Added trigger exclusion
 * 
** ******/
trigger EventRegistrationTrigger on Event_Registration__c (after insert) {
    //Exclude this trigger
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    if(TriggerExclusion.isTriggerExclude('Event_Registration__c')
         || TriggerExclusion.isBypassTriggerExecution('Event_Registration__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    if(Trigger.isAfter)    
    {
        if(Trigger.isInsert){
            EventRegistration_ConfirmationEmail.hanldeAfterInsert(trigger.new);
        }
    }
   
}
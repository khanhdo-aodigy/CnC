/** ******
 * Description: dsfs__DocuSign_Status__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210510            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger EnvelopeStatusTrigger on dsfs__DocuSign_Status__c (before insert, before update) {
	/**
     -- changelog v1.0: add handling before insert to populate related SA's ID base on envelope ID
     -- modified on: 13 March 2020 by Phap Mai
     -- changelog v1.1: add handling before update to change the approval status on related SA, replace the current PB to avoid conflit
     */
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    
    if(TriggerExclusion.isTriggerExclude('dsfs__DocuSign_Status__c')
        || TriggerExclusion.isBypassTriggerExecution('dsfs__DocuSign_Status__c') 
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    if(Trigger.isBefore && Trigger.isInsert) {
        EnvelopeStatus.handleBeforeInsert(trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        EnvelopeStatus.handleBeforeUpdate(trigger.new, trigger.oldMap);
    }
}
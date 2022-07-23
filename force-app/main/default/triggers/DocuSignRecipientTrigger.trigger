/** ******
 * Description: DocuSign_Recipient__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * 20200228            nguyen.tho           Created Initial Version.
 * 20210510            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger DocuSignRecipientTrigger on DocuSign_Recipient__c (after insert, after update, after delete) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('DocuSign_Recipient__c')
         || TriggerExclusion.isBypassTriggerExecution('DocuSign_Recipient__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    DocuSignRecipients triggerHandler = new DocuSignRecipients(trigger.new, trigger.old);
    if (trigger.isAfter && trigger.isUpdate) {
        triggerHandler.handleAfterUpdate(trigger.new, trigger.oldMap);
    }

    if (trigger.isAfter && trigger.isInsert) {
        triggerHandler.handleAfterInsert(trigger.new);
    }

    if (trigger.isAfter && trigger.isDelete) {
        triggerHandler.handleAfterDelete(trigger.old);
    }
}
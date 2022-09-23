/** ******
 * Description: Trigger for the Credit_Note__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20220916           dong.nguyen@aodigy.com    Created Initial Version. 
** ******/

trigger CreditDebitNoteTrigger on Credit_Note__c (before insert, after insert, before update, after update) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if ( TriggerExclusion.isTriggerExclude('Credit_Note__c')
        || TriggerExclusion.isBypassTriggerExecution('Credit_Note__c')
            || automationSetting.Bypass_Triggers__c)
    {
        return;
    }

    adglib_SObjectDomain.triggerHandler(CreditDebitNotes.class);
}
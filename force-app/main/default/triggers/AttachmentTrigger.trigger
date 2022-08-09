/**
 * ================================================================================================================================
 * Created Date: 08 Aug 2022
 * Created By: dangphap.mai@aodigy.com
 * Changelog
 *              DATE::                              BY::                                        DETAIL::
 *              08 Aug 2022                         dangphap.mai@aodigy.com                     init
 * ================================================================================================================================
 */
trigger AttachmentTrigger on Attachment (before delete, before insert, before update)
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if (TriggerExclusion.isTriggerExclude('Attachment')
        || TriggerExclusion.isBypassTriggerExecution('Attachment')
            || automationSetting.Bypass_Triggers__c)
    {
        return;
    }

    adglib_SObjectDomain.triggerHandler(AttachmentDomain.class);
}
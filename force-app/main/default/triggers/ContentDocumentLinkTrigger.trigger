/** ******
 * Description: Trigger for ContentDocumentLink object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210312             TP@aodigy.com       Created Initial Version. 
 * 20210706             hanh.do             Added Trigger exclusion
** ******/

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, before update, after update) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    //Trigger exclusion check
    if( TriggerExclusion.isTriggerExclude('ContentDocumentLink')
         || TriggerExclusion.isBypassTriggerExecution('ContentDocumentLink') 
            || automationSetting.Bypass_Triggers__c
    )
    {
        return;
    }
    adglib_SObjectDomain.triggerHandler(ContentDocumentLinks.class);
}
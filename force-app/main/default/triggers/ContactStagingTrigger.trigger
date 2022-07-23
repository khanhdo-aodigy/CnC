/** ******
 * Description: Contact_Staging__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C			        Created Initial Version.
 * 20210706            khanh.do             Added Trigger exclusion
 * 
** ******/
trigger ContactStagingTrigger on Contact_Staging__c (before insert)  
{ 

    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    //Trigger exclusion check
    if( TriggerExclusion.isTriggerExclude('Contact_Staging__c')
         || TriggerExclusion.isBypassTriggerExecution('Contact_Staging__c') 
            || automationSetting.Bypass_Triggers__c
    )
    {
        return;
    }

    if(Trigger.isInsert && Trigger.isBefore)
    {
        ContactStagingHandler.uncheckPDPA_email(trigger.new);
    }

}
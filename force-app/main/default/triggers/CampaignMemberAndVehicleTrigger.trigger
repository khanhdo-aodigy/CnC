/** ******
 * Description: Trigger for the Campaign_Member_Vehicle__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20220415           TPhan@aodigy.com    Created Initial Version. 
** ******/

trigger CampaignMemberAndVehicleTrigger on Campaign_Member_Vehicle__c (before insert, after insert, before update, after update) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if ( TriggerExclusion.isTriggerExclude('Campaign_Member_Vehicle__c')
        || TriggerExclusion.isBypassTriggerExecution('Campaign_Member_Vehicle__c')
            || automationSetting.Bypass_Triggers__c)
    {
        return;
    }

    adglib_SObjectDomain.triggerHandler(CampaignMemberAndVehicles.class);
}
/** ******
 * Description: Trigger for the Campaign_Promo_Line_Item__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20220415           TPhan@aodigy.com    Created Initial Version. 
** ******/

trigger CampaignPromoLineItemTrigger on Campaign_Promo_Line_Item__c (before insert, after insert, before update, after update) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if ( TriggerExclusion.isTriggerExclude('Campaign_Promo_Line_Item__c')
        || TriggerExclusion.isBypassTriggerExecution('Campaign_Promo_Line_Item__c')
            || automationSetting.Bypass_Triggers__c)
    {
        return;
    }

    adglib_SObjectDomain.triggerHandler(CampaignPromoLineItems.class);
}
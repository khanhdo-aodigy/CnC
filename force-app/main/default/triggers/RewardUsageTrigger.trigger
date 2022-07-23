/** *****
 * Description : Trigger for Reward Usage Object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200629            HS@aodigy            Created Initial Version 
 * 20210706            KD@aodigy            Added bypass trigger via custom setting
 * 
** *****/
trigger RewardUsageTrigger on Reward_Usage__c (before insert, after insert) {

    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if(TriggerExclusion.isTriggerExclude('Reward_Usage__c')
        || TriggerExclusion.isBypassTriggerExecution('Reward_Usage__c')
            || automationSetting.Bypass_Triggers__c
    ){
        System.debug('By Pass RewardUsageTrigger !!!');
        return;
    }

    adglib_SObjectDomain.triggerHandler(RewardUsages.class);

}
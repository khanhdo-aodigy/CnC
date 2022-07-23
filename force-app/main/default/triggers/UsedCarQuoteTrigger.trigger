/** *****
 * Description : Trigger on object Used_Car_Quote__c
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * 20220526             khanh.do@aodigy.com              Created Initial Version
 * 
** *****/
trigger UsedCarQuoteTrigger on Used_Car_Quote__c (before insert, before update, after update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('Used_Car_Quote__c') 
        || TriggerExclusion.isBypassTriggerExecution('Used_Car_Quote__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    adglib_SObjectDomain.triggerHandler(UsedCarQuote.class);
}
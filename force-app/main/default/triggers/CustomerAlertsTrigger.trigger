/** ******
 * Description : Trigger Class of CustomerAlerts__c Custom Object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200319            HS         Created Initial Version
 * 20210706            KD         Added Bypass Trigger via Custom settings
 * 
** ******/
trigger CustomerAlertsTrigger on CustomerAlerts__c (after insert, before insert) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('CustomerAlerts__c') 
        || TriggerExclusion.isBypassTriggerExecution('CustomerAlerts__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    CustomerAlertsTriggerHandler.handler();
    
}
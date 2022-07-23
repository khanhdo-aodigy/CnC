/** ******
 * Description: Trigger for SA_Accessory__c object
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger SAAccessoryTrigger on SA_Accessory__c (before insert, before update) {
    //Exclude this trigger 
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if( TriggerExclusion.isTriggerExclude('SA_Accessory__c') || TriggerExclusion.isBypassTriggerExecution('SA_Accessory__c') || automationSetting.Bypass_Triggers__c
    ) {
        return;
    }
    
    adglib_SObjectDomain.triggerHandler(SAAccessories.class);
}
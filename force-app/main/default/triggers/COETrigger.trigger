/** *****
 * Description : Trigger on object COE__c
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description 
 * YYYYMMDD             somebody@aodigy.com              Created Initial Version
 * 20220817             khanh.do@aodigy.com              Added trigger exclusion logic
 * 
** *****/
trigger COETrigger on COE__c (before insert, after insert, before update, after update) {
	Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('COE__c') 
        || TriggerExclusion.isBypassTriggerExecution('COE__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
	adglib_SObjectDomain.triggerHandler(COE.class);
}
/** ******
 * Description: Accs_Rate_Master__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C			        Created Initial Version.
 * 20210706            khanh.do             Added Trigger exclusion
 * 
** ******/
trigger AccsRateMasterTrigger on Accs_Rate_Master__c (after insert, after update, after delete) {
	Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('Accs_Rate_Master__c')
         || TriggerExclusion.isBypassTriggerExecution('Accs_Rate_Master__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

	adglib_SObjectDomain.triggerHandler(AccsRateMasters.class);
}
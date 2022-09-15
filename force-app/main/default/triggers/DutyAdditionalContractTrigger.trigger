/** ******
 * Description: Duty_Additional_Contract__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210510            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger DutyAdditionalContractTrigger on Duty_Additional_Contract__c (after update) {
	Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
	//Exclude this trigger 
	if( TriggerExclusion.isTriggerExclude('Duty_Additional_Contract__c')
		|| TriggerExclusion.isBypassTriggerExecution('Duty_Additional_Contract__c') 
			|| automationSetting.Bypass_Triggers__c
	) {
		return;
	}

	adglib_SObjectDomain.triggerHandler(DutyAdditionalContract.class);
}
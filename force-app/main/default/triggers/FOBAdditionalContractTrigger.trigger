/** ******
 * Description: FOB_Additional_Contract__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210510            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger FOBAdditionalContractTrigger on FOB_Additional_Contract__c (after update, after insert) {
	//Exclude this trigger 
	Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
	if( TriggerExclusion.isTriggerExclude('FOB_Additional_Contract__c') 
		|| TriggerExclusion.isBypassTriggerExecution('FOB_Additional_Contract__c') 
			|| automationSetting.Bypass_Triggers__c
	) {
		return;
	}

	// if (Trigger.isAfter && Trigger.isUpdate)
    // {
	// 	FOBAdditionalContract.updateAverageExRateOnSVMByFOBAdditionalIds(Trigger.oldMap,Trigger.new);
	// }

	adglib_SObjectDomain.triggerHandler(FOBAdditionalContract.class);
}
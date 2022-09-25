trigger ForwardFOBContractTrigger on Forward_FOB_Contract__c (after update) {
	Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if (TriggerExclusion.isTriggerExclude('FOB_Additional_Contract__c') 
		|| TriggerExclusion.isBypassTriggerExecution('FOB_Additional_Contract__c') 
			|| automationSetting.Bypass_Triggers__c)
    {
		return;
	}

    adglib_SObjectDomain.triggerHandler(ForwardFOBContract.class);
}
/** ******
 * Description: MB_Sales_Agreement__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210510            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger MBSalesAgreementTrigger on MB_Sales_Agreement__c (before update, after update) {
    //Exclude this trigger 
	Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
	if( TriggerExclusion.isTriggerExclude('MB_Sales_Agreement__c') 
		|| TriggerExclusion.isBypassTriggerExecution('MB_Sales_Agreement__c') 
			|| automationSetting.Bypass_Triggers__c
	) {
		return;
	}

    adglib_SObjectDomain.triggerHandler(MBSalesAgreement.class);
}
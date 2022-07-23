/** ******
 * Description: MB_SA_Spec__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210510            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger MBSASpecTrigger on MB_SA_Spec__c (after insert, after delete, after update) {
    //Exclude this trigger 
	Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
	if( TriggerExclusion.isTriggerExclude('MB_SA_Spec__c') 
		|| TriggerExclusion.isBypassTriggerExecution('MB_SA_Spec__c')  
			|| automationSetting.Bypass_Triggers__c
	){
		return;
	}

    adglib_SObjectDomain.triggerHandler(MBSASpec.class);
}
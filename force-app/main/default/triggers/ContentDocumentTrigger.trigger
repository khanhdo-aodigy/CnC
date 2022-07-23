/** ******
 * Description: ContentDocument Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C			        Created Initial Version.
 * 20210706            khanh.do             Added Trigger exclusion
 * 
** ******/
trigger ContentDocumentTrigger on ContentDocument (before delete) {
	Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('ContentDocument')
         || TriggerExclusion.isBypassTriggerExecution('ContentDocument')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
	
	adglib_SObjectDomain.triggerHandler(ContentDocuments.class);
}
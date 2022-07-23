/** ******
 * Description: ContentVersion Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C			        Created Initial Version.
 * 20210706            khanh.do             Added Trigger exclusion
 * 
** ******/
trigger ContentVersionTrigger on ContentVersion (after insert) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('ContentVersion')
         || TriggerExclusion.isBypassTriggerExecution('ContentVersion')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    adglib_SObjectDomain.triggerHandler(ContentVersions.class);
}
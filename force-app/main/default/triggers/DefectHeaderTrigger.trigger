/** ******
 * Description: Defect_Header__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C			        Created Initial Version.
 * 20210706            khanh.do             Added Trigger exclusion
 * 
** ******/
trigger DefectHeaderTrigger on Defect_Header__c (before update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('Defect_Header__c')
         || TriggerExclusion.isBypassTriggerExecution('Defect_Header__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    adglib_SObjectDomain.triggerHandler(DefectHeader.class);
}
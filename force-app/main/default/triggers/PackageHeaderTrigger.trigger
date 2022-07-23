/** ******
 * Description: Package_Header__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210510            khanh.do             Added trigger exclusion
 * 
** ******/
//Start of RN2020Q1010 
trigger PackageHeaderTrigger on Package_Header__c (after insert, after update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('Package_Header__c')
         || TriggerExclusion.isBypassTriggerExecution('Package_Header__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    adglib_SObjectDomain.triggerHandler(PackageHeader.class);
}
//End of RN2020Q1010
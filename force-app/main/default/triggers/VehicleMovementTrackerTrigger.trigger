/** ******
 * Description: Trigger Vehicle_Movement_Tracker__c
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added trigger exclusion check
 * 
** ******/
trigger VehicleMovementTrackerTrigger on Vehicle_Movement_Tracker__c (before insert, after insert) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if(TriggerExclusion.isTriggerExclude('Vehicle_Movement_Tracker__c') 
        || TriggerExclusion.isBypassTriggerExecution('Vehicle_Movement_Tracker__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    adglib_SObjectDomain.triggerHandler(VehicleMovementTracker.class);
}
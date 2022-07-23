/** ******
 * Description: MB_Stock_Vehicle_Master__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210510            khanh.do             Added trigger exclusion
 * 
** ******/
trigger MBStockVehicleMasterTrigger on MB_Stock_Vehicle_Master__c (before insert, before update, after update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('MB_Stock_Vehicle_Master__c')
         || TriggerExclusion.isBypassTriggerExecution('MB_Stock_Vehicle_Master__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    adglib_SObjectDomain.triggerHandler(MBStockVehicleMaster.class);
}
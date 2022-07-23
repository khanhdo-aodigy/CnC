/** ******
 * Description: Trigger for the Registered_Vehicle__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        				Description
 * 20190429             Christian Gaylan            Created Initial Version. 
 * 20200221			    HS							Added isBypassTriggerExecution to perform additional check based on mdt data setup to bypass Trigger execution
 * 20210706             KD                          Added bypass trigger via custom setting
 * 20210723             Thang                       Add after Update
 * 20220510             Thanh                       Add after Insert to get KCL records
 * 
** ******/
trigger RegisteredVehicleTrigger on Registered_Vehicle__c (before update, after update, after insert) {
    
    //Exclude this trigger
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    
    if( TriggerExclusion.isTriggerExclude('Registered_Vehicle__c') 
        || TriggerExclusion.isBypassTriggerExecution('Registered_Vehicle__c') 
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            TriggerHandlerRegisteredVehicle.isRunBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        /*if(Trigger.isAfter){
            TriggerHandlerRegisteredVehicle.isRunAfterUpdate(Trigger.new, Trigger.oldMap);
        }*/
    }

    if(Trigger.isAfter && Trigger.isInsert){
        TriggerHandlerRegisteredVehicle.isRunAfterInsert(Trigger.new);
    }

}
/** ******
 * Description: This trigger will sync info to the corresponding PA whenever update happens on JCC Contact.
 *              Please call any Business Logic class/methods in the TriggerHandler.
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                 Description
 * 20200219            huynh.hung           Created Initial Version. 
 * 
** ******/
trigger ContactTrigger on Contact (before insert, after update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if(TriggerExclusion.isTriggerExclude('Contact') 
        || TriggerExclusion.isBypassTriggerExecution('Contact')
            || automationSetting.Bypass_Triggers__c
    ){
        System.debug('By Pass Contact ContactTrigger.trig !!!');
        return;
    }

    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            //ContactTriggerHandler.isRunAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
}
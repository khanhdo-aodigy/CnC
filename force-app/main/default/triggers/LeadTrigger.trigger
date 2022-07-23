/** ******
 * Description: This trigger will sync info to the corresponding PA whenever update happens on Lead.
 *              Please call any Business Logic class/methods in the TriggerHandler.
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * 20200221            huynh.hung           Created Initial Version. 
 * 
** ******/
trigger LeadTrigger on Lead (after insert, after update) {
    if(TriggerExclusion.isTriggerExclude('Lead') || TriggerExclusion.isBypassTriggerExecution('Lead')){
        return;
    }
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            LeadTriggerHandler.isRunAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isInsert){
        if(Trigger.isAfter){
            LeadTriggerHandler.handleAfterInsert(Trigger.New);
        }
    }
}
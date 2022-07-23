/** ******
 * Description: This trigger will consolidate all Opportunity-related logic.
 *              Please call any Business Logic class/methods in the TriggerHandler.
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		    Description
 * 20190325             Christian Gaylan        Created Initial Version. 
 * 20200221			    HS@aodigy		        Added isBypassTriggerExecution to perform additional check based on mdt data setup to bypass Trigger execution
 * 20201128             HS@aodigy               Added isBefore execution context          
 * 
****** **/
trigger OpportunityTrigger on Opportunity ( before insert, before update, after insert, after update ) {

    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    //Trigger exclusion check
    if( TriggerExclusion.isTriggerExclude('Opportunity')
        || TriggerExclusion.isBypassTriggerExecution('Opportunity')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    System.debug('Testing Oppo !!!');
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            TriggerHandlerOpportunity.afterInsert(Trigger.new);
        }
        else if(Trigger.isUpdate) {
            TriggerHandlerOpportunity.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            TriggerHandlerOpportunity.beforeInsert(Trigger.new);
        }
        else if(Trigger.isUpdate) {
            TriggerHandlerOpportunity.beforeUpdate(Trigger.new, Trigger.oldMap); 
        }
    }
}
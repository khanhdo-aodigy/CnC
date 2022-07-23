/** *****
 * Description : Trigger for Transaction Object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200623            HS@aodigy            Created Initial Version 
 * 20210706            KD@aodigy            Added bypass trigger via custom setting
 * 
** *****/
trigger TransactionTrigger on Transaction__c (before insert, before update, after insert, after update) {

    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if(TriggerExclusion.isTriggerExclude('Transaction__c') 
        || TriggerExclusion.isBypassTriggerExecution('Transaction__c')
            || automationSetting.Bypass_Triggers__c
    ){
        System.debug('By Pass TransactionTrigger !!!');
        return;
    }
    
    adglib_SObjectDomain.triggerHandler(Transactions.class);

}
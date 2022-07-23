/** ******
 * Description: Trigger for the Sales_Agreement__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20191102             Mai Phap            Created Initial Version. 
 * 20200221             HS                  Added isBypassTriggerExecution to perform additional check based on mdt data setup to bypass Trigger execution
 * 20210706             KD                  Added bypass trigger via custom setting
 * 
** ******/
trigger SalesAgreementTrigger on Sales_Agreement__c (before insert, before update, after insert, after update) {

    //Trigger exclusion check
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if( TriggerExclusion.isTriggerExclude('Sales_Agreement__c')
        || TriggerExclusion.isBypassTriggerExecution('Sales_Agreement__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    adglib_SObjectDomain.triggerHandler(SalesAgreements.class);
}
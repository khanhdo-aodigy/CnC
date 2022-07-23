/**
 * @File Name          : SAAdditionalChargeTrigger.trigger
 * @Description        : 
 * @Author             : jmt@aodigy.com
 * @Group              : 
 * @Last Modified By   : jmt@aodigy.com
 * @Last Modified On   : 12/10/2019, 8:16:47 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/10/2019   jmt@aodigy.com	           If there is changes to the existing charges, it will calculate and update sales agreement. 
 * *     20210706          KD                      Added trigger exclusion
**/

trigger SAAdditionalChargeTrigger on SA_Additional_Charge__c (before insert, after update) {
	Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if( TriggerExclusion.isTriggerExclude('SA_Additional_Charge__c') 
        || TriggerExclusion.isBypassTriggerExecution('SA_Additional_Charge__c') 
            || automationSetting.Bypass_Triggers__c
    ) {
        return;
    }


	adglib_SObjectDomain.triggerHandler(SA_Addtional_Charges.class);
}
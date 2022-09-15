/*==========================================================================================================================================================================
 * Trigger for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          27 July 2022                       phan.thu@aodigy.com                    US-VPO-000009                                           init
 * ========================================================================================================================================================================== 
 */

trigger VehiclePurchaseOrderTrigger on Vehicle_Purchase_Order__c (before insert, before update, after insert, after update) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if (TriggerExclusion.isTriggerExclude('Vehicle_Purchase_Order__c')
        || TriggerExclusion.isBypassTriggerExecution('Vehicle_Purchase_Order__c')
            || automationSetting.Bypass_Triggers__c)
    {
        return;
    }

    adglib_SObjectDomain.triggerHandler(VehiclePurchaseOrders.class);
}
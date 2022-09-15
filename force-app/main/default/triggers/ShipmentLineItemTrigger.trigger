/*==========================================================================================================================================================================
 * Trigger for Shipment Line Item Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          23 Aug 2022                       phan.thu@aodigy.com                    US-Ship-000025                                           init
 * ========================================================================================================================================================================== 
 */

trigger ShipmentLineItemTrigger on Shipment_Line_Item__c (before insert, after insert, before update, after update) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if (TriggerExclusion.isTriggerExclude('Shipment_Line_Item__c')
        || TriggerExclusion.isBypassTriggerExecution('Shipment_Line_Item__c')
            || automationSetting.Bypass_Triggers__c)
    {
        return;
    }

    adglib_SObjectDomain.triggerHandler(VehicleShipmentLineItems.class);
}
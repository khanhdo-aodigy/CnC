/** ******
 * Description: Trigger for the Delivery_Bay_Booking__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210714             Thang            Created Initial Version. 
** ******/
trigger DeliveryBayBookingTrigger on Delivery_Bay_Booking__c (before insert, before update, after insert, after update) {

    //Trigger exclusion check
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if( TriggerExclusion.isTriggerExclude('Delivery_Bay_Booking__c')
        || TriggerExclusion.isBypassTriggerExecution('Delivery_Bay_Booking__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    adglib_SObjectDomain.triggerHandler(DeliveryBayBookings.class);
}
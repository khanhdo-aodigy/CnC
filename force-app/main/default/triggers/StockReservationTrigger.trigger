/** ******
 * Description: Trigger for Stock_Reservation__c
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger StockReservationTrigger on Stock_Reservation__c (after update) {
    
    //Exclude this trigger 
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if( TriggerExclusion.isTriggerExclude('Stock_Reservation__c')
          || TriggerExclusion.isBypassTriggerExecution('Stock_Reservation__c')
              || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    /*
    remark by taufik 18 may 2016
    already add to the pages to send data 
    if (trigger.isInsert && trigger.isAfter){
        for (Stock_Reservation__c SR:trigger.new){
            User theSalesRep=[select id,Username2__c from User where ID = :SR.OwnerID];
            VSMSHelperClass.insertSR(SR.id,theSalesRep.Username2__c);
        }
    }
    */

    TriggerHandlerStockReservation sr = new TriggerHandlerStockReservation(Trigger.new, Trigger.oldMap);
}
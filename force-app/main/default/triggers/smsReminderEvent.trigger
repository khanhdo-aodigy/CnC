/** ******
 * Description: Trigger for Event object
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added trigger exclusion
 * 
** ******/
trigger smsReminderEvent on Event (before update,before insert) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if( TriggerExclusion.isTriggerExclude('Event') 
        || TriggerExclusion.isBypassTriggerExecution('Event') 
            || automationSetting.Bypass_Triggers__c
    )
    {
        return;
    }

    if (Trigger.isUpdate && Trigger.isBefore){
        List<Event> theEvents = new List<Event>();
        for(Event theEvent : Trigger.new){
            Boolean oldValue = Trigger.oldMap.get(theEvent.Id).Send_SMS__c;
            if (theEvent.Send_SMS__c==true && oldValue==false){
                String theText=theEvent.Subject.left(80)+' '+theEvent.StartDateTime+' '+Label.smsUrl+theEvent.id;
                String thePhone = [select MobilePhone from User where ID = :theEvent.OwnerID].MobilePhone;
                sendSmsClass.sendSms(thePhone,theText);
            }
            if (theEvent.SMS_reminder__c == null){
                theEvent.sms_date_trigger__c=theEvent.SMS_reminder__c;
            }else{
                theEvent.sms_date_trigger__c=theEvent.SMS_reminder__c.addMinutes(-15);
                //theEvent.sms_date_trigger__c=theEvent.SMS_reminder__c;
            }
        }
    }
    if (Trigger.isInsert && Trigger.isBefore){
        for(Event theEvent : Trigger.new){
            if (theEvent.SMS_reminder__c == null) { /*Saroja-1/10/2015 - set default time if the field blank*/
                theEvent.SMS_reminder__c=theEvent.StartDateTime.addMinutes(-30);
            }
            theEvent.sms_date_trigger__c=theEvent.SMS_reminder__c.addMinutes(-15);
        }
    }
}
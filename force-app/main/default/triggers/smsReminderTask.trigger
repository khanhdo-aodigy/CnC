/** ******
 * Description: Trigger for Task
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added trigger exclusion
 * 
** ******/
trigger smsReminderTask on Task (before update,before insert) {

    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if( TriggerExclusion.isTriggerExclude('Task') 
        || TriggerExclusion.isBypassTriggerExecution('Task') 
            || automationSetting.Bypass_Triggers__c
    )
    {
        return;
    }

    if (Trigger.isUpdate && Trigger.isBefore){
        List<Task> theTasks = new List<Task>();
        for(Task theTask : Trigger.new){
            Boolean oldValue = Trigger.oldMap.get(theTask.Id).Send_SMS__c;
            if (theTask.Send_SMS__c==true && oldValue==false){
                String theSubject='-';
                if (theTask.Subject==null || theTask.Subject==''){
                    theSubject='-';
                }else{
                    theSubject=theTask.Subject;
                }
                String theText=theSubject.left(80)+' '+theTask.ActivityDate+' '+Label.smsUrl+theTask.id;
                String thePhone = [select MobilePhone from User where ID = :theTask.OwnerID].MobilePhone;
                sendSmsClass.sendSms(thePhone,theText);
            }
            
            if(theTask.Subject != System.Label.OppAssignment){
                if (theTask.SMS_reminder__c == null) {
                    theTask.sms_date_trigger__c=theTask.SMS_reminder__c;
                }else{
                    theTask.sms_date_trigger__c=theTask.SMS_reminder__c.addMinutes(-15);
                }  
            }

        }
    }
    if (Trigger.isInsert && Trigger.isBefore){
        for(Task theTask : Trigger.new){
            if(theTask.Subject != System.Label.OppAssignment){
                Date today=date.today();
                if (theTask.SMS_reminder__c == null) {         /*saroja-1/10/2015 - set default reminder time when user leave as blank*/ 
                    if (theTask.ActivityDate == null){
                        theTask.ActivityDate=today;
                    }
                    if (theTask.ActivityDate.isSameDay(today)){
                        theTask.SMS_reminder__c=DateTime.now().addHours(1);
                    }else{
        
                        theTask.SMS_reminder__c=DateTime.newInstance(theTask.ActivityDate.year(), theTask.ActivityDate.month(), theTask.ActivityDate.day(), 9, 0, 0);
                    }
                }
                theTask.sms_date_trigger__c=theTask.SMS_reminder__c.addMinutes(-15);
            }
        }
    }
}
/** ******
 * Description: Trigger for set branch code and franchise code
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger Trigger_FeedBack on Feedback__c (after insert) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    if(TriggerExclusion.isTriggerExclude('Feedback__c') 
        || TriggerExclusion.isBypassTriggerExecution('Feedback__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

     if (Trigger.isAfter && Trigger.isInsert)
     {
         try
      {
       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
   
       String name = '';
       String phoneNumber = '';
       String emailaddr = '';
       String category = '';
       String message = '';
       String regNumber = '';
       String lastVisitedCenter = '';
       String triggeredSendMessageId = '10045';
      for(Feedback__c feedck : trigger.new)
        {
          name = feedck.Name__c;
          phoneNumber = '' ;
              if(feedck.Mobile__c.length() == 8)
              {
                  
              String prefix = feedck.Mobile__c.substring(0,4);
              String postfix =  feedck.Mobile__c.substring(4,8);
              phoneNumber = prefix+' '+postfix;
              }
              if(feedck.Mobile__c.length() == 10)
              {
                  
              String prefix = feedck.Mobile__c.substring(0,6);
              String postfix =  feedck.Mobile__c.substring(6,10);
              phoneNumber = prefix+' '+postfix;
              }
          
               emailaddr = feedck.Email__c ;
               category = feedck.Category__c;
               message =  feedck.Message__c;
               regNumber = feedck.Registration_Number__c;
               lastVisitedCenter = feedck.Last_Visited_Service_Cent__c;
        } 
        SendFeedBackEmail.sendEmail(name, phoneNumber,category,message,regNumber,lastVisitedCenter,triggeredSendMessageId,emailaddr);
        //
        //System.enqueueJob( new SendFeedBackEmail(false, 0, name, phoneNumber,category,message,regNumber,lastVisitedCenter,triggeredSendMessageId,emailaddr));
     }
         
        catch(Exception e)
         {
             system.debug('Error'+e.getMessage());
         }
       
     }
        
                 
     }
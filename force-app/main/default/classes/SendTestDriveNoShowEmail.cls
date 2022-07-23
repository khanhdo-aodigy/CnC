/** *******
 * Class Name: SendTestDriveNoShowEmail
 * Description: Sends a Test Drive No Show Email
 * 				via Mktg Cloud Triggered Send
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20180913            Cycle & Carriage              Created Initial Version. 
 * 20200908            khanh.do@aodigy.com           Added PA - Phase 2 Changes
 * 
******* **/ 
public without sharing class SendTestDriveNoShowEmail implements Schedulable {
    
    //execute Schedule
    public void execute (SchedulableContext ctx)
    {   
        SendTestDriveNoShowEmail.sendTestDriveNoShowEmail(); 
    } 
    
    //Sends Test Drive No Show Email
    public static void sendTestDriveNoShowEmail() {

        List<Test_Drive__c> testDrive = [SELECT Id,
                                            Prospect__c,
                                            Prospect__r.Name,
                                            Branch_Code__c,
                                            Prospect__r.Email,
                                            Model__r.Name, 
                                            Opportunity__c,
                                            Opportunity__r.Owner.Name,
                                            Opportunity__r.Owner.MobilePhone,
                                            Account__c,
                                            Account__r.Name,
                                            Account__r.PersonEmail
                                         FROM Test_Drive__c 
                                         WHERE Date__c >= YESTERDAY
                                         AND Date__c < TODAY  	 
                                         AND Status__c = 'Pending'];  
        
        if( testDrive != null && !testDrive.isEmpty() )
        {
            for(Test_Drive__c tdrive : testDrive)
            {
                String emailAddr   = '';
                String contactName = '';
                String contactId   = tdrive.Prospect__c;
                if(tdrive.Prospect__c != null){
                    emailAddr = tdrive.Prospect__r.Email;
                    contactName = tdrive.Prospect__r.Name; 
                }
                
                if( !Test.isRunningTest() )
                {   
                    send_NoShowTriggeredEmail.sendNoShowEmail( emailAddr, tdrive.Branch_Code__c, tdrive.Model__r.Name, tdrive.Opportunity__r.Owner.Name,
                                                               tdrive.Opportunity__r.Owner.MobilePhone, contactId, contactName);
                }
            }
        }        
    }
}
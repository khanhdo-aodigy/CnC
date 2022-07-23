/** *****
 * Description : SendTestDriveCheckInReminderEmail
 *               Used in Flow "Send Test Drive Check In Reminder" to send out Reminder Email
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20211102            khanh.do@aodigy.com           Created Initial Version.
 * 
** *****/
public class SendTestDriveCheckInReminderEmail {
    @InvocableMethod  
    public static void sendEmail(List<List<String>> testDriveIdAndRecipientIds) {
        try{
            OrgWideEmailAddress orgWideEmail = [ SELECT Id, DisplayName, Address 
                                                FROM OrgWideEmailAddress 
                                                LIMIT 1];
            EmailTemplate template = [  SELECT Id, Body
                                        FROM EmailTemplate
                                        WHERE DeveloperName = 'Test_Drive_Check_In_Reminder'
                                        LIMIT 1
                                    ];
            
            System.debug('orgWideEmail = ' + orgWideEmail);
            System.debug('testDriveIdAndRecipientIds = ' + testDriveIdAndRecipientIds);

            String testDriveId = testDriveIdAndRecipientIds[0][0];
            String consultantId = testDriveIdAndRecipientIds[0][1];
            System.debug('testDriveId = ' + testDriveId);
            System.debug('Sales Consultant Id = ' + consultantId);
    
            Test_Drive__c testDrive = [ SELECT Id, Owner.Name, Account__r.Name, Model__r.Name, Check_Out__c
                                        FROM Test_Drive__c
                                        WHERE Id = :testDriveId
            ];

            User consultant = [ SELECT Id, Name FROM User WHERE Id = :consultantId];

            System.debug('testDrive = ' + testDrive);
            System.debug('Sales Consultant = ' + consultant);

            List<Messaging.SingleEmailMessage > allmsg = new List<Messaging.SingleEmailMessage >();
            Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
            mail.setSubject('Please Check In the Test-Drive');
            mail.setTemplateID(template.Id);
            mail.setTargetObjectId(consultantId); //Send to consultant
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            testDriveIdAndRecipientIds[0].remove(0); //Remove Test Drive Id
            testDriveIdAndRecipientIds[0].remove(0); //Remove Sales Consultant Id
            mail.setCcAddresses(testDriveIdAndRecipientIds[0]); // CC managers

            //Set Email Body
            String plainBody = template.Body;
            plainBody = plainBody.replace('{!User.Name}', consultant.Name);
            plainBody = plainBody.replace('{!Test_Drive__c.Account__c}', testDrive.Account__r.Name);
            plainBody = plainBody.replace('{!Test_Drive__c.Model__c}', testDrive.Model__r.Name);
            plainBody = plainBody.replace('{!Test_Drive__c.Check_Out__c}', testDrive.Check_Out__c.format('dd/MM/yyyy HH:mm'));
            mail.setPlainTextBody(plainBody);

            allmsg.add(mail);
        
            Messaging.sendEmail(allmsg);
        } catch(Exception ex){
            System.debug('ex = ' + ex);
            loggerDataPool.buildLogDataPool('SendTestDriveCheckInReminderEmail', ex);
        }       

    }

}
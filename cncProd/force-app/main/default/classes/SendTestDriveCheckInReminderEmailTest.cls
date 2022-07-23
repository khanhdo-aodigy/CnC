@IsTest
private class SendTestDriveCheckInReminderEmailTest {
    @TestSetup
    private static void setup(){
        EmailTemplate email = new EmailTemplate();
        email.DeveloperName = 'Test_Drive_Check_In_Reminder';
        email.FolderId = UserInfo.getUserId();
        email.TemplateType= 'Text';
        email.Name = 'Test_Drive_Check_In_Reminder';
        email.Body = 'Hi {!User.Name},'
            		+ 'Your test drive has exceeded 45 minutes based on the check out time.'
                    + '- Name of Customer: {!Test_Drive__c.Account__c}'
                    + '- Vehicle (Model Name): {!Test_Drive__c.Model__c}'            
                    + '- Check out Date and Time: {!Test_Drive__c.Check_Out__c}';
		insert email;
    }
    
	@IsTest
    private static void testSendMail(){
        Account pa = Test_DataFactory.createPA(true, 'Miew Miew', 'miewmiew@test.com', 'Customer');
		pa = [SELECT Id, PersonContactId FROM Account WHERE Id = :pa.Id];

        Model__c model = Test_DataFactory.createmodelId(true, 'modelName', 'CCK', 'KIAPC');
        Variant__c variant = Test_DataFactory.createVariant(true, 'variantName', model.Id, 'CCK');
        Vehicle_Master__c vehicleMaster = Test_DataFactory.createVehicleMaster(true, 'name', variant.Id, model.Id); 
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'Miew Miew', pa.Id);
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, opp.Id);
        testDrive.Account__c = pa.Id;
        testDrive.Model__c = vehicleMaster.Id;
        testDrive.Check_Out__c = Datetime.now();
        insert testDrive;
        		        
        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name='End User'].Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@abcd.com';   
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;      
        user.ContactId = pa.PersonContactId;
        insert user;
        
        List<List<String>> recipientIds = new List<List<String>>();
        recipientIds.add(new List<String>{testDrive.Id, user.Id});
        SendTestDriveCheckInReminderEmail.sendEmail(recipientIds);
        
    }
}
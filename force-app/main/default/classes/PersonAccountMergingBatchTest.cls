@isTest
private class PersonAccountMergingBatchTest {

    @isTest
    private static void testPersonAccountMergingBatch() {
        PersonAccountMergingService.bypassAutomation(true);
        Account primaryAcc = Test_DataFactory.createPA(false, 'Benjamin', 'ben@test.com', 'Customer');
        primaryAcc.Is_Primary_Account__c = true;
        insert primaryAcc;        
        
        Account dupAcc = Test_DataFactory.createPA(false, 'Benjamin', 'ben@test.com', 'Customer');
        dupAcc.is_Duplicated__pc = true;
        dupAcc.Primary_Account_ID__c = primaryAcc.Id;
        insert dupAcc;
        
        dupAcc = [ SELECT Id, PersonContactId
                       FROM Account
                       WHERE is_Duplicated__pc = true
                     ];
        
        List<CustomerAlerts__c> custAlertLst = new List<CustomerAlerts__c>();
        List<Registered_Vehicle__c> rvLst = new List<Registered_Vehicle__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Test_Drive__c> testDriveList = new List<Test_Drive__c>();
        List<Case> caseList = new List<Case>();
        List<Feedback__c> feedbackList = new List<Feedback__c>();
        
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(false, 'Individual', 'CCK', 'KIA', 'Accessories Credit');
        rewardProfile.Contact__c = dupAcc.PersonContactId;
        insert rewardProfile;
        List<Reward__c> rwList = new List<Reward__c>();
        
       for(Integer i = 0; i < 10 ; i++) {
            Opportunity opp = Test_DataFactory.createOpportunity(false, 'Ben-Dup', dupAcc.Id);
            oppList.add(opp);
            
            Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, opp.Id);
            testDrive.Account__c = dupAcc.Id;
            testDrive.Prospect__c = dupAcc.PersonContactId;
            testDriveList.add(testDrive);
            
            Case dummyCase = Test_DataFactory.createCase(false, dupAcc.PersonContactId);
            dummyCase.Account__c = dupAcc.Id;
            caseList.add(dummyCase);
            
            Feedback__c feedback = Test_DataFactory.createFeedback(false, 'That good');
            feedback.Account__c = dupAcc.Id;
            feedbackList.add(feedback);        
           
            CustomerAlerts__c cusAlert = Test_DataFactory.createCusAlert(false, 'Test Alert', dupAcc.PersonContactId);
            cusAlert.Account__c = dupAcc.Id;
            custAlertLst.add(cusAlert);
            
            Registered_Vehicle__c regVehicle = Test_DataFactory.createRegVehicle(false, 'Test Name', 'CCK', 'KIAPC', '74L1666', dupAcc.PersonContactId);
			regVehicle.Account__c = dupAcc.Id;
            rvLst.add(regVehicle);
           
            Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(5));
            reward.Credit__c = 1000;
            reward.Contact__c = dupAcc.PersonContactId;
        	rwList.add(reward);
        }
        insert oppList;
        insert testDriveList;
        insert caseList;
        insert feedbackList;
        insert custAlertLst;
        insert rvLst;
        insert rwList;
        
        Database.executeBatch(new PersonAccountMergingBatch());
    }
    
    @isTest
    private static void testMergeDupPortalCustomer() {
        User admin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Account primaryPA = Test_DataFactory.createPA(false, 'Benjamin','ben@test.com', 'Customer');
        primaryPA.Is_Primary_Account__c = true;
        insert primaryPA;
        
        Profile endUserProfile = [ SELECT Id FROM Profile WHERE Name = 'End User'];
        Account dupPA = Test_DataFactory.createPA(false, 'Benjamin','ben@test.com', 'Customer');
        dupPA.is_Duplicated__pc = true;
        dupPA.Primary_Account_ID__c = primaryPA.Id;
        insert dupPA;
        
        dupPA = [ SELECT Id, PersonContactId FROM Account WHERE Id = :dupPA.Id];
        User dupPortalUser = new User(
            ProfileId = endUserProfile.Id,
            Username = 'ben2@test.com',
            Alias = 'ben2',
            Email ='ben@test.com',
            ContactId = dupPA.PersonContactId,
            EmailEncodingKey ='UTF-8',
            Firstname ='Bruce',
            Lastname ='Benjamin',
            LanguageLocaleKey ='en_US',
            LocaleSidKey ='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        System.runAs(admin) {
            insert dupPortalUser;
        }
        Database.executeBatch(new PersonAccountMergingBatch());
    }
    
    @isTest
    private static void testMergeReferral() {
        Test.startTest();
            Account primaryCust = Test_DataFactory.createPA(false, 'Benjamin', 'ben@test.com', 'Customer');
            primaryCust.Is_Primary_Account__c = true;
            insert primaryCust;        
            
            Account dupCust = Test_DataFactory.createPA(false, 'Benjamin', 'ben@test.com', 'Customer');
        	dupCust.is_Duplicated__pc = true;
        	dupCust.Primary_Account_ID__c = primaryCust.Id;
        	insert dupCust;
            
            Account primaryPros = Test_DataFactory.createPA(false, 'Bin', 'bin@test.com', 'Prospect');  
            primaryPros.Is_Primary_Account__c = true;
            insert primaryPros;
    
            Account dupPros = Test_DataFactory.createPA(false, 'Bin', 'bin@test.com', 'Prospect');
        	dupPros.is_Duplicated__pc = true;
        	dupPros.Primary_Account_ID__c = primaryPros.Id;
        	insert dupPros;
            
            Referral__c dupReferee = Test_DataFactory.createReferral(true, primaryCust.Id, dupPros.Id);
            Referral__c dupReferrer = Test_DataFactory.createReferral(true, dupCust.Id, primaryPros.Id);
            Referral__c dupBoth = Test_DataFactory.createReferral(true, dupCust.Id, dupPros.Id);
        Test.stopTest();
        Database.executeBatch(new PersonAccountMergingBatch());
    }

}
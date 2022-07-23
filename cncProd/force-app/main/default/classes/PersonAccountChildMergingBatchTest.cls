@isTest
private class PersonAccountChildMergingBatchTest {
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
        
       for(Integer i = 0; i < 100 ; i++) {
           	CustomerAlerts__c cusAlert = Test_DataFactory.createCusAlert(false, 'Test Alert', dupAcc.PersonContactId);
            cusAlert.Account__c = dupAcc.Id;
            custAlertLst.add(cusAlert);
            
            Registered_Vehicle__c regVehicle = Test_DataFactory.createRegVehicle(false, 'Test Name', 'CCK', 'KIAPC', '74L1666', dupAcc.PersonContactId);
			regVehicle.Account__c = dupAcc.Id;
            rvLst.add(regVehicle);
           
            Opportunity opp = Test_DataFactory.createOpportunity(false, 'Ben-Dup', dupAcc.Id);
            oppList.add(opp);
            
            Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, opp.Id);
            testDrive.Account__c = dupAcc.Id;
            testDrive.Prospect__c = dupAcc.PersonContactId;
            testDriveList.add(testDrive);
            
            Case dummyCase = Test_DataFactory.createCase(false, dupAcc.PersonContactId);
            dummyCase.Account__c = dupAcc.Id;
            caseList.add(dummyCase);
            
			Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(5));
            reward.Credit__c = 1000;
            reward.Contact__c = dupAcc.PersonContactId;
        	rwList.add(reward);           
        }
        insert custAlertLst;
        insert rvLst;
        insert oppList;
        insert testDriveList;
        insert caseList;
        insert feedbackList;
        insert rwList;
        System.debug('case before ::' + caseList[0]);
        List<String> listChildObjs = new List<String>{'CustomerAlerts__c', 'Registered_Vehicle__c', 'Opportunity', 'Test_Drive__c', 'Case', 'Feedback__c', 'Reward_Profile__c', 'Reward__c'};
        Database.executeBatch(new PersonAccountChildMergingBatch(listChildObjs, new Set<Id>{dupAcc.Id}));
        
        caseList = [SELECT Id, ACcountId, COntactId from Case];
        System.debug('case after ::' + caseList[0]);
    }
}
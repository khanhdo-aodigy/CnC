@isTest
public class CMGetUsageTransactionsAPITest {
    private static String regVehNo;
	@testSetUp
    private static void createData(){
         Account personAcc = Test_DataFactory.createPerson(true, 'Lee', 'Customer');
          personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];

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
          user.ContactId = personAcc.PersonContactId;        
          insert user;
       
        Registered_Vehicle__c dummyRegVeh = Test_DataFactory.createRegVehicle(true, 'Fake Name', 'CCK', 'KIAPC', 'Fake No 1', personAcc.PersonContactId);
        
        Reward_Profile__c fleetRewardProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        fleetRewardProfile.Registered_Vehicle__c = dummyRegVeh.Id;
        insert fleetRewardProfile;
        
        Reward_Profile__c individualRewardProfile = Test_DataFactory.createRewardProfile(false, 'Individual', 'CCK', 'KIA', 'Accessories Credit');
        individualRewardProfile.Registered_Vehicle__c = dummyRegVeh.Id;
        insert individualRewardProfile;
        
        Reward__c fleetReward = Test_DataFactory.createReward(false, fleetRewardProfile.Id, fleetRewardProfile.Type__c, 'Valid', Date.today().addDays(15));
    	fleetReward.Brand__c = 'KIA';
        fleetReward.Registered_Vehicle__c = dummyRegVeh.Id;
        insert fleetReward;
        Reward_Usage__c fleetUsage = Test_DataFactory.createRewardUsage(false, fleetReward.Id, 'Hold', 'Debit');
        fleetUsage.Transaction_Date__c = Date.today().addDays(-90);
        insert fleetUsage;
        
        Reward__c reward = Test_DataFactory.createReward(false, fleetRewardProfile.Id, individualRewardProfile.Type__c, 'Valid', Date.today().addDays(15));
    	reward.Brand__c = 'KIA';
        reward.Registered_Vehicle__c = dummyRegVeh.Id;
        insert reward;
        Reward_Usage__c rewardUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Hold', 'Debit');        
        rewardUsage.Transaction_Date__c = Date.today().addDays(-90);
        insert rewardUsage;
        
        regVehNo = [SELECT Name FROM Registered_Vehicle__c LIMIT 1].Name;
    }
    
       
    @isTest
	private static void testGetRewardProfile_IndividualType_HappyPath(){
        String userId = [SELECT Id FROM User WHERE UserName = 'test@abcd.com' LIMIT 1].Id;
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "Individual","UserId": "' + userId + '","VehNumber": "","Brand": "KIA", "PreviousMonth": 3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest(); 
    }
    
    @isTest
	private static void testGetRewardProfile_FleetType_HappyPath(){
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "Fleet","UserId": "","VehNumber": "' + regVehNo +'","Brand": "KIA", "PreviousMonth": 3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest(); 
    }
    
    @isTest
	private static void testGetRewardProfile_InvalidBrand(){
        String userId = [SELECT Id FROM User WHERE UserName = 'test@abcd.com' LIMIT 1].Id;
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "Individual","UserId": "' + userId + '","VehNumber": "","Brand": "HIHIHI", "PreviousMonth": 3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest(); 
    }
    
    @isTest
	private static void testGetRewardProfile_InvalidPreviousMonths(){
        String userId = [SELECT Id FROM User WHERE UserName = 'test@abcd.com' LIMIT 1].Id;
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "Individual","UserId": "' + userId + '","VehNumber": "","Brand": "KIA", "PreviousMonth": -3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest(); 
    }
    
    @isTest
	private static void testGetRewardProfile_InvalidUserId(){
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "Individual","UserId": "001O0000005JHSXXX","VehNumber": "","Brand": "KIA", "PreviousMonth": 3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest(); 
    }
    
    @isTest
	private static void testGetRewardUsage_RequestWithNullProfileType_ErrorResponses(){
        String userId = [SELECT Id FROM User WHERE UserName = 'test@abcd.com' LIMIT 1].Id;
        String profileType = '';
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "'+ profileType + '","UserId": "' + userId + '","VehNumber": "","Brand": "KIA", "PreviousMonth": 3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest();
    }

	@isTest
	private static void testGetRewardUsage_RequestWithInvalidProfileType_ErrorResponses(){
        String userId = [SELECT Id FROM User WHERE UserName = 'test@abcd.com' LIMIT 1].Id;
        String profileType = 'FakeGroup';
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "'+ profileType + '","UserId": "' + userId + '","VehNumber": "","Brand": "KIA", "PreviousMonth": 3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest();
    }
    
    
    @isTest
	private static void testGetRewardUsage_FleetTypeWithNullVehNo_ErrorReturned(){
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "Fleet","UserId": "","VehNumber": "","Brand": "KIA", "PreviousMonth": 3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest();
    }
    
    @isTest
	private static void testGetRewardUsage_IndividualTypeWithNullUserId_ErrorReturned(){
        String profileType = 'Individual';
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "' + profileType + '","UserId": "","VehNumber": "","Brand": "KIA", "PreviousMonth": 3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest();
    }
    
    @isTest
	private static void testGetRewardUsage_InvalidVehNo_ErrorReturned(){
        String regVeNo = 'NONEEXIST1';
        Test.startTest();
        String reqURI = '/RewardUsage/retrieve/*'; 
        String reqBody = '{"ProfileType": "Fleet","UserId": "","VehNumber": "'+regVeNo+'","Brand": "KIA", "PreviousMonth": 3}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetUsageTransactionsAPI.getRewardUsage();
        Test.stopTest();
    }

}
/** *****
 * Description : Test Class for CMGetRewardProfileAPI.cls
 * 
 * Change History
 * Date(YYYYMMDD)       Name                            Description
 * 20200706             khanh.do@aodigy.com             Created Initial Version. 
 * 
** *****/
@isTest
private class CMGetRewardProfileAPITest {
    @testSetUp
    private static void createData(){
        Account dummyAcc = Test_DataFactory.createAccount(true, 'Company');
        Contact dummyCon = Test_DataFactory.createContact(true, 'Test', 'Test', dummyAcc.Id);
       
        Registered_Vehicle__c dummyRegVeh = Test_DataFactory.createRegVehicle(true, 'Fake Name', 'CCK', 'KIAPC', 'Fake No 1', dummyCon.Id);
        
        Reward_Profile__c fleetRewardProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        fleetRewardProfile.Registered_Vehicle__c = dummyRegVeh.Id;
        insert fleetRewardProfile;
        Reward__c reward = Test_DataFactory.createReward(true, fleetRewardProfile.Id, fleetRewardProfile.Type__c, 'Valid', Date.today().addDays(15));
    }
    
    @isTest
	private static void testGetRewardProfile_FleetType_HappyPath(){
        String regVehNo = [SELECT Name FROM Registered_Vehicle__c LIMIT 1].Name;
        String brand = 'KIA';
        Test.startTest();
        String reqURI = '/RewardProfiles/retrieve/*'; 
        String reqBody = '{"ProfileType": "Fleet","UserId": "","VehNumber": "'+regVehNo+'","Brand": "'+ brand +'"}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetRewardProfileAPI.getRewardProfiles();
        Test.stopTest();
    }
    
    @isTest
	private static void testGetRewardProfile_IndividualType_HappyPath(){
        Test.startTest();
        String reqURI = '/RewardProfiles/retrieve/*'; 
        String reqBody = '{"ProfileType": "Individual","UserId": "005O0000005JHS0IAO","VehNumber": "","Brand": "KIA"}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetRewardProfileAPI.getRewardProfiles();
        Test.stopTest();
    }
    
    @isTest
	private static void testGetRewardProfile_RequestWithNullProfileType_ErrorResponses(){
        String profileType = '';
        Test.startTest();
        String reqURI = '/RewardProfiles/retrieve/*'; 
        String reqBody = '{"ProfileType": "' + profileType + '","UserId": "","VehNumber": "","Brand": "KIA"}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetRewardProfileAPI.getRewardProfiles();
        Test.stopTest();
    }

	@isTest
	private static void testGetRewardProfile_RequestWithInvalidProfileType_ErrorResponses(){
        String profileType = 'FakeGroup';
        Test.startTest();
        String reqURI = '/RewardProfiles/retrieve/*'; 
        String reqBody = '{"ProfileType": "' + profileType + '","UserId": "","VehNumber": "","Brand": "KIA"}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetRewardProfileAPI.getRewardProfiles();
        Test.stopTest();
    }

    
    @isTest
	private static void testGetRewardProfile_FleetTypeWithNullVehNo_ErrorReturned(){
        Test.startTest();
        String reqURI = '/RewardProfiles/retrieve/*'; 
        String reqBody = '{"ProfileType": "Fleet","UserId": "","VehNumber": "","Brand": "KIA"}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetRewardProfileAPI.getRewardProfiles();
        Test.stopTest();
    }
    
    @isTest
	private static void testGetRewardProfile_IndividualTypeWithNullUserId_ErrorReturned(){
        String profileType = 'Individual';
        Test.startTest();
        String reqURI = '/RewardProfiles/retrieve/*'; 
        String reqBody = '{"ProfileType": "' + profileType + '","UserId": "","VehNumber": "","Brand": "KIA"}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetRewardProfileAPI.getRewardProfiles();
        Test.stopTest();
    }
    
    @isTest
	private static void testGetRewardProfile_InvalidVehNo_ErrorReturned(){
        String regVeNo = 'NONEEXIST1';
        Test.startTest();
        String reqURI = '/RewardProfiles/retrieve/*'; 
        String reqBody = '{"ProfileType": "Fleet","UserId": "","VehNumber": "'+regVeNo+'","Brand": "KIA"}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetRewardProfileAPI.getRewardProfiles();
        Test.stopTest();
    }
    
    @isTest
	private static void testGetRewardProfile_InvalidUserId_ErrorReturned(){
        String userId = '003O00000024OjhIAE';
        Test.startTest();
        String reqURI = '/RewardProfiles/retrieve/*'; 
        String reqBody = '{"ProfileType": "Individual","UserId": "'+userId+'","VehNumber": "","Brand": "KIA"}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CMGetRewardProfileAPI.getRewardProfiles();
        Test.stopTest();
    }
}
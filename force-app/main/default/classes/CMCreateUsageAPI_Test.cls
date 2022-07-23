/** ******
 * Description : Test class for CMCreateUsageAPI.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200707             TP@aodigy       Created Initial Version. 
 * 
** ******/
@isTest
private class CMCreateUsageAPI_Test 
{
	@testSetup
    static void setUp()
    {
        Account acct = Test_DataFactory.createAccount(true, 'Company');
        Contact con = Test_DataFactory.createContact(true, 'Test', 'Test', acct.Id);
        Order__c order = Test_DataFactory.createOrder(Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('C_C_E_Shop').getRecordTypeId());
        order.Shop__c = 'KIA';
        insert order;
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(true, 'TEST', 'CCK', 'KIAPC', 'ABC987655', con.Id);
        Registered_Vehicle__c regVehicle1 = Test_DataFactory.createregVehicle(true, 'TEST', 'CCK', 'KIAPC', 'ABC9876556', con.Id);
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(5));
        reward.Credit__c = 1000;
        reward.Registered_Vehicle__c = regVehicle.Id;
        insert reward;
        Reward__c reward1 = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(10));
        reward1.Credit__c = 2000;
        reward1.Registered_Vehicle__c = regVehicle.Id;
        insert reward1;  
        Reward__c reward2 = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(10));
        reward2.Credit__c = 2000;
        reward2.Registered_Vehicle__c = regVehicle1.Id;
        insert reward2;  
    }
    
    @isTest
    static void Test_createRewardUsages_RewardProfile_Success()
    {
        Reward_Profile__c rewardProfile = [SELECT ID FROM Reward_Profile__c];
        String reqBody = '{"UserId":"005280000055uQ1","Branch":"CCK","Brand":"KIA","OrderID":"ABCDE","OrderNumber":"12345ABC","TotalAmount":5000,"Channel":"eShop","VehicleRegNum":"ABC987655","FIFO":true,"Usage":[{"RewardProfileId":'
                          + '\"' + rewardProfile.Id + '\"'
                          + ',"CreditType":"Accessories Credit","TransactionType":"Debit","CreditAmount":1000}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/RewardUsage/insert';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        CMCreateUsageAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void Test_createRewardUsages_RewardProfile_Error()
    {
        Reward_Profile__c rewardProfile = [SELECT ID FROM Reward_Profile__c];
        String reqBody = '{"UserId":"005280000055uQ1","Branch":"CCK","Brand":"KIA","OrderID":"ABCDE","OrderNumber":"12345ABC","TotalAmount":5000,"Channel":"eShop","VehicleRegNum":"ABC987655","FIFO":true,"Usage":[{"RewardProfileId":'
                          + '\"' + rewardProfile.Id + '\"'
                          + ',"CreditType":"Accessories Credit","TransactionType":"Debit","CreditAmount":4000}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/RewardUsage/insert';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        CMCreateUsageAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void Test_createRewardUsages_VehicleRegisteredNo()
    {
        Reward_Profile__c rewardProfile = [SELECT ID FROM Reward_Profile__c];
        String reqBody = '{"UserId":"005280000055uQ1","Branch":"CCK","Brand":"KIA","OrderID":"ABCDE","OrderNumber":"12345ABC","TotalAmount":5000,"Channel":"eShop","VehicleRegNum":"ABC987655","FIFO":false,"Usage":[{"RewardProfileId":'
                          + '\"' + rewardProfile.Id + '\"'
                          + ',"CreditType":"Accessories Credit","TransactionType":"Debit","CreditAmount":1000}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/RewardUsage/insert';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        CMCreateUsageAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void Test_createOneRewardUsage_VehicleRegisteredNo()
    {
        Reward_Profile__c rewardProfile = [SELECT ID FROM Reward_Profile__c];
        String reqBody = '{"UserId":"005280000055uQ1","Branch":"CCK","Brand":"KIA","OrderID":"ABCDE","OrderNumber":"12345ABC","TotalAmount":5000,"Channel":"eShop","VehicleRegNum":"ABC9876556","FIFO":false,"Usage":[{"RewardProfileId":'
                          + '\"' + rewardProfile.Id + '\"'
                          + ',"CreditType":"Accessories Credit","TransactionType":"Debit","CreditAmount":1000}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/RewardUsage/insert';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        CMCreateUsageAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void Test_createOneRewardUsage_VehicleRegisteredNo_Case2()
    {
        Reward_Profile__c rewardProfile = [SELECT ID FROM Reward_Profile__c];
        String reqBody = '{"UserId":"005280000055uQ1","Branch":"CCK","Brand":"KIA","OrderID":"ABCDE","OrderNumber":"12345ABC","TotalAmount":5000,"Channel":"eShop","VehicleRegNum":"ABC9876556","FIFO":false,"Usage":[{"RewardProfileId":'
                          + '\"' + rewardProfile.Id + '\"'
                          + ',"CreditType":"Accessories Credit","TransactionType":"Debit","CreditAmount":2000}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/RewardUsage/insert';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        CMCreateUsageAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void Test_createRewardUsages_VehicleRegisteredNo_Error()
    {
        Reward_Profile__c rewardProfile = [SELECT ID FROM Reward_Profile__c];
        String reqBody = '{"UserId":"005280000055uQ1","Branch":"CCK","Brand":"KIA","OrderID":"ABCDE","OrderNumber":"12345ABC","TotalAmount":5000,"Channel":"eShop","VehicleRegNum":"DEF73657345","FIFO":false,"Usage":[{"RewardProfileId":'
                          + '\"' + rewardProfile.Id + '\"'
                          + ',"CreditType":"Accessories Credit","TransactionType":"Debit","CreditAmount":1000}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/RewardUsage/insert';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        CMCreateUsageAPI.doPost();
        Test.stopTest();
    }
}
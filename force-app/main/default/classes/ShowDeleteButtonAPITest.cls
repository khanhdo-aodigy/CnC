@isTest
private class ShowDeleteButtonAPITest {
	@testSetup
    static void setUp()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT PersonContactId FROM Account];
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'End User' Limit 1];
        User u = new User(Alias = 'ksa2',
                          Email='patest@mail.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          FirstName= 'First',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = portalProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='patest@mail.com', 
                          ContactId= personAcc.PersonContactId, 
                          isValid__c = true);
        insert u;
    }

    @isTest
    static void Test_NoError()
    {
        User u = [SELECT Id FROM USER WHERE UserName = 'patest@mail.com'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/ShowDeleteButton/' + u.Id;
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200, null));
        ShowDeleteButtonAPI.ShowDeleteButtonAPI();
        Test.stopTest();
    }

    @isTest
    static void Test_Error_EmptyUserId()
    {
        User u = [SELECT Id FROM USER WHERE UserName = 'patest@mail.com'];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/ShowDeleteButton/';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(400, null));
        ShowDeleteButtonAPI.ShowDeleteButtonAPI();
        Test.stopTest();
    }

    @isTest
    static void Test_Error_InvalidUserId()
    {
        User u = [SELECT Id FROM USER WHERE UserName = 'patest@mail.com'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/ShowDeleteButton/testUserId';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(400, null));
        ShowDeleteButtonAPI.ShowDeleteButtonAPI();
        Test.stopTest();
    }

    @isTest
    static void Test_Error_NoPA()
    {
        User u = [SELECT Id FROM USER WHERE UserName = 'patest@mail.com'];
        Account personAcc = [SELECT Id FROM Account WHERE PersonEmail = 'patest@mail.com'];
        personAcc.PersonEmail = 'patest1@mail.com';
        TriggerExclusion.excludeTrigger('Account',true);
        update personAcc;
        TriggerExclusion.excludeTrigger('Account',false);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/ShowDeleteButton/' + u.Id;
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(400, null));
        ShowDeleteButtonAPI.ShowDeleteButtonAPI();
        Test.stopTest();
    }
}
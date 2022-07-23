@isTest
private with sharing class DocusignJWT_Test {
    
    @testSetup
    private static void setUp(){
        User testUser = Test_DataFactory.createUser(false, 'Test DocuSign Callout', 'Test');
        testUser.dsfs__DSProSFUsername__c = 'TESTUSERNAME';
        insert testUser;
    }

    @isTest
    private static void getAccessToken_Admin() {
        Test.setMock(HttpCalloutMock.class, new DocusignJWTMockResponse());
        Test.startTest();
        HttpResponse response = DocusignJWT.getAccessToken();
        Test.stopTest();
        system.assertEquals(200, response.getStatusCode());
    }
    
    @isTest
    private static void accessTokenResponseProcess() {
        DocusignJWTMockResponse mockGenerator = new DocusignJWTMockResponse();
        HttpResponse response = mockGenerator.respond(new HttpRequest());
        string access_token = DocusignJWT.accessTokenResponseProcess(response);
        system.assertEquals('MOCK_ACCESS_TOKEN', access_token);
    }

    @isTest
    static void getAccessToken_Test_SOBO() {
        User testUser = [SELECT ID FROM User WHERE Email = 'test@jcc.com'];
        string recordOwnerId = testUser.ID;
        Test.setMock(HttpCalloutMock.class, new DocusignJWTMockResponse());
        Test.startTest();
        HttpResponse response = DocusignJWT.getAccessToken(recordOwnerId);
        Test.stopTest();
        system.assertEquals(200, response.getStatusCode());
    }
}
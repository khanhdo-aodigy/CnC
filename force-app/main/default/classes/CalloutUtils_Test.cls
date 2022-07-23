@isTest
public with sharing class CalloutUtils_Test {
    
    @isTest
    private static void envelopeCreateRequest_Test() {
        string ACCOUNT_ID = '123456';
        string ACCESS_TOKEN = 'ACCESSTOKEN';
        string BOUNDARY = 'TEST_BOUNDARY';
        string body = 'TEST_BODY';
        string endPoint = 'https://eu.docusign.net/restapi/v2.1/accounts/' + ACCOUNT_ID + '/envelopes/';

        HttpRequest testRequest = CalloutUtils.envelopeCreateRequest(ACCOUNT_ID, ACCESS_TOKEN, BOUNDARY, body);
        system.assertEquals(body, testRequest.getBody());
        system.assertEquals(endPoint, testRequest.getEndpoint());
    }

    @isTest
    private static void signingGroupUsersUpdate_Test_DELETE() {
        string ACCOUNT_ID = '123456';
        string ACCESS_TOKEN = '123456';
        string signingGroupID = '123456';
        string body = 'TEST_BODY';
        boolean isDelete = true;

        Test.setMock(HttpCalloutMock.class, new DocusignMockHttpResponseGenerator());
        
        Test.startTest();
        HttpResponse response = CalloutUtils.signingGroupUsersUpdate(ACCOUNT_ID, ACCESS_TOKEN, signingGroupID, body, isDelete);
        system.assert(response.getBody() != null);
        Test.stopTest();
    }

    @isTest
    private static void signingGroupUsersUpdate_Test_PUT() {
        string ACCOUNT_ID = '123456';
        string ACCESS_TOKEN = '123456';
        string signingGroupID = '123456';
        string body = 'TEST_BODY';
        boolean isDelete = false;

        Test.setMock(HttpCalloutMock.class, new DocusignMockHttpResponseGenerator());
        
        Test.startTest();
        HttpResponse response = CalloutUtils.signingGroupUsersUpdate(ACCOUNT_ID, ACCESS_TOKEN, signingGroupID, body, isDelete);
        system.assert(response.getBody() != null);
        Test.stopTest();
    }
    
    @isTest
    private static void getBaseURI() {
        Test.setMock(HttpCalloutMock.class, new DocusignGetBaseUriMockResponse());
        Test.startTest();
        HttpResponse response = CalloutUtils.getBaseURI('ACCESS_TOKEN');
        system.assertEquals(200, response.getStatusCode());
        system.assert(!string.isBlank(response.getBody()));
        Test.stopTest();
    }
    
    @isTest
    private static void baseUriResponseProcess_Test() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"sub":"c0331450-4277-4697-adc1-8afb7c2478b9","name":"Aaron Cycle","given_name":"Aaron","family_name":"Cycle","created":"2019-08-27T08:33:19.53","email":"a.aodigy@gmail.com","accounts":[{"account_id":"1b031c3d-4437-4807-a579-64d44f9e9b30","is_default":false,"account_name":"Aodigy Asia Pacific Pte Ltd","base_uri":"https://eu.docusign.net"},{"account_id":"bee1e3b0-2576-4df4-a794-7f51e96a9d0a","is_default":false,"account_name":"Aaron Cycle","base_uri":"https://eu.docusign.net"},{"account_id":"7ff318cb-0f56-425f-b617-56f7cdfcb1e4","is_default":false,"account_name":"Cycle & Carriage","base_uri":"https://eu.docusign.net"},{"account_id":"1bb2b796-c7a0-4d1c-a36a-dafd4d0a8e17","is_default":true,"account_name":"Aodigy Asia Pacific Pte. Ltd.","base_uri":"https://eu.docusign.net"},{"account_id":"edfbc09d-1dd9-4467-b66a-6773057d6567","is_default":false,"account_name":"Aodigy Asia Pacific Pte. Ltd.","base_uri":"https://eu.docusign.net"}]}');
        string baseURI = CalloutUtils.baseUriResponseProcess(mockResponse);
        system.assertEquals('https://eu.docusign.net/', baseURI);
    }
}
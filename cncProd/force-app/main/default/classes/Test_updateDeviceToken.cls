@isTest
global class Test_updateDeviceToken implements  HttpCalloutMock {
    private static String deviceId = '432454354645656';
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        return res;
    }
    
    @testSetup
    static void createData(){
        Account personAcc = Test_DataFactory.createPerson(true, 'Last Name', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.NRIC_Passport_No__c = 'S7528446B';
        personCon.Device__c = deviceId;
        update personCon;     
    }
    
    @isTest
    static void testPositiveCase() {
        Contact personCon = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new Test_updateDeviceToken());
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='UpdateDeviceToken/v1/';//updatealternateemailaddress
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        UpdateDeviceToken.UpdateDeviceToken(personCon.Id, deviceId);
        Test.stopTest();
    }
    
    @isTest
    static void testCaseInvalidNRIC() 
    {
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new Test_updateDeviceToken());
        String nric = 'S171';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='UpdateDeviceToken/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        UpdateDeviceToken.UpdateDeviceToken(nric, deviceId);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    
    @isTest
    static void testCaseMissingRequiredField() {
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new Test_updateDeviceToken()); 
        String nric = '';
        String deviceId = '';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='UpdateDeviceToken/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        UpdateDeviceToken.UpdateDeviceToken(nric, deviceId);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
}
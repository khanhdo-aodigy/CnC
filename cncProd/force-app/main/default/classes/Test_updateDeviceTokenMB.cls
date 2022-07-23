@isTest
global class Test_updateDeviceTokenMB implements  HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        return res;
    }
    @TestSetup static void createData(){
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getFirstName());
        Contact con = Test_DataFactory.createContact(true, 'fname', 'lname', acc.Id);
        con.NRIC_Passport_No__c = 'ProdNRIC';
        con.Device__c = '432454354645656';
        update con;
        
    }
    static testMethod void testPositiveMethod() 
    { 
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new Test_updateDeviceTokenMB());
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        String deviceId = '432454354645656';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='UpdateDeviceToken/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        UpdateDeviceTokenMB.UpdateDeviceTokenMB(con.Id, deviceId);
        Test.stopTest();
    }
    static testMethod void testPositiveMethodPA() 
    { 
        Account pa = Test_DataFactory.createPerson(true, 'PA', 'PersonAccount');
        pa.NRIC_Passport_No__pc = 'ProdNRIC';
        update pa;
        Contact personCon = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new Test_updateDeviceTokenMB());
        String nric = 'ProdNRIC';
        String deviceId = '432454354645656';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='UpdateDeviceToken/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        UpdateDeviceTokenMB.UpdateDeviceTokenMB(personCon.Id, deviceId);
        Test.stopTest();
    }
    
    static testMethod void testNegativeInvalidMethod() 
    {
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new Test_updateDeviceTokenMB());
        String nric = 'S171';
        String deviceId = '432454354645656';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='UpdateDeviceTokenMB/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        UpdateDeviceTokenMB.UpdateDeviceTokenMB(nric, deviceId);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    static testMethod void testNegativeBlankMethod() 
    {
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new Test_updateDeviceTokenMB()); 
        String nric = '';
        String deviceId = '';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='UpdateDeviceTokenMB/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        UpdateDeviceTokenMB.UpdateDeviceTokenMB(nric, deviceId);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
}
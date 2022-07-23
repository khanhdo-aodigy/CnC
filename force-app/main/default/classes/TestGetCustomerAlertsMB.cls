@IsTest
global  with sharing class TestGetCustomerAlertsMB {
     @testSetup
    public static void createData(){
        Account acct = Test_DataFactory.createAccount(true, 'nameA');
        
        Account acc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        acc.NRIC_Passport_No__pc = '198400907Z';
        update acc;
        Contact con = Test_DataFactory.createContact(false, 'fname', 'lname', acct.Id);
        //con.Account__c = acc.Id;
        con.NRIC_Passport_No__c = '198400907Z';
        insert con;
        
        CustomerAlerts__c ca = Test_DataFactory.createCusAlert(false, 'name', con.Id);
        ca.Account__c = acc.Id;
        ca.Contact__c = con.Id;
        insert ca;
    }
    //Valid NRIC
    @isTest global static void testPositiveGetMethod() 
    {
        getCustomerAlertsMB obj = new getCustomerAlertsMB();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerAlertsMB/v1/198400907Z';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        getCustomerAlertsMB.getAlertsMB();
        //System.assert(response.statusCode == 200);
        //System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
        System.assertEquals( 1 , [Select Count() From CustomerAlerts__c WHERE Account__r.NRIC_Passport_No__pc = '198400907Z' OR Contact__r.NRIC_Passport_No__c = '198400907Z']);

    }
    
    //NRIC is blank 
    
    @isTest global static void testBlankNRICGetMethod() 
    {       
        getCustomerAlertsMB obj = new getCustomerAlertsMB();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerAlerts/v1/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        getCustomerAlertsMB.getAlertsMB();
        System.assert(response.statusCode == 400);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
        System.assertEquals( 0 , [Select Count() From CustomerAlerts__c WHERE Account__r.NRIC_Passport_No__pc = '' OR Contact__r.NRIC_Passport_No__c = '']);

    }
    
    //Invalid NRIC 
    
    @isTest global static void testInvalidNRICGetMethod() 
    {       
        getCustomerAlertsMB obj = new getCustomerAlertsMB();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerAlerts/v1/23052018';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        getCustomerAlertsMB.getAlertsMB();
        //System.debug('Response Code =='+response.statusCode);
        //System.assert(response.statusCode == 200);
        
        Test.stopTest();
        System.assertEquals( 0, [Select Count() From CustomerAlerts__c WHERE Account__r.NRIC_Passport_No__pc = '' OR Contact__r.NRIC_Passport_No__c = '']);

    }
    
}
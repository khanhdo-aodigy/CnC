@IsTest(SeeAllData=true)
global  with sharing class testUpdateCustomerAlerts
{  
     //valid payload 
      
    @isTest global static void testPositiveGetMethod() 
    {
        String alertID = 'a0n0K00000G7x1x';
        String status = 'unread';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerAlerts/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        Map<String, String> responseMap =  updateCustomerAlerts.updateAlerts(alertID,status);
        System.assert(response.statusCode == 200);
        Test.stopTest();
    }
    
    // payload is blank 
    
    @isTest global static void testBlankIDGetMethod() 
    {
       
        String alertID = '';
        String status = '';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerAlerts/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        Map<String, String> responseMap =  updateCustomerAlerts.updateAlerts(alertID,status);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    
    //only alertid 
     @isTest global static void testBlankAlertIDGetMethod() 
    {
       
        String alertID = 'a0wO0000005ajbA';
        String status = '';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerAlerts/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        Map<String, String> responseMap =  updateCustomerAlerts.updateAlerts(alertID,status);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    
    
        
    //only status  
     @isTest global static void testBlankStatusGetMethod() 
    {
       
        String alertID = '';
        String status = 'unread';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerAlerts/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        Map<String, String> responseMap =  updateCustomerAlerts.updateAlerts(alertID,status);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    //wrong payload id
    
      @isTest global static void testWrongIDGetMethod() 
    {
         
         String alertID = 'a0wO0000005aj';
        String status = 'test';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCustomerAlerts/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        Map<String, String> responseMap =  updateCustomerAlerts.updateAlerts(alertID,status);
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
}
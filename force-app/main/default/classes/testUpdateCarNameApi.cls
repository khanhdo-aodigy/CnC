@IsTest(SeeAllData=true)
global  with sharing class testUpdateCarNameApi
{ 
     //valid payload 
      
    @isTest global static void testPositiveGetMethod() 
    {
        String vehicleId = 'a0s0K000005fymM';
        String carName = 'Deepak8';
        
       // String payLoad = '{"vehicleId": "a0qO0000009H5v4", "carName": "Deepak8"}' ;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCarName/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        Map<String, String> responseMap =  UpdateCarName.updateCarName(vehicleId,carName);
        System.assert(response.statusCode == 200);
        System.assert(responseMap.size()>0);
        System.debug('Map size=='+responseMap.size());
        Test.stopTest();
    }
    
    //blank payload is blank 
    
    @isTest global static void testBlankIDGetMethod() 
    {
       
        String vehicleId = '';
        String carName = '';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCarName/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        Map<String, String> responseMap =  UpdateCarName.updateCarName(vehicleId,carName);
        System.debug('Map size=='+responseMap.size());
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
    
    //wrong payload id
    
      @isTest global static void testWrongIDGetMethod() 
    {
         
        String vehicleId = 'a0qO00000';
        String carName = 'Deepak8';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/UpdateCarName/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        Map<String, String> responseMap =  UpdateCarName.updateCarName(vehicleId,carName);
        System.assert(response.statusCode == 400);
         System.debug('Map size=='+responseMap.size());
        Test.stopTest();
    }
}
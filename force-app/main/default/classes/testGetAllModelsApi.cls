@IsTest(SeeAllData=true)
global  with sharing class testGetAllModelsApi
{ 
     //valid input country
      
    @isTest global static void testPositiveGetMethod() 
    {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetAllModels/v1/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        getAllModelsApi.getModels();
        System.assert(response.statusCode == 200);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    
    
    //Input country is invalid
    
      @isTest global static void testWrongIDGetMethod() 
    {
         
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetAllModels/v1/Sing';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        getAllModelsApi.getModels();
        System.assert(response.statusCode == 400);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
}
@IsTest(SeeAllData=true)
global  with sharing class testgetAllVariantApiClass
{ 
     //valid model id 
      
    @isTest global static void testPositiveGetMethod() 
    {
        
       
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetVariants/v1/SG';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        getAllVariantsApi.getAllVariantsMethod();
        System.assert(response.statusCode == 200);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    
   
    //wrong model id
    
      @isTest global static void testWrongIDGetMethod() 
    {
         
      
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetVariants/v1/a0mO000000';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        getAllVariantsApi.getAllVariantsMethod();
        System.assert(response.statusCode == 400);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
}
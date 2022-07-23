@IsTest(SeeAllData=true)
global  with sharing class testGetVehicleServicePacks {
    //Positive Test Scenario
    @isTest global static void testPositiveGetVehicleServicePacks()
    {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetVehicleServicePacks/v1/a0s0K000005fyV5';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetVehicleServicePacks.GetVehicleServicePacks();
        //System.assert(response.statusCode == 200);
        //System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    
    // Negative Test Scenario, Invalid Vehicle ID
    
   /*  @isTest global static void testInvalidGetVehicleServicePacks()
    {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetVehicleServicePacks/v1/a0qO0000009';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
         GetVehicleServicePacks.GetVehicleServicePacks();
        System.assert(response.statusCode == 400);
        //System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    //Invalid Scenario, Blank ID
@isTest global static void testBlankGetVehicleServicePacks()
    {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetVehicleServicePacks/v1/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetVehicleServicePacks.GetVehicleServicePacks();
        System.assert(response.statusCode == 400);
        //System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    */

}
@isTest
private class testGetCustomerVehicle {
    private static String nric = '321X05011979';
    private static String franchise = 'MITPC';
    
    @testSetup
    private static void setup(){
        Account personAcc = Test_DataFactory.createPerson(true, 'Name', 'Customer');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId); //Workaround to update person contact
        personCon.NRIC_Passport_No__c = nric;
        update personCon;        
        
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(true, 'name', 'CCA', franchise, '1235234', personCon.Id);
    	Vehicle_Credit__c vehCredit = new Vehicle_Credit__c();
        vehCredit.Registered_Vehicle__c = regVehicle.Id;
        vehCredit.Status__c = 'Active';
        insert vehCredit;
    }
    
    @isTest
    private static void testGetCustomerVehicle()
    {
        Contact personCon = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerVehicle/v1/' + personCon.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        
        GetCustomerVehicle.GetCustomerVehicle();
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    } 
    
    @isTest
    private static void testInvalidGetCustomerVehicle()
    {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerVehicle/v1/P44627';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCustomerVehicle.GetCustomerVehicle();
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetCustomerVehicleWithBlankNRIC_ExceptionThrown()
    {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerVehicle/v1/'+ '';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCustomerVehicle.GetCustomerVehicle();
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
}
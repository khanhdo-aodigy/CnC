@isTest
private class testGetCustomerVehicleMB {
    private static String nric = '321X05011979';
    
    @testSetup
    private static void setup(){        
        String franchise = 'MBP';
        
        Account acct = Test_DataFactory.createAccount(true, 'nameA');
        Contact con = Test_DataFactory.createContact(false, 'fname', 'lname', acct.Id);
        con.NRIC_Passport_No__c = nric;
        insert con;
        
        Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.NRIC_Passport_No__c = nric;
        update personCon;
        
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(false, 'SEBE', 'CCI', 'MBP', 'SEBE1', personCon.Id);
        rv.Contact__c = personCon.Id;
        insert rv;
        
        Service_Packages__c sp = new Service_Packages__c();
        sp.Registered_Vehicle__c = rv.Id;
        sp.ITEM_EXPIRY_DATE__c = null;
        sp.Status__c = 'Active';
        insert sp;
        
    }
    
    @isTest
    private static void testGetCustomerVehicle_PossitiveCase()
    {   
        Contact con = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerVehicleMB/v1/' + con.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCustomerVehicleMB.GetCustomerVehicleMB();
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    } 
    
    @isTest
    private static void testInvalidGetCustomerVehicle()
    {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerVehicleMB/v1/1234567890987654321';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCustomerVehicleMB.GetCustomerVehicleMB();
        //System.assert(response.statusCode == 200);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    
    @isTest 
    private static void testGetCustomerVehicleMBWithBlankNRIC_ExceptionThrown()
    {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerVehicleMB/v1/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCustomerVehicleMB.GetCustomerVehicleMB();
        //System.assert(response.statusCode == 200);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
}
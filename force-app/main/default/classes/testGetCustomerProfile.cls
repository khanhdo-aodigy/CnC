@isTest
private class testGetCustomerProfile {
    static String nric = 'S8113909A';
    
    @testSetup
    private static void setup(){
        Account testAcc = Test_DataFactory.createAccount(true, 'nameA');
        Contact testCon = Test_DataFactory.createContact(false, 'fname', 'lname', testAcc.Id);
        testCon.NRIC_Passport_No__c = nric;
        insert testCon;
        
        Account personAcc = Test_DataFactory.createPerson(true, 'Name', 'Customer');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId); //Workaround to update Person Contact
        personCon.NRIC_Passport_No__c = nric;        
        personCon.MobilePhone = '1234567890';
        update personCon;
        
        
        User testUser = Test_DataFactory.createUser(false, 'LastName', 'testUser');
        //testUser.NRIC__c = nric;
    }
    
    @isTest
    private static void testExistingUserWithInputNRIC() {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerProfile/v1/' + nric;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCustomerProfile.GetCustomerProfile();
        Test.stopTest();
    }
    
    @isTest
    private static void testInvalidInputNRIC() {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerProfile/v1/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        
        Test.startTest();
        try{            
        	GetCustomerProfile.GetCustomerProfile();
        } catch (Exception ex){
         	System.debug(ex.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testNoExistingUserHasInputNRIC() {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerProfile/v1/S136112B';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCustomerProfile.GetCustomerProfile();
        Test.stopTest();
    }
    
    @isTest
    private static void NRICIsBlank_ExceptionThrown() {
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCustomerProfile/v1/***************************************************************************************************************************************************************************************************************';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCustomerProfile.GetCustomerProfile();
        Test.stopTest();
    }

}
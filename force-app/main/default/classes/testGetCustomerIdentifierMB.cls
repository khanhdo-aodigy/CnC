@IsTest
private class testGetCustomerIdentifierMB {
    
    @testSetup
    static void createData(){
        Test.startTest();
        //Create Business Account
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName());
        
        //Create Business Contact
        Contact con = Test_DataFactory.createContact(false, 'Name', 'LastName', acc.Id);
        con.NRIC_Passport_No__c = 'SLTEST01';
        con.NRIC__c = 'SLTEST01';
        con.MobilePhone = '81234567';
        con.Email = 'test@test.com';
        insert con;
        
        //Create Registered Vehicle
        Registered_Vehicle__c rev = Test_DataFactory.createregVehicle(true, 'rvtest01', 'CCI', 'MBP', 'SLTEST01', con.Id);
        Test.stopTest();
    }
    
    //Positive Test Scenario
    @isTest static void testPositiveGetCustomerIdentifier()
    {
        
        Test.startTest();        
        String reqURI = '/services/apexrest/GetCustomerIdentifierMB/v1/'; 
        String reqBody = '{"registrationNumber":"SLTEST01","mobileNumber":"81234567","email":"test@test.com"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        GetCustomerIdentifierMB.GetCustomerIdentifierMB();
        Test.stopTest();
        System.assertEquals( 1 , [SELECT COUNT() FROM Registered_Vehicle__c 
                                      WHERE Registration_Number__c = 'SLTEST01'
                                      AND (Contact__r.MobilePhone = '81234567' OR Account__r.PersonMobilePhone = '81234567')		
                                      AND (Contact__r.Email = 'test@test.com' OR Account__r.PersonEmail = 'test@test.com')
                                      AND Franchise__c IN ('MBP')]);

    } 
    
    //Test post request with blank body
    @isTest static void testNegativeGetCustomerIdentifier()
    {
        
        Test.startTest();
        String reqURI = '/services/apexrest/GetCustomerIdentifierMB/v1/'; 
        String reqBody = '{"registrationnumber":"SLTEST01","mobilenumber":"81234567","email":"test@test.com"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', null, null, 200);
        GetCustomerIdentifierMB.GetCustomerIdentifierMB();
        Test.stopTest();

    }
    
    // invalid registration number
    @isTest static void testInvalidCustomerRegistration()
    {
        
        Test.startTest();
        String reqURI = '/services/apexrest/GetCustomerIdentifierMB/v1/'; 
        String reqBody = '{"registrationnumber":"SLTEST02","mobilenumber":"81234567","email":"test@test.com"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        GetCustomerIdentifierMB.GetCustomerIdentifierMB();
        Test.stopTest();
         System.assertEquals( 0 , [SELECT COUNT() FROM Registered_Vehicle__c 
                                      WHERE Registration_Number__c = 'SLTEST02'
                                      AND (Contact__r.MobilePhone = '81234567' OR Account__r.PersonMobilePhone = '81234567')		
                                      AND (Contact__r.Email = 'test@test.com' OR Account__r.PersonEmail = 'test@test.com')
                                      AND Franchise__c IN ('MBP')]);
    }
    
    // invalid phone number
    @isTest static void testInvalidCustomerMobile()
    {
        
        Test.startTest();
        String reqURI = '/services/apexrest/GetCustomerIdentifierMB/v1/'; 
        String reqBody = '{"registrationnumber":"SLTEST02","mobilenumber":"8123456","email":"test@test.com"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        GetCustomerIdentifierMB.GetCustomerIdentifierMB();
        Test.stopTest();
         System.assertEquals( 0 , [SELECT COUNT() FROM Registered_Vehicle__c 
                                      WHERE Registration_Number__c = 'SLTEST01'
                                      AND (Contact__r.MobilePhone = '8123456' OR Account__r.PersonMobilePhone = '8123456')		
                                      AND (Contact__r.Email = 'test@test.com' OR Account__r.PersonEmail = 'test@test.com')
                                      AND Franchise__c IN ('MBP')]);
        
    }
    
    // invalid email number
    @isTest static void testInvalidCustomerEmail()
    {
        
        Test.startTest();
        String reqURI = '/services/apexrest/GetCustomerIdentifierMB/v1/'; 
        String reqBody = '{"registrationnumber":"SLTEST02","mobilenumber":"81234567","email":"testfail@test.com"}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        GetCustomerIdentifierMB.GetCustomerIdentifierMB();
        Test.stopTest();
         System.assertEquals( 0 , [SELECT COUNT() FROM Registered_Vehicle__c 
                                      WHERE Registration_Number__c = 'SLTEST01'
                                      AND (Contact__r.MobilePhone = '81234567' OR Account__r.PersonMobilePhone = '81234567')		
                                      AND (Contact__r.Email = 'testfail@test.com' OR Account__r.PersonEmail = 'testfail@test.com')
                                      AND Franchise__c IN ('MBP')]);
        
    }
    
    // blank values
    @isTest static void testBlankValues()
    {
        
        Test.startTest();
        String reqURI = '/services/apexrest/GetCustomerIdentifierMB/v1/'; 
        String reqBody = '{"registrationnumber":"","mobilenumber":"","email":""}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        GetCustomerIdentifierMB.GetCustomerIdentifierMB();
        Test.stopTest();
         System.assertEquals(0 , [SELECT COUNT() FROM Registered_Vehicle__c 
                                      WHERE Registration_Number__c = ''
                                      AND (Contact__r.MobilePhone = '' OR Account__r.PersonMobilePhone = '')		
                                      AND (Contact__r.Email = '' OR Account__r.PersonEmail = '')
                                      AND Franchise__c IN ('MBP')]);
        
    }
    
}
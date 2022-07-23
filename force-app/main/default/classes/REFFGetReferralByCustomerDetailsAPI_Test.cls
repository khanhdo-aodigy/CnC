@isTest
private class REFFGetReferralByCustomerDetailsAPI_Test {
  
    @TestSetup
    static void createData()
    {
        //Account acc = Test_DataFactory.createAccount(true, 'Test');
        Account acc = Test_DataFactory.createPA(true, 'Test', 'test2362@gmail.com', 'Prospect');
        acc         = [SELECT Id, PersonContactId FROM Account WHERE ID =: acc.Id];
        Contact con = [SELECT Id FROM Contact WHERE Id =: acc.PersonContactId];
        // Contact con = Test_DataFactory.createContact(true, 'contact', 'test', acc.Id);
        // con.NRIC_Passport_No__c = 'S12315031993';  
        // con.mobilePhone = String.valueOf('65814636');
        // con.Source__c = 'DWH';
		// con.AccountId = acc.Id;
        // update con;
        // system.debug('@@@ con: '+con);
  
        Profile endUserProfile = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User endUser = Test_DataFactory.createUserWithProfileID(false,'re','re','test@force.com',endUserProfile.id);
        //endUser.nric__c = 'zsdfzsdd';   
        endUser.contactId = con.id;    
        //endUser.contactId__c = con.Id;
        endUser.Account_Activation_Random_Number__c = '504503';
        endUser.isValid__c = false;
        TriggerExclusion.excludeTrigger('User', true);
        insert endUser; 
        system.debug('@@@ endUser: '+endUser);
        
        Lead ld = Test_DataFactory.createLead(true, 'Test Company', 'Test_Lead');
        
        Referral__c ref = new Referral__c();
        ref.Referrer__c = con.Id;
        ref.Referee__c = ld.Id;
        ref.Stage__c='Opened'; 
		ref.Brand_Picklist__c = 'MIT';
        insert ref;
    }
    
    @isTest
    private static void testPositive()
    {
        User us = [SELECT Id, Name/*, ContactId__c*/ FROM User WHERE LastName = 're' LIMIT 1];
        String reqURI = '/services/apexrest/GetReferallByCustomerDetails/User/'+us.Id+'/Stage/Opened'; 
        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 200);
        Test.startTest();
        REFFGetReferralByCustomerDetailsAPI.getReferralByCustomerDetails();
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Count() FROM Service_Data_Pool__c]);
    }
    
    
    /** PA Migration : Newly Added */
    @isTest
    private static void testPAMigrationPositive()
    {
        Account acc = Test_DataFactory.createPerson(false, 'PA', 'Customer');
        acc.PersonEmail = 'test1212@gmail.com';
        insert acc;
        Profile endUserProfile = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        
        Contact pCon = Test_DataFactory.createContact(false, 'contactPA', 'testPA', acc.Id);
        pCon.Account__c = acc.Id;
        pCon.NRIC_Passport_No__c = 'S12315031997';  
        pCon.mobilePhone = String.valueOf('65814636');
        pCon.Source__c = 'DWH';
        insert pCon;
      
        acc = [Select PersonContactId From Account WHERE Name = 'PA' LIMIT 1];
        System.debug(acc.PersonContactId);
        User endUser = Test_DataFactory.createUserWithProfileID(false,'re','re','test@force.com',endUserProfile.id);
        //endUser.nric__c = 'zsdfzsdd';   
        endUser.contactId = acc.PersonContactId;   
        //endUser.contactId__c = acc.PersonContactId;    
        endUser.Account_Activation_Random_Number__c = '504503';
        endUser.isValid__c = false;
        TriggerExclusion.excludeTrigger('User', true);
        insert endUser; 
        Lead ldPA = Test_DataFactory.createLead(true, 'Test Company1', 'Test_Lead1');
        Account referee = Test_DataFactory.createPerson(false, 'referee', 'Customer');
        referee.PersonEmail = 'pa84734@hotmail.com';
        referee.PersonMobilePhone = '12345678';
        insert referee;
      
        Referral__c refPA = new Referral__c();
        refPA.Referee_Account__c = referee.Id;
        refPA.Referrer_Account__c = acc.Id;
        refPA.Stage__c='Opened';
		refPA.Brand_Picklist__c = 'MIT';
        insert refPA;
           
        String reqURI = '/services/apexrest/GetReferallByCustomerDetails/User/'+endUser.Id+'/Stage/Opened'; 
        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 200);
        Test.startTest();
        REFFGetReferralByCustomerDetailsAPI.getReferralByCustomerDetails();
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Count() FROM Service_Data_Pool__c]);
    }
}
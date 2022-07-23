@isTest
private with sharing class PABatchContactToPAConverter_Test {
    @TestSetup
    static void createDate(){
        //for withoutPA case
        Account company = Test_DataFactory.createAccount(true, 'Company');
        Contact con = Test_DataFactory.createContact(true, 'Test', 'Test', company.Id);
        Registered_Vehicle__c vh = Test_DataFactory.createregVehicle(true,'Test','CCK','KIAPC','Test12', con.Id);
        //Campaign camp = Test_DataFactory.createCamp(true, 'test', 'Promotions', 'CCK');
        //Campaign_Member_Vehicle__c cmv = Test_DataFactory.createCampVehicle(true, 'Test', camp.Id, con.Id, vh.Id);
     //   ContactHobby__c conHobby = Test_DataFactory.createConHobby(true, con.Id);  Hobbies__c, ContactHobby__c is deleted [Thang - 04/08/21]
        CustomerAlerts__c alert = Test_DataFactory.createCusAlert(true, 'Test', con.Id);

        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(true, modelCode.Id, colorCode.Id, trimCode.Id, modelYearCode.Id);
  
        Case cs = Test_DataFactory.createCase(true,con.Id);
        Feedback__c feedback = Test_DataFactory.createFeedback(true, 'Test');
        /*String invIC = 'S123456TEST';
        Invoice__c inv = Test_DataFactory.createInvoice(false, con);
        inv.NRIC__c = invIC;
        inv.Campaign_ID__c = camp.Id;
        insert inv;*/
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Test', company.Id);
    //    opp.Contact_Person__c = con.Id;
        insert opp;

        Lead led = Test_DataFactory.createLead(true, company.Name, 'Test');
        //Event_Registration__c eventRegistration = Test_DataFactory.createEventReg(true, con.Id, camp.Id, inv.Id, opp.Id, led.Id, null);
        Test_Drive__c td = Test_DataFactory.createTestDrive(true, opp.Id);


    }

    @isTest
    private static void testConvertContactWithoutPA(){
        Test.startTest();
            PABatchContactWithoutPAConverter paConverter = new PABatchContactWithoutPAConverter();
            database.executebatch(paConverter,50);
        Test.stopTest();
        
        // system.assertEquals(1, [SELECT Count() FROM Contact WHERE isPersonAccount = true]);
    }
    @isTest
    private static void testConvertContactWithPA(){
        Account person = Test_DataFactory.createPerson(true, 'Test', 'PersonAccount');
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :person.Id];
        Contact jccContact = [SELECT Id, Account__c FROM Contact WHERE isPersonAccount = false];

        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User'];
        User us = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test@user.com',
            Username = 'test@user.com',     
            Alias = 'TestPA', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id,
            isValid__c = true );
        insert us;
        
        Test.startTest();
            PABatchContactWithPAConverter paConverter = new PABatchContactWithPAConverter(new Set<String>{jccContact.Id});
            database.executebatch(paConverter,50);
        Test.stopTest();
        system.debug([SELECT Id, Account__r.RecordTypeId FROM Contact WHERE isPersonAccount = false AND Account__c != null]);
        // system.assertEquals(1, [SELECT Count() FROM Contact WHERE isPersonAccount = false AND Account__c != null]);
    }
}
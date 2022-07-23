@isTest
private class PABatchLeadToPAConverter_Test {
    @TestSetup
    static void createData(){
        Lead led = Test_DataFactory.createLead(true, 'JCC', 'Test');
        Campaign camp = Test_DataFactory.createCamp(true, 'test', 'Promotions', 'CCK');

        String invIC = 'S123456TEST';
        Invoice__c inv = Test_DataFactory.createInvoice(false, null);
        inv.NRIC__c = invIC;
        inv.Campaign_ID__c = camp.Id;
        inv.Lead__c = led.Id;
        insert inv;

        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Test', null);
        opp.Lead__c = led.Id;
        insert opp;

        Event_Registration__c eventRegistration = Test_DataFactory.createEventReg(true, null, camp.Id, inv.Id, opp.Id, led.Id, null);

        Test_Drive__c td = Test_DataFactory.createTestDrive(false, opp.Id);
        td.Lead__c = led.Id;
        insert td;
    }

    @isTest
    private static void testprocessConversion(){
        
        Test.startTest();
        List<Lead> lds = [SELECT ID FROM Lead];
        PABatchLeadToPAConverter paConverter = new PABatchLeadToPAConverter();
        Database.QueryLocator ql = paConverter.start(null);
        paConverter.execute(null,lds);
        paConverter.Finish(null);
        // database.executebatch(paConverter,50);
        Test.stopTest();
        
    }
    
    /*@isTest
    private static void testPAMigrationService(){
        Account company = Test_DataFactory.createAccount(true, 'Company');
        Contact con = Test_DataFactory.createContact(true, 'Test', 'Test', company.Id);
        Registered_Vehicle__c vh = Test_DataFactory.createregVehicle(true,'Test','CCK','KIAPC','Test12', con.Id);
        Campaign camp = Test_DataFactory.createCamp(true, 'test', 'Promotions', 'CCK');
        CustomerAlerts__c alert = Test_DataFactory.createCusAlert(true, 'Test', con.Id);

        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(true, modelCode.Id, colorCode.Id, trimCode.Id, modelYearCode.Id);
  
        Case cs = Test_DataFactory.createCase(true,con.Id);
        Feedback__c feedback = Test_DataFactory.createFeedback(true, 'Test');
        String invIC = 'S123456TEST';
        Invoice__c inv = Test_DataFactory.createInvoice(false, con);
        inv.NRIC__c = invIC;
        inv.Campaign_ID__c = camp.Id;
        insert inv;
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Test', company.Id);
        opp.Contact_Person__c = con.Id;
        insert opp;

        Lead dummyLead = Test_DataFactory.createLead(false, null, 'Test');
        dummyLead.IsConverted = false;
        dummyLead.Account__c = null;
        insert dummyLead;
        Test_Drive__c td = Test_DataFactory.createTestDrive(true, opp.Id);
        
        Database.executeBatch(new PABatchLeadToPAConverter(new Set<Id>{dummyLead.Id}));
    }*/
}
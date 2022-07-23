@isTest
private class Test_Queries {
    static Account testAcc = Test_DataFactory.createAccount(true, 'accName');
    
    @testSetup
    private static void setup(){      
        
    }
    
    @isTest
    private static void testGetLeadById(){
        List<Lead> dummyLeads = new List<Lead>();
        for(Integer i=1; i<= 5; i++){            
            Lead dummyLead =  new Lead();
            dummyLead.Company  = 'Shell Corporation';
            dummyLead.LastName = 'Test Lead ' + i;
            dummyLead.Email    = 'test'+ i +'@fakedomain.com';
            dummyLead.NRIC__c  = 'VN97392';
            dummyLead.Birthdate__c = Date.today().addDays(i);
            dummyLeads.add(dummyLead);
        }    
        insert dummyLeads;
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead lead: dummyLeads){
            leadIdSet.add(lead.Id);
        }
        Test.startTest();
        List<Lead> result = Queries.getLeads(LeadIdSet);
        Test.stopTest();
        System.assertEquals(dummyLeads.size(), result.size());
    }
    
    @isTest
    private static void testGetOpportunityById(){
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> dummyOpps = new List<Opportunity>();
        List<Models_Interested__c> dummyModelInteresteds = new List<Models_Interested__c>();
        
        for(Integer i=1; i<= 5; i++){
          
            Opportunity opp = new Opportunity();
            opp.Name ='Test Opportunity - ' + i;
            opp.StageName = 'Open';
            opp.Amount = 3000;
            opp.CloseDate = Date.today().addDays(5);
            dummyOpps.add(opp);
        }
        insert dummyOpps;
            
       for(Opportunity opp: dummyOpps){
            oppIdSet.add(opp.Id);
        }
        Test.startTest();
        List<Opportunity> result = Queries.getOpps(oppIdSet);
        Test.stopTest();
        System.assertEquals(dummyOpps.size(), result.size());
    }
    
    @isTest
    private static void testGetTestDriveByOpportunityId(){
        Opportunity testOpp = Test_DataFactory.createOpportunity(true, 'oppName', testAcc.Id);
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
		for(Integer i=0; i<5; i++){
            Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, testOpp.Id);
            testDrives.add(testDrive);
        }   
        insert testDrives;
        
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(testOpp.Id);
        Test.startTest();
        List<Test_Drive__c> result = Queries.getTestDrives(oppIdSet);
        Test.stopTest();
        System.assertEquals(testDrives.size(), result.size());
    }
    
    @isTest
    private static void testModelInterestedByOpportunityId(){
        Opportunity testOpp = Test_DataFactory.createOpportunity(true, 'oppName', testAcc.Id);
		List<Models_Interested__c> dummyModelInteresteds = new List<Models_Interested__c>();        
        for(Integer i=1; i<= 5; i++){                      
            Models_Interested__c modelInterested = new Models_Interested__c();
            modelInterested.Status__c = 'Open';
            modelInterested.Opportunity__c = testOpp.Id;
            dummyModelInteresteds.add(modelInterested);            
        }
        insert dummyModelInteresteds;       
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(testOpp.Id);
        Test.startTest();
        List<Models_Interested__c> result = Queries.getModelsInterested(oppIdSet);
        Test.stopTest();
        System.assertEquals(dummyModelInteresteds.size(), result.size());
    }
    
    @isTest
    private static void testGetStockReservationByChassisNumber(){
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'ModelCodeName');
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Pastel', '#000', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'TrimCodeName');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        
        String chassisNum = 'Dummy Chassis';
        Set<String> chassisNumSet = new Set<String>{chassisNum};
        Vehicle_Master2__c vehicleMaster2 = Test_DataFactory.createVehicleMaster2(false, modelCode.Id, colorCode.Id, trimCode.Id, modelYearCode.Id, 'ORIGINAL123', 'SYS123');
        vehicleMaster2.Chassis__c = chassisNum;
        vehicleMaster2.ProductionMonth__c = Date.today();
        insert vehicleMaster2;
        
        Opportunity testOpp = Test_DataFactory.createOpportunity(true, 'oppName', testAcc.Id);
        List<Stock_Reservation__c> dummyStockReservations = new List<Stock_Reservation__c>();  
		for(Integer i=1; i<= 5; i++){                      
            Stock_Reservation__c stockReservation = new Stock_Reservation__c();
            stockReservation.Reservation_Status__c = 'Print';
            stockReservation.Opportunity__c = testOpp.Id;
            stockReservation.Model_Code__c = modelCode.Id; // for FIELD_FILTER_VALIDATION
            stockReservation.Color_Code__c = colorCode.Id; // for FIELD_FILTER_VALIDATION
            stockReservation.Trim_Code__c = trimCode.Id; // for FIELD_FILTER_VALIDATION
            stockReservation.Model_Year_Code__c = modelYearCode.Id; // for FIELD_FILTER_VALIDATION
            stockReservation.Vehicle_Master__c = vehicleMaster2.Id;
            dummyStockReservations.add(stockReservation);            
        }
		insert dummyStockReservations;
		List<Stock_Reservation__c> result = Queries.getSR(chassisNumSet);
    }
    
    @isTest
    private static void testGetEventRegistrationByLeadId(){
        Account dummyAcc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        Lead dummyLead =  new Lead();
        dummyLead.Account__c = dummyAcc.Id;
        dummyLead.Company  = 'Shell Corporation';
        dummyLead.LastName = 'Test Lead' ;
        dummyLead.Email    = 'test@fakedomain.com';
        dummyLead.NRIC__c  = 'VN97392';
        dummyLead.Birthdate__c = Date.today().addDays(5);
        insert dummyLead;
        
        Event_Registration__c evtReg = new Event_Registration__c(Name = 'Test', LeadId__c = dummyLead.Id);
        insert evtReg;
        
        Map<Id,Id> idMap = new Map<Id,Id>();
        idMap.put(dummyLead.Id,dummyAcc.Id);
        List<Event_Registration__c> result = Queries.getEventRegistrations(idMap);
    }
    
    @isTest
    private static void testGetTestDriveByOpportunityIdMap(){
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', null);
        Opportunity testOpp = Test_DataFactory.createOpportunity(true, 'oppName', testAcc.Id);
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
		for(Integer i=0; i<5; i++){
            Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, testOpp.Id);
            testDrives.add(testDrive);
        }   
        insert testDrives;
        
        Map<Id,Id> idsMap= new Map<Id,Id>();
        idsMap.put(testOpp.Id, testCon.Id);
        Test.startTest();
        List<Test_Drive__c> result = Queries.getTestDrives(idsMap);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetCustomQuotesByLeadId(){
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', null);
        Lead testLead = Test_DataFactory.createLead(true, 'C&C', 'lName');
        List<Custom_Quote__c> cusQuotes = new List<Custom_Quote__c>();
		for(Integer i=0; i<5; i++){
            Custom_Quote__c cusQuote = new Custom_Quote__c(Name = 'Test', Lead__c = testLead.Id);
            cusQuotes.add(cusQuote);
        }   
        insert cusQuotes;
        
        Map<Id,Id> idsMap= new Map<Id,Id>();
        idsMap.put(testLead.Id, testCon.Id);
        Test.startTest();
        List<Custom_Quote__c> result = Queries.getCustomQuotes(idsMap);
        Test.stopTest();
    }
    
    @isTest
    private static void QueriesTest(){
        Test.startTest();
        Queries q = new Queries();
        Test.stopTest();
    }
}
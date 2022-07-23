@isTest
private class PABatchLinkRecordToPersonContactTest {
    
    @testSetup
    private static void setup() {
        Account personAcc = Test_DataFactory.createPerson(true, 'lastName', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = : personAcc.Id];
        
        
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'DummyOpp', personAcc.Id);
        opp.Account__c = personAcc.Id;
        insert opp;
        
        Test_Drive__c testDrive = Test_DataFactory.createTestDrive(false, opp.Id);
        testDrive.Account__c = personAcc.Id;
        insert testDrive;
        
        Case dummyCase = Test_DataFactory.createCase(false, null);
        dummyCase.Account__c = personAcc.Id;
        insert dummyCase;
        
        Order__c order = new Order__c();
		order.Account__c = personAcc.Id;
		insert order;
        
        Event_Registration__c evtReg = new Event_Registration__c(Name = 'DummyEvtReg');
        evtReg.Account__c = personAcc.Id;
        insert evtReg;
    }
	
    @isTest
    private static void testBatchJob() {
        PABatchLinkRecordToPersonContact sJob = new PABatchLinkRecordToPersonContact();
        Database.executeBatch(sJob);
    }
    
    @isTest
    private static void testBatchJobWithSpecificParam() {
        Account personAcc = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        PABatchLinkRecordToPersonContact sJob = new PABatchLinkRecordToPersonContact(new Set<String>{personAcc.Id}, 'Opportunity');
        Database.executeBatch(sJob);
    }
}
@isTest
public class Test_EventRegistration_TaskCreation {
    
    static testMethod void testEvtRegWithContactId()
    {
        Test.startTest();
        Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', testAcc.Id);
        Date eventDate = Date.today().addDays(2);
        Event_Registration__c TestEvnt =  new Event_Registration__c(Name='TestRunL',Event_Date__c = eventDate, ContactId__c = testCon.Id);
        insert TestEvnt;        
        EventRegistration_TaskCreation.taskCreation();
    }
    
    static testMethod void testEvtRegWithLeadId()
    {
        Test.startTest(); 
        Lead TestLead =  new Lead(LastName='TestRunL',NRIC__c='TestRunNRIC');
        insert TestLead;
        Date eventDate = Date.today().addDays(2);
        Event_Registration__c TestEvnt1 =  new Event_Registration__c(Name='TestRunL',LeadId__c=TestLead.Id,Event_Date__c = eventDate);
        insert TestEvnt1;        
        EventRegistration_TaskCreation.taskCreation();
        Test.stopTest();
    }
    //PA MIGRATION: TO-DO: Remove old test methods above//
    
    //PA MIGRATION: Newly Added -- Start //
    @isTest
    static void testCreateTaskWithRelatedPA(){
        Account personAccToInsert = Test_DataFactory.createPerson(true, 'A Cool Name', 'Customer');    
        Account personAcc = [SELECT Id, Name, PersonContactId FROM Account];

		Opportunity oppToInsert = Test_DataFactory.createOpportunity(true, 'oppName', personAcc.Id);
        Opportunity opp = [SELECT Id, OwnerId FROM Opportunity];
        
        String evtRegName = 'Dummy Event Registration';
        Date eventDate = Date.today().addDays(2);
        Event_Registration__c evtRegToInsert = new Event_Registration__c(Name = evtRegName, Account__c = personAcc.Id, Opportunity__c = opp.Id, Event_Date__c = eventDate);
        insert evtRegToInsert;
        Event_Registration__c evtReg = [SELECT Id, Name, Account__c, Account__r.PersonContactId, OwnerId FROM Event_Registration__c];

        Test.startTest();
        EventRegistration_TaskCreation.taskCreation();
        Task actualTask = [SELECT WhatId, Description, Status, WhoId  FROM Task WHERE WhatId=:evtReg.Id];
        Test.stopTest();     
        
        Task expectedTask = new Task(Description = 'Please update the Event registration record with appropriate status', Status='Open', WhatId=evtReg.Id, WhoId = evtReg.Account__r.PersonContactId);  
        System.assertEquals(expectedTask.WhatId, actualTask.WhatId);
		System.assertEquals(expectedTask.Description, actualTask.Description);
        System.assertEquals(expectedTask.Status, actualTask.Status);
        System.assertEquals(expectedTask.WhoId, actualTask.WhoId);
    }
    
    @isTest
    static void testCreateTaskWithoutOpp_ExceptionThrown(){
        Account personAccToInsert = Test_DataFactory.createPerson(true, 'A Cool Name', 'Customer');    
        Account personAcc = [SELECT Id, Name, IsPersonAccount FROM Account];
       
        String evtRegName = 'Dummy Event Registration';
        Date eventDate = Date.today().addDays(2);
        Event_Registration__c evtRegToInsert = new Event_Registration__c(Name = evtRegName, Account__c = personAcc.Id, Event_Date__c = eventDate);
        insert evtRegToInsert;
        Test.startTest();
        try{
        	EventRegistration_TaskCreation.taskCreation();
        } catch (Exception e){
            System.assertEquals(e.getMessage(), 'Upsert failed. First exception on row 0; first error: INVALID_CROSS_REFERENCE_KEY, Assigned To ID: owner cannot be blank: [OwnerId]');
        }
        Test.stopTest();     
    }  //PA MIGRATION: Newly Added -- Stop //

}
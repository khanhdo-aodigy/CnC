@isTest
public class Test_EventRegistration_ConfirmationEmail {
    Static Account acct = Test_DataFactory.createAccount(true,'testRun'); //PA MIGRATION: To Remove                   
    Static Contact testCon  = Test_DataFactory.createContact(true,'testRun','testRun',acct.Id); //PA MIGRATION: To Remove        
    Static Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);      
    Static Model__c testMod = Test_DataFactory.createmodelId(true,'testRun','CCA','MITPC');
    static Account customerAcc = Test_DataFactory.createPerson(true, 'Cool Name', 'Customer'); //PA MIGRATION: Newly Added  
    
    Public static testMethod void testSendEmail()
    {   
        Test.startTest();        
        List<Event_Registration__c> listEvent= new List<Event_Registration__c>();
   
        Boolean ReminderEmail=true;
        Campaign ccaCamp = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCA');            
        ccaCamp.Description = 'testing the test event';
        ccaCamp.UnitPrice__c = 25;
        insert ccaCamp;
        
        Campaign cckCamp = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCK');             
        cckCamp.Description = 'testing the test event';
        cckCamp.UnitPrice__c = 25;
        insert cckCamp;
        
        Campaign ccfCamp = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');             
        ccfCamp.Description = 'testing the test event';
        ccfCamp.Brand__c = 'DS';
        ccfCamp.UnitPrice__c = 25;
        insert ccfCamp;
        
        Opportunity opp  = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);         
        opp.Opportunity_Score__c = 5;
        insert opp;
        
        Invoice__c testInvoice = Test_DataFactory.createInvoice(false,TestCon.id, null);
        testInvoice.Campaign__c = ccaCamp.id;
        insert testInvoice;
        
        //PA MIGRATION: To Remove -- Start //
        Lead testLead = Test_DataFactory.createLead(true,'testRun','testRun');
        
        Event_Registration__c tempInsertER1 = Test_DataFactory.createEventReg(false,null,cckCamp.id,null,oppt.id,testLead.id,testMod.id); // Insertion of Event_Registration__c using TestDataFactory
        tempInsertER1.Event_Reminder_Status__c=true;
        tempInsertER1.Waitlist__c = true;
       // tempInsertER1.PromoID__c = TestCamp.id;
        tempInsertER1.NumberOfGuests__c = 5;
        tempInsertER1.Opportunity__c = opp.id;
        insert tempInsertER1;
        
       
        Event_Registration__c tempInsertER = Test_DataFactory.createEventReg(false,null,ccaCamp.id,TestInvoice.id,oppt.id,testLead.id,testMod.id); // Insertion of Event_Registration__c using TestDataFactory
        tempInsertER.Event_Reminder_Status__c=true;
        tempInsertER.Opportunity__c = opp.id;
        tempInsertER.Event_Status__c='Attended';
        //tempInsertER.Event_Date__c = '1/1/2020';
        insert tempInsertER; 
        

        Event_Registration__c tempInsertER2 = Test_DataFactory.createEventReg(false,testCon.Id,ccfCamp.id,null,oppt.id,null,testMod.id); // Insertion of Event_Registration__c using TestDataFactory
        tempInsertER2.Event_Reminder_Status__c=false;
        tempInsertER2.Opportunity__c = opp.id;
        tempInsertER2.Waitlist__c = true;
        insert tempInsertER2;
        //PA MIGRATION: To Remove -- End //
        
        //PA MIGRATION: Newly Added -- Start //
        Event_Registration__c ccaEvtReg = Test_DataFactory.createPAEventReg(false, customerAcc.Id, ccaCamp.Id, testInvoice.Id, oppt.Id, testMod.Id);
        ccaEvtReg.Event_Reminder_Status__c=true;
        ccaEvtReg.Opportunity__c = opp.id;
        ccaEvtReg.Event_Status__c='Attended';
        ccaEvtReg.Event_Date__c = Date.newInstance(2020, 03, 31);
        insert ccaEvtReg;
        
        Event_Registration__c cckEvtReg = Test_DataFactory.createPAEventReg(false, customerAcc.Id, cckCamp.Id, testInvoice.Id, oppt.Id, testMod.Id);
        cckEvtReg.Event_Reminder_Status__c=true;
        cckEvtReg.Opportunity__c = opp.id;
        cckEvtReg.Event_Status__c='Attended';
        cckEvtReg.Event_Date__c = Date.newInstance(2020, 03, 31);
        insert cckEvtReg;
        
        Event_Registration__c ccfEvtReg = Test_DataFactory.createPAEventReg(false, customerAcc.Id, ccfCamp.Id, testInvoice.Id, oppt.Id, testMod.Id);
        ccfEvtReg.Event_Reminder_Status__c=true;
        ccfEvtReg.Opportunity__c = opp.id;
        ccfEvtReg.Event_Status__c='Attended';
        ccfEvtReg.Event_Date__c = Date.newInstance(2020, 03, 31);
        insert ccfEvtReg; 
        //PA MIGRATION: Newly Added -- End //
        
        //PA MIGRATION: To Remove -- Start //
        listEvent.add(tempInsertER);
        listEvent.add(tempInsertER1);
        listEvent.add(tempInsertER2);
        //PA MIGRATION: To Remove -- End //
        
        //PA MIGRATION: Newly Added -- Start //
        listEvent.add(ccaEvtReg);
        listEvent.add(cckEvtReg);
        listEvent.add(ccfEvtReg);
        //PA MIGRATION: Newly Added -- End //
        
        EventRegistration_ConfirmationEmail.hanldeAfterInsert(listEvent);
        Test.stopTest();
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Event_Registration__c', true);
        Campaign cckCamp = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCK');             
        cckCamp.Description = 'testing the test event';
        cckCamp.UnitPrice__c = 25;
        insert cckCamp;
        Lead testLead = Test_DataFactory.createLead(true,'testRun','testRun');
		Event_Registration__c tempInsertER1 = Test_DataFactory.createEventReg(true,null,cckCamp.id,null,oppt.id,testLead.id,testMod.id);
        TriggerExclusion.excludeTrigger('Event_Registration__c', false);
    }
}
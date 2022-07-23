@isTest
public class Test_EventRegistrationTrigger {
  
    Static Account acct = Test_DataFactory.createAccount(true,'testRun');                   //Common Account Using TestFactory
    Static Contact testCon  = Test_DataFactory.createContact(true,'testRun','testRun',acct.Id); //Common Contact Using TestFactory      
    Static Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);      //Opportunity for method testInsertInvoice Using TestFactory  
    Static Model__c testMod = Test_DataFactory.createmodelId(true,'testRun','CCA','MITPC');     //Common Model Using TestFactory          
    Static testMethod void testInsertInvoice(){
        
        Campaign testCamp1 = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCK');
        testCamp1.Description = 'TestDescp for camp1';
        testCamp1.UnitPrice__c = 10;
        insert testCamp1;
        oppt.Opportunity_Score__c = 1232134;
        Insert oppt;
        Test.startTest();    
        Event_Registration__c tempInsertER = Test_DataFactory.createEventReg(true,testCon.Id,testCamp1.id,null,oppt.id,null,testMod.Id); // Insertion of Event_Registration__c using TestDataFactory
        tempInsertER.Event_Reminder_Status__c = true;
        tempInsertER.Event_Status__c = 'Attended';
       	tempInsertER.Event_Date__c = Date.newInstance(2016, 12, 9);
		tempInsertER.NumberOfGuests__c = 3;
        tempInsertER.Name = 'Test_Er1';
        Update tempInsertER;
        Test.stopTest();
    }      
    Static testMethod void testInsert1Trigger(){
        Opportunity opp = Test_DataFactory.createOpportunity(true,'testRun',acct.Id);
        Campaign testCamp = Test_DataFactory.createCamp(false,'testRun','Paid Event',null);
        testCamp.Description = 'TestDescp for camp1';
        testCamp.UnitPrice__c = 5;
        insert testCamp;
        Model__c testMod1 = Test_DataFactory.createmodelId(false,'testRun','CCA','MITPC');
        testMod1.Branch_Code__c = 'CCA';
        insert testMod1;
        Lead testLead = Test_DataFactory.createLead(true,'testRun','testRun');
        Invoice__c testInvoice = Test_DataFactory.createInvoice(false,null, testLead.id);
        insert testInvoice;
        String JsonMsg = '{"test":"test"}';
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,JsonMsg));
        Event_Registration__c tempInsertER = Test_DataFactory.createEventReg(false,null,testCamp.id,null,opp.id,testLead.id,testMod1.Id); // Insertion of Event_Registration__c using TestDataFactory
        tempInsertER.Payment__c =testInvoice.id;
        tempInsertER.Name = 'Test_Er1';
        tempInsertER.NumberOfGuests__c = 3;
        tempInsertER.Waitlist__c = false;
        tempInsertER.Event_Reminder_Status__c = false;
        tempInsertER.Event_Date__c = Date.newInstance(2016, 12, 9);
        insert tempInsertER;
        Test.stopTest();
    }
    Static testMethod void testInsertTrigger2(){
        Campaign testCamp = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');
        testCamp.Description = 'TestDescp for camp1';
        testCamp.UnitPrice__c = 5;
        insert testCamp;
        Lead testLead = Test_DataFactory.createLead(true,'testRun','testRun');
        Invoice__c testInvoice = Test_DataFactory.createInvoice(false,null, testLead.id);
        testInvoice.Campaign__c = testCamp.Id;
        insert testInvoice;
        Test.startTest();            
        Event_Registration__c tempInsertER = Test_DataFactory.createEventReg(false,null,testCamp.id,null,null,testLead.id,testMod.Id); // Insertion of Event_Registration__c using TestDataFactory
        tempInsertER.Name = 'Test_Er1';
        tempInsertER.Waitlist__c = true;
        tempInsertER.Event_Reminder_Status__c = false;
		tempInsertER.NumberOfGuests__c = 3;
        tempInsertER.Event_Date__c = Date.newInstance(2016, 12, 9);
        insert tempInsertER;
        Test.stopTest();
    }

}
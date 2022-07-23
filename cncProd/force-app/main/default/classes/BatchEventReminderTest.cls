@isTest
private class BatchEventReminderTest {
	static Date eventDate  = Date.today().addDays(2);
    static Account acct = Test_DataFactory.createAccount(true,'testRun');                 
    static Contact testCon  = Test_DataFactory.createContact(true,'testRun','testRun',acct.Id);      
    static Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);       
    static Model__c model = Test_DataFactory.createmodelId(true,'testRun','CCA','MITPC');              
    
    @isTest
    private static void testBatchEventReminder_possitiveCase(){        
        Campaign camp = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCK');
        camp.Description = 'TestDescp for camp';
        camp.UnitPrice__c = 10;
        insert camp;
        Test.startTest();
        Event_Registration__c eventRegistration = Test_DataFactory.createEventReg(false,testCon.Id,camp.id,null,oppt.id,null, model.Id); 
        eventRegistration.Event_Reminder_Status__c = true;
        eventRegistration.Event_Status__c = 'Attended';
        eventRegistration.Event_Date__c = eventDate;
        eventRegistration.NumberOfGuests__c = 3;
        eventRegistration.Name = 'Test_Er1';
        insert eventRegistration;
        Database.executeBatch(new BatchEventReminder(new List<Event_Registration__c>{eventRegistration}), 1);                                                        
        Test.stopTest();
    }
}
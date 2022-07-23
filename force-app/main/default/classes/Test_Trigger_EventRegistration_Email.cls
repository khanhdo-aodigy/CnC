@isTest(seeAllData=true)
public class Test_Trigger_EventRegistration_Email {

    static testMethod void testInsertTrigger()
    {
        Test.startTest();    
        Date OppExpectedCloseDate = date.today();
        Contact TestCon =  new Contact(LastName='TestRun',NRIC_Passport_No__c='TestRunNRIC');
        insert TestCon;
        
        Event_Registration__c tempInsertER = new Event_Registration__c();
        tempInsertER.Name = 'Test_Er';
        tempInsertER.ContactId__c =TestCon.Id;         
        insert tempInsertER;
        
        tempInsertER.Name = 'Test_Er1';
        update tempInsertER;
            
        List<Event_Registration__c> ErList = [Select Id, Name from Event_Registration__c where Name =: 'Test_Er1'];  
        system.assert(ErList.size()>0, true);
        Test.stopTest();
    }
    
    
    
}
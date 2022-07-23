@isTest
public class Test_Convert_Lead_toContact_Scheduler {

    static testMethod void testInsertTrigger()
    {   
        Contact TestCon =  new Contact(LastName='TestLeadToConRun',NRIC_Passport_No__c='TestRunNRICLtoC');
        insert TestCon;
        Date today = Date.today();
		Test.setCreatedDate(TestCon.Id, today);
        Lead TestLead =  new Lead(LastName='TestRunLtoC',NRIC__c='TestRunNRICLtoC');
        insert TestLead;
        Account Acc = new Account(Name = 'JCC');
        Insert Acc;
        
        Test.startTest();        
        Convert_Lead_toContact_Scheduler.ConvertLeads();
        Test.stopTest();
    }
}
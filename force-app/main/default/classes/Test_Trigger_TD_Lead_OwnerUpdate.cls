@isTest(seeAllData=true)
public class Test_Trigger_TD_Lead_OwnerUpdate {

    static testMethod void testInsertLeadTrigger()
    {
        Test.startTest(); 
         Lead TestLead =  new Lead(LastName='TestRunL',NRIC__c='TestRunNRIC');
        insert TestLead;
         User Testuser =  new User(Username='test_old@abc.com',LastName='test', Email='test_old@abc.com', Alias='testrun', TimeZoneSidKey='America/Denver', LocaleSidKey='en_GB', 
                                  EmailEncodingKey='UTF-8', ProfileId='00e28000000s2hr', LanguageLocaleKey='en_US');
        insert Testuser;
        TestLead.OwnerId=Testuser.Id;
Update TestLead;        
        Test.stopTest();
    }
    
        
}
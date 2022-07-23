@isTest
private class Test_Trigger_PriceAlert_ConfirmEmail {
    @isTest
    static void testInsertContactTrigger()
    {
        Test.startTest(); 
        Contact TestCon =  new Contact(LastName='TestRun',NRIC_Passport_No__c='TestRunNRIC');
        insert TestCon;
        Opportunity TestOpp =  new Opportunity(Name='TestOpp',Rating__c='HOT',CloseDate=Date.valueOf('2018-10-10'),StageName='Open',Branch_Code__c='CCK',Contact_Person__c=TestCon.Id);
        insert TestOpp;
        
        price_alert__c tempInsertPA = new price_alert__c();
        tempInsertPA.Opportunity__c =TestOpp.Id;         
        insert tempInsertPA;   
        Test.stopTest();
    }
   
    @isTest
    static void testInsertPATrigger()
    {
        Test.startTest(); 
        Account acc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        Lead TestLead =  new Lead(LastName='TestRunL',NRIC__c='TestRunNRIC');
        insert TestLead;
        Opportunity TestOpp =  new Opportunity(Name='TestOpp',Rating__c='HOT',CloseDate=Date.valueOf('2018-10-10'),StageName='Open',Branch_Code__c='CCK',Lead__c=TestLead.Id);
       	TestOpp.Account__c = acc.Id;
        insert TestOpp;
        
        price_alert__c tempInsertPA = new price_alert__c();
        tempInsertPA.Opportunity__c =TestOpp.Id;         
        insert tempInsertPA;   
        Test.stopTest();
    }
 
    
}
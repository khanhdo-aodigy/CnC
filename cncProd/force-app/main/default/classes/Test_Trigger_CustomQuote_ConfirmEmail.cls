@isTest
private class Test_Trigger_CustomQuote_ConfirmEmail {
	
    /** PA MIGRATION: To Removed -- Start*/
    // @isTest
    // private static void testInsertLeadTrigger()
    // {
    //     Test.startTest(); 
    //     Lead TestLead =  new Lead(LastName='TestRunL',NRIC__c='TestRunNRIC');
    //     insert TestLead;
    //     Opportunity TestOpp =  new Opportunity(Name='TestOpp',Rating__c='HOT',CloseDate=Date.valueOf('2018-10-10'),StageName='Open',Branch_Code__c='CCK',Lead__c=TestLead.Id);
    //     insert TestOpp;
        
    //     Custom_Quote__c tempInsertCQ = new Custom_Quote__c();
    //     //tempInsertPA.Name = 'Test_PA';
    //     tempInsertCQ.Opportunity__c =TestOpp.Id;         
    //     insert tempInsertCQ;   
    //     Test.stopTest();
    // }
    /** PA MIGRATION: To Removed -- End*/
    
    @isTest
    private static void testByPassTrigger(){
        Test.startTest();
        Custom_Quote__c testCusQuote = new Custom_Quote__c(Name = 'Dummy');
        
        TriggerExclusion.excludeTrigger('Custom_Quote__c', true);    
        insert testCusQuote;
        Test.stopTest();
        System.assertEquals(true, TriggerExclusion.isTriggerExclude('Custom_Quote__c'));
    }
    
    @isTest
    private static void testInsertContactTrigger()
    {
        Test.startTest(); 
        Contact TestCon =  new Contact(LastName='TestRun',NRIC_Passport_No__c='TestRunNRIC');
        insert TestCon;
        Opportunity TestOpp =  new Opportunity(Name='TestOpp',Rating__c='HOT',CloseDate=Date.valueOf('2018-10-10'),StageName='Open',Branch_Code__c='CCK',Contact_Person__c=TestCon.Id);
        insert TestOpp;
        
        Custom_Quote__c tempInsertCQ = new Custom_Quote__c();
        tempInsertCQ.Opportunity__c =TestOpp.Id;         
        insert tempInsertCQ;   
        Test.stopTest();
    }
    
    /** PA MIGRATION: Newly Added -- Start */
    @isTest
    private static void testAfterInsertCustomQuoteTrigger_caseOpportunityWithPersonAccount(){        
        Account accToInsert = Test_DataFactory.createPerson(false, 'Test Name', 'Customer');
        accToInsert.PersonEmail = 'dummmyEmail@fakedomain.com';
        insert accToInsert;
        Account personAcc = [SELECT Id, PersonContactId FROM Account];
        Contact personCon = [SELECT Id FROM Contact WHERE Id = :personAcc.PersonContactId];
        
        Opportunity testOpp = new Opportunity(Name='TestOpp' ,Rating__c = 'HOT', CloseDate = Date.valueOf('2020-04-01'), StageName='Open' ,Branch_Code__c='CCK', Contact_Person__c=personCon.Id);
        testOpp.AccountId = personAcc.Id;
        insert testOpp;
        
        Custom_Quote__c testCusQuote = new Custom_Quote__c(Name = 'Dummy');
        testCusQuote.Opportunity__c =TestOpp.Id;

        Test.startTest(); 
        insert testCusQuote;
        Test.stopTest();     
        
        //System.assertEquals();
    }
    
    /** PA MIGRATION: Newly Added -- Stop */
}
@isTest
private class TriggerCustomQuoteTest {
	
    @isTest
    private static void testTriggerExclusion() {
        Custom_Quote__c customQuote = new Custom_Quote__c(Name = 'Test');
        TriggerExclusion.excludeTrigger('Custom_Quote__c', true);
        insert customQuote;
    }
    
    @isTest
    private static void testAfterInsert() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Account personAcc = Test_DataFactory.createPerson(true, 'Test Customer', 'Customer');
            personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
            
            Opportunity opp = Test_DataFactory.createOpportunity(false, 'Test Opp', personAcc.Id);
            opp.Contact_Person__c = personAcc.PersonContactId;
            insert opp;
            
            Custom_Quote__c customQuote = new Custom_Quote__c(Name = 'Test', Opportunity__c = opp.Id);
        	insert customQuote;
        }
        
    }
    
    
}
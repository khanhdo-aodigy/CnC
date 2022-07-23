@isTest
private class ContactStagingTriggerTest {
	@isTest
    private static void testTriggerExclusion() {
        Account account = Test_DataFactory.createAccount(true, 'accName');        
        Contact con = Test_DataFactory.createContact(false, 'fname', 'lname', account.Id);
        con.Email = 'test@gmail.com';        
        insert con;
        
        TriggerExclusion.excludeTrigger('Contact_Staging__c', true);
        
        Contact_Staging__c contactStaging = new Contact_Staging__c(Contact_Key__c = con.Id);        
        insert contactStaging;
        
    }
    
    @isTest
    private static void testBeforeInsert() {
        Account account = Test_DataFactory.createAccount(true, 'accName');        
        Contact con = Test_DataFactory.createContact(false, 'fname', 'lname', account.Id);
        con.Email = 'test@gmail.com';        
        insert con;
        
        Contact_Staging__c contactStaging = new Contact_Staging__c(Contact_Key__c = con.Id);        
        insert contactStaging;
        
    }
}
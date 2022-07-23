@isTest
private class ContactTriggerTest {
	@isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Contact', true);
        Account acc = Test_DataFactory.createAccount(true, 'CnC Group');
        Contact con = Test_DataFactory.createContact(true, 'Mimi', 'Lee', acc.Id);        
        TriggerExclusion.excludeTrigger('Contact', false);
    }
    
    @isTest
    private static void testOnUpdate() {
        Account acc = Test_DataFactory.createAccount(true, 'CnC Group');
        Contact con = Test_DataFactory.createContact(true, 'Mimi', 'Lee', acc.Id);
        con.Email = 'mimi.lee@test.com';
        update con;
    }
}
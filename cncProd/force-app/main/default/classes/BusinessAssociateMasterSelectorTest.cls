@isTest
private class BusinessAssociateMasterSelectorTest {
    
    @testSetUp
    private static void setUp() {
        // business associate master
        Business_Associate_Master__c bam = new Business_Associate_Master__c(Name = 'Test BAM', BAM_TYPE__c = 'FIN');
        insert bam;
    }
    
	@isTest
    private static void selectByTypeTest() {
        BusinessAssociateMasterSelector o =  new BusinessAssociateMasterSelector();
        list<Business_Associate_Master__c> results = o.selectByType(new list<string> {'FIN'});
        system.assertEquals(1, results.size());
    }
}
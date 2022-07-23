@isTest
private class BatchCalculateSLADefectHeaderTest {
	@testSetup
    static void setUp() {
        // Create Defect Header
        List<Defect_Header__c> dhs = new List<Defect_Header__c>();
        for (Integer i = 0; i < 5; i++) {
            Defect_Header__c dh = new Defect_Header__c();
            dhs.add(dh);
        }
        insert dhs;
    }

    @isTest
    static void test() {
        Test.startTest();
        BatchCalculateSLADefectHeader b = new BatchCalculateSLADefectHeader();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();
    }
}
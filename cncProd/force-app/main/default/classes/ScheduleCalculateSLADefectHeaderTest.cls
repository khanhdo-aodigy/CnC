@isTest
private class ScheduleCalculateSLADefectHeaderTest {
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
       String sch = '0 0 0 * * ?';
       Test.startTest();
       String jobId = System.schedule('ScheduleApexClassTest',  sch, new ScheduleBatchCalculateSLADefectHeader());
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
       System.assertEquals(sch, ct.CronExpression);
       System.assertEquals(0, ct.TimesTriggered);
       Test.stopTest();
    }
}
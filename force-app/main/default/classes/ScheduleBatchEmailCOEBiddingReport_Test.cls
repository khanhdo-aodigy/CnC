@isTest
private class ScheduleBatchEmailCOEBiddingReport_Test {
    @isTest(SeeAllData=true)
    static void executeBatch(){
        Test.startTest();
        COE_Bid_Period__c coePeriod = new COE_Bid_Period__c();
        coePeriod.From_Date__c = Date.today();
        coePeriod.To_Date__c = Date.today() + 1;
        insert coePeriod;

        String CRON_EXP = '0 5 * * * ?';
        String jobId = System.schedule('Send COE Report', CRON_EXP, new ScheduleBatchEmailCOEBiddingReport());
        Test.stopTest();
    } 
    
}
@isTest
private class ScheduleBatchEmailCOEBiddingReport_Test {
    @isTest(SeeAllData=true)
    static void executeBatch(){
        // COE_Bid_Period__c coePeriod = [SELECT Id, From_Date__c, To_Date__c
        //                                 FROM COE_Bid_Period__c
        //                                 WHERE From_Date__c = :Date.today()];

        // Profile profile = [SELECT Id FROM Profile WHERE Name = 'CITPC Sales' LIMIT 1];
        // User user = [SELECT Id, Email FROM User WHERE ProfileId = :profile.Id AND IsActive = true LIMIT 1];
        // Report coeReport = [SELECT Id, DeveloperName FROM Report WHERE DeveloperName = 'DSAs_for_COE_Bidding_aVt'];
        String CRON_EXP = '0 5 * * * ?';
        Test.startTest();
        String jobId = System.schedule('Send COE Report', CRON_EXP, new ScheduleBatchEmailCOEBiddingReport());
        Test.stopTest();
    } 
    
}
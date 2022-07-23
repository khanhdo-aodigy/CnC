/** *****
 * Description : Test Class for RAP_CheckCOEBiddingExpirationBatch job
 * 
 * Change History
 * Date(YYYYMMDD)       Name                        Description
 * 20210325             tan.nguyen@aodigy.com       Created Initial Version. 
 * 
** *****/
@isTest

private class RAP_CheckCOEBiddingExpirationBatchTest  {

    @isTest
    private static void testUpdateStatus() {
        Date today = Date.today();
        Test.startTest();
        Used_Car_Quote__c ucq1 = Test_DataFactory.createUCQ(true, 'CN1',  'VN1', today, 'N001');
        Used_Car_Quote__c ucq2 = Test_DataFactory.createUCQ(true, 'CN2',  'VN2', today, 'N002');
        Used_Car_Quote__c ucq3 = Test_DataFactory.createUCQ(true, 'CN3',  'VN3', today, 'N003');
        Used_Car_Quote__c ucq4 = Test_DataFactory.createUCQ(true, 'CN4',  'VN4', today, 'N004');
        Used_Car_Quote__c ucq5 = Test_DataFactory.createUCQ(true, 'CN5',  'VN5', today, 'N005');
        Used_Car_Quote__c ucq6 = Test_DataFactory.createUCQ(true, 'CN6',  'VN6', today, 'N006');

        COE_Bid_Period__c bidding = new COE_Bid_Period__c();
        bidding.From_Date__c = Date.today().addDays(-6);
        bidding.To_Date__c = Date.today().addDays(-1);
        bidding.Bid_Status__c = 'Active';
        insert bidding;

        Database.executebatch(new RAP_CheckCOEBiddingExpirationBatch());
        Test.stopTest();

        Integer result = [SELECT Id FROM Used_Car_Quote__c ].size();
        System.assertEquals(6, result);
    }
    
    @isTest
    private static void testTodayIsNotCOEDay() {
        String sched = '0 00 00 * * ?';
		Database.executebatch(new RAP_CheckCOEBiddingExpirationBatch());
    }
    
    @isTest
    private static void testSchedule() {
        String sched = '0 00 00 * * ?';
		System.schedule('CheckCOEBiddingExpirationBatch', sched, new RAP_CheckCOEBiddingExpirationBatch());
    }
}
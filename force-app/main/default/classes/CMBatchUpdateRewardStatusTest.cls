/** ******
 * Description : Test Class for CMBatchUpdateRewardStatus.cls and CMBatchUpdateRewardStatusSchedule
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                                Description
 * 20200708             khanh.do@aodigy.com                  Created Initial Version. 
 * 
***** **/
@isTest
private class CMBatchUpdateRewardStatusTest {

    static Date expiryDate = Date.today().addDays(-30);
    static Integer noExpiredRecord = 20;

    @testSetup
    private static void setup() {
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        List<Reward__c> rewards = new List<Reward__c>();
        for(Integer i = 0; i < noExpiredRecord; i++) {
            Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', expiryDate);
        	reward.Credit__c = 20000;
            rewards.add(reward);
        }        
        insert rewards;
    }
    
    @isTest
    private static void testCMBatchUpdateRewardStatus_noSpecifyRecordId_UpdateAllExpiredRecords() {
        System.Test.startTest();
            Database.executeBatch(new CMBatchUpdateRewardStatus());
        System.Test.stopTest();
        List<Reward__c> updatedRewards = [SELECT Id, Status__c, Expiry__c FROM Reward__c WHERE Expiry__c = :expiryDate AND Status__c = 'Expired'];
        List<Reward_Usage__c> createdRewardUsages = [SELECT Id FROM Reward_Usage__c];
        System.assertEquals(noExpiredRecord, updatedRewards.size());
        System.assertEquals(noExpiredRecord, createdRewardUsages.size());
    }

    @isTest
    private static void testCMBatchUpdateRewardStatus_withSpecificIdSet_OnlyUpdateTheSpecifiedRecords() {
        Integer noRecordToUpdate = 10;
        Map<String, Reward__c> mapIdToRewards = new Map<String, Reward__c>([SELECT Id FROM Reward__c LIMIT :noRecordToUpdate]);
        Set<String> rewardIds = mapIdToRewards.keySet();
        System.Test.startTest();
            Database.executeBatch(new CMBatchUpdateRewardStatus(rewardIds));
        System.Test.stopTest();
        List<Reward__c> updatedRewards = [SELECT Id, Status__c, Expiry__c FROM Reward__c WHERE Expiry__c = :expiryDate AND Status__c = 'Expired'];
        List<Reward_Usage__c> createdRewardUsages = [SELECT Id FROM Reward_Usage__c];
        System.assertEquals(noRecordToUpdate, updatedRewards.size());
        System.assertEquals(noRecordToUpdate, createdRewardUsages.size());
    }
    
    @isTest
    private static void testCMBatchUpdateRewardStatusSchedule() {
        String CRON_EXP = '0 1 0 * * 2020';
        Test.startTest();
            CMBatchUpdateRewardStatusSchedule schedulableBatch = new CMBatchUpdateRewardStatusSchedule();
			schedulableBatch.execute(null);
        Test.stopTest();
        List<Reward__c> updatedRewards = [SELECT Id, Status__c, Expiry__c FROM Reward__c WHERE Expiry__c = :expiryDate AND Status__c = 'Expired'];
        List<Reward_Usage__c> createdRewardUsages = [SELECT Id FROM Reward_Usage__c];
        System.assertEquals(noExpiredRecord, updatedRewards.size());
        System.assertEquals(noExpiredRecord, createdRewardUsages.size());
    }
}
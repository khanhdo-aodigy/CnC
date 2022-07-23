@isTest
private class RewardUsagesTest {
    @testSetup
    private static void setup() {
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
    	Reward__c reward = Test_DataFactory.createReward(true, rewardProfile.Id, 'Accessories Credit', 'Valid', Date.today().addDays(30));
    }
    
    //@isTest
    //private static void testOnAfterInsert() {
    //    Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
    //}
    
    @isTest
    private static void testBypassTrigger() {
        String rewardId = [SELECT Id FROM Reward__c LIMIT 1].Id;
        System.Test.startTest();
         	TriggerExclusion.excludeTrigger( 'Reward_Usage__c', true );
            Test_DataFactory.createRewardUsage(true, rewardId, 'Hold', 'Debit');
        	TriggerExclusion.excludeTrigger( 'Reward_Usage__c', false );
        System.Test.stopTest();
        System.assertEquals( 1, ([SELECT ID FROM Reward_Usage__c ]).size());
    }
}
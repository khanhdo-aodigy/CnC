/** ******
 * Description : Test class for RewardService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200706             TP@aodigy       Created Initial Version. 
 * 
** ******/

@isTest
private class RewardService_Test 
{
	@testSetup
    static void setUp()
    {
        Account acct = Test_DataFactory.createAccount(true, 'Company');
        Contact con = Test_DataFactory.createContact(true, 'Test', 'Test', acct.Id);
        
        Order__c order = Test_DataFactory.createOrder(Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('C_C_E_Shop').getRecordTypeId());
        order.Shop__c = 'KIA';
        insert order;
        
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(true, 'TEST', 'CCK', 'KIAPC', 'ABC987655', con.Id);
        
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(15));
     	reward.Registered_Vehicle__c = regVehicle.Id;
        insert reward;
        
        Reward__c reward1 = Test_DataFactory.createReward(true, rewardProfile.Id, rewardProfile.Type__c, 'Expired', Date.today().addDays(15));
        Reward_Usage__c rewardUsage1 = Test_DataFactory.createRewardUsage(false, reward1.Id, 'Expired', 'Debit');
        rewardUsage1.Channel__c = 'System';
        insert rewardUsage1;
    }
    
    @isTest
    static void Test_getRewardsByRewardProfileId()
    {
        Reward_Profile__c rewardProfile = [SELECT Id, Type__c FROM Reward_Profile__c];
        List<Reward__c> rewards = RewardService.getRewardsByRewardProfileId(rewardProfile.Id, rewardProfile.Type__c);
        System.assertEquals(1, rewards.size());
    }
    
    @isTest
    static void Test_getRewardsByVehicleRegNum()
    {
        Reward__c reward = [SELECT Id, Type__c, Registered_Vehicle__c from Reward__c where status__c = 'Valid'];
        List<Reward__c> rewards = RewardService.getRewardsByVehicleRegNum(reward.Registered_Vehicle__c, reward.Type__c);
    }
    
    @isTest
    static void Test_getRewardsByRecordIds()
    {
        Reward__c reward = [SELECT Id, Type__c, Registered_Vehicle__c from Reward__c where status__c = 'Valid'];
        List<Reward__c> rewards = RewardService.getRewardsByRecordIds(new Set<Id>{reward.Id});
    }
    
    @isTest
    static void Test_getRewardsByRewardTypes()
    {
        Reward__c reward = [SELECT Id, Type__c, Registered_Vehicle__c from Reward__c where status__c = 'Valid'];
        List<Reward__c> rewards = RewardService.getRewardsByRewardTypes(reward.Registered_Vehicle__c, new Set<String>{reward.Type__c});
    }
    
    @isTest
    static void Test_reactivateRewards()
    {
        Reward__c reward = [SELECT Id, Type__c, Registered_Vehicle__c from Reward__c where status__c = 'Expired'];
 		RewardService.reactivateRewards(new List<Reward__c>{reward});
    }
    
}
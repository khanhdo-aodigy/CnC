/** ******
 * Description : Test class for RewardSelector.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200706             TP@aodigy       Created Initial Version. 
 * 
** ******/
@isTest
private class RewardSelector_Test 
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
    }
    
    @isTest
    static void Test_selectRewardsByRewardProfileId()
    {
        Reward_Profile__c rewardProfile = [Select Id, Type__c from Reward_Profile__c];
        RewardSelector sel = new RewardSelector();
        List<Reward__c> rewards = sel.selectRewardsByRewardProfileId(rewardProfile.Id, rewardProfile.Type__c);
        
        System.assertEquals(1, rewards.size());
    }
    
    @isTest
    static void Test_selectRewardsByVehicleRegNum()
    {
        Reward__c reward = [SELECT Id, Type__c, Registered_Vehicle__c from Reward__c];
        RewardSelector sel = new RewardSelector();
        List<Reward__c> rewards = sel.selectRewardsByVehicleRegNum(reward.Registered_Vehicle__c, reward.Type__c);
    }
    
    @isTest
    static void Test_selectRewardsByRewardTypes()
    {
        Reward__c reward = [SELECT Id, Type__c, Registered_Vehicle__c from Reward__c];
        RewardSelector sel = new RewardSelector();
        List<Reward__c> rewards = sel.selectRewardsByRewardTypes(reward.Registered_Vehicle__c, new Set<String> {reward.Type__c});
    }
    
    @isTest
    static void Test_selectRewardsByRecordIds()
    {
        Reward__c reward = [SELECT Id from Reward__c];
        RewardSelector sel = new RewardSelector();
        List<Reward__c> rewards = sel.selectRewardsByRecordIds(new Set<Id> {reward.Id});
    }    
}
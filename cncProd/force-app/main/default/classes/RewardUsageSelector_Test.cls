/** ******
 * Description : Test class for RewardUsageSelector.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200706             TP@aodigy       Created Initial Version. 
 * 
** ******/
@isTest
private class RewardUsageSelector_Test 
{
    @testSetup
    static void setUp(){
        Account acct = Test_DataFactory.createAccount(true, 'Company');
        Contact con = Test_DataFactory.createContact(true, 'Test', 'Test', acct.Id);
        
        Order__c order = Test_DataFactory.createOrder(Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('C_C_E_Shop').getRecordTypeId());
        order.Shop__c = 'KIA';
        insert order;
        
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        Reward__c reward = Test_DataFactory.createReward(true, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(15));
        Reward_Usage__c rewardUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Hold', 'Debit');
        rewardUsage.Order__c = order.id;
        rewardUsage.Autoline_Invoice_Number__c = 'ABC123456';
        insert rewardUsage;   
    }
    
    @isTest
    static void Test_selectRewardUsagesByOrderId()
    {
        Order__c order = [SELECT Id FROM Order__c];
        RewardUsageSelector sel = new RewardUsageSelector();
        List<Reward_Usage__c> rewardUsages = sel.selectRewardUsagesByOrderId(order.Id, '');
        
       System.assertEquals(1, rewardUsages.size());
    }
    
    @isTest
    static void Test_selectRewardUsagesByIds()
    {
        Reward_Usage__c usage = [SELECT Id FROM Reward_Usage__c];
        RewardUsageSelector sel = new RewardUsageSelector();
        List<Reward_Usage__c> rewardUsages = sel.selectRewardUsagesByIds(new Set<Id>{usage.Id}, null);
        
       System.assertEquals(1, rewardUsages.size());
    }
    
    @isTest
    static void Test_selectUsagesByRewardIds()
    {
        Reward__c reward = [SELECT Id FROM Reward__c];
        RewardUsageSelector sel = new RewardUsageSelector();
        List<Reward_Usage__c> rewardUsages = sel.selectUsagesByRewardIds(new Set<Id>{reward.Id}, null, null, null);
        
       System.assertEquals(1, rewardUsages.size());
    }
    
    @isTest
    static void Test_selectRewardUsagesByInvoiceNo() 
    {
        Reward_Usage__c usage = [SELECT Id, Autoline_Invoice_Number__c, Reward__r.Reward_Profile__c FROM Reward_Usage__c];
        RewardUsageSelector sel = new RewardUsageSelector();
        List<Reward_Usage__c> rewardUsages = sel.selectRewardUsagesByInvoiceNo(usage.Autoline_Invoice_Number__c, usage.Reward__r.Reward_Profile__c);
        
       System.assertEquals(1, rewardUsages.size());
    }
    
    @isTest
    static void Test_selectRewardUsagesByPaymentIds()
    {
        Reward_Usage__c usage = [SELECT Id, Payment__c FROM Reward_Usage__c];
        RewardUsageSelector sel = new RewardUsageSelector();
        List<Reward_Usage__c> rewardUsages = sel.selectRewardUsagesByPaymentIds(new Set<Id> {usage.Payment__c});
        
       System.assertEquals(1, rewardUsages.size());
    }
}
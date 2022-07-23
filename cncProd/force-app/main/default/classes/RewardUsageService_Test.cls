/** ******
 * Description : Test class for RewardUsageService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200706             TP@aodigy       Created Initial Version. 
 * 
** ******/

@isTest
private class RewardUsageService_Test 
{
    @testSetup
    static void setUp()
    {
        List<Reward_Usage__c> rewardUsages = new List<Reward_Usage__c>();
        Account acct = Test_DataFactory.createAccount(true, 'Company');
        Contact con = Test_DataFactory.createContact(true, 'Test', 'Test', acct.Id);
        
        Registered_Vehicle__c rvObj = Test_DataFactory.createRegVehicle(false, 'Test-RV123', 'CCK', 'KIAPC', 'Test-RV123', con.Id);
        rvObj.Account__c = acct.Id;
        insert rvObj;
        
        Order__c order = Test_DataFactory.createOrder(Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('C_C_E_Shop').getRecordTypeId());
        order.Shop__c = 'KIA';
        insert order;
        
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(15));
        reward.Contact__c = con.Id;
        reward.Registered_Vehicle__c = rvObj.Id;
        reward.Brand__c = 'KIA';
        insert reward;
        Reward_Usage__c rewardUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Hold', 'Debit');
        rewardUsage.Order__c = order.id;
        rewardUsage.Autoline_Invoice_Number__c = 'ABC123456';
        rewardUsage.Channel__c = 'eShop';
        rewardUsages.add(rewardUsage);   
        
        Reward_Usage__c rewardUsage1 = Test_DataFactory.createRewardUsage(false, reward.Id, 'Expired', 'Debit');
        rewardUsage1.Channel__c = 'System';
        rewardUsages.add(rewardUsage1);  
        insert rewardUsages;
    }
    
    @isTest
    static void Test_getRewardUsagesByOrderId()
    {
        Order__c order = [Select id from Order__c];
        List<Reward_Usage__c> rewardUsages = RewardUsageService.getRewardUsagesByOrderId(order.Id, 'Status__c = \'Hold\'');
        
       System.assertEquals(1, rewardUsages.size());
    }
    
    @isTest
    static void Test_getRewardUsagesByIds()
    {
        Reward_Usage__c usage = [Select id from Reward_Usage__c where status__c ='Hold'];
        List<Reward_Usage__c> rewardUsages = RewardUsageService.getRewardUsagesByIds(new Set<Id>{usage.Id});
        
       System.assertEquals(1, rewardUsages.size());
    }
    
    @isTest
    static void Test_getExpiredRewardUsagesByRewardIds()
    {
        Reward__c reward = [Select id from Reward__c];
        List<Reward_Usage__c> rewardUsages = RewardUsageService.getExpiredRewardUsagesByRewardIds(new Set<Id>{reward.Id});
        
       System.assertEquals(1, rewardUsages.size());
    }
    
    @isTest
    static void Test_getRewardUsagesByInvoiceNo() 
    {
        Reward_Profile__c rewardProfile = [Select id from Reward_Profile__c];
        Reward_Usage__c usage = [Select id, Autoline_Invoice_Number__c from Reward_Usage__c where status__c ='Hold'];
        List<Reward_Usage__c> rewardUsages = RewardUsageService.getRewardUsagesByInvoiceNo(usage.Autoline_Invoice_Number__c, rewardProfile.Id);
        
       System.assertEquals(1, rewardUsages.size());
    }
    
    @isTest
    static void Test_getRewardUsagesByPaymentIds()
    {
        Reward_Usage__c usage = [Select id, Payment__c from Reward_Usage__c where status__c ='Hold'];
        List<Reward_Usage__c> rewardUsages = RewardUsageService.getRewardUsagesByPaymentIds(new Set<ID> {usage.Payment__c});
        
       System.assertEquals(1, rewardUsages.size());
    }
    
    @isTest
    static void Test_getRecordTypeNameById()
    {
        RecordType recordTypeObj = [Select id from RecordType where name = 'debit' and SobjectType = 'reward_usage__c'];
      
        System.assertEquals('Debit', RewardUsageService.getRecordTypeNameById(recordTypeObj.Id));
    }
    
    @isTest
    static void Test_getRewardUsageHistory()
    {  
        Contact cont = [Select Id from Contact];
        Registered_Vehicle__c regVehicle = [Select Id from Registered_Vehicle__c];
        System.assertEquals(2 , RewardUsageService.getRewardUsageHistory(Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get('Fleet').getRecordTypeId(), 
                                                                         cont.Id, regVehicle.Id, 'KIA', 0).size());
    }
    
    @isTest
    static void Test_getRewardUsagesByCreditNote()
    {  
        System.assertEquals(null , RewardUsageService.getRewardUsagesByCreditNote('CN123456', Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get('Credit').getRecordTypeId()));
    }
    
    @isTest
    static void Test_getDebitRewardUsagesByInvoiceNo()
    {  
        System.assertEquals(1 , RewardUsageService.getDebitRewardUsagesByInvoiceNo('ABC123456', Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get('Debit').getRecordTypeId()).size());
    }
    
    @isTest
    static void Test_createPaymentForCreditUsage()
    {
        Reward_Usage__c usage = [Select id, Payment__c from Reward_Usage__c where status__c ='Hold'];
        Reward__c reward = [Select id from Reward__c];
        Reward_Usage__c rewardUsage2 = Test_DataFactory.createRewardUsage(false, reward.Id, 'Issued', 'Credit'); 
        rewardUsage2.Reward_Usage__c = usage.Id;
        rewardUsage2.Type__c = 'Refund';
        rewardUsage2.Credit_Note__c = 'TEST';
        rewardUsage2.Credit_Amount__c = 100;
        rewardUsage2.Refund_Reason__c = 'TEST';
        insert rewardUsage2;      
    }
    
    @isTest
    static void Test_initExpiredRewardUsage()
    {
        Reward__c reward = [Select id, Remainder__c from Reward__c];
   		RewardUsageService.initExpiredRewardUsage(reward, reward.Id, 100);
        
        
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Reward_Usage__c', true);
        Reward_Usage__c usage = [Select id, Payment__c from Reward_Usage__c where status__c ='Hold'];
        Reward__c reward = [Select id from Reward__c];
        Reward_Usage__c rewardUsage2 = Test_DataFactory.createRewardUsage(false, reward.Id, 'Issued', 'Credit'); 
        rewardUsage2.Reward_Usage__c = usage.Id;
        rewardUsage2.Type__c = 'Refund';
        rewardUsage2.Credit_Note__c = 'TEST';
        rewardUsage2.Credit_Amount__c = 100;
        rewardUsage2.Refund_Reason__c = 'TEST';
        insert rewardUsage2;  
        TriggerExclusion.excludeTrigger('Reward_Usage__c', false);
    }
}
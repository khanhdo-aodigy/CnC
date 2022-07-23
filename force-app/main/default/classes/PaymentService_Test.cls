/** ******
 * Description : Test class for PaymentService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200708             TP@aodigy       Created Initial Version. 
 * 
** ******/

@isTest
private class PaymentService_Test {
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
    static void Test_getPaymentsByIDs()
    {
        Reward_Usage__c usage = [Select id, Payment__c from Reward_Usage__c];
        PaymentService.getPaymentsByIDs(new Set<Id> {usage.Payment__c});
    }
    
    @isTest
    static void Test_getPaymentsByOrderId()
    {
        Reward_Usage__c usage = [Select id, Order__r.OrderID__c from Reward_Usage__c];
        PaymentService.getPaymentsByOrderId(usage.Order__r.OrderID__c);
    }
    
    @isTest
    static void Test_getPaymentRecordTypeId()
    {
        PaymentService.getPaymentRecordTypeId('E_Shop_Payment_RT');
    }
    
    @isTest
    static void Test_getPaymentRecordTypeId_Null()
    {
        PaymentService.getPaymentRecordTypeId('E_Shop_Payment');
    }
    
    @isTest
    static void Test_getEshopRefundUsagePayments()
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
        
        PaymentService.getEshopRefundUsagePayments(Date.today().addDays(-15));
    }
    
}
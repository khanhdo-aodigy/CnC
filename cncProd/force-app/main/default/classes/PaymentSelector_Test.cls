/** ******
 * Description : Test class for PaymentSelector.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200708             TP@aodigy       Created Initial Version. 
 * 
** ******/
@isTest
private class PaymentSelector_Test 
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
        Reward_Usage__c rewardUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Utilised', 'Debit');
        rewardUsage.Order__c = order.id;
        rewardUsage.Autoline_Invoice_Number__c = 'ABC123456';
        rewardUsage.Channel__c = 'eShop';
        insert rewardUsage;   
    }
    
    @isTest
    static void Test_selectPaymentsByIds()
    {
        Reward_Usage__c usage = [Select id, Payment__c from Reward_Usage__c];
        PaymentSelector sel = new PaymentSelector();
        sel.selectPaymentsByIds(new Set<Id> {usage.Payment__c});
    }
    
    @isTest
    static void Test_selectPaymentsByOrderId()
    {
        Reward_Usage__c usage = [Select id, Order__r.OrderID__c from Reward_Usage__c];
        PaymentSelector sel = new PaymentSelector();
        sel.selectPaymentsByOrderId(usage.Order__r.OrderID__c);
    }
    
    @isTest
    static void Test_selectPaymentsByTypeAndDateFiters()
    {
        PaymentSelector sel = new PaymentSelector();
        List<Invoice__c> payments = sel.selectPaymentsByTypeAndDateFiters(new Set<Id>{Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('E_Shop_Payment_RT').getRecordTypeId()}, 
                                              new Set<String>{'Accessories Credit'}, new Set<String>{'Purchase'}, Date.today().addDays(-15));
        System.assertEquals(1, payments.size());
    }

}
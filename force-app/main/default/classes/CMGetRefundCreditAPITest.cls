/** *****
 * Description : Test Class for CMGetRefundCreditAPI.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                         Description
 * 20200708            khanh.do@aodigy              Created Initial Version 
 * 
** *****/
@isTest
private class CMGetRefundCreditAPITest {
    static Integer noRecord = 10;
	@testSetup
    private static void setUp() {
        Account dummyAcc = Test_DataFactory.createAccount(true, 'Dummy Account');
        Contact dummyCon = Test_DataFactory.createContact(true, 'FName', 'DummyLName', dummyAcc.Id);
        Id recordTypeId = PaymentService.getPaymentRecordTypeId('E_Shop_Payment_RT');
        List<Invoice__c> invoices = new List<Invoice__c>();
        for(Integer i =0; i< noRecord; i++) {
            Invoice__c invoice = Test_DataFactory.createInvoice(false, dummyCon);
            invoice.RecordTypeId = recordTypeId;
            invoice.Payment_Type__c = 'Accessories Credit';
            invoice.Transaction_Type__c = 'Refund';
            invoices.add(invoice);
        }
        TriggerExclusion.excludeTrigger( 'Invoice__c', true );
        insert invoices;
        
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        Reward__c reward = Test_DataFactory.createReward(true, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(15));
        List<Reward_Usage__c> rewardUsages = new List<Reward_Usage__c>();
        for(Invoice__c payment: invoices) {
            Reward_Usage__c rewardUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Hold', 'Debit');
            rewardUsage.Autoline_Invoice_Number__c = 'ABC123456';
            rewardUsage.Payment__c = payment.Id;
            rewardUsages.add(rewardUsage); 
        }
        insert rewardUsages;
        
    }
    
    @isTest
	private static void testGetEShopRefundCredit_HappyPath(){
        Test.startTest();
        String reqURI = '/RefundCreditPayment/retrieve?startdate/' + Date.today().addDays(-1); 
        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 200);
        CMGetRefundCreditAPI.getEShopRefundCredit();
        Test.stopTest();
    }
}
/** *****
 * Description : Test Class for CMCreditUsageService.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name              Description
 * 20200707            KD@aodigy         Created Initial Version 
 * 
** *****/
@isTest
private class CMCreditUsageServiceTest {

    static String invoiceNo = 'INV70070070000';

	@testSetup
    private static void setUp(){

        Account paObj = Test_DataFactory.createPerson(false, 'Test-Acct', 'Customer');
        paObj.DWH_Contact_ID__pc = 'Test-Contact-DWHID1';
        insert paObj;
        paObj = [SELECT Id, PersonContactId FROM Account WHERE Id =: paObj.Id];

        Registered_Vehicle__c rvObj = Test_DataFactory.createRegVehicle(false, 'Test-RV123', 'CCK', 'KIAPC', 'Test-RV123', paObj.PersonContactId);
        rvObj.Account__c = paObj.Id;
        insert rvObj;

        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(false, 'Individual', 'CCK', 'KIA', 'Accessories Credit');
        rewardProfile.Contact__c = paObj.PersonContactId;
        insert rewardProfile;

        Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(5));
        reward.Credit__c = 20000;
        reward.Branch__c = 'CCK';
        reward.Brand__c  = 'KIA';
        reward.Registered_Vehicle__c = rvObj.Id;
        reward.Contact__c = paObj.PersonContactId;
        insert reward;

        Reward_Usage__c debitUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Utilised', 'Debit');
        debitUsage.Credit_Amount__c = 8000;
        debitUsage.Autoline_Invoice_Number__c = invoiceNo;
        insert debitUsage;

        Reward_Usage__c creditUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Issued', 'Credit');
        creditUsage.Credit_Amount__c = 500;
        creditUsage.Autoline_Invoice_Number__c = invoiceNo;
        insert creditUsage;
    }
    
    @istest
    private static void testCreateRewardCreditUsage_HappyPath() {
        
        List<Reward_Profile__c> lstRewardProfiles = [SELECT ID FROM Reward_Profile__c];
        System.assert(lstRewardProfiles.size() == 1);
        Decimal refundAmount = 5000;
        List<Reward_Usage__c> results = CMCreditUsageService.createRewardCreditUsage(lstRewardProfiles.get(0).ID, invoiceNo, 'CREDITNOTE123', refundAmount, 'CREDITNOTEREASON', Date.today());
    }
    
    @istest
    private static void testCreateRewardCreditUsage_RefundAmountGreaterThanCreditAmount() {
        
        List<Reward_Profile__c> lstRewardProfiles = [SELECT ID FROM Reward_Profile__c];
        System.assert(lstRewardProfiles.size() == 1);
        Decimal refundAmount = 9000;
        try{
			List<Reward_Usage__c> results = CMCreditUsageService.createRewardCreditUsage(lstRewardProfiles.get(0).ID, invoiceNo, 'CREDITNOTE123', refundAmount, 'CREDITNOTEREASON', Date.today());            
        } 
        catch(Exception ex){}
        
    }
        
    @istest
    private static void testCreateRewardCreditUsage_RefundAmountIsNotGreaterThan0_ExceptionThrown() {
        
        List<Reward_Profile__c> lstRewardProfiles = [SELECT ID FROM Reward_Profile__c];
        System.assert(lstRewardProfiles.size() == 1);
        Decimal refundAmount = 0;
        try{
            List<Reward_Usage__c> results = CMCreditUsageService.createRewardCreditUsage(lstRewardProfiles.get(0).ID, invoiceNo, 'CREDITNOTE123', refundAmount, 'CREDITNOTEREASON', Date.today());
        } 
        catch (Exception ex){
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
    }
    
    @istest
    private static void testCreateRewardCreditUsage_RefundAmountGreaterThanTotalCredit_ExceptionThrown() {
        
        List<Reward_Profile__c> lstRewardProfiles = [SELECT ID FROM Reward_Profile__c];
        System.assert(lstRewardProfiles.size() == 1);
        Decimal refundAmount = 100000;
        try{
            List<Reward_Usage__c> results = CMCreditUsageService.createRewardCreditUsage(lstRewardProfiles.get(0).ID, invoiceNo, 'CREDITNOTE123', refundAmount, 'CREDITNOTEREASON', Date.today());
        } 
        catch (Exception ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
    }
    
    @istest
    private static void testCreateRewardCreditUsage_NoExistingRewardUsageWithInvoiceNo_ExceptionThrown(){
        List<Reward_Profile__c> lstRewardProfiles = [SELECT ID FROM Reward_Profile__c];
        System.assert(lstRewardProfiles.size() == 1);
        String invoiceNumber = 'INVALIDINVOICENO';
        Decimal refundAmount = 5000;
        try{
            List<Reward_Usage__c> results = CMCreditUsageService.createRewardCreditUsage(lstRewardProfiles.get(0).ID, invoiceNumber, 'CREDITNOTE123', refundAmount, 'CREDITNOTEREASON', Date.today());
        } 
        catch (Exception ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }        
    }
    
    @isTest
    private static void test_extendRewardExpiry()
    {
        Reward_Profile__c rewardProfile = [Select ID from Reward_Profile__c];
        Reward__c reward = Test_DataFactory.createReward(true, rewardProfile.Id, 'Accessories Credit', 'Expired', Date.today().addDays(-1));
        Reward_Usage__c newRewardUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Expired', 'Debit');
        newRewardUsage.Channel__c          = 'System';
        newRewardUsage.Type__c             = 'Expiry';
        newRewardUsage.Transaction_Date__c = Date.today();
        newRewardUsage.Invoice_Amount__c   = 0;
        newRewardUsage.Credit_Amount__c    = 100;
        insert newRewardUsage;

        try 
        {
            CMCreditUsageService.extendRewardExpiry(reward.Id, 100, Date.today().addDays(1), 'TEST', Date.today());
        }
        catch(Exception e)
        {
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }
    }
    
    @isTest
    private static void test_createAttachment()
    {
        Reward_Profile__c rewardProfile = [SELECT id, Total_Remainder__c FROM Reward_Profile__c];
        String attachmentName = String.valueOf(Date.today()).remove('-') + '_' +  'CN098765' + '.pdf';
        Attachment att = new Attachment(ParentId = rewardProfile.Id,
                                        Body = Blob.valueOf('TEST'),
                                        Name = attachmentName);
        insert att;
    
        System.assertEquals(CMCreditUsageService.retrieveAttachment(rewardProfile.Id, 'CN098765', Date.today()).Id, att.Id);
    }
}
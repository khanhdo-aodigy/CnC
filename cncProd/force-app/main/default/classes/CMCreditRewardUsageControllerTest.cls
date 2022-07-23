/** *****
 * Description : Test Class for CMCreditRewardUsageController.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name              Description
 * 20200708            KD@aodigy         Created Initial Version 
 * 
** *****/
@isTest
private class CMCreditRewardUsageControllerTest {

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
        debitUsage.Type__c = 'Purchase';
        debitUsage.Autoline_Invoice_Number__c = invoiceNo;
        insert debitUsage;

        Reward_Usage__c creditUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Issued', 'Credit');
        creditUsage.Credit_Amount__c = 500;
        debitUsage.Type__c = 'Refund';
        creditUsage.Autoline_Invoice_Number__c = invoiceNo;
        insert creditUsage;
    }
    
    @istest
    private static void testCreateRewardCreditUsage_HappyPath() {

        Decimal refundAmount = 5000;
        List<Reward_Profile__c> lstRewardProfiles = [SELECT ID FROM Reward_Profile__c];
        System.assert(lstRewardProfiles.size() == 1);
        System.Test.startTest();
            List<Reward_Usage__c> results = CMCreditRewardUsageController.createRewardCreditUsage(lstRewardProfiles.get(0).ID, invoiceNo, 'CNINV70070070000', refundAmount, 'RefundTest', Date.today());
        System.Test.stopTest();
        System.assert( ([SELECT ID FROM Reward_Usage__c WHERE RecordType.Name = 'Credit' AND Autoline_Invoice_Number__c = 'INV70070070000']).size() == 2 );
    }

}
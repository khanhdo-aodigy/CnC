/** ******
 * Description : Test class for CMDebitUsageTranscriptController.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200903             TP@aodigy       Created Initial Version. 
 * 
** ******/

@isTest
private class CMDebitUsageTranscriptControllerTest 
{
    @testSetup
    static void setUp()
    {
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
        reward.Credit__c = 1000;
        reward.Branch__c = 'CCK';
        reward.Brand__c  = 'KIA';
        reward.Registered_Vehicle__c = rvObj.Id;
        reward.Contact__c = paObj.PersonContactId;
        insert reward;
        
        Reward_Usage__c rewardUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Hold', 'Debit');
        rewardUsage.Credit_Amount__c = 100;
        insert rewardUsage;   
    }
    
    @isTest
	static void testCMDebitUsageTranscriptController()
    {
        Reward_Profile__c rewardProfile = [SELECT id, Total_Remainder__c FROM Reward_Profile__c];
 
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', rewardProfile.Id);
        ApexPages.currentPage().getParameters().put('totalRemainderBefore', String.valueOf(1000));
        ApexPages.currentPage().getParameters().put('usageDate', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('invoiceNumber', 'INV12345');
        ApexPages.currentPage().getParameters().put('invoiceAmount', String.valueOf(200));
        ApexPages.currentPage().getParameters().put('creditAmount', String.valueOf(100));
        ApexPages.currentPage().getParameters().put('outStandingAmount', String.valueOf(100));
        ApexPages.currentPage().getParameters().put('totalRemainder', String.valueOf(900)); 
        
        CMDebitUsageTranscriptController controller = new CMDebitUsageTranscriptController();
        Reward_Profile__c rwdProfile = controller.rewardProfileRec;
        
        System.assertEquals(rwdProfile.Id, rewardProfile.Id);
    }
}
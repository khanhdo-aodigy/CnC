/** ******
 * Description : Test class for CMAttachmentService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200903             TP@aodigy       Created Initial Version. 
 * 
** ******/
@isTest
private class CMAttachmentServiceTest 
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
    static void test_generateDebitUsageAttachment()
    {
        Reward_Profile__c rewardProfile = [SELECT id, Total_Remainder__c FROM Reward_Profile__c];
        CMAttachmentService.generateDebitUsageAttachment(rewardProfile.Id, 1000, Date.today(), 'INV123456', 200, 100, 100, rewardProfile.Total_Remainder__c);
    }
    
    @isTest
    static void test_generateCreditUsageAttachment()
    {
        Reward_Profile__c rewardProfile = [SELECT id, Total_Remainder__c FROM Reward_Profile__c];
        CMAttachmentService.generateCreditUsageAttachment(rewardProfile.Id, Date.today(), 'INV123456', 'CN098765', 50, 'TEST', 950, 50);
    }
    
    @isTest
    static void test_createAttachment()
    {
        Reward_Profile__c rewardProfile = [SELECT id, Total_Remainder__c FROM Reward_Profile__c];
        CMAttachmentService.createAttachment(rewardProfile.Id, Date.today(), 'INV09876', Blob.valueOf('TEST'));
    }
    
    @isTest
    static void test_getAttachmentById()
    {
        Reward_Profile__c rewardProfile = [SELECT id, Total_Remainder__c FROM Reward_Profile__c];
        CMAttachmentService.createAttachment(rewardProfile.Id, Date.today(), 'INV09876', Blob.valueOf('TEST'));
        String attachmentName = String.valueOf(Date.today()).remove('-') + '_' +  'INV09876' + '.pdf';
        Attachment att =  [SELECT Id FROM Attachment WHERE ParentId =: rewardProfile.Id AND Name =: attachmentName];
    
        System.assertEquals(CMAttachmentService.getAttachmentById(rewardProfile.Id, 'INV09876', Date.today()).Id, att.Id);
    }
}
/** ******
 * Description : Test class for CMDebitUsageService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200707             TP@aodigy       Created Initial Version. 
 * 
** ******/
@isTest
private class CMDebitUsageService_Test 
{  
    @testSetup
    static void setUp()
    {
        User user = Test_DataFactory.createUser(true, 'TESTUSER', 'test1');
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

        Reward__c reward1 = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(10));
        reward1.Credit__c = 2000;
        reward1.Branch__c = 'CCK';
        reward1.Brand__c  = 'KIA';
        reward1.Registered_Vehicle__c = rvObj.Id;
        reward1.Contact__c = paObj.PersonContactId;
        insert reward1;
        
        Reward_Usage__c rewardUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Hold', 'Debit');
        rewardUsage.Credit_Amount__c = 100;
        insert rewardUsage;   
    }
    

    @isTest
    static void Test_checkRewardProfileRemainder()
    {
        Reward_Profile__c rewardProfile = [SELECT id, Total_Remainder__c FROM Reward_Profile__c];
        System.assertEquals(true,  CMDebitUsageService.checkRewardProfileRemainder(rewardProfile.id, 200));       
    }
    
    @isTest
    static void Test_checkTotalRemainder()
    {
        List<Reward__c> rewards = [SELECT id, Remainder__c FROM Reward__c];
        System.assertEquals(true,  CMDebitUsageService.checkTotalRemainder(rewards, 200));       
    }
    
    @isTest
    static void Test_retrieveRewardProfile()
    {
       Reward_Profile__c rewardProfile = [SELECT Id FROM Reward_Profile__c];
       CMDebitUsageService.retrieveRewardProfile(rewardProfile.id);
    }
    
    @isTest
    static void Test_retrieveReward()
    {
        Reward__c rw= [Select Id from Reward__c Where Credit__c = 1000];
        System.assertEquals(rw.Id, CMDebitUsageService.retrieveReward(rw.Id).Id);
    }
    
    @isTest
    static void Test_createAdjustment()
    {
        User user = [Select Id from User Where LastName = 'TESTUSER'];
        Reward_Profile__c rewardProfile = [SELECT Id, Total_Remainder__c FROM Reward_Profile__c];
        System.assertEquals(1, CMDebitUsageService.createAdjustment(rewardProfile.Id, 10, user.Id, 'AK-00000', 'TEST').size());
    }
    
    @isTest
    static void Test_createDebitRewardUsages_OneUsage()
    {
        try {
            Reward_Profile__c rewardProfile = [SELECT Id, Total_Remainder__c FROM Reward_Profile__c];
            CMDebitUsageService.createDebitRewardUsages(rewardProfile.Id, 500, 'INV123456', 200, Date.today(), null, null, rewardProfile.Total_Remainder__c);
        }
        catch(Exception ex)
        {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }     
	}
    
    @isTest
    static void Test_createDebitRewardUsages_MultipleUsages()
    {
        try {
            Reward_Profile__c rewardProfile = [SELECT Id, Total_Remainder__c FROM Reward_Profile__c];
            CMDebitUsageService.createDebitRewardUsages(rewardProfile.Id, 2000, 'INV1234567', 1500, Date.today(), null, null, rewardProfile.Total_Remainder__c);
        }
        catch(Exception ex)
        {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
	}
    
    @isTest
    static void Test_createDebitRewardUsages_OneUsage2()
    {
        try{
            Reward_Profile__c rewardProfile = [SELECT Id, Total_Remainder__c FROM Reward_Profile__c];
            CMDebitUsageService.createDebitRewardUsages(rewardProfile.Id, 2000, 'INV1234562', 900, Date.today(), null, null, rewardProfile.Total_Remainder__c);
        }
        catch(Exception ex)
        {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
    }
    
    @isTest
    static void Test_createDebitRewardUsages_Error()
    {
        try{
            Reward_Profile__c rewardProfile = [SELECT Id, Total_Remainder__c FROM Reward_Profile__c];
            CMDebitUsageService.createDebitRewardUsages(rewardProfile.Id, 5000, 'INV1234563', 4500, Date.today(), null, null, rewardProfile.Total_Remainder__c);
        } 
        catch (Exception ex){
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
    }
}
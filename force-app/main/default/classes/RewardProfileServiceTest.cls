/** *****
 * Description : Test Class for RewardProfileService.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                       Description
 * 20200706            khanh.do@aodigy            Created Initial Version 
 * 
** *****/
@isTest
private class RewardProfileServiceTest {
    
    @isTest
    private static void testGetRegVehId() 
    {
        User user = Test_DataFactory.createUser(true, 'TESTUSER', 'test1');
        Account paObj = Test_DataFactory.createPerson(false, 'Test-Acct', 'Customer');
        paObj.DWH_Contact_ID__pc = 'Test-Contact-DWHID1';
        insert paObj;
        paObj = [SELECT Id, PersonContactId FROM Account WHERE Id =: paObj.Id];

        Registered_Vehicle__c dummyRegVeh = Test_DataFactory.createRegVehicle(false, 'Fake Name', 'CCK', 'KIAPC', 'Fake No 1', paObj.PersonContactId);
        dummyRegVeh.Account__c = paObj.Id;
        insert dummyRegVeh;
        String vehNumber = dummyRegVeh.Name;
        String actualRegVehId = RewardProfileService.getRegVehId(vehNumber);
        System.assertEquals(dummyRegVeh.Id, actualRegVehId);
    }
    
    @isTest
    private static void testGetRewardProfiles() {
        String vehNumber = '005vjsfsdk';
        String recordType = 'Fleet';
		String recordTypeId = Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        
        Account dummyAcc = Test_DataFactory.createAccount(true, 'Company');
        Contact dummyCon = Test_DataFactory.createContact(true, 'Test', 'Test', dummyAcc.Id);
        String contactId = dummyCon.Id;
        Registered_Vehicle__c dummyRegVeh = Test_DataFactory.createRegVehicle(true, 'Fake Name', 'CCK', 'KIAPC', 'Fake No 1', dummyCon.Id);
        String regVehId = dummyRegVeh.Id;
        String brand = 'KIA';
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', brand, 'Accessories Credit');
        rewardProfile.Contact__c = contactId;
        rewardProfile.Registered_Vehicle__c = regVehId;
        insert rewardProfile;

        List<Reward_Profile__c> rewardProfiles = RewardProfileService.getRewardProfiles(recordTypeId, contactId, regVehId, brand);
    	System.assertEquals(1, rewardProfiles.size());
    }
    
    @isTest
    private static void testGetRewardProfileById() {
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        Reward_Profile__c result = RewardProfileService.getRewardProfileById(rewardProfile.Id);
        System.assertNotEquals(null, result);
    }
    
    @isTest
    private static void testGetRewardProfileByIds(){
        List<Reward_Profile__c> rewardProfiles = new List<Reward_Profile__c>();        
        
        Reward_Profile__c accCreditProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        rewardProfiles.add(accCreditProfile);
        
        Reward_Profile__c boutiqueProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', 'KIA', 'Boutique');
        rewardProfiles.add(boutiqueProfile);
        
        Reward_Profile__c birthdayProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', 'KIA', 'Birthday Voucher');
        rewardProfiles.add(birthdayProfile);
        
        insert rewardProfiles;
        Set<String> rewardProfileIds = new Set<String>();
        for(Reward_Profile__c profile: rewardProfiles) {
            rewardProfileIds.add(profile.Id);
        }        
        List<Reward_Profile__c> results = RewardProfileService.getRewardProfilesByIds(rewardProfileIds);
        System.assertEquals(rewardProfiles.size(), results.size());
    }
    
    @isTest
    private static void testGetRewardProfileByIdWithRewards(){
        List<Reward_Profile__c> rewardProfiles = new List<Reward_Profile__c>();
        
        Reward_Profile__c accCreditProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        rewardProfiles.add(accCreditProfile);
        
        Reward_Profile__c boutiqueProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', 'KIA', 'Boutique');
        rewardProfiles.add(boutiqueProfile);
        
        Reward_Profile__c birthdayProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', 'KIA', 'Birthday Voucher');
        rewardProfiles.add(birthdayProfile);
        
        insert rewardProfiles;
        Set<String> rewardProfileIds = new Set<String>();
        for(Reward_Profile__c profile: rewardProfiles) {
            rewardProfileIds.add(profile.Id);
        }        
        List<Reward_Profile__c> results = RewardProfileService.getRewardProfilesByIdsWithRewards(rewardProfileIds);
        System.assertEquals(rewardProfiles.size(), results.size());
    }
    
    @isTest
    private static void getPersonContactIdByUserId() {
          Account personAcc = Test_DataFactory.createPerson(true, 'Lee', 'Customer');
          personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];

          User user = new User();
          user.ProfileID = [Select Id From Profile Where Name='End User'].Id;
          user.EmailEncodingKey = 'ISO-8859-1';
          user.LanguageLocaleKey = 'en_US';
          user.TimeZoneSidKey = 'America/New_York';
          user.LocaleSidKey = 'en_US';
          user.FirstName = 'first';
          user.LastName = 'last';
          user.Username = 'test@appirio.com';   
          user.CommunityNickname = 'testUser123';
          user.Alias = 't1';
          user.Email = 'no@email.com';
          user.IsActive = true;
          user.ContactId = personAcc.PersonContactId;        
          insert user;
        
          String result = RewardProfileService.getPersonContactId(user.Id);
          System.assertEquals(personAcc.PersonContactId, result);
    }
    
}
/** *****
 * Description : Test Class for RewardProfileSelector.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200706            KH@aodigy            Created Initial Version 
 * 
** *****/
@isTest
private class RewardProfileSelectorTest {
    
    static RewardProfileSelector rewardProfileSelector = new RewardProfileSelector();
    @testSetUp
    private static void setup(){      
        
        //Insert RP for Person Accounts [START]
        List<Account> lstPersonAccounts = new List<Account>();
        for(Integer count = 0 ; count < 5 ; count++ ){
            Account tempAcct = Test_DataFactory.createPerson(false, 'PersonAcct'+count, 'Customer');
            tempAcct.DWH_Contact_ID__pc = 'PersonAcctDWHCNT'+count;
            lstPersonAccounts.add( tempAcct );
        }
        if( !lstPersonAccounts.isEmpty() ){
            insert lstPersonAccounts;
        }

        List<Registered_Vehicle__c> lstRegisteredVehs = new List<Registered_Vehicle__c>();
        Integer index = 0;
        for(Account acct : [SELECT Id, PersonContactId FROM Account WHERE ID IN :lstPersonAccounts]){
            Registered_Vehicle__c tempVeh = Test_DataFactory.createRegVehicle(false, 'TESTREGNO'+index, 'CCK', 'KIAPC', 'TESTREGNO'+index, acct.PersonContactId);
            tempVeh.Account__c = acct.Id;
            lstRegisteredVehs.add( tempVeh );
            index++;
        }
        if( !lstRegisteredVehs.isEmpty() ){
            insert lstRegisteredVehs;
        }

        List<Reward_Profile__c> lstRewardProfiles = new List<Reward_Profile__c>();
        for(Integer count = 0; count < lstRegisteredVehs.size() ; count++ ){
            Reward_Profile__c tempRP = Test_DataFactory.createRewardProfile(false, 'Individual', 'CCK', 'KIA', 'Accessories Credit');
            tempRP.Contact__c = lstRegisteredVehs.get(count).Contact__c;
            tempRP.Account__c = lstRegisteredVehs.get(count).Account__c;

            lstRewardProfiles.add( tempRP );
        }
        if( !lstRewardProfiles.isEmpty() ){
            insert lstRewardProfiles;
        }
        //Insert RP for Person Accounts [END]
        
        Account dummyAcc = Test_DataFactory.createAccount(true, 'Company');
        Contact dummyCon = Test_DataFactory.createContact(true, 'Test', 'Test', dummyAcc.Id);
        Registered_Vehicle__c dummyRegVeh = Test_DataFactory.createRegVehicle(true, 'Fake Name', 'CCK', 'KIAPC', 'Fake No 1', dummyCon.Id);
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(false, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
    	rewardProfile.Contact__c = dummyCon.Id;
        rewardProfile.Registered_Vehicle__c = dummyRegVeh.Id;
        insert rewardProfile;
    }
    
    @isTest
    private static void testGetSObjectType(){
        Schema.SObjectType actualResult = rewardProfileSelector.getSObjectType();
        System.assertEquals('Reward_Profile__c', String.valueOf(actualResult));
    }
    
    @isTest
    private static void testGetSObjectFieldList(){
        List<Schema.SObjectField> rewardProfileFieldList = rewardProfileSelector.getSObjectFieldList();
        System.assert(rewardProfileFieldList != null);
    }
    
    @isTest
    private static void testGetRewardProfiles(){
		String recordTypeId = Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get('Fleet').getRecordTypeId();
        
        Registered_Vehicle__c dummyRegVeh = [SELECT Id, Contact__c FROM Registered_Vehicle__c WHERE Contact__r.IsPersonAccount = false LIMIT 1];
        String regVehId = dummyRegVeh.Id;
        String contactId = dummyRegVeh.Contact__c;
        String brand = 'KIA';

        List<Reward_Profile__c> rewardProfiles = rewardProfileSelector.getRewardProfiles(recordTypeId, contactId, regVehId, brand);
    	System.assertEquals(1, rewardProfiles.size());
    }
    
    @isTest
    private static void testGetRecordTypeId(){
        System.assertEquals(Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get( 'Fleet' ).getRecordTypeId(), rewardProfileSelector.getRecordTypeId('Fleet'));
        System.assertEquals(Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get( 'Individual' ).getRecordTypeId(), rewardProfileSelector.getRecordTypeId('Individual'));
    }
    
    @isTest
    private static void testSelectByIdWithRewards(){
        Id rpRTId = Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get( 'Individual' ).getRecordTypeId();
        Map<Id,Reward_Profile__c> mapRewardProfiles = new Map<Id,Reward_Profile__c>([SELECT ID FROM Reward_Profile__c WHERE RecordTypeId =:rpRTId]);
        System.Test.startTest();
            List<Reward_Profile__c> results = rewardProfileSelector.selectByIdWithRewards( (Set<String>)JSON.deserialize(JSON.serialize(mapRewardProfiles.keySet()), Set<String>.class) );
            System.assert(results.size()==5);
        System.Test.stopTest();
    }
       
    @isTest
    private static void testSelectById(){
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        Reward_Profile__c result = rewardProfileSelector.selectById(rewardProfile.Id);
    }
    
    @isTest
    private static void testSelectByIds(){
        Id rpRTId = Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get( 'Individual' ).getRecordTypeId();
        Map<Id,Reward_Profile__c> mapRewardProfiles = new Map<Id,Reward_Profile__c>([SELECT ID FROM Reward_Profile__c WHERE RecordTypeId =:rpRTId]);
        System.Test.startTest();
            List<Reward_Profile__c> results = rewardProfileSelector.selectByIds( (Set<String>)JSON.deserialize(JSON.serialize(mapRewardProfiles.keySet()), Set<String>.class) );
            System.assert(results.size()==5);
        System.Test.stopTest();
    }
    
    @isTest
    private static void testSelectByUniqueKeys(){
        Id rpRTId = Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get( 'Individual' ).getRecordTypeId();
        Set<String> setUniqueKeys = new Set<String>();
        for( Reward_Profile__c rp : [SELECT ID, Unique_Key__c FROM Reward_Profile__c WHERE RecordTypeId =: rpRTId]){
            setUniqueKeys.add( rp.Unique_Key__c );
        }
        System.Test.startTest();
            List<Reward_Profile__c> results = rewardProfileSelector.selectByUniqueKeys(setUniqueKeys);
            System.assert(results.size()==5);
        System.Test.stopTest();
    }
}
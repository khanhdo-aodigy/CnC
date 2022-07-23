/** *****
 * Description : Selector Class for Reward_Profile__c object
 * 
 * Change History
 * Date(YYYYMMDD)      Name                 Description
 * 20200617            KD@aodigy            Created Initial Version. 
 * 20200617            TP@aodigy            Added getRewardProfileById & getRewardProfilesByIds methods. 
 * 
** *****/
public with sharing class RewardProfileService {

    private static RewardProfileSelector rewardProfileSelector = new RewardProfileSelector();
    private static RegisteredVehicleSelector registeredVehicleSelector = new RegisteredVehicleSelector();
    private static ContactSelector contactSelector = new ContactSelector();

    public static String getPersonContactId(String userId) {
        return contactSelector.getPersonContactIdByUserId(userId);
    }

    public static String getRegVehId(String vehNumber) {
        return registeredVehicleSelector.getIdByName(vehNumber);
    }

    public static List<Reward_Profile__c> getRewardProfiles(String recordTypeId, String contactId, String regVehId, String brand){
        return rewardProfileSelector.getRewardProfiles(recordTypeId, contactId, regVehId, brand);
    }

    public static Reward_Profile__c getRewardProfileById(String rewardProfileId) {
        return rewardProfileSelector.selectById(rewardProfileId);
    }

    public static List<Reward_Profile__c> getRewardProfilesByIds(Set<String> rewardProfileIds) {
        return rewardProfileSelector.selectByIds(rewardProfileIds);
    }

    public static List<Reward_Profile__c> getRewardProfilesByIdsWithRewards(Set<String> rewardProfileIds)
    {
        return rewardProfileSelector.selectByIdWithRewards(rewardProfileIds);
    }


    // public static List<Reward_Profile__c> checkRewardProfile( List<Reward__c> lstNewRewards )
    // {
    //     Map<String, List<RewardProfile>> mapKeyToRewardProfiles = new Map<String,List<RewardProfile>>();
    //     Map<String, List<Reward__c>> mapKeyToRewards = new Map<String,List<Reward__c>>();
    //     String individualTypeId = RewardProfileSelector.getRecordTypeId('Individual');
    //     String leasingTypeId = RewardProfileSelector.getRecordTypeId('Fleet');
    //     Set<String> contactIds = new Set<String>();

    //     for(Reward__c reward: lstNewRewards) {
    //         if(reward.Contact__c != null) {
    //             contactIds.add(reward.Contact__c);
    //         }            
    //     }

    //     Map<String, Boolean> mapContactIdToIsPerson = getIsPersonAccountContact(contactIds);

    //     for(Reward__c reward: lstNewRewards) {
    //         String uniqueKey;            
    //         String brand      = reward.Brand__c;
    //         String rewardType = reward.Type__c;                
    //         String contactId  = reward.Contact__c;                            
    //         String regVehId   = reward.Registered_Vehicle__c;
    //         Boolean isPersonAccCon = false;
    //         String recordTypeId;
    //         if(contactId != null) {
    //             isPersonAccCon = mapContactIdToIsPerson.get(contactId);
    //         }

    //         System.debug('=========DEBUG checkRewardProfile :: isPersonAccCon = ' + isPersonAccCon);
    //         String recordType = isPersonAccCon ? 'Individual' : 'Leasing'; // Record Type can be more that these 

    //         if(recordType == 'Individual') {
    //             recordTypeId = individualTypeId;
    //             uniqueKey = recordTypeId + '_' + contactId + '_' + brand + '_' + rewardType;
    //         } 
    //         else {
    //             recordTypeId = leasingTypeId;
    //             uniqueKey = recordTypeId + '_' + regVehId + '_' + brand + '_' + rewardType;
    //         }
    //         System.debug('@@@@DEBUG checkRewardProfile :: uniqueKey = ' + uniqueKey);

    //         if (!mapKeyToRewards.containsKey(uniqueKey)) {           
    //             mapKeyToRewards.put(uniqueKey, new List<Reward__c>{ reward });
    //         } 
    //         else {
    //             mapKeyToRewards.get(uniqueKey).add(reward);
    //         }

    //         RewardProfile profileInst = new RewardProfile(recordTypeId, contactId, regVehId, brand, rewardType, uniqueKey);
            
    //         if (!mapKeyToRewardProfiles.containsKey(uniqueKey)) {
    //             List<RewardProfile> values = new List<RewardProfile>();
    //             values.add(profileInst);            
    //             mapKeyToRewardProfiles.put(uniqueKey, values);
    //         } 
    //         else {
    //             mapKeyToRewardProfiles.get(uniqueKey).add(profileInst);
    //         }
    //     }

        
    //     Set<String> newKeys = mapKeyToRewardProfiles.keySet();
    //     Set<String> allKeys = new Set<String>(newKeys);
    //     System.debug('newKeys = ' + newKeys);
        
    //     //Retrieve Existing Reward Profiles if any
    //     Map<String,Reward_Profile__c> mapExistingRewardProfiles = new Map<String,Reward_Profile__c>();
    //     for(Reward_Profile__c profile : rewardProfileSelector.selectByUniqueKeys( mapKeyToRewardProfiles.KeySet() ) ){
    //         mapExistingRewardProfiles.put(profile.Unique_Key__c , profile);
    //     }
    //     System.debug('@@@@DEBUG checkRewardProfile :: mapExistingRewardProfiles = ' + mapExistingRewardProfiles.size() + ' --- ' + mapExistingRewardProfiles );
        
    //     //Remove existing Reward Profile Unique Key(s)
    //     if( !mapExistingRewardProfiles.isEmpty() ){
    //         newKeys.removeAll( mapExistingRewardProfiles.KeySet() );
    //     }
        
    //     //Create new Profile(s) with new Unique Key(s)
    //     List<Reward_Profile__c> rewardProfilesToInsert = new List<Reward_Profile__c>();
    //     Map<String,Reward_Profile__c> mapNewRewardProfile = new Map<String,Reward_Profile__c>();
    //     for(String uniqueKey : newKeys) 
    //     {
    //         RewardProfile data = mapKeyToRewardProfiles.get(uniqueKey)[0];
    //         Reward_Profile__c newProfile = new Reward_Profile__c();
    //         newProfile.RecordTypeId          = data.recordTypeId;
    //         newProfile.Contact__c            = data.contactId;
    //         newProfile.Registered_Vehicle__c = data.regVehId;
    //         newProfile.Brand__c              = data.brand;
    //         newProfile.Type__c               = data.type;
    //         newProfile.Unique_Key__c         = uniqueKey;
    //         rewardProfilesToInsert.add(newProfile);

    //         mapNewRewardProfile.put( newProfile.Unique_Key__c, newProfile );
    //     }
    //     System.debug('@@@@DEBUG checkRewardProfile :: rewardProfilesToInsert = ' + rewardProfilesToInsert.size() + ' --- ' + rewardProfilesToInsert );
    //     if( !mapNewRewardProfile.isEmpty() )
    //     {
    //         insert (mapNewRewardProfile.values());
    //         mapExistingRewardProfiles.putAll( mapNewRewardProfile );
    //     }

    //     linkRewardsToRewardProfile( mapKeyToRewards, mapExistingRewardProfiles );
    //     return rewardProfilesToInsert;
    // }

    // private static Map<String, Boolean> getIsPersonAccountContact(Set<String> contactIds) {
    //     List<Contact> contacts =  [SELECT Id, IsPersonAccount FROM Contact WHERE Id IN :contactIds];
    //     Map<String, Boolean> mapContactIdToIsPerson = new Map<String, Boolean>();
    //     for(Contact contact : contacts) {
    //         mapContactIdToIsPerson.put(contact.Id, contact.IsPersonAccount);
    //     }
    //     return mapContactIdToIsPerson;
    // }

    // private static void linkRewardsToRewardProfile(Map<String, List<Reward__c>> mapKeyToRewards, Map<String,Reward_Profile__c> mapRewardProfiles ) {

    //     for(String ukey: mapRewardProfiles.keySet()) 
    //     {   
    //         Reward_Profile__c rProfile = mapRewardProfiles.get( ukey );
    //         if( mapKeyToRewards.containsKey( ukey ) ) {
    //             for( Reward__c newReward : mapKeyToRewards.get( ukey ) ){
    //                 if( rProfile.Id <> null ){
    //                     newReward.Reward_Profile__c = rProfile.Id;
    //                 }
    //             }
    //         }
    //     }
    // }
    
    // public class RewardProfile {
    //     String recordTypeId;
    //     String contactId;
    //     String regVehId;
    //     String brand;
    //     String type;
    //     String uniqueKey;

    //     public RewardProfile(String recordTypeId, String contactId, String regVehId, String brand, String Type, String uniqueKey) {
    //         this.recordTypeId = recordTypeId;
    //         this.contactId = contactId;
    //         this.regVehId = regVehId;
    //         this.brand = brand;
    //         this.type = type;
    //         this.uniqueKey = uniqueKey;
    //     }
    // }


}
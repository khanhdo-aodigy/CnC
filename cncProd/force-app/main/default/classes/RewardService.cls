/** ******
 * Description : Service Class for Reward object
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                        Description
 * 20200617             TP@aodigy                   Created Initial Version. 
 * 20200629             HS@aodigy                   Added reactivateRewards method
 * 
***** **/
public with sharing class RewardService {
    
    private static RewardSelector rewardSelector = new RewardSelector();

    public static List<Reward__c> getRewardsByRewardProfileId(String rewardProfileId, String rewardType) {
        return rewardSelector.selectRewardsByRewardProfileId(rewardProfileId, rewardType);
    }

    public static List<Reward__c> getRewardsByVehicleRegNum(String vehicleRegNum, String rewardType) {
        return rewardSelector.selectRewardsByVehicleRegNum(vehicleRegNum, rewardType);
    }

    public static List<Reward__c> getRewardsByRecordIds( Set<Id> setRewardIds ) {
        return rewardSelector.selectRewardsByRecordIds( setRewardIds );
    }

    public static List<Reward__c> getRewardsByRewardTypes(String vehicleRegNum, Set<String> rewardTypes) {
        return rewardSelector.selectRewardsByRewardTypes(vehicleRegNum, rewardTypes);
    }

    public static void reactivateRewards( List<Reward__c> lstRewards ) {
        try{

            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Reward__c.SObjectType, Reward_Usage__c.SObjectType } );
            Map<Id,Reward__c> mapRewardToWriteback = new Map<Id,Reward__c>();
            List<Reward_Usage__c> lstCreditUsagesToInsert = new List<Reward_Usage__c>();

            for( Reward__c reward : getRewardsByRecordIds( (new Map<Id,Reward__c>(lstRewards)).KeySet() ) ){
                if( reward.Status__c == 'Expired' && reward.Expiry__c > Date.Today() ){
                    reward.Status__c = 'Valid';
                    mapRewardToWriteback.put( reward.Id , reward );
                }
            }
            System.debug('@@@@DEBUG reactivateRewards :: mapRewardToWriteback = ' + mapRewardToWriteback.size() + ' --- ' + mapRewardToWriteback );

            if( mapRewardToWriteback <> null && !mapRewardToWriteback.isEmpty() ){
                for(Reward_Usage__c expiredUsage : RewardUsageService.getExpiredRewardUsagesByRewardIds( mapRewardToWriteback.KeySet() ) ){
                    Reward_Usage__c newCreditUsage = new Reward_Usage__c();
                    newCreditUsage.RecordTypeId = RewardUsageService.getRecordTypeId('Credit');
                    newCreditUsage.Reward__c           = expiredUsage.Reward__c; 
                    newCreditUsage.Channel__c          = 'Service';
                    newCreditUsage.Status__c           = 'Issued';
                    newCreditUsage.Type__c             = 'Extension';
                    newCreditUsage.Transaction_Date__c = Date.Today();
                    newCreditUsage.Credit_Amount__c    = expiredUsage.Credit_Amount__c;
                    newCreditUsage.Reward_Usage__c     = expiredUsage.Id;
                    lstCreditUsagesToInsert.add( newCreditUsage );
                }
            }

            if( mapRewardToWriteback <> null && !mapRewardToWriteback.isEmpty() && lstCreditUsagesToInsert <> null && !lstCreditUsagesToInsert.isEmpty() ){
                TriggerExclusion.excludeTrigger('Reward__c', true);
                uow.registerDirty( (mapRewardToWriteback.values()) );
                uow.registerNew( lstCreditUsagesToInsert );
                uow.commitWork();
            }
        }
        catch(Exception ex){
            System.debug('@@@@DEBUG reactivateRewards :: ERROR :: err.cause = ' + ex.getCause() + ' --- err.msg = ' + ex.getMessage() + ' --- err.line = ' + ex.getLineNumber() );
        }
    }

    public static Set<String> getPickListValues(String fieldName) {
        Set<String> pickListValues= new Set<String>();
        Map<String,Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('Reward__c').getDescribe().fields.getMap() ;
        List<Schema.PicklistEntry> ple = fieldsMap.get(fieldName).getDescribe().getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValues.add(pickListVal.getValue());
        }     
        return pickListValues;
    }

}
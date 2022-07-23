/** *****
 * Description : Selector Class for Reward_Profile__c object
 * 
 * Change History
 * Date(YYYYMMDD)      Name                 Description
 * 20200617            KD@aodigy            Created Initial Version. 
 * 20200617            TP@aodigy            Added selectById method. 
 * 
** *****/
public class RewardProfileSelector extends ADGLIB_SObjectSelector  {
    public RewardProfileSelector() {

    }
    public Schema.SObjectType getSObjectType(){
        return Reward_Profile__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Reward_Profile__c');
    }

    public List<Reward_Profile__c> getRewardProfiles(String recordTypeId, String contactId, String regVehId, String brand) {
        String queryString = 'SELECT Id, Type__c, Total_Credit__c, Total_Remainder__c, Total_Credited_Usage__c, Total_Debited_Usage__c,'
                     + ' (SELECT Id, Type__c, Status__c, Registered_Vehicle__c, Registered_Vehicle__r.Name, Remainder__c, Expiry__c FROM Rewards__r)'
                     + ' FROM Reward_Profile__c'
                     + ' WHERE RecordTypeId = :recordTypeId';

        if(String.isNotBlank(contactId)) {
            queryString += ' AND Contact__c = :contactId';
        }
        if(String.isNotBlank(regVehId)) {
            queryString += ' AND Registered_Vehicle__c = :regVehId';
        }

        if(String.isNotBlank(brand)) {
            queryString += ' AND Brand__c = :brand';
        }

        System.debug('getRewardProfiles ' + queryString);
        return Database.query(queryString); 
    }
    
    public String getRecordTypeId(String recordTypeName) {
        String recordTypeId = Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().containsKey( recordTypeName ) ? 
                              Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get( recordTypeName ).getRecordTypeId() : null;

        return recordTypeId;
    }

    public List<Reward_Profile__c> selectByIdWithRewards(Set<String> rewardProfileIds) 
    {
        adglib_QueryFactory query = newQueryFactory();
        query.subselectQuery('Rewards__r')
             .selectFields(new RewardSelector().getSObjectFieldList())
             .setOrdering('Expiry__c', ADGLIB_QueryFactory.SortOrder.ASCENDING)
             .setCondition('Status__c = \'Valid\'');
        query.setCondition('Id IN :rewardProfileIds');
        return (List<Reward_Profile__c> )Database.query(query.toSOQL()); 
    }

    public Reward_Profile__c selectById (String recordId) {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('Contact__r.Name');
        query.setCondition('Id =: recordId');
        return (Reward_Profile__c)Database.query(query.toSOQL())[0]; 
    }

    public List<Reward_Profile__c> selectByIds( Set<String> setRecordIds ){
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :setRecordIds');
        return (List<Reward_Profile__c> )Database.query(query.toSOQL()); 
    }

    public List<Reward_Profile__c> selectByUniqueKeys( Set<String> setUniqueKeys ){
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Unique_Key__c IN :setUniqueKeys');
        return (List<Reward_Profile__c> )Database.query(query.toSOQL()); 
    }
    
}
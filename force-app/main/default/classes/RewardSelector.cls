/** ******
 * Description : Selector Class for Reward object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20200617             TP@aodigy           Created Initial Version. 
 * 
** ******/
public inherited sharing class RewardSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Reward__c.Id,
            Reward__c.Type__c,
            Reward__c.Expiry__c,
            Reward__c.Remainder__c,
            Reward__c.Status__c,
            Reward__c.Credit__c,
            Reward__c.Name,
            Reward__c.Brand__c,
            Reward__c.Expired_Credit__c,
            Reward__c.Contact__c,
            Reward__c.Registered_Vehicle__c
		};
    }

    public Schema.SObjectType getSObjectType() {
        return Reward__c.sObjectType;
    }

    public override String getOrderBy() {
    	return 'Expiry__c ASC, Credit__c ASC, CreatedDate ';
    }

    public List<Reward__c> selectRewardsByRewardProfileId(String rewardProfileId, String rewardType){
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Reward_Profile__c =: rewardProfileId AND Type__c =: rewardType AND  Status__c = \'Valid\'');
        
        return (!Database.query(query.toSOQL()).isEmpty() ? Database.query(query.toSOQL()) : null); 
    }

    public List<Reward__c> selectRewardsByVehicleRegNum(String vehicleRegNum, String rewardType) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Registered_Vehicle__r.Registration_Number__c =: vehicleRegNum AND Type__c =: rewardType AND  Status__c = \'Valid\'');

        return (!Database.query(query.toSOQL()).isEmpty() ? Database.query(query.toSOQL()) : null);           
    }

    public List<Reward__c> selectRewardsByRewardTypes(String vehicleRegNum, Set<String> rewardTypes) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Registered_Vehicle__r.Registration_Number__c  =: vehicleRegNum AND Type__c IN :rewardTypes AND Status__c = \'Valid\'');

        return (List<Reward__c> )Database.query(query.toSOQL());         
    }

    public List<Reward__c> selectRewardsByRecordIds( Set<Id> setRewardIds ) {
        adglib_QueryFactory query = newQueryFactory();
        query.selectField('Contact__r.Name');
        query.setCondition('Id IN :setRewardIds ');
        return (List<Reward__c> )Database.query(query.toSOQL());    
    }
}
public class ModelRateMasterSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Model_Rate_Master__c.MRM_SECOMM__c,
            Model_Rate_Master__c.MRM_DEALERMARGIN__c   
		};
    }

    public Schema.SObjectType getSObjectType() {
        return Model_Rate_Master__c.sObjectType;
    }
    
    public override String getOrderBy() {
        return 'MRM_EFFDT__c DESC NULL LAST';
    }

    public List<Model_Rate_Master__c> selectModelRateMasterByModelMasterId(Id modelMasterId) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Model_Master__c =: modelMasterId');
        query.setLimit(1);
        
        return (List<Model_Rate_Master__c>) Database.query(query.toSOQL());
    }
}
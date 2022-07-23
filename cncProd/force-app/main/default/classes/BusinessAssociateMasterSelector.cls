public class BusinessAssociateMasterSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>  {   
            Business_Associate_Master__c.Id,
            Business_Associate_Master__c.Name,
            Business_Associate_Master__c.BAM_ASSOCIATECD__c,
            Business_Associate_Master__c.BAM_TYPE__c,
            Business_Associate_Master__c.BAM_ASSOCIATECD__c,
            Business_Associate_Master__c.BAM_INHOUSE__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Business_Associate_Master__c.sObjectType;
    }

    public LIST<Business_Associate_Master__c> selectByType(LIST<String> typeList){
       	adglib_QueryFactory query = newQueryFactory();
        
        query.setCondition('BAM_TYPE__c in:typeList');
        system.debug('typeList ' + query.toSOQL());
        return (List<Business_Associate_Master__c>) Database.query(query.toSOQL());
    }

}
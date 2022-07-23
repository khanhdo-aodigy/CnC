public class AdditionalChargesMasterSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Additional_Charges_Master__c.Id,
            Additional_Charges_Master__c.ADM_CHRGCD__c,
            Additional_Charges_Master__c.Name
		};
    }

    public Schema.SObjectType getSObjectType() {
        return Additional_Charges_Master__c.sObjectType;
    }

    public List<Additional_Charges_Master__c> selectBasedOnChargeCode(LIST<String> chargeCode){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('ADM_CHRGCD__c in:chargeCode');
        return (List<Additional_Charges_Master__c>) Database.query(query.toSOQL());
    }


}
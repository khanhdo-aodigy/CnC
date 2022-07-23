public class SaAddnlChargeSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            SA_Additional_Charge__c.Id,
            SA_Additional_Charge__c.Name,
            SA_Additional_Charge__c.ChargeCodeDescription__c,
            SA_Additional_Charge__c.SAD_ADDCHARGE__c,
            SA_Additional_Charge__c.SAD_CHARGES__c,
            SA_Additional_Charge__c.DisplayOrder__c,
            SA_Additional_Charge__c.SAD_PACKAGE__c,
            SA_Additional_Charge__c.AdditionalChargesMaster__c,
            SA_Additional_Charge__c.Sales_Agreement__c,
            SA_Additional_Charge__c.SAD_SOH_SONO__c,
            SA_Additional_Charge__c.SAD_ADM_CHRGCD__c,
            SA_Additional_Charge__c.SAD_ADM_CHARGTYPE__c,
            SA_Additional_Charge__c.SAD_ADM_OTHERTYPE__c,
            SA_Additional_Charge__c.SAD_REMOVE__c,
            SA_Additional_Charge__c.SAD_DISPLAY__c,
            SA_Additional_Charge__c.SAD_PRINT__c,
            SA_Additional_Charge__c.SAD_INCPRICE__c,
            SA_Additional_Charge__c.SAD_SUPINVOICE__c,
            SA_Additional_Charge__c.SAD_PACKAGE_REBATE__c,
            SA_Additional_Charge__c.SAD_REBATE__c,
            SA_Additional_Charge__c.VSMS_Compound_Primary_Key__c
		};
    }

    public Schema.SObjectType getSObjectType() {
        return SA_Additional_Charge__c.sObjectType;
    }

    public override String getOrderBy() {
    	return 'DisplayOrder__c';
    }

    public List<SA_Additional_Charge__c> selectbySalesAgreementIdAndChargeCodes(Id salesAgreementIds, LIST<String> chargeCodeList){
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Sales_Agreement__c =: salesAgreementIds AND SAD_ADM_CHRGCD__c in:chargeCodeList');
        //system.debug(query.toSOQL());

        return (List<SA_Additional_Charge__c>) Database.query(query.toSOQL());
    }
       
    
    public List<SA_Additional_Charge__c> selectAddnlChargeBySalesAgreementIds(Set<Id> salesAgreementIds){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Sales_Agreement__c in: salesAgreementIds');
        //system.debug(query.toSOQL());
        
        return (List<SA_Additional_Charge__c>) Database.query(query.toSOQL());
    }

    public List<SA_Additional_Charge__c> selectAdditionalChargeBySalesAgreementId(Id salesAgreementId){
        List<String> queryFields = new List<String> {'Sales_Agreement__r.UniqueBranchCode__c', 'Sales_Agreement__r.FranchiseCode__c', 'Sales_Agreement__r.Road_Tax_Top_Up__c'};
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Sales_Agreement__c =: salesAgreementId');
        query.selectFields(queryFields);
        
        return (List<SA_Additional_Charge__c>) Database.query(query.toSOQL());
    }
}
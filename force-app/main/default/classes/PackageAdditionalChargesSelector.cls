public class PackageAdditionalChargesSelector extends ADGLIB_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Package_Additional_Charges__c.Additional_Charges_Master__c,
            Package_Additional_Charges__c.DisplayOrder__c,
            Package_Additional_Charges__c.Id,
            Package_Additional_Charges__c.Name,
            Package_Additional_Charges__c.Package_Header__c,
            Package_Additional_Charges__c.PKC_ADDCHARGE__c,
            Package_Additional_Charges__c.PKC_ADM_CHRGCD__c,
            Package_Additional_Charges__c.PKC_ADM_CHRGDESC__c,
            Package_Additional_Charges__c.PKC_CHARGES__c,
            Package_Additional_Charges__c.PKC_DISPLAY__c,
            Package_Additional_Charges__c.PKC_INCPRICE__c,
            Package_Additional_Charges__c.PKC_PKH_FRNCD__c,
            Package_Additional_Charges__c.PKC_PKH_PKGNO__c,
            Package_Additional_Charges__c.PKC_PKH_UNIQUEBRCD__c,
            Package_Additional_Charges__c.PKC_PRINT__c,
            Package_Additional_Charges__c.PKC_REBATE__c,
            Package_Additional_Charges__c.PKC_REMOVABLE__c,
            Package_Additional_Charges__c.VSMS_Compound_Primary_Key__c
		};
    }

    public Schema.SObjectType getSObjectType() {
        return Package_Additional_Charges__c.sObjectType;
    }

    public override String getOrderBy() {
    	return 'DisplayOrder__c';
    }

    public List<Package_Additional_Charges__c> selectByPackageHeaderIds(SET<Id> packageHeaderIds){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Package_Header__c in: packageHeaderIds');
        return (List<Package_Additional_Charges__c>) Database.query(query.toSOQL());
    }
    
    //Road tax, VES Surcharge/Rebate and FEES by package header Id
    public List<Package_Additional_Charges__c> selectByPackageHeaderAndChargeCode(Id packageHeaderId, LIST<String> chargeCodeList){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('PKC_ADM_CHRGCD__c in:chargeCodeList AND Package_Header__c =:packageHeaderId');
        return (List<Package_Additional_Charges__c>) Database.query(query.toSOQL());
    }
    
    public List<Package_Additional_Charges__c> selectByPackageHeaderId(Id packageHeaderId) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Package_Header__c =: packageHeaderId');
        return (List<Package_Additional_Charges__c>) Database.query(query.toSOQL());
    }

}
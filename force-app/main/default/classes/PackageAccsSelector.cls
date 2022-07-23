public  class PackageAccsSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
            Package_Accs__c.Accessories_Master__c,
            Package_Accs__c.PKA_PKH_UNIQUEBRCD__c,
            Package_Accs__c.PKA_ACM_ACCSDESC__c,
            Package_Accs__c.PKA_DISPLAY__c,
            Package_Accs__c.PKA_PKH_FRNCD__c,
            Package_Accs__c.PKA_INCPRICE__c,
            Package_Accs__c.Name,
            Package_Accs__c.Package_Header__c,
            Package_Accs__c.PKA_PRINT__c,
            Package_Accs__c.PKA_QTY__c,
            Package_Accs__c.PKA_RATE__c,
            Package_Accs__c.PKA_REBATE__c,
            Package_Accs__c.PKA_REMOVABLE__c,
            Package_Accs__c.PKA_VALUE__c,
            Package_Accs__c.DisplayOrder__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Package_Accs__c.sObjectType;
    }

    public override String getOrderBy() {
    	return 'DisplayOrder__c';
    }

    public List<Package_Accs__c> selectByPackageHeaderIds(SET<Id> packageHeaderIds){
       	adglib_QueryFactory query = newQueryFactory();
        /* Added by TP */
        query.selectField('Accessories_Master__r.ACM_ACCSCD__c');
        /* END */
        query.setCondition('Package_Header__c in: packageHeaderIds');
        return (List<Package_Accs__c>) Database.query(query.toSOQL());
    }
    
    public List<Package_Accs__c> selectByPackageHeaderId(Id packageHeaderId){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Package_Header__c =: packageHeaderId');
        return (List<Package_Accs__c>) Database.query(query.toSOQL());
    }   
}
public inherited sharing class AccessoriesMasterSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Accessories_Master__c.Id,
            Accessories_Master__c.AccessoriesGroup__c,
            Accessories_Master__c.Name,
            Accessories_Master__c.ACM_ACCSTYPE__c,
            Accessories_Master__c.ACM_ACCSCD__c,
            Accessories_Master__c.ACM_ACCSCOST__c,
            Accessories_Master__c.ACM_ACCSDESC__c,
            Accessories_Master__c.AccsRateMaster__c,
            Accessories_Master__c.ACMCANREMOVEINEDIT__c,
            Accessories_Master__c.ACMDISSTATUS__c,
            Accessories_Master__c.ACMDLRCOMMAMT__c,
            Accessories_Master__c.ACM_BIN__c,
            Accessories_Master__c.BranchCode__c,
            Accessories_Master__c.ACM_CASHREBATE__c,
            Accessories_Master__c.ACM_CONVRATE__c,
            Accessories_Master__c.ACM_CRM_CURRENCYCD__c,
            Accessories_Master__c.ACM_DEALERTRADECOST__c,
            Accessories_Master__c.ACM_FITMENTREQD__c,
            Accessories_Master__c.ACM_FRN_FRNCD__c,
            Accessories_Master__c.ACM_STM_GSTCD__c,
            Accessories_Master__c.ACM_LASTISSUEDT__c,
            Accessories_Master__c.ACM_LEADTIME__c,
            Accessories_Master__c.ACM_MNM_MAJGROUPCD__c,
            Accessories_Master__c.ACM_MNM_MINGROUPCD__c,
            Accessories_Master__c.ACM_MDM_MODELCD__c,
            Accessories_Master__c.ACM_PARTS__c,
            Accessories_Master__c.ACM_PURPRICE__c,
            Accessories_Master__c.Rate__c,
            Accessories_Master__c.ACM_SETRADECOST__c,
            Accessories_Master__c.ACM_SHORTDESC__c,
            Accessories_Master__c.ACM_STATUS__c,
            Accessories_Master__c.ACM_TRADABLE__c,
            Accessories_Master__c.ACM_BRM_UNIQUEBRCD__c,
            Accessories_Master__c.ACM_UOM_UOMCD__c
		};
    }

    public Schema.SObjectType getSObjectType() {
        return Accessories_Master__c.sObjectType;
    }

    public override String getOrderBy() {
    	return 'ACM_ACCSDESC__c';
    }

/** Added franchiseCode due to accessories selection are returning other franchise items.
    public List<Accessories_Master__c> selectAccessoriesBasedOnGroup(LIST<String> accessoriesGroupList, String branchCode, String modelGroup, String status){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('ACM_STATUS__c=:status AND AccessoriesGroup__c in:accessoriesGroupList AND BranchCode__c =: branchCode AND ( ACM_MDM_MODELCD__c = \'\'  OR ACM_MDM_MODELCD__c =: modelGroup )');
        return Database.query(query.toSOQL());
    }
 */
    public List<Accessories_Master__c> selectAccessoriesBasedOnGroup(LIST<String> accessoriesGroupList, String branchCode, String franchiseCode, String modelGroup, String status){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('ACM_STATUS__c=:status AND AccessoriesGroup__c in:accessoriesGroupList AND  ACM_FRN_FRNCD__c=:franchiseCode AND BranchCode__c =: branchCode AND ( ACM_MDM_MODELCD__c = \'\'  OR ACM_MDM_MODELCD__c =: modelGroup )');
        return Database.query(query.toSOQL()); 
    }
    
    public List<Accessories_Master__c> selectAccsMastersWithRateMastersByIds(Set<Id> accsMasterIds) {
        ADGLIB_QueryFactory query = newQueryFactory();
        query.setCondition('Id In :accsMasterIds')
             .subselectQuery('Accs_Rate_Master__r')
             .selectFields(new Set<String>{'ARM_EFFDT__c', 'ARM_SALEPRICE__c'});
        
        return Database.query(query.toSOQL());
    }    
    
    public Accessories_Master__c selectAccsMasterById(Id accsMasterId) {
        adglib_QueryFactory query = newQueryFactory();
        query.subselectQuery('Accs_Rate_Master__r')
             .selectField('ARM_SALEPRICE__c')
             .setOrdering('ARM_EFFDT__c', ADGLIB_QueryFactory.SortOrder.DESCENDING, true)
             .setLimit(1);
        query.setCondition('id =: accsMasterId');
        
        return Database.query(query.toSOQL());
    }

    public Accessories_Master__c selectByBranchAndAccsCode(String branchCode, String accessoryCode) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('BranchCode__c =: branchCode AND ACM_ACCSCD__c =: accessoryCode');   
        query.setLimit(1);   
        List<Accessories_Master__c> aCMs = Database.query(query.toSOQL());
        if (!aCMs.isEmpty()) {
            return aCMs[0];
        }
        
        return null;
    }
    
    public Accessories_Master__c selectByVSMSCompoundPrimaryKey (String franchiseCode, String accCode, String uniqueBranchCode) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('ACM_BRM_UNIQUEBRCD__c =: uniqueBranchCode AND ACM_ACCSCD__c =: accCode AND ACM_FRN_FRNCD__c =: franchiseCode')
             .setLimit(1);
        List<Accessories_Master__c> aCMs = Database.query(query.toSOQL());
        if (!aCMs.isEmpty()) {
            return aCMs[0];
        }
        
        return null;
    }
}
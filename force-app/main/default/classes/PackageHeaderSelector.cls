//Start of RN2020Q1010 
public with sharing class PackageHeaderSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
            Package_Header__c.CreatedById,
            Package_Header__c.CreatedDate,
            Package_Header__c.DisplayOrder__c,
            Package_Header__c.Id,
            Package_Header__c.IsDeleted,
            Package_Header__c.LastActivityDate,
            Package_Header__c.LastModifiedById,
            Package_Header__c.LastModifiedDate,
            Package_Header__c.Model_Master__c,
            Package_Header__c.Name,
            Package_Header__c.OwnerId,
            Package_Header__c.PKH_ACCSCOST__c,
            Package_Header__c.PKH_ACCSGP__c,
            Package_Header__c.PKH_ACCSPKGPRICE__c,
            Package_Header__c.PKH_ADDNLPKGPRICE__c,
            Package_Header__c.PKH_ALLOWPKGPRICE__c,
            Package_Header__c.PKH_APPROVEBY__c,
            Package_Header__c.PKH_APPROVEDT__c,
            Package_Header__c.PKH_BRM_BRCD__c,
            Package_Header__c.PKH_BRM_COMPCD__c,
            Package_Header__c.PKH_BRM_LOCCD__c,
            Package_Header__c.PKH_BRM_UNIQUEBRCD__c,
            Package_Header__c.PKH_CREATEDBY__c,
            Package_Header__c.PKH_CREATEDDT__c,
            Package_Header__c.PKH_CRM_CURRENCYCD__c,
            Package_Header__c.PKH_FRN_FRNCD__c,
            Package_Header__c.PKH_FULCOPACKAGE__c,
            Package_Header__c.PKH_LASTUPDBY__c,
            Package_Header__c.PKH_LASTUPDDT__c,
            Package_Header__c.PKH_MDM_MODELCD__c,
            Package_Header__c.PKH_MODELCONVRATE__c,
            Package_Header__c.PKH_MODELCOST__c,
            Package_Header__c.PKH_MODELGP__c,
            Package_Header__c.PKH_MODELPKGPRICE__c,
            Package_Header__c.PKH_MODELPURPRICE__c,
            Package_Header__c.PKH_MYM_MODELYEAR__c,
            Package_Header__c.PKH_PKGDESC__c,
            Package_Header__c.PKH_PKGNO__c,
            Package_Header__c.PKH_PKGPRICE__c,
            Package_Header__c.PKH_STATUS__c,
            Package_Header__c.PKH_VALIDFROM__c,
            Package_Header__c.PKH_VALIDTO__c,
            Package_Header__c.SA_PKH_PKGPRICE__c,
            Package_Header__c.SystemModstamp,
            Package_Header__c.VSMS_Compound_Primary_Key__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Package_Header__c.sObjectType;
    }

    public List<Package_Header__c> selectByModelsAndStaus(SET<Id> modelIds, String status){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Model_Master__c in: modelIds');
        query.setCondition('PKH_STATUS__c =: status');
        return (List<Package_Header__c>) Database.query(query.toSOQL());
    }
    
    /* Class by TP */
     public List<Package_Header__c> selectById(SET<Id> Ids, String status){
       	adglib_QueryFactory query = newQueryFactory();
        System.debug('TEST SELECTOR 1: ' + Ids);
        query.setCondition('Id in: Ids');
        //query.setCondition('PKH_STATUS__c =: status');
        System.debug('TEST SELECTOR 2: ' + query.toSOQL());
        return (List<Package_Header__c>) Database.query(query.toSOQL());
    }
     /* END */
}
//End of RN2020Q1010
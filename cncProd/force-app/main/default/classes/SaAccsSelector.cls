public class SaAccsSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            SA_Accessory__c.Id,
            SA_Accessory__c.Name,
            SA_Accessory__c.Description__c,
            SA_Accessory__c.SAC_ACCSCOST__c,
            SA_Accessory__c.SAC_ACCSVALUE__c,
            SA_Accessory__c.SAC_PACKAGE__c,
            SA_Accessory__c.DisplayOrder__c,
            SA_Accessory__c.SAC_ACM_ACCSCD__c,
            SA_Accessory__c.Accessories_Master__c,
            SA_Accessory__c.Sales_Agreement__c,
            SA_Accessory__c.SACQTY__c,
            SA_Accessory__c.SAC_INCPRICE__c,
            SA_Accessory__c.SAC_ACCSTRADE__c,
            SA_Accessory__c.SACSETRADECOST__c,
            SA_Accessory__c.SAC_DEALERTRADECOST__c,
            SA_Accessory__c.SOH_ACCSAMT__c,   
            SA_Accessory__c.SAD_SOH_SONO__c,
            SA_Accessory__c.AccessoriesTradable__c,
            SA_Accessory__c.SAC_PRICE__c, 
            SA_Accessory__c.SAC_LINENO__c,
            SA_Accessory__c.Acc_Code_Trigger__c,  
            SA_Accessory__c.Price_Trigger__c,
            SA_Accessory__c.SAC_PACKAGE_TRADE_REBATE__c,
            SA_Accessory__c.SAC_REBATE__c,
            SA_Accessory__c.PKA_VALUE__c    
		};
    }

    public Schema.SObjectType getSObjectType() {
        return SA_Accessory__c.sObjectType;
    }

    public override String getOrderBy() {
    	return 'DisplayOrder__c';
    }

    public List<SA_Accessory__c> selectAccBySalesAgreementId(Set<Id> salesAgreementIds){
       	adglib_QueryFactory query = newQueryFactory();
        query.setCondition('SAC_PACKAGE__c = \'Y\' AND Sales_Agreement__c in: salesAgreementIds');
        //system.debug(query.toSOQL());
        
        return (List<SA_Accessory__c>) Database.query(query.toSOQL());
    }

    public List<SA_Accessory__c> selectAddonAccBySalesAgreementId(Set<Id> salesAgreementIds){
       	adglib_QueryFactory query = newQueryFactory();
        //query.setCondition('Sales_Agreement__c in: salesAgreementIds');
        query.setCondition('SAC_PACKAGE__c != \'Y\' AND Sales_Agreement__c in: salesAgreementIds');
        
        return (List<SA_Accessory__c>) Database.query(query.toSOQL());
    }
    
    public SA_Accessory__c selectAccsBySaIdandAccCode (ID saId, String accCode) {
        adglib_QueryFactory query = newQueryFactory();
        SA_Accessory__c sAAcc;
        query.setCondition('Sales_Agreement__c =: saId AND (Acc_Code_Trigger__c =: accCode OR SAC_ACM_ACCSCD__c =: accCode)');
        query.selectFields(new List<String> {'Sales_Agreement__r.UniqueBranchCode__c', 'Sales_Agreement__r.FranchiseCode__c'});

        List<SA_Accessory__c> sAAccs = Database.query(query.toSOQL());
        
        if (!sAAccs.isEmpty()) {
            sAAcc = sAAccs[0];
        }
        return sAAcc;
    }

    public List<SA_Accessory__c> selectAccessoriesBySalesAgreementId(Id salesAgreementId) {
        List<String> queryFields = new List<String> {'Sales_Agreement__r.UniqueBranchCode__c', 'Sales_Agreement__r.FranchiseCode__c'};
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Sales_Agreement__c =: salesAgreementId');
        query.selectFields(queryFields);
        return (List<SA_Accessory__c>) Database.query(query.toSOQL());
    }

    public SA_Accessory__c selectOffpeakRecord(Id salesAgreementId, Id offpeakId) {
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('Sales_Agreement__c =: salesAgreementId AND Accessories_Master__c =: offpeakId');
        query.setLimit(1);
        return Database.query(query.toSOQL());
    }
}
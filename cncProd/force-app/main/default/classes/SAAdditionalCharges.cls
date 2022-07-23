public inherited sharing class SAAdditionalCharges extends ADGLIB_SObjectDomain {
    
    public SAAdditionalCharges(List<SA_Additional_Charge__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new SAAdditionalCharges(sObjectList);
		}
	}


    public void setVSMSCompoundPrimaryKey() {
        Map<Id, Sales_Agreement__c> salesAgreementsById = getSalesAgreementsOfAdditionalCharges();
        for(SA_Additional_Charge__c additionalCharge : (List<SA_Additional_Charge__c>)Records) {
            Sales_Agreement__c parentSa = salesAgreementsById.get(additionalCharge.Sales_Agreement__c);
            additionalCharge.VSMS_Compound_Primary_Key__c = '';
            if(String.isNotBlank(parentSa.UniqueBranchCode__c)) {
                additionalCharge.VSMS_Compound_Primary_Key__c += parentSa.UniqueBranchCode__c;
            }
            if(String.isNotBlank(parentSa.FranchiseCode__c)) {
                additionalCharge.VSMS_Compound_Primary_Key__c += parentSa.FranchiseCode__c;
            }
            if(String.isNotBlank(additionalCharge.SAD_SOH_SONO__c)) {
                additionalCharge.VSMS_Compound_Primary_Key__c += additionalCharge.SAD_SOH_SONO__c;
            }
            if(String.isNotBlank(additionalCharge.SAD_ADM_CHRGCD__c)) {
                additionalCharge.VSMS_Compound_Primary_Key__c += additionalCharge.SAD_ADM_CHRGCD__c;
            }                     
        }   
        
        update Records;
    }
    
    private Map<Id, Sales_Agreement__c> getSalesAgreementsOfAdditionalCharges() {
        Set<Id> salesAgreementIds = new Set<Id>();
        for(SA_Additional_Charge__c additionalCharge : (List<SA_Additional_Charge__c>)Records) {
            salesAgreementIds.add(additionalCharge.Sales_Agreement__c);
        } 
        
        return new Map<Id, Sales_Agreement__c>(
            [Select FranchiseCode__c, UniqueBranchCode__c From Sales_Agreement__c Where Id In :salesAgreementIds]
        );        
    }
}
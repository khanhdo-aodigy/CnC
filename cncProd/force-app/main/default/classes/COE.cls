public inherited sharing class COE extends ADGLIB_SObjectDomain {
    
    public COE(List<COE__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new COE(sObjectList);
		}
	}    
    
    public override void onAfterInsert() {
        Set<String> saNumbers = new Set<String>();
        for(COE__c coe : (List<COE__c>) records) {
            saNumbers.add(coe.COH_SOH_SONO__c);
        }
        
        Map<String, Sales_Agreement__c> agreementByDocNo = new Map<String, Sales_Agreement__c>();
        for(Sales_Agreement__c agreement : [Select Id, SOH_SONO__c From Sales_Agreement__c
                                            Where SOH_SONO__c In :saNumbers])
        {
            agreementByDocNo.put(agreement.SOH_SONO__c, agreement);
        }
        
        for(COE__c coe : (List<COE__c>) records) {
            if(!agreementByDocNo.containsKey(coe.COH_SOH_SONO__c)) {
                coe.addError('No Agreement found with Doc No of ' + coe.COH_SOH_SONO__c);
            } else {
                Sales_Agreement__c agreement = agreementByDocNo.get(coe.COH_SOH_SONO__c);
                agreement.COE__c = coe.Id;
                agreement.COE_Expiry_Date__c = coe.COH_EXPMONTH__c;
            }
        }

        Database.update(agreementByDocNo.values(), false);
    }
    
    public override void onAfterUpdate(Map<Id, sObject> previousMap) {
        Map<Id, String> changedAgreementNumberByCOEId = new Map<Id, String>();
        
        for(COE__c coe : (List<COE__c>) records) {
            if(previousMap.get(coe.Id).get('COH_SOH_SONO__c') != coe.COH_SOH_SONO__c) {
                changedAgreementNumberByCOEId.put(coe.Id, coe.COH_SOH_SONO__c);
            }
        }
        
        if(changedAgreementNumberByCOEId.isEmpty()) {
            return;
        }
        
        Map<String, Sales_Agreement__c> agreementByDocNo = new Map<String, Sales_Agreement__c>();
        for(Sales_Agreement__c agreement : [Select Id, COE__c, SOH_SONO__c From Sales_Agreement__c
                                            Where SOH_SONO__c In :changedAgreementNumberByCOEId.values()])
        {
            agreementByDocNo.put(agreement.SOH_SONO__c, agreement);
        }        
        
        Map<Id, COE__c> coes = new Map<Id, COE__c>( (List<COE__c>)records );
        Set<Id> coesToDeleteIds = new Set<Id>();

        for(Id coeId : changedAgreementNumberByCOEId.keySet()) {
            COE__c coe = coes.get(coeId);
            if(!agreementByDocNo.containsKey(coe.COH_SOH_SONO__c)) {
                coesToDeleteIds.add(coe.Id);
            } else {
                Sales_Agreement__c agreement = agreementByDocNo.get(coe.COH_SOH_SONO__c);
                if(agreement.COE__c != coe.Id) {
                    agreement.COE__c = coe.Id;
                    agreement.COE_Expiry_Date__c = coe.COH_EXPMONTH__c;
                }
            }            
        }

        Database.update(agreementByDocNo.values(), false);
		delete [Select Id From COE__c Where Id In :coesToDeleteIds];
    }  
}
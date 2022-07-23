public with sharing class SAAccessories extends ADGLIB_SObjectDomain {

    public SAAccessories(List<SA_Accessory__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new SAAccessories(sObjectList);
		}
	}    
    
    public override void onBeforeInsert() {
        clearServiceCreditPackageField((List<SA_Accessory__c>)Records);   
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        List<SA_Accessory__c> changedAccessories = new List<SA_Accessory__c>();
        for(SA_Accessory__c record : (List<SA_Accessory__c>)Records) {
            SA_Accessory__c oldRecord = (SA_Accessory__c)existing.get(record.Id);
            if(record.Accessories_Master__c != oldRecord.Accessories_Master__c || record.SAC_PACKAGE__c != oldRecord.SAC_PACKAGE__c) {
                changedAccessories.add(record);
            }
        }
        clearServiceCreditPackageField(changedAccessories);
    }   
    
    private void clearServiceCreditPackageField(List<SA_Accessory__c> accessories) {
		Set<Id> accessoryMasterIds = new Set<Id>();
        for(SA_Accessory__c accessory : accessories) {
            accessoryMasterIds.add(accessory.Accessories_Master__c);
        }        
        
        Map<Id, Accessories_Master__c> accessoryMasters = new Map<Id, Accessories_Master__c>([
            Select ACM_MNM_MAJGROUPCD__c From Accessories_Master__c Where Id In :accessoryMasterIds
        ]);
        
        for(SA_Accessory__c accessory : (List<SA_Accessory__c>)Records) {
            if(String.isBlank(accessory.Accessories_Master__c)) {
               continue;
            }
            
            String masterMajorGroup = accessoryMasters.get(accessory.Accessories_Master__c).ACM_MNM_MAJGROUPCD__c;
            if(masterMajorGroup == 'SVC_CREDIT' || masterMajorGroup == 'SVC CREDIT') {
                accessory.SAC_PACKAGE__c = null;
            }       
        }
    }
}
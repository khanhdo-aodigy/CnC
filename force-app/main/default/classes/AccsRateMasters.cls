public inherited sharing class AccsRateMasters extends ADGLIB_SObjectDomain {
    public AccsRateMasters(List<Accs_Rate_Master__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new AccsRateMasters(sObjectList);
		}
	}
	
    public override void onAfterInsert() {
		recalculateAccessoriesMasterRate(null);    
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
		recalculateAccessoriesMasterRate((Map<Id, Accs_Rate_Master__c>)existingRecords);   
    }

    public override void onAfterDelete() {
		recalculateAccessoriesMasterRate(null);       
    }    
    
    private void recalculateAccessoriesMasterRate(Map<Id, Accs_Rate_Master__c> existingRecords) {
        Set<Id> accMasterIds = new Set<Id>();
        for(Accs_Rate_Master__c armMaster : (List<Accs_Rate_Master__c>)Records) {
            if(existingRecords != null) {
                Accs_Rate_Master__c oldArmMaster = (Accs_Rate_Master__c)existingRecords.get(armMaster.Id);
                if(armMaster.ARM_EFFDT__c != oldArmMaster.ARM_EFFDT__c || 
                   armMaster.ARM_SALEPRICE__c != oldArmMaster.ARM_SALEPRICE__c ||
                   armMaster.Accessories__c != oldArmMaster.Accessories__c)
                {
                    accMasterIds.add(armMaster.Accessories__c);
                }                
            } else {
                accMasterIds.add(armMaster.Accessories__c);
            }
        }        
        
		AccessoriesMasters accessoriesMasters = new AccessoriesMasters(
            new AccessoriesMasterSelector().selectAccsMastersWithRateMastersByIds(accMasterIds)
        );  
        accessoriesMasters.updateRate(); 
    }
}
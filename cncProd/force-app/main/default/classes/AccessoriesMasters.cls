public inherited sharing class AccessoriesMasters extends ADGLIB_SObjectDomain {
    public AccessoriesMasters(List<Accessories_Master__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new AccessoriesMasters(sObjectList);
		}
	}

    public void updateRate() {
        for(Accessories_Master__c accsMaster : (List<Accessories_Master__c>)Records) {
            Date latestEffectiveDate;
            Decimal latestRate;
            for(Accs_Rate_Master__c armMaster : accsMaster.Accs_Rate_Master__r) {
                if(latestEffectiveDate == null || armMaster.ARM_EFFDT__c > latestEffectiveDate) {
                    latestEffectiveDate = armMaster.ARM_EFFDT__c;
                    latestRate = armMaster.ARM_SALEPRICE__c;
                }
            }
            accsMaster.Rate__c = latestRate;
		}
        
        update Records;
    }	    
}
//Start of RN2020Q1010 
public with sharing class PackageHeader extends ADGLIB_SObjectDomain{
    public PackageHeader(LISt<Package_Header__c> sObjectList) {
        super(sObjectList);
    }
    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new PackageHeader(sObjectList);
		}
	}

    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        Set<Id> packageIds = new Set<Id>();
        for(Package_Header__c rec : (LIST<Package_Header__c>)Records){
            if(rec.PKH_PKGPRICE__c <> ((Package_Header__c)existingRecords.get(rec.Id)).PKH_PKGPRICE__c){
                packageIds.add(rec.Id);
            }
        }

        if(packageIds.size() > 0){
            SalesAgreementService.processSalesAgreementForPriceChange(packageIds);
        }
    }

}
//End of RN2020Q1010
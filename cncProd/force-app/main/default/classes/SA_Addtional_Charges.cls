/**
 * @File Name          : SA_Addtional_Charges.cls
 * @Description        : 
 * @Author             : jmt@aodigy.com
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 12/11/2019, 10:44:39 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/11/2019   jmt@aodigy.com    Initial Version
**/
public class SA_Addtional_Charges extends ADGLIB_SObjectDomain  {

    public SA_Addtional_Charges(List<SA_Additional_Charge__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new SA_Addtional_Charges(sObjectList);
		}
	}
    
    public override void onBeforeInsert(){
        List<SA_Additional_Charge__c> charges = new List<SA_Additional_Charge__c>();
        for(SA_Additional_Charge__c record : (List<SA_Additional_Charge__c>)Records) {
            if(String.isNotBlank(record.SAD_SOH_SONO__c)) {
                charges.add(record);
            }
        }
        
        // if(!charges.isEmpty()) {
        //     new SAAdditionalCharges(charges).setVSMSCompoundPrimaryKeyBeforeTrigger();
        // }
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        
        
        SET<Id> salesAgreementIds = new set<id> (); 
        for(SA_Additional_Charge__c record : (List<SA_Additional_Charge__c>) records){
            if(((SA_Additional_Charge__c) existingRecords.get(record.Id)).SAD_CHARGES__c <> record.SAD_CHARGES__c){
                salesAgreementIds.add(record.Sales_Agreement__c); 
            } 
        }
        
        if(salesAgreementIds.size() > 0){
            system.debug('Update Sales Agreement');
            SalesAgreements.updateSalesAgreementTotalFees(salesAgreementIds);
        }
    }
}
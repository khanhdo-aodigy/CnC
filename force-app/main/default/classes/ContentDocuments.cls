public inherited sharing class ContentDocuments extends ADGLIB_SObjectDomain {
    public ContentDocuments(List<ContentDocument> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new ContentDocuments(sObjectList);
		}
	}
    
    public override void onBeforeDelete() {
		blockUnauthorizedDelete();        
    }
    
    public void blockUnauthorizedDelete() {
        if(userProfileIsAuthorizedToDeleteFiles()) {
            return;
        }

        Set<Id> contentDocIds = new Set<Id>();
        for(ContentDocument cd : (List<ContentDocument>)Records) {
            contentDocIds.add(cd.Id);
		}

        Map<Id, Id> salesAgreementIdByContentDocId = new Map<Id, Id>();
        for(ContentDocumentLink cdl : [Select ContentDocumentId, LinkedEntityId From ContentDocumentLink
                                       Where ContentDocumentId In :contentDocIds])
        {
            if(cdl.LinkedEntityId.getSObjectType() == Sales_Agreement__c.sObjectType) {
                salesAgreementIdByContentDocId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }                                           
		}
        
        Map<Id, Sales_Agreement__c> salesAgreementById = new Map<Id, Sales_Agreement__c>([
            Select Stage__c, Unsigned_DSA_Id__c From Sales_Agreement__c
            Where Id In :salesAgreementIdByContentDocId.values()
        ]); // Stores parent Sales Agreements of ContentDocuments in Trigger, if indeed any of them are children of Sales Agreement record(s)
        
        blockDeleteOfDocumentsNotMarkedForPurging(salesAgreementIdByContentDocId, salesAgreementById);
    }
    
    private Boolean userProfileIsAuthorizedToDeleteFiles() {
        Map<Id, Profile> authorizedProfiles = new Map<Id, Profile>([
            Select Id From Profile Where Name Not In ('BSD', 'SDP_Sales')
        ]);
        
        if(authorizedProfiles.keySet().contains(UserInfo.getProfileId())) {
            return true;
        } else {
            return false;
        }
    }    
    
    private void blockDeleteOfDocumentsNotMarkedForPurging(Map<Id, Id> salesAgreementIdByContentDocId,
                                                           Map<Id, Sales_Agreement__c> salesAgreementById)
    {
        Set<String> permittedDocumentsToDelete = new Set<String>{
            'Approval Advice', 'COE Buy Back', 'Driving License (back)', 'Driving License (back)', 'Release Letter'
		};
		for(ContentDocument cd : (List<ContentDocument>)Records) {
            if(salesAgreementIdByContentDocId.containsKey(cd.Id)) {
                Sales_Agreement__c salesAgreement = salesAgreementById.get(
                    salesAgreementIdByContentDocId.get(cd.Id)
                );

                if( cd.Id == salesAgreement.Unsigned_DSA_Id__c ||
                   (permittedDocumentsToDelete.contains(cd.Description) && salesAgreement.Stage__c == 'Car Collection') )
                {
                    continue;
                } else {
                    cd.addError('You are not authorized to delete this file. Please upload a new version instead.');
                }
            } else {
                cd.addError('You are not authorized to delete this file. Please upload a new version instead.');
            }
        }        
    }
}
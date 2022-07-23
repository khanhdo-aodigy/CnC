public inherited sharing class ContentVersions extends ADGLIB_SObjectDomain {
    
    public ContentVersions(List<ContentVersion> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new ContentVersions(sObjectList);
		}
	}
    
    public override void onAfterInsert() {
		shareDocsWithAllUsers();        
    }
    
    public void shareDocsWithAllUsers() {
        List<ContentVersion> newCvs = (List<ContentVersion>)Records;
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentVersion newCv : newCvs) {
            contentDocumentIds.add(newCv.ContentDocumentId);
        }
        
        insertNewContentDocLinks(contentDocumentIds);
    }
    
    private void insertNewContentDocLinks(Set<Id> contentDocumentIds) {
        Id orgId = UserInfo.getOrganizationId();
        List<ContentDocumentLink> existingCdls = [Select Id, ContentDocumentId From ContentDocumentLink
                                                  Where ContentDocumentId In :contentDocumentIds
                                                  And LinkedEntityId = :orgId
                                                  And ShareType = 'C'
                                                  And Visibility = 'AllUsers'];

        insert constructNewCdls(existingCdls, orgId);
    }
    
    private List<ContentDocumentLink> constructNewCdls(List<ContentDocumentLink> existingCdls, Id orgId) {
        List<ContentDocumentLink> newCdls = new List<ContentDocumentLink>();
        for(ContentVersion cv : (List<ContentVersion>)Records) {
            Boolean cdlExists = false;
            for(ContentDocumentLink existingCdl : existingCdls) {
                if(cv.ContentDocumentId == existingCdl.ContentDocumentId) {
                    cdlExists = true;
                    break;
                }
            }
            if(!cdlExists) {
                newCdls.add(new ContentDocumentLink(
                    ContentDocumentId = cv.ContentDocumentId, 
                    LinkedEntityId = orgId, 
                    ShareType = 'C', 
                    Visibility = 'AllUsers'                        	
                ));                
            }
        }
        
        return newCdls;        
    }
}
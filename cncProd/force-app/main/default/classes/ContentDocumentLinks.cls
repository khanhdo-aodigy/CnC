/** ******
 * Description: Domain class for ContentDocumentLink object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210312           TP@aodigy.com     Created Initial Version. 
** ******/


public class ContentDocumentLinks extends ADGLIB_SObjectDomain 
{
    public ContentDocumentLinks(List<ContentDocumentLink> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new ContentDocumentLinks(sObjectList);
		}
	}

    public override void onAfterInsert() 
    {
        createCDLForNewChildCase(null);
    }

    private void createCDLForNewChildCase(Map<Id, SObject> existingRecords)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {ContentDocumentLink.SObjectType});
        String parentEMId;
        Set<Id> parentEMIdSet = new Set<Id>();       
        Map<Id, ContentDocumentLink> CDLMap = New Map<Id, ContentDocumentLink>();

        for (ContentDocumentLink cdl : (List<ContentDocumentLink>)Records) 
        {
            parentEMId = cdl.LinkedEntityId;
            if (parentEMId.left(3) == '02s') 
            {
                parentEMIdSet.add(cdl.LinkedEntityId);
                CDLMap.put(cdl.LinkedEntityId, CDL);
            }
        }

        if(!parentEMIdSet.isEmpty())
        {
            Map<Id, EmailMessage> parentEMMap = new Map<Id, EmailMessage>([SELECT Id FROM EmailMessage WHERE Id IN :parentEMIdSet AND Incoming = TRUE]);

            List<EmailMessage> dupEMList = [SELECT ID, Parent_Email_Message_ID__c, ParentId 
                                            FROM EmailMessage 
                                            WHERE Parent_Email_Message_ID__c IN :parentEMMap.keySet() 
                                            AND RelatedTo.Type = 'Case' AND Is_it_dup_email__c = TRUE];

            if (dupEMList.size() > 0 && dupEMList <> null)
            {
                for(EmailMessage EM : dupEMList)
                {
                    ContentDocumentLink cdl    = CDLMap.get(EM.Parent_Email_Message_ID__c);
                    ContentDocumentLink newCDL = new ContentDocumentLink();
                    newCDL.LinkedEntityId      = EM.ParentId;
                    newCDL.ContentDocumentId   = cdl.ContentDocumentId;
                    newCDL.ShareType           = 'V';
                    newCDL.Visibility          = 'InternalUsers';
                    uow.registerNew(newCDL);
                }

                uow.commitWork();
            }  
        }
    }
}
public class ContentVersionSelector extends adglib_SObjectSelector {
    
    
    public Schema.SObjectType getSObjectType() {
        return ContentVersion.SObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            ContentVersion.Id,
            ContentVersion.Title,
            ContentVersion.ContentDocumentId,
            ContentVersion.Description
        };
    }

   public LIST<ContentVersion> selectById(Id recordId){
        return (List<ContentVersion>) selectSObjectsById(new Set<Id> {recordId});
    }
    
    public LIST<ContentVersion> getFilesByParentId(Id parentId){
        SET<Id>  conversionIDs = new set<id>();
        ContentDocumentLinkSelector contentLinkSelector = new ContentDocumentLinkSelector();
        List<ContentDocumentLink> contentDocumentLinkList = contentLinkSelector.selectByEntityID(new SET<ID>{parentId});
        
        for(ContentDocumentLink row: contentDocumentLinkList){
            conversionIDs.add(row.ContentDocumentId);
        }
        
        adglib_QueryFactory query = newQueryFactory();
        query.setCondition('ContentDocumentId IN :conversionIDs');
        return (List<ContentVersion>) Database.query( query.toSOQL() );

    }


    public class ContentDocumentLinkSelector extends adglib_SObjectSelector {
            public Schema.SObjectType getSObjectType(){
                return ContentDocumentLink.SObjectType;
            }
            public  List<Schema.SObjectField> getSObjectFieldList(){
                return new List<Schema.SObjectField> {
                    ContentDocumentLink.Id,
                    ContentDocumentLink.ContentDocumentId,
                    ContentDocumentLink.LinkedEntityId
                };
            }

            public LiST<ContentDocumentLink> selectByEntityID(Set<ID> idSet){
                adglib_QueryFactory query = newQueryFactory();
                query.setCondition('LinkedEntityId IN :idSet');
                return (List<ContentDocumentLink>) Database.query( query.toSOQL() );
            }

    }
}
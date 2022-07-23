public inherited sharing class AttachmentService {

    public static Map<String, List<ContentDocument>> getMappedFilesByDescription(Id parentId) {
        Map<Id, Id> parentIdByContentDocId = getParentIdByContentDocId(new Set<Id>{parentId});
        Map<String, List<ContentDocument>> contentDocsByDescription = new Map<String, List<ContentDocument>>();
        for(ContentDocument doc : [Select Description, Owner.Name, Title From ContentDocument Where Id In :parentIdByContentDocId.keySet()]) {
            if(contentDocsByDescription.containsKey(doc.Description)) {
                contentDocsByDescription.get(doc.Description).add(doc);
            } else {
                contentDocsByDescription.put(doc.Description, new List<ContentDocument>{doc});
            }
        }
        return contentDocsByDescription;
    }
    
    public static void deleteFilesByDescription(Map<Id, String> descriptionByParentId) {
        Map<Id, Id> parentIdByContentDocId = getParentIdByContentDocId(descriptionByParentId.keySet());
        system.debug('parentIdByContentDocId:: ' + parentIdByContentDocId);
        delete getFilesWithMatchingDescription(parentIdByContentDocId, descriptionByParentId);
    }

    /**
     -- Added by: Mai Phap
     -- delete files attach to specific parentID with target description list
     -- create logger data pool record when delete failed
     */
    public static void deleteFiles(list<ID> parentIDs, list<string> targetDescriptions) {
        map<string, object> batchContext = new map<string, object>();
        batchContext.put('parentID', parentIDs);
        batchContext.put('targetDescriptions', targetDescriptions);

        // get all CD attached to parent records
        list<ContentDocumentLink> docLinks = [SELECT ID, ContentDocumentID FROM ContentDocumentLink WHERE LinkedEntityId IN :parentIDs];
        list<ID> cdIDs = new list<ID>();
        for (ContentDocumentLink cdl : docLinks) cdIDs.add(cdl.ContentDocumentID);
        batchContext.put('Content Document ID', cdIDs);

        // check description of CDs, compare with target description and add to deleteDoc if matched
        list<ContentDocument> deleteDocs = new list<ContentDocument>();
        list<ID> deleteDocIDs = new list<ID>();
        for (ContentDocument doc : [SELECT ID, Description, Title FROM ContentDocument WHERE ID IN :cdIDS]) {
            string description = doc.Description == null? '' : doc.Description;
            for (string targetDescription : targetDescriptions) {
                if (string.isNotBlank(description) && description.startsWith(targetDescription)) {
                    deleteDocs.add(doc);
                    deleteDocIDs.add(doc.ID);
                    break;
                }

                // [TODO] check with Tom is it code block necessary
                // if (string.isBlank(description) && description == '') {
                //     deleteDocs.add(doc);
                //     deleteDocIDs.add(doc.ID);
                //     break;
                // }
            }
        }
        batchContext.put('Delete Document ID', deleteDocIDs);
        system.debug(JSON.serialize(batchContext));

        list<Logger_Data_Pool__c> loggerPool = new list<Logger_Data_Pool__c>();
        if (deleteDocs.size() > 0) {
            list<Database.DeleteResult> saveResults = Database.delete(deleteDocs, false);
            for (Database.DeleteResult sr : saveResults) if(!sr.isSuccess()) loggerPool.add(logDatabaseError(sr.getErrors(), 'Files Purging', batchContext));
        } else loggerPool.add(logDatabaseError(null, 'Files Purging NAP', batchContext));

        if (loggerPool.size() > 0) insert loggerPool;
    }
    
    private static Map<Id, Id> getParentIdByContentDocId(Set<Id> parentIds) {
        Map<Id, Id> parentIdByContentDocId = new Map<Id, Id>();
        for(ContentDocumentLink cdl : [Select ContentDocumentId, LinkedEntityId From ContentDocumentLink
                                       Where LinkedEntityId In :parentIds])
        {
            parentIdByContentDocId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);      
        }   
		return parentIdByContentDocId;        
    }
    
    private static List<ContentDocument> getFilesWithMatchingDescription(Map<Id, Id> parentIdByContentDocId, Map<Id, String> descriptionByParentId) {
		List<ContentDocument> contentDocumentsMatchingDescription = new List<ContentDocument>();
        for(ContentDocument doc : [Select Id, Description, Title From ContentDocument
                                   Where Id In :parentIdByContentDocId.keySet()])
        {
			Id parentId = parentIdByContentDocId.get(doc.Id);
            String description = descriptionByParentId.get(parentId);
            
            // Default null to blank in order to avoid null argument error when using String startsWith method below
            if(description == null) {description = '';}
            
            if(String.isNotBlank(doc.Description) && doc.Description.startsWith(description)) {
                contentDocumentsMatchingDescription.add(doc);
            } else if(String.isBlank(doc.Description) && description == '') {
                contentDocumentsMatchingDescription.add(doc);
            }
        }        
        return contentDocumentsMatchingDescription;
    }

    @testVisible
    private static Logger_Data_Pool__c logDatabaseError(list<Database.Error> errors, string serviceName, map<string, object> batchContext) {
        Logger_Data_Pool__c log = new Logger_Data_Pool__c();
        log.Name = 'Files Purging log at ' + DateTime.now().format('dd/MM/yyyy HH:mm');
        log.Instance__c = 'AttachmentService';
        log.Type__c = serviceName;
        log.Message__c = '--- Error Messages ---\n';
        log.Stack_Trace__c = '--- Error Fields ---\n';
        log.Cause__c = '--- Error Status Code ----\n';

        if (errors != null) {
            for (Database.Error error : errors) {
                log.Message__c += error.getMessage() + '\n';
                log.Stack_Trace__c += error.getFields().toString() + '\n';
                log.Cause__c += error.getStatusCode() +'\n';
            }
        }

        for (string ctxLabel : batchContext.keySet()) {
            log.Cause__c += '--- ' + ctxLabel + ' ---' + '\n';
            log.Cause__c += JSON.serialize(batchContext.get(ctxLabel)) + '\n';
        }

        log.Name = log.Name.left(80);
        log.Message__c = log.Message__c.left(100000);
        log.Stack_Trace__c = log.Stack_Trace__c.left(100000);
        log.Cause__c = log.Cause__c.left(100000);
        return log;
    }
}
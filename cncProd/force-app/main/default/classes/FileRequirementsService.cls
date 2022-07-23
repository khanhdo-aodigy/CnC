public inherited sharing class FileRequirementsService {
    
    @TestVisible private static List<File_Requirements__mdt> mockFileRequirements = new List<File_Requirements__mdt>();
    
    public static List<FilesPerRequirement> getFilesPerRequirements(Id recordId, FileSelectionCriteria criteria) {
        Map<Id, Id> parentIdByContentDocId = new Map<Id, Id>();
        Map<Id, String> descriptionByParentId = new Map<Id, String>();

        Map<String, List<ContentDocument>> filesByDescription = AttachmentService.getMappedFilesByDescription(recordId);

        List<FilesPerRequirement> filesPerRequirements = new List<FilesPerRequirement>();
        
        List<File_Requirements__mdt> fileRequirements = new List<File_Requirements__mdt>();
        switch on criteria {
            when ALL {
                fileRequirements = getAllFileRequirements(recordId);
            } 
            when CONDITIONAL {
                fileRequirements = getConditionalFileRequirements(recordId);
            }
        }
        
        for(File_Requirements__mdt fileReq : fileRequirements) {
            FilesPerRequirement filesPerReq = new FilesPerRequirement(
                fileReq,
                filesByDescription.get(fileReq.Document_Name__c)
            );
            filesPerRequirements.add(filesPerReq);
        }

        return filesPerRequirements;        
    }
    
    private static List<File_Requirements__mdt> getAllFileRequirements(Id recordId) {
        String objApiName = recordId.getSObjectType().getDescribe().getName();
        List<File_Requirements__mdt> dedupedFileRequirements = new List<File_Requirements__mdt>();
        Set<String> uniqueFileNames = new Set<String>();
        for(File_Requirements__mdt fileMdt : [Select Allowed_Types__c, Associated_Checkbox_Field_API_Name__c, 
                                              Condition_Field_API_Name__c, DeveloperName, Display_Order__c,
                                              Document_Name__c, Document_Name_for_Small_Screens__c, 
                                              Max_Files__c, Naming_Convention__c, Section__c
                                              From File_Requirements__mdt Where Object_API_Name__c = :objApiName
                                              Order By Display_Order__c Asc])
        {
            if(!uniqueFileNames.contains(fileMdt.Document_Name__c)) {
                dedupedFileRequirements.add(fileMdt);
            }
            uniqueFileNames.add(fileMdt.Document_Name__c);
        }

        return dedupedFileRequirements;
    }
    
    @TestVisible private static List<File_Requirements__mdt> getConditionalFileRequirements(Id recordId) {
        Map<Id, String> conditionFieldNameByFileReqId = new Map<Id, String>();
        Map<String, Boolean> valueByConditionFieldName = new Map<String, Boolean>();
        String objApiName = recordId.getSObjectType().getDescribe().getName();
        List<File_Requirements__mdt> fileReqs = Test.isRunningTest() && !mockFileRequirements.isEmpty() ?
                								mockFileRequirements :
                                                [Select Allowed_Types__c, Associated_Checkbox_Field_API_Name__c, 
                                                 Condition_Field_API_Name__c, DeveloperName, Display_Order__c,
                                                 Document_Name__c, Document_Name_for_Small_Screens__c, 
                                                 Max_Files__c, Naming_Convention__c
                                                 From File_Requirements__mdt Where Object_API_Name__c = :objApiName
                                                 Order By Display_Order__c Asc];
        for(File_Requirements__mdt fileReq : fileReqs) {
			conditionFieldNameByFileReqId.put(fileReq.Id, fileReq.Condition_Field_API_Name__c);
        } 
        
        String query = 'Select ';
        for(String fieldName : conditionFieldNameByFileReqId.values()) {
            if(String.isNotBlank(fieldName) && !query.contains(fieldName)) {
                query += fieldName;
                query += ',';
            }
        }
        
        if(query != 'Select ') {
            query = query.removeEnd(',');
            query += ' From ';
            query += objApiName;
            query += ' Where Id = :recordId';
            List<SObject> records = Database.query(query);
            
            for(String fieldName : conditionFieldNameByFileReqId.values()) {
                if(String.isNotBlank(fieldName)) {
                    valueByConditionFieldName.put(fieldName, Boolean.valueOf(records[0].get(fieldName)));
                }
            }
            
            for(Integer i = fileReqs.size() - 1; i >= 0 ; i--) {
                if(valueByConditionFieldName.containsKey(fileReqs[i].Condition_Field_API_Name__c) &&
                   valueByConditionFieldName.get(fileReqs[i].Condition_Field_API_Name__c) == false)
                {
                    fileReqs.remove(i);                 
                }
            }             
        }      
        
        return fileReqs;                                     
    }     
    
    public static void renameAndTagFile(Id fileId, Id parentId, File_Requirements__mdt fileReq) {
        renameAndTagFiles(
        	new Map<Id, FileDefinitionDetails>{fileId => new FileDefinitionDetails(parentId, fileReq)}
        );
    }
    
    public static void renameAndTagFiles(Map<Id, FileDefinitionDetails> fileDefinitionByFileId) {
        Pattern mergeField = Pattern.compile('\\{!(.*?)\\}');
        List<ContentDocument> filesToUpdate = new List<ContentDocument>();
        
        for(Id fileId : fileDefinitionByFileId.keySet()) {
            FileDefinitionDetails fileDefinition = fileDefinitionByFileId.get(fileId);
            
            Map<String, String> fldNameByMergeFieldExpression = new Map<String, String>();
            Matcher matcher = mergeField.matcher(fileDefinition.fileReq.Naming_Convention__c);
            while(matcher.find()) {
                fldNameByMergeFieldExpression.put(matcher.group(), matcher.group().substring(2, matcher.group().length() - 1));
            }
            
            ContentDocument file = new ContentDocument(
                Id = fileId,
                Description = fileDefinition.fileReq.Document_Name__c
            );
            setFileTitle(file, fldNameByMergeFieldExpression, fileDefinition);
            filesToUpdate.add(file);
        }
        
        update filesToUpdate;
    }
     
    private static void setFileTitle(ContentDocument file, Map<String, String> fldNameByMergeFieldExpression, FileDefinitionDetails fileDefinition) {
        if(!fldNameByMergeFieldExpression.isEmpty()) {
            Id parentId = fileDefinition.parentId;
            String objApiName = parentId.getSObjectType().getDescribe().getName();
                    
            String query = 'Select ';
            for(String fldName : fldNameByMergeFieldExpression.values()) {
                query += fldName;
                query += ', ';
            }    
            query = query.removeEnd(', ');
            query += ' From ';
            query += objApiName;
            query += ' Where Id = :parentId';
            SObject record = Database.query(query);
                    
            String fileTitle = fileDefinition.fileReq.Naming_Convention__c;
            for(String mergeFieldExpression : fldNameByMergeFieldExpression.keySet()) {
                String fldName = fldNameByMergeFieldExpression.get(mergeFieldExpression);
                if(record.get(fldName) != null) {
                    fileTitle = fileTitle.replace(mergeFieldExpression, String.valueOf(record.get(fldName)));
                } else {
                    fileTitle = fileTitle.replace(mergeFieldExpression, '');
                }
            }
            file.Title = fileTitle;
        } else {
            file.Title = fileDefinition.fileReq.Naming_Convention__c;
        }      
    }
    
    public class FileDefinitionDetails {
        Id parentId {get; private set;}
        File_Requirements__mdt fileReq {get; private set;}
        
        FileDefinitionDetails(Id parentId, File_Requirements__mdt fileReq) {
            this.parentId = parentId;
            this.fileReq = fileReq;
        }
    }

    public class FilesPerRequirement {
        @AuraEnabled File_Requirements__mdt fileReq {get; private set;}
        @AuraEnabled List<ContentDocument> files {get; private set;}
        
        FilesPerRequirement(File_Requirements__mdt fileReq, List<ContentDocument> files) {
            this.fileReq = fileReq;
            this.files = files;
        }
    }  
    
    public enum FileSelectionCriteria {ALL, CONDITIONAL}    

}
public with sharing class FileUploadServiceImpl {

    @AuraEnabled
    public static ContentVersion saveFileToRecord(String recordId, String fileName, String baseData, String prefix) {

        baseData = EncodingUtil.urlDecode(baseData, 'UTF-8');

        ContentVersion cv = new ContentVersion();
    
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.description = prefix;
        cv.FirstPublishLocationId = recordId;
        cv.VersionData = EncodingUtil.base64Decode(baseData);
        cv.IsMajorVersion = true;

        insert cv;

        return cv;
    }

     @AuraEnabled
    public static ContentVersion saveFileToRecordCompressedFile(String recordId, String fileName, String baseData, String prefix) {

        baseData = EncodingUtil.urlDecode(baseData, 'UTF-8');

        ContentVersion cv = new ContentVersion();
    
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.description = prefix;
        cv.FirstPublishLocationId = recordId;
        cv.VersionData = EncodingUtil.base64Decode(baseData);
        cv.IsMajorVersion = true;

        insert cv;

        return cv;
    }

    @AuraEnabled
    public static boolean removeFileFromRecord(String fileRecordId) {
        ContentVersion delRecord = getFileById(fileRecordId);
        if(delRecord == null){
            throw new AuraHandledException('No file found for deletion');
        }

        try {  
            
             delete [Select Id From ContentDocument Where Id = :delRecord.ContentDocumentId];
        }
        catch (DmlException e){
                throw new AuraHandledException('Deletion failed. ' + e.getMessage());
        }


        return true;
    }


     @AuraEnabled(cacheable=true)
    public static ContentVersion getFileById(Id recordId) {
        ContentVersionSelector fileSelector = new ContentVersionSelector();
        return fileSelector.selectById(recordId) [0]; //This is always 1 as it select based on Id
    }

    @AuraEnabled(cacheable=true)
    public static LIST<ContentVersion> getrelatedFileByParentId(Id recordId) {
        ContentVersionSelector fileSelector = new ContentVersionSelector();
        return fileSelector.getFilesByParentId(recordId); //This is always 1 as it select based on Id
    }


    @AuraEnabled(cacheable=true)
    public static ContentVersion getFileBySalesAgreementAndType(Id salesAgreementId, String fileType) {

        String searchParam = '%' + fileType.replace('{RecordName}', '') +'%';
        system.debug('salesAgreementId: ' + salesAgreementId + 'fileType: ' + searchParam);

       LIST<ContentDocumentLink> filesResult = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId, Visibility, 
                                                        IsDeleted, ShareType, ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId = : salesAgreementId
                                                AND ContentDocument.Title like : searchParam
                                                ORDER BY ContentDocument.createdDate DESC NULLS LAST];

        if(filesResult.isEmpty()){
            throw new AuraHandledException('There are no files associated to the record');
        }

        //return fileSelector.selectById(recordId) [0]; //This is always 1 as it select based on Id
        return getFileById(filesResult[0].ContentDocument.LatestPublishedVersionId);
    }


}
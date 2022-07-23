public without sharing class FileRequirementUploadController {
    
    @AuraEnabled
    // public static FilesRequirementDetails getAllFilesRequirementDetails(Id recordId) {
    public static String getAllFilesRequirementDetails(Id recordId) {
        List<FileRequirementsService.FilesPerRequirement> filesPerRequirements = FileRequirementsService.getFilesPerRequirements(
            recordId, FileRequirementsService.FileSelectionCriteria.ALL
        );

        // work around for sandbox, dont deploy this
        FilesRequirementDetails result = new FilesRequirementDetails(filesPerRequirements);
        return JSON.serialize(result);

        // original
        // system.debug(filesPerRequirements);
        // return new FilesRequirementDetails(filesPerRequirements);
    }
    
    @AuraEnabled
    public static List<FileRequirementsService.FilesPerRequirement> getAllFilesPerRequirements(Id recordId) {
        return FileRequirementsService.getFilesPerRequirements(recordId, FileRequirementsService.FileSelectionCriteria.ALL);
    }

    @AuraEnabled
    // public static FilesRequirementDetails getConditionalFilesRequirementDetails(Id recordId) {
    public static String getConditionalFilesRequirementDetails(Id recordId) {
        List<FileRequirementsService.FilesPerRequirement> filesPerRequirements = FileRequirementsService.getFilesPerRequirements(
            recordId, FileRequirementsService.FileSelectionCriteria.CONDITIONAL
        );

        // work around for sandbox, dont deploy this
        FilesRequirementDetails result = new FilesRequirementDetails(filesPerRequirements);
        return JSON.serialize(result);

        // original
        // system.debug(filesPerRequirements);
        // return new FilesRequirementDetails(filesPerRequirements);
    }    
    
    @AuraEnabled
    public static List<FileRequirementsService.FilesPerRequirement> getConditionalFilesPerRequirements(Id recordId) {
        return FileRequirementsService.getFilesPerRequirements(recordId, FileRequirementsService.FileSelectionCriteria.CONDITIONAL);
    }
    
    // work around for sandbox, dont deploy this changed method
    @AuraEnabled
    public static void renameAndTagFile(Id fileId, Id parentId, Map<String, Object> fileReq) {
    // public static void renameAndTagFile(Id fileId, Id parentId, File_Requirements__mdt fileReq) {
        System.debug('RENAMING');
        System.debug(fileReq);
        File_Requirements__mdt fileReqMdt = new File_Requirements__mdt(
            Document_Name__c = (String)fileReq.get('Document_Name__c'),
        	Naming_Convention__c = (String)fileReq.get('Naming_Convention__c')
        );
        FileRequirementsService.renameAndTagFile(fileId, parentId, fileReqMdt);
        // FileRequirementsService.renameAndTagFile(fileId, parentId, fileReq);
    }
    
    @AuraEnabled    
    public static ContentDocument getFileAfterUpload(Id fileId) {
        return [Select Id, LatestPublishedVersionId, Owner.Name, Title From ContentDocument Where Id = :fileId];
    } 
    
    @AuraEnabled    
    public static void deleteFile(Id fileId) {
        delete [Select Id From ContentDocument Where Id = :fileId];
    }     

    public class FilesRequirementDetails {
        @AuraEnabled final Boolean userIsSysAdmin {get; private set;}
        @AuraEnabled List<FileRequirementsService.FilesPerRequirement> filesPerRequirements {get; private set;}
        
        FilesRequirementDetails(List<FileRequirementsService.FilesPerRequirement> filesPerRequirements) {
            this.userIsSysAdmin = [Select Name From Profile Where Id = :UserInfo.getProfileId()].Name == 'System Administrator';
            this.filesPerRequirements = filesPerRequirements;
        }
    }

    /**
     * Logger Data Pool
     */
    @AuraEnabled
    public static void log(Map<String, String> details) {
        try {
            Id recordId       = Id.valueOf(details.get('recordId'));
            String objApiName = recordId.getSObjectType().getDescribe().getName();

            if (objApiName != 'MB_Sales_Agreement__c') return;

            Logger_Data_Pool__c log = new Logger_Data_Pool__c();
            log.Instance__c = 'File_Requirement';
            log.Message__c = JSON.serialize(details);
            insert log;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'kauthamts@aodigy.com', 'thieudang.vu@aodigy.com'});
            mail.saveAsActivity = false;
            mail.setSubject('File Requirement Log ' + Datetime.now());
            String body = 'Hi recipients, please refer to this log ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + log.Id;
            mail.setPlainTextBody(body);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            if (Boolean.valueOf(details.get('reUpdateMBSA')))
            {
                system.debug('re-update mbsa......');
                String condition =  'Id = ' + '\'' + recordId + '\'';
                List<MB_Sales_Agreement__c> mbSAs = ADGLIB_UtilityHelper.getSObjectRecords('MB_Sales_Agreement__c', condition, true);
                String checkboxFieldName = details.get('checkboxField');
                if ((Boolean)mbSAs[0].get(checkboxFieldName)) {
                    mbSAs[0].put(checkboxFieldName, false);
                } else {
                    mbSAs[0].put(checkboxFieldName, true);
                }

                try {
                    update mbSAs;
                } catch (Exception e) {
                    loggerDataPool.buildLogDataPool('File Requirement Re-Update MBSA', e);
                }
            }
        } catch (Exception e) {
            loggerDataPool.buildLogDataPool('File Requirement Exception', e);
        }
    }
}
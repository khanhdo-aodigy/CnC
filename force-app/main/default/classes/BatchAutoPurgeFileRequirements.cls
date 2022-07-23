global with sharing class BatchAutoPurgeFileRequirements implements Schedulable, Database.Batchable<sObject> {
    // @TestVisible private static List<File_Requirements__mdt> mockFileRequirements = new List<File_Requirements__mdt>();
 
    global static Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT DeveloperName, Document_Name__c, Object_API_Name__c, Auto_Purge_in_Months__c
                                         FROM File_Requirements__mdt
                                         WHERE Auto_Purge_in_Months__c != null]);
    }

    global void execute(Database.BatchableContext bc, List<File_Requirements__mdt> fileReqMdts) {
        // if (Test.isRunningTest()) fileReqMdts = mockFileRequirements;

        Map<String, Decimal> autoPurgeMonthsByDocumentNm = new Map<String, Decimal>();
        for (File_Requirements__mdt fileReqMdt : fileReqMdts) {
            if (String.isNotBlank(fileReqMdt.Document_Name__c)) autoPurgeMonthsByDocumentNm.put(fileReqMdt.Document_Name__c, fileReqMdt.Auto_Purge_in_Months__c);
        }
        List<String> fileDescriptions = new List<String>();
        for (String documentNm : autoPurgeMonthsByDocumentNm.keySet()) {
            fileDescriptions.add('%' + documentNm + '%');
        }
        system.debug('fileDescriptions:: '+ fileDescriptions);
        List<ContentDocument> cds = new List<ContentDocument>([SELECT Id, Title, Description, CreatedDate
                                                               FROM ContentDocument
                                                               WHERE Description LIKE :fileDescriptions]);
        system.debug('cds:: ' + cds.size());
        if (cds.size() > 0) {
            List<ContentDocument> filesToBeDeleted = new List<ContentDocument>();
            Integer monthsToPurge;  // Auto-Purge Months from Metadata
            Date cdCreatedDate;     // CreatedDate of Content Document
            Integer monthDiff;      // Months diff between CreatedDate and Auto-Purge Months
            system.debug('autoPurgeMonthsByDocumentNm:: ' + autoPurgeMonthsByDocumentNm);
            for (ContentDocument cd : cds) {
                system.debug('cd.Id:: ' + cd.Id + ' ' + 'cd.Description:: ' + cd.Description);
                if (autoPurgeMonthsByDocumentNm.containsKey(cd.Description)) {
                    monthsToPurge = autoPurgeMonthsByDocumentNm.get(cd.Description).intValue();
                    system.debug('monthsToPurge:: ' + monthsToPurge);
                    cdCreatedDate = Date.newinstance(cd.CreatedDate.year(), cd.CreatedDate.month(), cd.CreatedDate.day());
                    monthDiff = cdCreatedDate.monthsBetween(Date.today());
                    system.debug('monthDiff:: ' + monthDiff);
                    if (monthDiff >= monthsToPurge) filesToBeDeleted.add(cd);
                }
            }
            system.debug('No of files deleted:: ' + filesToBeDeleted.size());
            system.debug('filesToBeDeleted====' + filesToBeDeleted);
            if (filesToBeDeleted.size() > 0) {
                Set<String> errorMsgs = new Set<String>();
                List<Database.DeleteResult> results = Database.delete(filesToBeDeleted, false);
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        for(Database.Error err : results[i].getErrors()) {
                            errorMsgs.add(results[i].Id + ' ' + err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                if (errorMsgs.size() > 0) {
                    Logger_Data_Pool__c log = new Logger_Data_Pool__c(Instance__c = 'Files_Auto_Purge', Message__c = JSON.serialize(errorMsgs));
                    insert log;
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        batchDataPool.buildBatchDataPool('BatchAutoPurgeFileRequirement', bc.getJobId());
    }

    global void execute (SchedulableContext ctx) {
        BatchAutoPurgeFileRequirements b = new BatchAutoPurgeFileRequirements();
        Database.executeBatch(b);
    }
}
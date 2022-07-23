public with sharing class DefectFormTemplateCtrl {
    @AuraEnabled
    public static void sendEmail(String recordID) {
        EmailTemplate template = getTemplate('VehicleDefectForm');
		EmailTemplate templateAdvisor = getTemplate('VehicleDefectFormAdvisor');

        Sales_Agreement__c currentSA = getSalesAgreement(recordID);
        String emailToSend = currentSA.emailaddress__c;
        String emailToSendAdvisor = currentSA.Service_Center_Email__c;

        List<String> toAddress = new List<String> {emailToSend};
        List<String> toAddressAdvisor = new List<String> {emailToSendAdvisor};

        List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
        List<Defect__c> defects = [SELECT Id, Name from Defect__c where Sales_Agreement__c = :recordId];
        if (defects.size() > 0) {
            efaList = getAttachments(recordID, defects);
        }

        // Send email to Customer
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, null, recordID);
        mail.setSenderDisplayName(currentSA.Owner.Name);
        mail.setToAddresses(toAddress);
        if (!efaList.isEmpty()) {
			mail.setFileAttachments(efaList);
        }

        // Send email to Service Advisor
        Messaging.SingleEmailMessage mailToAdvisor = Messaging.renderStoredEmailTemplate(templateAdvisor.Id, null, recordID);
        mailToAdvisor.setSenderDisplayName(currentSA.Owner.Name);
        mailToAdvisor.setToAddresses(toAddressAdvisor);
        if (!efaList.isEmpty()){
			mailToAdvisor.setFileAttachments(efaList);
        }

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>{mail, mailToAdvisor};
        //system.debug(allmsg);
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
            system.debug(results);
            if (results[0].success) {
                system.debug('Send success');
                system.debug('========= TOTAL OF SENT MAILS =========');
        		system.debug(allmsg.size());
            } else {
                system.debug('Failed to send' + results[0].errors[0].message);
            }
            return;
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
    }

    private static EmailTemplate getTemplate(String templateNm) {
        EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :templateNm];
        return template;
    }

    private static Sales_Agreement__c getSalesAgreement(String recordId) {
        Sales_Agreement__c currentSA = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, Service_Center_Email__c FROM Sales_Agreement__c WHERE ID = :recordId];
        system.debug(currentSA);
        return currentSA;
    }

    private static List<Messaging.EmailFileAttachment> getAttachments(String recordId, List<Defect__c> defects) {
        // Create a Map contains defectId - defectName (1 key - 1 value)
        Map<Id, String> defectMap = new Map<Id, String>();
        for (Defect__c defect : defects) {
            defectMap.put(defect.Id, defect.Name);
        }

        // Get list files of Defect
        Set<Id> defectIdSet = defectMap.keySet();
        List<ContentDocumentLink> fileResults = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId, Visibility, 
                                                        IsDeleted, ShareType, ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                                                 FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId IN :defectIdSet AND ContentDocument.Title LIKE '%_01%'
                                                 ORDER BY ContentDocument.createdDate DESC NULLS LAST];

        // Create a Map contains 1 LinkedEntityId - 1 ContentDocumentLink
        Map<Id, ContentDocumentLink> entityCDLMap = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink file : fileResults) {
            if (!entityCDLMap.containsKey(file.LinkedEntityId)) {
                entityCDLMap.put(file.LinkedEntityId, file);
            }
        }

        // Create a Map contains 1 ContentDocumentId - 1 Defect Name
        Map<Id, String> cdlDefectMap = new Map<Id, String>();
        for (ContentDocumentLink file : entityCDLMap.values()) {
            cdlDefectMap.put(file.ContentDocumentId, defectMap.get(file.LinkedEntityId));
        }

        // Get list ContentVersion of ContentDocumentLink
        Set<Id> cdlDefectSet = cdlDefectMap.keySet();
        List<ContentVersion> cvs = [SELECT VersionData, ContentModifiedDate, ContentDocumentId
                                    FROM ContentVersion
                                    WHERE ContentDocumentId IN :cdlDefectSet
                                    ORDER BY ContentModifiedDate];

        // Create a Map contains 1 ContentDocumentLink - 1 VersionData
        Map<Id, Blob> cdlCVSMap = new Map<Id, Blob>();
        for (ContentVersion cv : cvs) {
            cdlCVSMap.put(cv.ContentDocumentId, cv.VersionData);
        }

        // Prepare list attachments for email 
        List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
        if (!entityCDLMap.isEmpty()) {
            for (ContentDocumentLink file : entityCDLMap.values()) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cdlDefectMap.get(file.ContentDocumentId) + '.' + file.ContentDocument.FileType);
                efa.setBody(cdlCVSMap.get(file.ContentDocumentId));
                efa.setContentType('application/' + file.ContentDocument.FileType);
                efaList.add(efa);
            }
        }

        return efaList;
    }
}
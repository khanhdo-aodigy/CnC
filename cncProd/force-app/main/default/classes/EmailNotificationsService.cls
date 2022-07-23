public with sharing class EmailNotificationsService {
    public static Messaging.SingleEmailMessage renderToEmail(Id recordId, String templateNm) {
        // Get email template by template name
        EmailTemplate template = getTemplate(templateNm);

        // Get sales agreement record
        Sales_Agreement__c currentSA = getSalesAgreement(recordID);

		// Create list of addresses to send
        String emailToSend = currentSA.emailaddress__c;
        List<String> toAddress = new List<String> {emailToSend};

		OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName 
                                   FROM OrgWideEmailAddress 
                                   WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg' 
                                   LIMIT 1];

        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, null, recordID);
        //mail.setSenderDisplayName(currentSA.Owner.Name);
        mail.setOrgWideEmailAddressId(owa.Id);
        mail.setToAddresses(toAddress);
        if (templateNm == 'Registration_Email_Notification') {
            String docNm = getDocNm(currentSA.Registration_Type__c, currentSA.Branch_Code__c, currentSA.DS_Model__c);
            if (String.isNotEmpty(docNm)) {
                List<Document> docs = [SELECT ID, Name, DeveloperName FROM Document WHERE DeveloperName =: docNm];
                system.debug(docs);
                if (docs.size() > 0) {
                    mail.setEntityAttachments(new List<String>{docs[0].Id});
                }
            }
        }
        return mail;
    }

    public static EmailTemplate getTemplate(String templateNm) {
        EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :templateNm];
        return template;
    }

    private static Sales_Agreement__c getSalesAgreement(String recordId) {
        Sales_Agreement__c currentSA = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, COE__r.Id, COE__r.COH_COENO__c, 
                                        	   COE__r.COH_SUCCESSFROMDT__c, COE__r.COH_SUCCESSTODT__c, COE__r.COH_EXPMONTH__c,
                                               Registration_Type__c, Branch_Code__c, DS_Model__c, Finance_Company_Lookup__c,
                                               Finance_Company_In_House__c, Emailed_BAM__c
                                        FROM Sales_Agreement__c 
                                        WHERE ID = :recordId];
        system.debug(currentSA);

        return currentSA;
    }

    private static String getDocNm(String regisType, String branchCode, Boolean dsModel) {
        String docNm;
        if (regisType == 'P') {
            switch on branchCode {
                when 'CCK' {
                    docNm = 'KIA_VDAF_Private';
                    system.debug(docNm);
                }
                when 'CCA' {
                    docNm = 'MIT_VDAF_Private';
                    system.debug(docNm);
                }
                when else {
                    docNm = !dsModel ? 'CCF_VDAF_Private' : 'DS_VDAF_Private';
                    system.debug(docNm);
                }
            }
        } else {
            switch on branchCode {
                when 'CCK' {
                    docNm = 'KIA_VDAF_Company';
                    system.debug(docNm);
                }
                when 'CCA' {
                    docNm = 'MIT_VDAF_Company';
                    system.debug(docNm);
                }
                when else {
                    docNm = !dsModel ? 'CCF_VDAF_Company' : 'DS_VDAF_Company';
                    system.debug(docNm);
                }
            }
        }
        return docNm;
    }

    public static Messaging.SingleEmailMessage renderFinanceEmail(Sales_Agreement__c sa, String templateId) {
        // Get email emplate
        // EmailTemplate template = getTemplate('Finance_Email');

        // Get Email Settings
        List<Email_Setting__c> emailSettings = getEmailSetting(sa);
        if (emailSettings.size() == 0) {
            return null;
        }

        // Assign To Addresses
        List<String> toAddresses = convertEmailRecipients(emailSettings[0].Email_To__c);
        // Assign CC Addresses
        List<String> ccAddresses;
        if (!String.isBlank(emailSettings[0].Email_Cc__c)) {
            ccAddresses = convertEmailRecipients(emailSettings[0].Email_Cc__c);
        }
        // Get org wide email address
        OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName 
                                   FROM OrgWideEmailAddress 
                                   WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg' 
                                   LIMIT 1];

        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, null, sa.Id);
        mail.setOrgWideEmailAddressId(owa.Id);
        mail.setToAddresses(toAddresses);
        if (ccAddresses.size() > 0) {
            mail.setCcAddresses(ccAddresses);
        }
        List<Messaging.EmailFileAttachment> efaList = getAttachments(sa);
        if (efaList != null) {
			mail.setFileAttachments(efaList);
        }
        system.debug('TO ADDRESS:: ' + toAddresses);
        system.debug('CC ADDRESS:: ' + ccAddresses);

        return mail;
    }

    private static List<String> convertEmailRecipients(String emails) {
        List<String> recipients = new List<String>();
        if (emails.contains(';')) {
            recipients = emails.split(';');
        } else {
            recipients.add(emails);
        }
        return recipients;
    }

    private static List<sObject> getEmailSetting(Sales_Agreement__c sa) {

        String financeCompanyId = sa.Finance_Company_Lookup__c;
        String regisType = sa.Registration_Type__c;
        String query = 'SELECT Id, Name, Finance_Company_Lookup__c, Registration_Type__c, Email_To__c, Email_Cc__c, Branch_Code__c' +
                       ' FROM Email_Setting__c' +
                       ' WHERE Finance_Company_Lookup__c = :financeCompanyId AND (Registration_Type__c = \'' + String.escapeSingleQuotes('All') + '\' OR Registration_Type__c = :regisType)';
       
        if (sa.Branch_Code__c == 'CCK') {
            query += ' AND Branch_Code__c includes (\'CCK\')';
        } else if (sa.Branch_Code__c == 'CCA') {
            query += ' AND Branch_Code__c includes (\'CCA\')';
        } else {
            query += ' AND Branch_Code__c includes (\'CCF\')';
        }
        system.debug('QUERY:: ' + query);

        List<sObject> result = Database.query(query);
        system.debug(result);
        return result;
    }

    private static List<Messaging.EmailFileAttachment> getAttachments(Sales_Agreement__c sa) {
        List<ContentDocumentLink> cdlinks = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId, Visibility, 
                                                        IsDeleted, ShareType, ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId =: sa.Id AND ContentDocument.Title LIKE '%_Sales Agreement_%'
                                             ORDER BY ContentDocument.createdDate DESC NULLS LAST];
        system.debug('------ Content Document Link -----');
        system.debug(cdlinks);
        if (cdlinks.size() == 0) {
            return null;
        }
        List<ContentVersion> cvs = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId
                                    FROM ContentVersion
                                    WHERE ContentDocumentId = :cdlinks[0].ContentDocumentId
                                    ORDER BY ContentModifiedDate];

        
 		List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(cdlinks[0].ContentDocument.Title + '.' + cdlinks[0].ContentDocument.FileType);
        efa.setBody(cvs[0].VersionData);
        efa.setContentType('application/' + cdlinks[0].ContentDocument.FileType);
        efaList.add(efa);

        system.debug(efaList);
        return efaList;
    }

    @AuraEnabled
    public static void sendFinanceEmail(String saId){
        // Get Sales Agreement
        Sales_Agreement__c sa = getSalesAgreement(saId);
        if (!sa.Finance_Company_In_House__c) {
            throw new AuraHandledException('Finance Company is not in-house.');
        }
        // Get email template
        EmailTemplate template = getTemplate('Finance_Email');
        // Render email
        Messaging.SingleEmailMessage email = renderFinanceEmail(sa, template.Id);
        // Send email
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>{email};
        if (emails.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails, false);
            if (results[0].success) {
                if (!sa.Emailed_BAM__c) sa.Emailed_BAM__c = true;
                update sa;
                system.debug('All emails was sent successfully');
                system.debug('========= TOTAL OF SENT MAILS =========');
                system.debug(emails.size());
            } else {
                system.debug('Failed to send: ' + results[0].errors[0].message);
            }
        }
    }
}
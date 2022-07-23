public with sharing class MB_Docusign {

    /**
     * Counter to generate document ID and recipient ID
     */
    private static Integer documentCounter = 0;
    private static Integer recipientCounter = 0;

    /**
     * Docusign configuration tokens
     */
    private static String ACCOUNT_ID;
    private static String BOUNDARY;
    private static String BOUNDARY_START;
    private static String BOUNDARY_END;
    private static String ACCESS_TOKEN;
    private static String baseURI = 'https://eu.docusign.net';

    /**
     * Store information of direct signer (if have)
     */
    private static String directSignerID;                                           // ID of direct signer (assume only 1 direct signer)
    private static String directSignerName;                                         // Name of direct signer
    private static String directSignerEmail;                                        // Email of direct signer

    private static String documentType;                                             // targeted document type

    /**
     * ========== PUBLIC METHODS ==========
     */

     /* -------- MODIFIED BY THIEU DANG VU - Thu 5th Nov 2020 -- START --------*/
     /**
      * This method to update Validity Date field in MB SA
      */
    @AuraEnabled
    public static void updateValidityDate(ID recordID) {
        MB_Sales_Agreement__c SA = (MB_Sales_Agreement__c) getRecords(recordID, null)[0];

        Date currentDate = System.today();
        SA.Validity_Date__c = currentDate.addDays(3);
        try {
            update SA;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /* -------- MODIFIED BY THIEU DANG VU - Thu 5th Nov 2020 -- END --------*/

    /**
     * exposed method for sign in-place scenario
     */
    @AuraEnabled
    public static String signInPlace(ID recordID, String docType)
    {
        documentType = docType;
        try {
            HttpResponse response;
            switch on documentType {
                when 'SA' {
                    response = docusign(recordID, false, documentType);
                }
                when 'UCA' {
                    response = docusignUCA(recordID, false, documentType);
                }
                when 'CRF' {
                    response = docusignCRF(recordID, false, documentType);       // ADDED BY THIEU DANG VU - May 6th 2021 - Signing process for Change Request Form
                }
                when 'SAUCA' {
                    response = docusignSAUCA(recordID, false, documentType);    // ADDED BY THIEU DANG VU - June 3rd 2021 - Signing process for Sales & UCA Form
                }
                when else {
                    // DO NOTHING
                }
            }
            Integer statusCode = response.getStatusCode();
            if (statusCode == 201) {
                String signLink = getSignLink(response);
                updateEnvelopeResult(recordID, response, documentType);
                return signLink;
            } else {
                throw new AuraHandledException('Error response from Docusign server: ' + response.getBody());
            }
        } catch (Exception e) {
            throw e;
        }
    }

    /**
     * exposed method for sign via email scenario
     */
    @AuraEnabled
    public static void signViaEmail(ID recordID, String docType)
    {
        documentType = docType;
        try {
            HttpResponse response;
            switch on documentType {
                when 'SA' {
                    response = docusign(recordID, true, documentType);
                }
                when 'UCA' {
                    response = docusignUCA(recordID, true, documentType);
                }
                when 'CRF' {
                    response = docusignCRF(recordID, true, documentType);        // ADDED BY THIEU DANG VU - May 6th 2021 - Signing process for Change Request Form
                }
                when 'SAUCA' {
                    response = docusignSAUCA(recordID, true, documentType);     // ADDED BY THIEU DANG VU - June 3rd 2021 - Signing process for Sales & UCA Form
                }
                when else {
                    // DO NOTHING
                }
            }
            Integer statusCode = response.getStatusCode();
            if (statusCode == 201) {
                updateEnvelopeResult(recordID, response, documentType);
            } else {
                throw new AuraHandledException('Error response from Docusign server: ' + response.getBody());
            }
        } catch (Exception e) {
            throw e;
        }
    }

    /**
     * get preview URL
     */
    @AuraEnabled
    public static String getPreview(String recordID, String docType)
    {
        validation((MB_Sales_Agreement__c) getRecords(recordID, null)[0]);

        Id templateId;
        documentType = docType;
        switch on documentType {
            when 'SA' {
                templateId = getTemplateId('MB_Preview_Template').DocuSign_Template_Id__c;
            }
            when 'UCA' {
                templateId = getTemplateId('MB_Preview_Template').Used_Car_Agreement_Template__c;
            }
            when 'CRF' {
                templateId = getTemplateId('MB_CRF_Preview_Template').DocuSign_Template_Id__c;
            }
            when 'SAUCA' {
                templateId = getTemplateId('MB_SA_UCA_Preview_Template').DocuSign_Template_Id__c;
            }
            when else {
                // DO NOTHING
            }
        }
        return webm.WebmergeGenerator.previewDocument(templateId, recordID, 'MB_Sales_Agreement__c');
    }

    @AuraEnabled
    public static List<SObject> getRecords(ID recordID, String additionalConditions)
    {
        Schema.SObjectType objectToken = recordID.getSObjectType();

        String mainQueryCondition = 'ID = ' + '\'' + recordID + '\'' + ' ';

        if (additionalConditions != null && String.isNotBlank(additionalConditions)) {
            mainQueryCondition += additionalConditions;
        }

        return getRecords(objectToken, mainQueryCondition, null, null, false);
    }
    /**
     * ========== END PUBLIC METHODS ==========
     */


    /**
     * ========== PRIVATE METHODS ==========
     */

    /**
     * main method to launch the Docusign
     * @param recordID: MB Sales Agreement record ID
     * @param signViaEmail: customer to sign via email or sign in-place
     */
    @testVisible
    private static HttpResponse docusign(ID recordID, Boolean signViaEmail, String documentType) 
    {
        logTime('START');
        MB_Sales_Agreement__c SA;                                                                               // Target MB Sales Agreement
        User Owner;                                                                                             // Owner of [SA]
        final String SG_UNIQUE_IDENTIFIER;                                                                      // Unique identifier of [Owner]'s profile
        Signing_Group__c SG;                                                                                    // Signing_Group__c record
        List<DocuSign_Recipient_Configuration__mdt> recipientConfigurations;                                    // List of recipient configuration metadata
        final Schema.SObjectType SG_OBJECT_TOKEN = getObjectToken('Signing_Group__c');                          // Signing_Group__c token
        final Schema.SObjectType RC_OBJECT_TOKEN = getObjectToken('DocuSign_Recipient_Configuration__mdt');     // DocuSign_Recipient_Configuration__mdt token
        List<DocusignDocument> documents = new List<DocusignDocument>();                                        // Docusign object for documents
        List<DocusignSignerDetail> recipientDetails = new List<DocusignSignerDetail>{};                         // Docusign object for recipient details
        DocusignSigners recipients;                                                                             // Docusign object for coleection of recipients
        List<String> MFD = new List<String>();                                                                  // Document content in multiform
        String signedDocumentName;                                                                              // Name of the signed sales agreement
        String documentExt;                                                                                     // Extension type of document
        String documentID;                                                                                      // ID of document
        String emailSubject;                                                                                    // Signing email subject
        String multiformRequest;                                                                                // The request body in multiform
        String docVersion;                                                                                      // Version of DSA 

        SA = (MB_Sales_Agreement__c) getRecords(recordID, null)[0];
        Owner = [SELECT UserRole.Name, Name FROM USER WHERE ID = :SA.OwnerId];
        List<sObject> signingGroups = getRecords(SG_OBJECT_TOKEN, 'Unique_Identifier__c = ' + '\'' + getTeamIdentifier(Owner.UserRole.Name) + '\'', null, null, true);
        if (signingGroups.size() == 0) throw new AuraHandledException('The owner of this record have no valid role');
        else SG = (Signing_Group__c)signingGroups[0];

        validation(SA);
        configuration(SA.OwnerId);                                                                              // get configuration tokens

        if (!signViaEmail) {
            recipientConfigurations = (List<DocuSign_Recipient_Configuration__mdt>) getRecords(RC_OBJECT_TOKEN, 'Signing_Scenario__c = \'E\' AND Active__c = true', 'Signing_Order__c', 'ASC', false);
        } else {
            recipientConfigurations = (List<DocuSign_Recipient_Configuration__mdt>) getRecords(RC_OBJECT_TOKEN, 'Signing_Scenario__c = \'F\' AND Active__c = true', 'Signing_Order__c', 'ASC', false);
        }

        // get envelope documents
        docVersion = SA.Sales_Agreement_Version__c != null? 'v.' + String.valueOf(SA.Sales_Agreement_Version__c) : '';
        logTime('BEFORE GENERATE DOCUMENT');
        /* -------- MODIFIED BY THIEU DANG VU - Wed 4th Nov 2020 -- START --------*/
        DocuSignTemplate__mdt template = getTemplateId('MB_Template');
        List<Attachment> wmResults = webm.WebmergeGenerator.generateDocumentGetAttachments(template.DocuSign_Template_Id__c, recordID, 'MB_Sales_Agreement__c');
        /* -------- MODIFIED BY THIEU DANG VU - Wed 4th Nov 2020 -- END --------*/
        logTime('AFTER GENERATE DOCUMENT');
        if (!Test.isRunningTest()) {
            for (Attachment file : wmResults)
            {
                documentCounter++;
                documentID = String.valueOf(documentCounter);
                signedDocumentName = SA.Name + '_MB Sales Agreement ' + docVersion + ' ' + Datetime.now().format('dd/MM/yyyy');
                documents.add(new DocusignDocument(signedDocumentName, 'pdf', documentID));                                     // document declare
                MFD.add(DocusignUtility.getMFD(file.Body, 'pdf', signedDocumentName, documentID, BOUNDARY_START));              // document content in multiform
            }            
        } else {
            Attachment attach = new Attachment();
            attach.Name = 'MB Sales Agreement-'+ SA.Name; 
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = SA.Id;
            documentID = '1';
            signedDocumentName = attach.Name;
            documents.add(new DocusignDocument(signedDocumentName, 'docx', documentID));
            MFD.add(DocusignUtility.getMFD(attach.Body, 'docx', signedDocumentName, documentID, BOUNDARY_START));
        }

        for (DocuSign_Recipient_Configuration__mdt rc : recipientConfigurations)
        {
            recipientCounter++;
            String recipientType = DocusignUtility.getRecipientType(rc);
            switch on recipientType {
                when 'CUSTOMER' 
                {
                    recipientDetails.add(customer(rc, SA, SG, documentType));
                }
                when 'CC_ENDORSER' 
                {
                    recipientDetails.add(ccEndorser(rc, SA, SG, documentType));
                }
                when 'APPROVER' 
                {
                    recipientDetails.add(approver(rc, SA, SG, documentType));
                }
                when else {
                    throw new AuraHandledException('Invalid recipient type: ' + recipientType);
                }
            }

            if (rc.Signing_Method__c == 'Direct') 
            {
                directSignerID = String.valueOf(recipientCounter);
                directSignerName = SA.Customer_Full_Name__c;
                directSignerEmail = SA.CEmail_Address__c;
            }
        }
        recipients = new DocusignSigners(recipientDetails);
        emailSubject = ('Sales Agreement No. ' + SA.Name + ' ' + docVersion + ' by ' + Owner.Name).left(100);                  // 100 characters limit
        DocusignEnvelope envelope = new DocusignEnvelope('sent', emailSubject, recipients, documents);
        envelope.emailBlurb = 'Dear all,' + '\n' +'\n' + 'Please help sign / review this Sales Agreement. See the private message of this email for more detail.' + '\n' +'\n' + 'Thank you, ' + Owner.Name + '.';
        envelope.customFields.addRecordAutoNumber(SA.Name);
        envelope.brandId = getBrandID('MB_Template');
        // TODO: set reminder if needed

        /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 - Set Expiration for Envelopes - START --------*/
        // MB CR - 25/10/2021 Not apply Envelope's expiration for corporate purchases - NOT DEPLOY YET
        // if (SA.Registration_Type__c == 'P') {
        DocuSignNotificationSettings notiSettings = new DocuSignNotificationSettings();
        notiSettings.useAccountDefaults = 'false';
        DocuSign_Expiration_Configuration__mdt[] expirationSettings = getExpirationSettings('MB_SA');
        if (expirationSettings.size() > 0) {
            envelope.notification = notiSettings.addExpirationSettings('true', expirationSettings[0].Expire_After__c, expirationSettings[0].Expire_Warn__c);
        } else {
            system.debug('EnvelopeSendController: No expiration setting found');
        }
        // }

        /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 -- Set Expiration for Envelopes - END --------*/

        // put the request body into multiform (https://developers.docusign.com/esign-rest-api/guides/requests-and-responses)
        multiformRequest = DocusignUtility.multiform(BOUNDARY_START, BOUNDARY_END, JSON.serialize(envelope), MFD);

        Http http = new Http();
        HttpRequest request = DocusignUtility.prepareEnvelopeRequest(ACCOUNT_ID, ACCESS_TOKEN, BOUNDARY, multiformRequest, baseURI);
        system.debug(request.getBody());
        logTime('BEFORE SENDING DOCUSIGN');
        HttpResponse response = http.send(request);
        logTime('AFTER SENDING DOCUSIGN');
        System.debug('Docusign envelope create response: ' + response.getBody());
        return response;
    }

    /* -------- MODIFIED BY THIEU DANG VU - Wed 4th Nov 2020 -- START --------*/
    /**
     * main method to launch the Docusign for UCA
     * @param recordID: MB Sales Agreement record ID
     * @param signViaEmail: customer to sign via email or sign in-place
     */
    @testVisible
    private static HttpResponse docusignUCA(ID recordID, Boolean signViaEmail, String documentType) 
    {
        logTime('START');
        MB_Sales_Agreement__c SA;                                                                               // Target MB Sales Agreement
        User Owner;                                                                                             // Owner of [SA]
        final String SG_UNIQUE_IDENTIFIER;                                                                      // Unique identifier of [Owner]'s profile
        Signing_Group__c SG;                                                                                    // Signing_Group__c record
        List<DocuSign_Recipient_Configuration__mdt> recipientConfigurations;                                    // List of recipient configuration metadata
        final Schema.SObjectType SG_OBJECT_TOKEN = getObjectToken('Signing_Group__c');                          // Signing_Group__c token
        final Schema.SObjectType RC_OBJECT_TOKEN = getObjectToken('DocuSign_Recipient_Configuration__mdt');     // DocuSign_Recipient_Configuration__mdt token
        List<DocusignDocument> documents = new List<DocusignDocument>();                                        // Docusign object for documents
        List<DocusignSignerDetail> recipientDetails = new List<DocusignSignerDetail>{};                         // Docusign object for recipient details
        DocusignSigners recipients;                                                                             // Docusign object for coleection of recipients
        List<String> MFD = new List<String>();                                                                  // Document content in multiform
        String signedDocumentName;                                                                              // Name of the signed sales agreement
        String documentExt;                                                                                     // Extension type of document
        String documentID;                                                                                      // ID of document
        String emailSubject;                                                                                    // Signing email subject
        String multiformRequest;                                                                                // The request body in multiform
        String docVersion;                                                                                      // Version of DSA 

        SA = (MB_Sales_Agreement__c) getRecords(recordID, null)[0];
        Owner = [SELECT UserRole.Name, Name FROM USER WHERE ID = :SA.OwnerId];
        List<sObject> signingGroups = getRecords(SG_OBJECT_TOKEN, 'Unique_Identifier__c = ' + '\'' + getTeamIdentifier(Owner.UserRole.Name) + '\'', null, null, true);
        if (signingGroups.size() == 0) throw new AuraHandledException('The owner of this record have no valid role.');
        else SG = (Signing_Group__c)signingGroups[0];

        validation(SA);
        configuration(SA.OwnerId);                                                                              // get configuration tokens

        if (!signViaEmail) {
            recipientConfigurations = (List<DocuSign_Recipient_Configuration__mdt>) getRecords(RC_OBJECT_TOKEN, 'Signing_Scenario__c = \'H\' AND Active__c = true', 'Signing_Order__c', 'ASC', false);
        } else {
            recipientConfigurations = (List<DocuSign_Recipient_Configuration__mdt>) getRecords(RC_OBJECT_TOKEN, 'Signing_Scenario__c = \'G\' AND Active__c = true', 'Signing_Order__c', 'ASC', false);
        }

        // get envelope documents
        docVersion = SA.UCA_Version__c != null? 'v.' + String.valueOf(SA.UCA_Version__c) : '';
        logTime('BEFORE GENERATE DOCUMENT');
        DocuSignTemplate__mdt template = getTemplateId('MB_Template');
        List<Attachment> wmResults = webm.WebmergeGenerator.generateDocumentGetAttachments(template.Used_Car_Agreement_Template__c, recordID, 'MB_Sales_Agreement__c');
        logTime('AFTER GENERATE DOCUMENT');
        if (!Test.isRunningTest()) {
            for (Attachment file : wmResults) {
                documentCounter++;
                documentID = String.valueOf(documentCounter);
                signedDocumentName = SA.Name + '_MB Used Car Agreement ' + docVersion + ' ' + Datetime.now().format('dd/MM/yyyy');
                documents.add(new DocusignDocument(signedDocumentName, 'pdf', documentID));                                     // document declare
                MFD.add(DocusignUtility.getMFD(file.Body, 'pdf', signedDocumentName, documentID, BOUNDARY_START));              // document content in multiform
            }
        } else {
            Attachment attach = new Attachment();   	
            attach.Name = 'MB Sales Agreement-'+ SA.Name; 
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = SA.Id;
            documentID = '1';
            signedDocumentName = attach.Name;
            documents.add(new DocusignDocument(signedDocumentName, 'docx', documentID));
            MFD.add(DocusignUtility.getMFD(attach.Body, 'docx', signedDocumentName, documentID, BOUNDARY_START));
        }

        // get document recipients
        DocusignSignerDetail customer;
        for (DocuSign_Recipient_Configuration__mdt rc : recipientConfigurations)
        {
            recipientCounter++;
            String recipientType = DocusignUtility.getRecipientType(rc);
            switch on recipientType {
                when 'CUSTOMER' 
                {
                    customer = customer(rc, SA, SG, documentType);
                    recipientDetails.add(customer);
                }
                when 'THIRD_PARTY' 
                {
                    recipientDetails.add(thirdParty(rc, SA, SG, documentType));
                }
                when 'CC_ENDORSER' 
                {
                    recipientDetails.add(ccEndorser(rc, SA, SG, documentType));
                }
                when 'APPROVER' 
                {
                    recipientDetails.add(approver(rc, SA, SG, documentType));
                }
                when else {
                    throw new AuraHandledException('Invalid recipient type: ' + recipientType);
                }
            }

            if (rc.Signing_Method__c == 'Direct') 
            {
                directSignerID = String.valueOf(recipientCounter);
                directSignerName = SA.Customer_Full_Name__c;
                directSignerEmail = SA.CEmail_Address__c;
            }
        }
        recipients = new DocusignSigners(recipientDetails);
        emailSubject = ('Used Car Trade-In Agreement ' + docVersion + ' for Sales Agreement No.' + SA.Name + ' '  + ' by ' + Owner.Name).left(100);                  // 100 characters limit
        DocusignEnvelope envelope = new DocusignEnvelope('sent', emailSubject, recipients, documents);
        envelope.emailBlurb = 'Dear all,' + '\n' +'\n' + 'Please help sign / review this Used Car Purchase Agreement. See the private message of this email for more detail.' + '\n' +'\n' + 'Thank you, ' + Owner.Name + '.';
        envelope.customFields.addRecordAutoNumber(SA.Name);
        envelope.brandId = getBrandID('MB_Template');
        // TODO: set reminder if needed

        // TODO: set expiration if needed
        /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 - Set Expiration for Envelopes - START --------*/
        DocuSignNotificationSettings notiSettings = new DocuSignNotificationSettings();
        notiSettings.useAccountDefaults = 'false';
        DocuSign_Expiration_Configuration__mdt[] expirationSettings = getExpirationSettings('MB_UCA');
        if (expirationSettings.size() > 0) {
            envelope.notification = notiSettings.addExpirationSettings('true', expirationSettings[0].Expire_After__c, expirationSettings[0].Expire_Warn__c);
        } else {
            system.debug('EnvelopeSendController: No expiration setting found');
        }
        /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 -- Set Expiration for Envelopes - END --------*/

        // put the request body into multiform (https://developers.docusign.com/esign-rest-api/guides/requests-and-responses)
        multiformRequest = DocusignUtility.multiform(BOUNDARY_START, BOUNDARY_END, JSON.serialize(envelope), MFD);

        Http http = new Http();
        HttpRequest request = DocusignUtility.prepareEnvelopeRequest(ACCOUNT_ID, ACCESS_TOKEN, BOUNDARY, multiformRequest, baseURI);
        system.debug(request.getBody());
        logTime('BEFORE SENDING DOCUSIGN');
        HttpResponse response = http.send(request);
        logTime('AFTER SENDING DOCUSIGN');
        System.debug('Docusign envelope create response: ' + response.getBody());
        return response;
    }
    /* -------- MODIFIED BY THIEU DANG VU - Wed 4th Nov 2020 -- END --------*/

    /* -------- ADDED BY THIEU DANG VU - May 6th Nov 2021 -- START --------*/
    @testVisible
    private static HttpResponse docusignCRF(ID recordID, Boolean signViaEmail, String documentType) 
    {
        logTime('START');
        MB_Sales_Agreement__c SA;                                                                               // Target MB Sales Agreement
        User Owner;                                                                                             // Owner of [SA]
        final String SG_UNIQUE_IDENTIFIER;                                                                      // Unique identifier of [Owner]'s profile
        Signing_Group__c SG;                                                                                    // Signing_Group__c record
        List<DocuSign_Recipient_Configuration__mdt> recipientConfigurations;                                    // List of recipient configuration metadata
        final Schema.SObjectType SG_OBJECT_TOKEN = getObjectToken('Signing_Group__c');                          // Signing_Group__c token
        final Schema.SObjectType RC_OBJECT_TOKEN = getObjectToken('DocuSign_Recipient_Configuration__mdt');     // DocuSign_Recipient_Configuration__mdt token
        List<DocusignDocument> documents = new List<DocusignDocument>();                                        // Docusign object for documents
        List<DocusignSignerDetail> recipientDetails = new List<DocusignSignerDetail>{};                         // Docusign object for recipient details
        DocusignSigners recipients;                                                                             // Docusign object for coleection of recipients
        List<String> MFD = new List<String>();                                                                  // Document content in multiform
        String signedDocumentName;                                                                              // Name of the signed sales agreement
        String documentExt;                                                                                     // Extension type of document
        String documentID;                                                                                      // ID of document
        String emailSubject;                                                                                    // Signing email subject
        String multiformRequest;                                                                                // The request body in multiform
        String docVersion;                                                                                      // Version of DSA 

        SA = (MB_Sales_Agreement__c) getRecords(recordID, null)[0];
        Owner = [SELECT UserRole.Name, Name FROM USER WHERE ID = :SA.OwnerId];
        List<sObject> signingGroups = getRecords(SG_OBJECT_TOKEN, 'Unique_Identifier__c = ' + '\'' + getTeamIdentifier(Owner.UserRole.Name) + '\'', null, null, true);
        if (signingGroups.size() == 0) throw new AuraHandledException('The owner of this record have no valid role.');
        else SG = (Signing_Group__c)signingGroups[0];

        validation(SA);
        configuration(SA.OwnerId);                                                                              // get configuration tokens

        if (!signViaEmail) {
            recipientConfigurations = (List<DocuSign_Recipient_Configuration__mdt>) getRecords(RC_OBJECT_TOKEN, 'Signing_Scenario__c = \'I\' AND Active__c = true', 'Signing_Order__c', 'ASC', false);
        } else {
            recipientConfigurations = (List<DocuSign_Recipient_Configuration__mdt>) getRecords(RC_OBJECT_TOKEN, 'Signing_Scenario__c = \'J\' AND Active__c = true', 'Signing_Order__c', 'ASC', false);
        }

        // Get envelope documents
        docVersion = SA.Yellow_Form_Version__c != null? 'v.' + String.valueOf(SA.Yellow_Form_Version__c) : '';
        logTime('BEFORE GENERATE DOCUMENT');
        DocuSignTemplate__mdt template = getTemplateId('MB_CRF_Template');
        List<Attachment> wmResults = webm.WebmergeGenerator.generateDocumentGetAttachments(template.DocuSign_Template_Id__c, recordID, 'MB_Sales_Agreement__c');
        logTime('AFTER GENERATE DOCUMENT');
        if (!Test.isRunningTest()) {
            system.debug(wmResults);
            for (Attachment file : wmResults) {
                documentCounter++;
                documentID = String.valueOf(documentCounter);
                signedDocumentName = SA.Name + '_MB Change Request Form ' + docVersion + ' ' + Datetime.now().format('dd/MM/yyyy');
                documents.add(new DocusignDocument(signedDocumentName, 'pdf', documentID));                                     // document declare
                MFD.add(DocusignUtility.getMFD(file.Body, 'pdf', signedDocumentName, documentID, BOUNDARY_START));              // document content in multiform
            }
        } else {
            Attachment attach = new Attachment();   	
            attach.Name = 'MB Change Request Form -'+ SA.Name; 
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = SA.Id;
            documentID = '1';
            signedDocumentName = attach.Name;
            documents.add(new DocusignDocument(signedDocumentName, 'docx', documentID));
            MFD.add(DocusignUtility.getMFD(attach.Body, 'docx', signedDocumentName, documentID, BOUNDARY_START));
        }

        // Get document recipients
        for (DocuSign_Recipient_Configuration__mdt rc : recipientConfigurations)
        {
            recipientCounter++;
            String recipientType = DocusignUtility.getRecipientType(rc);
            switch on recipientType {
                when 'CUSTOMER' 
                {
                    recipientDetails.add(customer(rc, SA, SG, documentType));
                }
                when 'CC_ENDORSER' 
                {
                    recipientDetails.add(ccEndorser(rc, SA, SG, documentType));
                }
                when 'APPROVER' 
                {
                    recipientDetails.add(approver(rc, SA, SG, documentType));
                }
                when else {
                    throw new AuraHandledException('Invalid recipient type: ' + recipientType);
                }
            }

            if (rc.Signing_Method__c == 'Direct') 
            {
                directSignerID = String.valueOf(recipientCounter);
                directSignerName = SA.Customer_Full_Name__c;
                directSignerEmail = SA.CEmail_Address__c;
            }
        }
        recipients = new DocusignSigners(recipientDetails);

        emailSubject = ('Change Request Form for Sales Agreement No. ' + SA.Name + ' ' + docVersion + ' by ' + Owner.Name).left(100);                  // 100 characters limit
        DocusignEnvelope envelope = new DocusignEnvelope('sent', emailSubject, recipients, documents);
        envelope.emailBlurb = 'Dear all,' + '\n' +'\n' + 'Please help sign / review this Sales Agreement. See the private message of this email for more detail.' + '\n' +'\n' + 'Thank you, ' + Owner.Name + '.';
        envelope.customFields.addRecordAutoNumber(SA.Name);
        envelope.brandId = getBrandID('MB_CRF_Template');
        DocuSignNotificationSettings notiSettings = new DocuSignNotificationSettings();
        notiSettings.useAccountDefaults = 'false';
        // Assign Expiration Settings
        DocuSign_Expiration_Configuration__mdt[] expirationSettings = getExpirationSettings('MB_CRF');
        if (expirationSettings.size() > 0) {
            envelope.notification = notiSettings.addExpirationSettings('true', expirationSettings[0].Expire_After__c, expirationSettings[0].Expire_Warn__c);
        } else {
            system.debug('EnvelopeSendController: No expiration setting found');
        }
        // Put the request body into multiform (https://developers.docusign.com/esign-rest-api/guides/requests-and-responses)
        multiformRequest = DocusignUtility.multiform(BOUNDARY_START, BOUNDARY_END, JSON.serialize(envelope), MFD);

        Http http = new Http();
        HttpRequest request = DocusignUtility.prepareEnvelopeRequest(ACCOUNT_ID, ACCESS_TOKEN, BOUNDARY, multiformRequest, baseURI);
        system.debug(request.getBody());
        logTime('BEFORE SENDING DOCUSIGN');
        HttpResponse response = http.send(request);
        logTime('AFTER SENDING DOCUSIGN');
        System.debug('Docusign envelope create response: ' + response.getBody());

        return response;
    }
    /* -------- ADDED BY THIEU DANG VU - May 6th Nov 2021 -- END --------*/

    /* -------- ADDED BY THIEU DANG VU - June 3rd Nov 2021 -- START --------*/
    private static HttpResponse docusignSAUCA(ID recordID, Boolean signViaEmail, String documentType) 
    {
        logTime('START');
        MB_Sales_Agreement__c SA;                                                                               // Target MB Sales Agreement
        User Owner;                                                                                             // Owner of [SA]
        final String SG_UNIQUE_IDENTIFIER;                                                                      // Unique identifier of [Owner]'s profile
        Signing_Group__c SG;                                                                                    // Signing_Group__c record
        List<DocuSign_Recipient_Configuration__mdt> recipientConfigurations;                                    // List of recipient configuration metadata
        final Schema.SObjectType SG_OBJECT_TOKEN = getObjectToken('Signing_Group__c');                          // Signing_Group__c token
        final Schema.SObjectType RC_OBJECT_TOKEN = getObjectToken('DocuSign_Recipient_Configuration__mdt');     // DocuSign_Recipient_Configuration__mdt token
        List<DocusignDocument> documents = new List<DocusignDocument>();                                        // Docusign object for documents
        List<DocusignSignerDetail> recipientDetails = new List<DocusignSignerDetail>{};                         // Docusign object for recipient details
        DocusignSigners recipients;                                                                             // Docusign object for coleection of recipients
        List<String> MFD = new List<String>();                                                                  // Document content in multiform
        String signedDocumentName;                                                                              // Name of the signed sales agreement
        String documentExt;                                                                                     // Extension type of document
        String documentID;                                                                                      // ID of document
        String emailSubject;                                                                                    // Signing email subject
        String multiformRequest;                                                                                // The request body in multiform
        String docVersion;                                                                                      // Version of DSA 

        SA = (MB_Sales_Agreement__c) getRecords(recordID, null)[0];
        Owner = [SELECT UserRole.Name, Name FROM USER WHERE ID = :SA.OwnerId];
        List<sObject> signingGroups = getRecords(SG_OBJECT_TOKEN, 'Unique_Identifier__c = ' + '\'' + getTeamIdentifier(Owner.UserRole.Name) + '\'', null, null, true);
        if (signingGroups.size() == 0) throw new AuraHandledException('The owner of this record have no valid role.');
        else SG = (Signing_Group__c)signingGroups[0];

        validation(SA);
        configuration(SA.OwnerId);                                                                              // get configuration tokens

        if (!signViaEmail) {
            recipientConfigurations = (List<DocuSign_Recipient_Configuration__mdt>) getRecords(RC_OBJECT_TOKEN, 'Signing_Scenario__c = \'K\' AND Active__c = true', 'Signing_Order__c', 'ASC', false);
        } else {
            recipientConfigurations = (List<DocuSign_Recipient_Configuration__mdt>) getRecords(RC_OBJECT_TOKEN, 'Signing_Scenario__c = \'L\' AND Active__c = true', 'Signing_Order__c', 'ASC', false);
        }

        // get envelope documents
        docVersion = SA.Sales_and_UCA_Version__c != null? 'v.' + String.valueOf(SA.Sales_and_UCA_Version__c) : '';
        logTime('BEFORE GENERATE DOCUMENT');
        DocuSignTemplate__mdt template = getTemplateId('MB_SA_UCA_Template');
        List<Attachment> wmResults = webm.WebmergeGenerator.generateDocumentGetAttachments(template.DocuSign_Template_Id__c, recordID, 'MB_Sales_Agreement__c');
        logTime('AFTER GENERATE DOCUMENT');
        if (!Test.isRunningTest()) {
            for (Attachment file : wmResults) {
                documentCounter++;
                documentID = String.valueOf(documentCounter);
                signedDocumentName = SA.Name + '_Sales & Used Car Agreement ' + docVersion + ' ' + Datetime.now().format('dd/MM/yyyy');
                documents.add(new DocusignDocument(signedDocumentName, 'pdf', documentID));                                     // document declare
                MFD.add(DocusignUtility.getMFD(file.Body, 'pdf', signedDocumentName, documentID, BOUNDARY_START));              // document content in multiform
            }
        } else {
            Attachment attach = new Attachment();   	
            attach.Name = 'MB Sales & Used Car Agreement -'+ SA.Name; 
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = SA.Id;
            documentID = '1';
            signedDocumentName = attach.Name;
            documents.add(new DocusignDocument(signedDocumentName, 'docx', documentID));
            MFD.add(DocusignUtility.getMFD(attach.Body, 'docx', signedDocumentName, documentID, BOUNDARY_START));
        }

        // get document recipients
        DocusignSignerDetail customer;
        for (DocuSign_Recipient_Configuration__mdt rc : recipientConfigurations)
        {
            recipientCounter++;
            String recipientType = DocusignUtility.getRecipientType(rc);
            switch on recipientType {
                when 'CUSTOMER' 
                {
                    customer = customer(rc, SA, SG, documentType);
                    recipientDetails.add(customer);
                }
                when 'CC_ENDORSER' 
                {
                    recipientDetails.add(ccEndorser(rc, SA, SG, documentType));
                }
                when 'APPROVER' 
                {
                    recipientDetails.add(approver(rc, SA, SG, documentType));
                }
                when else {
                    throw new AuraHandledException('Invalid recipient type: ' + recipientType);
                }
            }

            if (rc.Signing_Method__c == 'Direct') 
            {
                directSignerID = String.valueOf(recipientCounter);
                directSignerName = SA.Customer_Full_Name__c;
                directSignerEmail = SA.CEmail_Address__c;
            }
        }
        recipients = new DocusignSigners(recipientDetails);
        emailSubject = ('Sales & Used Car Agreement ' + docVersion + ' for Sales Agreement No. ' + SA.Name + ' '  + ' by ' + Owner.Name).left(100);                  // 100 characters limit
        DocusignEnvelope envelope = new DocusignEnvelope('sent', emailSubject, recipients, documents);
        envelope.emailBlurb = 'Dear all,' + '\n' +'\n' + 'Please help sign / review this Sales & Used Car Agreement. See the private message of this email for more detail.' + '\n' +'\n' + 'Thank you, ' + Owner.Name + '.';
        envelope.customFields.addRecordAutoNumber(SA.Name);
        envelope.brandId = getBrandID('MB_SA_UCA_Template');
        // MB CR - 25/10/2021 - Not apply Envelope's expiration for corporate purchases - NOT DEPLOY YET
        // if (SA.Registration_Type__c == 'P') {
        DocuSignNotificationSettings notiSettings = new DocuSignNotificationSettings();
        notiSettings.useAccountDefaults = 'false';
        DocuSign_Expiration_Configuration__mdt[] expirationSettings = getExpirationSettings('MB_SAUCA');
        if (expirationSettings.size() > 0) {
            envelope.notification = notiSettings.addExpirationSettings('true', expirationSettings[0].Expire_After__c, expirationSettings[0].Expire_Warn__c);
        } else {
            system.debug('EnvelopeSendController: No expiration setting found');
        }        
        // }

        // put the request body into multiform (https://developers.docusign.com/esign-rest-api/guides/requests-and-responses)
        multiformRequest = DocusignUtility.multiform(BOUNDARY_START, BOUNDARY_END, JSON.serialize(envelope), MFD);

        Http http = new Http();
        HttpRequest request = DocusignUtility.prepareEnvelopeRequest(ACCOUNT_ID, ACCESS_TOKEN, BOUNDARY, multiformRequest, baseURI);
        system.debug(request.getBody());
        logTime('BEFORE SENDING DOCUSIGN');
        HttpResponse response = http.send(request);
        logTime('AFTER SENDING DOCUSIGN');
        System.debug('Docusign envelope create response: ' + response.getBody());
        return response;
    }
    /* -------- ADDED BY THIEU DANG VU - June 3rd Nov 2021 -- END --------*/

    private static List<SObject> getRecords(Schema.SObjectType objectToken, String conditions, String orderBy, String orderVector, Boolean onlyOne) 
    {

        Map<String, Schema.SObjectField> fieldTokens = objectToken.getDescribe().fields.getMap();
        
        ADGLIB_QueryFactory qFactory = new ADGLIB_QueryFactory(objectToken);
        qFactory.selectFields(fieldTokens.values());    
        /** ADDED BY TPHAN - 10/01/2022 */    
        /*if (String.valueOf(objectToken) == 'MB_Sales_Agreement__c')
        {
            qFactory.selectFields(new Set<String>{'Account__r.IsPersonAccount'});
        }*/
        /** END */
        qFactory.setCondition(conditions);
        if (orderBy != null && String.isNotBlank(orderBy) && orderVector != null && String.isNotBlank(orderVector)) {
            if (orderVector == 'ASC') {
                qFactory.setOrdering(orderBy, ADGLIB_QueryFactory.SortOrder.ASCENDING, true);
            }
            if (orderVector == 'DESC') {
                qFactory.setOrdering(orderBy, ADGLIB_QueryFactory.SortOrder.DESCENDING, true);
            }
            
        }
        if (onlyOne) qFactory.setLimit(1);
        List<SObject> records = Database.query(qFactory.toSOQL());

        return records;
    }

    @testVisible
    private static String getTeamIdentifier(String userRole) 
    {
        if (String.isBlank(userRole)) throw new AuraHandledException('The owner of this record have no role.');

        String SG_UNIQUE_IDENTIFIER = 'MB_Team_' + userRole.right(1);

        return SG_UNIQUE_IDENTIFIER;
    }

    private static Schema.SObjectType getObjectToken(String Name) 
    {
        return Schema.getGlobalDescribe().get(Name);
    }

    /**
     * get necessary configurations for docusign
     */
    private static void configuration(String recordOwnerID)
    {
        List<DocuSignCredential__mdt> configurations = (List<DocuSignCredential__mdt>) [SELECT AccountNumber__c, Multiform_Boundary__c FROM DocuSignCredential__mdt WHERE Active__c = true];
        if (configurations.size() == 1) {
            ACCOUNT_ID = configurations[0].AccountNumber__c;
            BOUNDARY = configurations[0].Multiform_Boundary__c;
            BOUNDARY_START = '--' + BOUNDARY;
            BOUNDARY_END = BOUNDARY_START + '--';
        } else {
            throw new AuraHandledException('Docusign credentials not exist or non-unique');
        }

        if (!Test.isRunningTest()) {
            ACCESS_TOKEN = DocusignJWT.accessTokenResponseProcess(DocusignJWT.getAccessToken(recordOwnerID));
            if (ACCESS_TOKEN == null || String.isBlank(ACCESS_TOKEN)) {
                throw new AuraHandledException('Error on docusign configurating: Can not get access token');
            }
        }

        baseURI = DocusignUtility.getBaseURI(ACCESS_TOKEN);
        System.debug('ACCOUNT_ID :: ' + ACCOUNT_ID);
        System.debug('BOUNDARY :: ' + BOUNDARY);
        System.debug('ACCESS_TOKEN :: ' + ACCESS_TOKEN);
        System.debug('baseURI :: ' + baseURI);
    }

    /**
     * get docusign signer detail object for customer
     */
    private static DocusignSignerDetail customer(DocuSign_Recipient_Configuration__mdt rc, MB_Sales_Agreement__c SA, Signing_Group__c SG, String documentType)
    {
        DocusignSignerDetail customer = new DocusignSignerDetail();
        customer.name = SA.Customer_Full_Name__c;
        customer.email = SA.CEmail_Address__c;
        customer.recipientId = String.valueOf(recipientCounter);
        if (rc.Signing_Method__c == 'Direct') customer.clientUserId = customer.recipientId;
        customer.routingOrder = rc.Signing_Order__c;
        customer.note = noteToCustomer(SA.Registration_Type__c, customer.name, documentType, SA.Validity_Date__c);
        customer.roleName = rc.Recipient_Type__c + ' ' + rc.Signing_Order__c;
        customer.recipientType = rc.Recipient_Type__c;
        customer.accessCode = SA.CNRIC_Number__c.toUpperCase().right(4).rightPad(4, '*');
        customer.addSignHereTab_MB(rc);

        return customer;
    }

    /**
     * get docusign signer detail object for third party
     */
    private static DocusignSignerDetail thirdParty(DocuSign_Recipient_Configuration__mdt rc, MB_Sales_Agreement__c SA, Signing_Group__c SG, String documentType) {
        DocusignSignerDetail thirdParty = new DocusignSignerDetail();
        thirdParty.name = SA.Seller_Registered_Name__c;
        thirdParty.email = SA.Seller_Email__c;
        thirdParty.recipientId = String.valueOf(recipientCounter);
        if (rc.Signing_Method__c == 'Direct') thirdParty.clientUserId = thirdParty.recipientId;
        thirdParty.routingOrder = rc.Signing_Order__c;
        thirdParty.note = noteToCustomer(SA.Registration_Type__c, thirdParty.name, documentType, SA.Validity_Date__c);
        thirdParty.roleName = rc.Recipient_Type__c + ' ' + rc.Signing_Order__c;
        thirdParty.recipientType = rc.Recipient_Type__c;
        thirdParty.accessCode = SA.Seller_NRIC__c.toUpperCase().right(4).rightPad(4, '*');
        thirdParty.addSignHereTab_MB(rc);

        return thirdParty;
    }

    /**
     * get docusign signer detail object for ccEndorser
     */
    private static DocusignSignerDetail ccEndorser(DocuSign_Recipient_Configuration__mdt rc, MB_Sales_Agreement__c SA, Signing_Group__c SG, String documentType)
    {
        String docType;
        switch on documentType {
            when 'SA' {
                docType = 'This is the carbon copy of Sales Agreement No. ';
            }
            when 'UCA' {
                docType = 'This is the carbon copy of Used Car Purchase Agreement for Sales Agreement No. ';
            }
            when 'SAUCA' {
                docType = 'This is the carbon copy of Sales & Used Car Purchase Agreement for Sales Agreement No. ';
            }
            when 'CRF' {
                docType = 'This is the carbon copy of Change Request Form for Sales Agreement No. ';
            }
        }
        DocusignSignerDetail ccEndorser = new DocusignSignerDetail();
        ccEndorser.signingGroupId = SG.Endorse_Group_ID__c;
        ccEndorser.signingGroupName = SG.Endorse_Group_Name__c;
        ccEndorser.recipientId = String.valueOf(recipientCounter);
        ccEndorser.routingOrder = rc.Signing_Order__c;
        ccEndorser.note = docType + SA.Name;
        ccEndorser.roleName = rc.Recipient_Type__c + ' ' + rc.Signing_Order__c;
        ccEndorser.recipientType = rc.Recipient_Type__c;

        return ccEndorser;
    }

    /**
     * get docusign signer detail object for approver
     */
    private static DocusignSignerDetail approver(DocuSign_Recipient_Configuration__mdt rc, MB_Sales_Agreement__c SA, Signing_Group__c SG, String documentType)
    {
        String docType;
        switch on documentType {
            when 'SA' {
                docType = 'Sales Agreement No. ';
            }
            when 'UCA' {
                docType = 'Used Car Purchase Agreement for Sales Agreement No. ';
            }
            when 'CRF' {
                docType = 'Change Request Form for Sales Agreement No. ';
            }
            when 'SAUCA' {
                docType = 'Sales & Used Car Agreement No. ';
            }
        }
        DocusignSignerDetail approver = new DocusignSignerDetail();
        approver.signingGroupId = SG.Approve_Group_ID__c;
        approver.signingGroupName = SG.Approve_Group_Name__c;
        approver.recipientId = String.valueOf(recipientCounter);
        approver.routingOrder = rc.Signing_Order__c;
        approver.note = docType + SA.Name + ' is pending for your endorsement.' + (!documentType.equals('CRF') ? ('\nGMS value: $ ' + (SA.GMS_Value__c == null ? '0.00' : String.valueOf(SA.GMS_Value__c))) : '');
        approver.roleName = rc.Recipient_Type__c + ' ' + rc.Signing_Order__c;
        approver.recipientType = rc.Recipient_Type__c;
        approver.addSignHereTab_MB(rc);
 
        return approver;
    }

    private static String noteToCustomer(String registrationType, String recipientFullName, String documentType, Date validityDate) 
    {
        switch on registrationType {
            when 'P' {
                return noteToIndividual(recipientFullName, documentType, validityDate);
            }
            when 'C' {
                return noteToIndividual(recipientFullName, documentType, validityDate);
            }
            when else {
                return 'Please sign this as ' + recipientFullName;
            }
        }
    }

    private static String noteToIndividual(String recipientFullName, String documentType, Date validityDate)
    {
        String docType;
        switch on documentType {
            when 'SA' {
                docType = 'Sales Agreement';
            }
            when 'UCA' {
                docType = 'Used Car Purchase Agreement';
            }
            when 'CRF' {
                docType = 'Change Request Form';
            }
            when 'SAUCA' {
                docType = 'Sales & Used Car Agreement';
            }
        }
        String note =   'Hi ' + recipientFullName + ',' + '\n\n' +
                        'We require your signature on this ' + docType + '. Enter the following password for access:' + '\n\n' +
                        '[Last 4 characters of your NRIC] example: 123A' + '\n\n' + 
                        'You have 3 attemps to enter the correct password. Should the agreement get locked, please contact your Sales Consultant. Thank you.' + '\n\n' +
                        'This Sales Agreement is only valid if signed before ' + validityDate.format();
        return note;
    }

    private static List<ID> getdocumentIDs(List<ContentDocumentLink> records)
    {
        List<ID> result = new List<ID>();
        for (ContentDocumentLink rec : records) result.add(rec.ContentDocumentId);
 
        return result;
    }

    /**
     * get signing link in case sign in-place
     */
    private static String getSignLink(HttpResponse response) 
    {
        DocusignEnvelope envelope = (DocusignEnvelope) JSON.deserialize(response.getBody(), DocusignEnvelope.class);

        return DocusignUtility.getSignLink(ACCOUNT_ID, ACCESS_TOKEN, envelope.envelopeID, baseURI, directSignerName, directSignerEmail, directSignerID, directSignerID);
    }

    /**
     * update the envelope create response into sales agreement record
     */
    private static void updateEnvelopeResult(ID recordID, HttpResponse response, String docType)
    {
        system.debug('response:: ' + response.getBody());
        DocusignEnvelope envelope = (DocusignEnvelope) JSON.deserialize(response.getBody(), DocusignEnvelope.class);
        system.debug('response::' + envelope);
        MB_Sales_Agreement__c SA = (MB_Sales_Agreement__c) getRecords(recordID, null)[0];

        /* -------- MODIFIED BY THIEU DANG VU - Wed 4th Nov 2020 -- START --------*/
        switch on docType {
            when 'SA' {
                SA.Latest_Docusign_Envelope__c = envelope.envelopeID.toUpperCase();
                SA.Sales_Agreement_Version__c++;
                SA.Newly_Added_SA_Spec__c = null;
                SA.Removed_SA_Spec__c = null;

                if (SA.Status__c == 'Draft') SA.Status__c = 'Waiting for Confirmation';
            }
            when 'UCA' {
                SA.Latest_UCA_Docusign_Envelope__c = envelope.envelopeID.toUpperCase();
                SA.UCA_Version__c++;
            }

            /** ADDED BY THIEU DANG VU - May 6th 2021 - Add version for Change Request Form - START */
            when 'CRF' {
                SA.Latest_YF_Docusign_Envelope__c = envelope.envelopeID.toUpperCase();
                SA.Yellow_Form_Version__c++;
                SA.Lock_SA_Generated__c = true;
            }
            /** ADDED BY THIEU DANG VU - May 6th 2021 - Add version for Change Request Form - END */

            /** ADDED BY THIEU DANG VU - June 3rd 2021 - Add version for Sales & Used Car Form - START */
            when 'SAUCA' {
                SA.Latest_SA_UCA_Docusign_Envelope__c = envelope.envelopeID.toUpperCase();
                SA.Sales_and_UCA_Version__c++;
                SA.Newly_Added_SA_Spec__c = null;
                SA.Removed_SA_Spec__c = null;

                if (SA.Status__c == 'Draft') SA.Status__c = 'Waiting for Confirmation';
            }
            /** ADDED BY THIEU DANG VU - June 3rd 2021 - Add version for Sales & Used Car Form  - END */

            when else {
                // DO NOTHING
            }
        }

        /* -------- MODIFIED BY THIEU DANG VU - Wed 4th Nov 2020 -- START --------*/
        update SA;
    }

    /**
     * Validate necessary fields for docusign launching
     */
    private static void validation(MB_Sales_Agreement__c SA)
    {
        // MB CR - 26/10/2021 - Not allow to generate Docusign if SA is Cancelled - NOT DEPLOY  YET
        // if (SA.Status__c == 'Cancelled') throw new AuraHandledException('Sales Agreement has been cancelled. You are not allowed to proceed!');

        if (isNull(SA.CEmail_Address__c)) throw new AuraHandledException('Customer\'s email is blank.');
        if (isNull(SA.Customer_Full_Name__c)) throw new AuraHandledException('Customer\'s full name is blank.');
        if (isNull(SA.Registration_Type__c)) throw new AuraHandledException('Registration type is blank.');
 
        if (SA.Registration_Type__c == 'P' && isNull(SA.CNRIC_Number__c)) throw new AuraHandledException('Customer\'s NRIC is blank.');
        if (SA.Registration_Type__c == 'C' && isNull(SA.ARCA_Number__c)) throw new AuraHandledException('ARCA number is blank.');

        if ((documentType == 'SA' || documentType == 'SAUCA') && !SA.Deposit_Collected__c) throw new AuraHandledException('Deposit not collected.');

        if (documentType == 'UCA') checkUCACompulsoryFields(SA);
 
        // Added by Thieu Dang Vu - May 10th 2021 - Add validation for Change Request Form
        if (documentType == 'CRF') validateCRF(SA);
    }

    /**
     * Check compulsory fields for UCA
     */
    private static void checkUCACompulsoryFields(MB_Sales_Agreement__c SA)
    {
        if (String.isBlank(SA.Used_Car_Registration_Number__c)) throw new AuraHandledException('You are not allowed to generate Used Car Purchase Agreement.');
        if (isNull(SA.Trade_In_Value__c)) throw new AuraHandledException('Used car trade-in value is blank.');
    }

    /* -------- ADDED BY THIEU DANG VU - May 10th 2021 -- START --------*/
    /**
     * Validate Change Request Form
     */
    private static void validateCRF(MB_Sales_Agreement__c SA) {
        if (SA.Sales_Agreement_Version__c == 1 && SA.Sales_and_UCA_Version__c == 1) throw new AuraHandledException('Please generate Sales Agreement first.');
        if (String.isBlank(SA.Newly_Added_SA_Spec__c) && String.isBlank(SA.Removed_SA_Spec__c)) throw new AuraHandledException('No new addition and deletion specs found.');
    }
    /* -------- ADDED BY THIEU DANG VU - May 10th 2021 -- END --------*/

    private static DocuSignTemplate__mdt getTemplateId(String templateLabel) {
        DocuSignTemplate__mdt DSTemplte = [SELECT DocuSign_Template_Id__c, Used_Car_Agreement_Template__c FROM DocuSignTemplate__mdt WHERE DeveloperName = :templateLabel LIMIT 1];
        return DSTemplte;
    }

    /* -------- ADDED BY THIEU DANG VU - Thu 26th Nov 2020 -- START --------*/
    /**
     * Get expiration settings from Metadata
     */
    private static DocuSign_Expiration_Configuration__mdt[] getExpirationSettings(String identifier) {
        DocuSign_Expiration_Configuration__mdt[] expirationSettings = (List<DocuSign_Expiration_Configuration__mdt>) [SELECT Active__c, Expire_After__c, Expire_Warn__c, Identifier__c
                                                                                                                      FROM DocuSign_Expiration_Configuration__mdt
                                                                                                                      WHERE Active__c = true AND Identifier__c = :identifier
                                                                                                                      LIMIT 1];
        system.debug(expirationSettings);
        return expirationSettings;
    }

    /**
     -- Get Docusign brand ID from metadata
     */
    private static string getBrandID(String templateNm) {
        DocuSignTemplate__mdt DSTemplte = [SELECT DocuSign_Brand_ID__c FROM DocuSignTemplate__mdt WHERE DeveloperName = :templateNm LIMIT 1];

        return DSTemplte.DocuSign_Brand_ID__c;
    }
    /* -------- ADDED BY THIEU DANG VU - Thu 26th Nov 2020 -- END --------*/

    private static Boolean isNull(object o)
    {
        return o == null;
    }

    private static void throwError(String message)
    {
        AuraHandledException error = new AuraHandledException(message);
        error.setMessage(message);
        throw error;
    }

    private static void logTime(String tag)
    {
        System.debug('[TIME] ' + tag + ' :: ' + DateTime.now());
    }

    /** ADDED BY TPHAN ON 26/07/2021 - PA MERGING */
    @AuraEnabled
    public static void updateRelatedPA(Id recordId)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Account.SObjectType});

        try 
        {
            MB_Sales_Agreement__c sA = (MB_Sales_Agreement__c) getRecords(recordId, null)[0];

            String addLine4 = String.isNotBlank(sA.Postal_CodeRA__c) ? 'Singapore ' + sA.Postal_CodeRA__c : '';

            AccountUtil.PAWrapper pAWrapper = new AccountUtil.PAWrapper(sA.CSalutation__c, sA.CFirst_Name__c, sA.CSurname__c, sA.Customer_Full_Name__c, sA.CNRIC_Number__c, sA.CMobile__c, sA.CDate_of_Birth__c,
                                                                        sA.Street_NameRA__c, sA.Floor_UnitRA__c, sA.Building_NameRA__c, addLine4, null, 'Singapore', 
                                                                        sA.AcknowledgementConsentClause__c, null, 'Customer', null, null, 'DWH');

            AccountUtil.updatePA(paWrapper, sA.Account__c);
        }
        catch (Exception e)
        {
            System.debug('Update PA From Docusign Button: ' + e.getMessage());
            loggerDataPool.buildLogDataPool('MBUpdatePA', e);
        }
    }
    /** ADDED BY TPHAN ON 26/07/2021 - PA MERGING */
}
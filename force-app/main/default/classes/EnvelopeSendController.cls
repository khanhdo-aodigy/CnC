public with sharing class EnvelopeSendController {
    public class docusignException extends Exception {}
    @testVisible static string ACCOUNT_ID;
    @testVisible static string BOUNDARY;
    @testVisible static string BOUNDARY_START;
    @testVisible static string BOUNDARY_END;
    @testVisible static string STATE_FOR_TEST = '';

    /**
     -- query Docusign credentials
     */
    static {
        system.debug('---------- Static initialize begin ----------');
        list<DocuSignCredential__mdt> docusignCredentials = (List<DocuSignCredential__mdt>) [SELECT AccountNumber__c, Multiform_Boundary__c FROM DocuSignCredential__mdt WHERE Active__c = true];
        if (docusignCredentials.size() == 1) {
            DocuSignCredential__mdt docusignCredential = docusignCredentials[0];
            ACCOUNT_ID = docusignCredential.AccountNumber__c;
            BOUNDARY = docusignCredential.Multiform_Boundary__c;
            BOUNDARY_START = '--' + BOUNDARY;
            BOUNDARY_END = BOUNDARY_START + '--';
            system.debug(docusignCredentials);
        } else throw new AuraHandledException('Docusign Credential getting failed.');
        system.debug('---------- Static initialize end ----------');
    }

    /**
    -- Create envelope for Sales Agreement
    -- (https://developers.docusign.com/esign-rest-api/guides/requests-and-responses).
    **/
    @AuraEnabled(continuation = true cacheable = true)
    public static object signingProcess(ID mySAId, Boolean signViaEmail) {
        system.debug('---------- Signing Process begin ----------');
        system.debug(datetime.now());

        // get sales agreement
        Sales_Agreement__c salesAgreement = getSalesAgreementById(mySAId);

        // get signing groups
        if (salesAgreement.Branch_Code__c == null) throw new AuraHandledException('Error in getting signing group -- Invalid branch code: [' + salesAgreement.Branch_Code__c + ']');
        /* -------- MODIFIED BY THIEU DANG VU - Thu 28th Jan 2021 -- START --------*/
        // Change logic get signing groups by User Role
        User owner = [SELECT UserRole.Name, UserRole.DeveloperName, Name, LastName FROM USER WHERE ID = :salesAgreement.OwnerId];
        system.debug('owner::  ' + owner);
        List<Signing_Group__c> signingGroups = getSigningGroupByUserRole(owner.UserRole.DeveloperName);
        /* -------- MODIFIED BY THIEU DANG VU - Thu 28th Jan 2021 -- END --------*/
        // list<Signing_Group__c> signingGroups = getSigningGroupsByBranchCode(salesAgreement.Branch_Code__c);
        string endorserID = signingGroups[0].Endorse_Group_ID__c;
        string endorserName = signingGroups[0].Endorse_Group_Name__c;
        string approverID = signingGroups[0].Approve_Group_ID__c;
        string approverName = signingGroups[0].Approve_Group_Name__c;

        // put signing group info to map for later reference
        Map<string, Map<string, string>> signingGroupsInfo = new Map<string, map<string, string>>{};
        signingGroupsInfo.put('Endorser', new Map<string, string> {'ID' => endorserID, 'Name' => endorserName});
        signingGroupsInfo.put('Approver', new Map<string, string> {'ID' => approverID, 'Name' => approverName});

        // get recipient configurations
        list<DocuSign_Recipient_Configuration__mdt> recipientConfigurations = new list<DocuSign_Recipient_Configuration__mdt>();
        if (!signViaEmail) recipientConfigurations = getRecipientConfiguration('A'); // sign in-place
        if (signViaEmail) recipientConfigurations = getRecipientConfiguration('B'); // sign via email

        // get newly created DSA's content document
        // @depreciated by Webmerge
        string documentNamePattern = 'Digital Sales Agreement%_' + salesAgreement.Name + '_%';
        list<ContentDocumentLink> contentDocuments = getDocumentsByIdAndName(salesAgreement.ID, documentNamePattern);
        
        // get binary content of DSA
        // @depreciated by Webmerge
        list<ContentVersion> contentVersions = new list<ContentVersion>{};
        contentVersions.addAll(getContentVersionByDocumentId(contentDocuments[0].ContentDocumentId)); // for now, expect only 1 document per envelope

        /**
         -- build recipient detail objects
         -- for now the signing process accept only first signer to be embedded signer (if sign in-place)
         -- if this configuration change in the future then this block of code need modification
         * */ 
        string embeddedSignerOrder = '';
        list<DocusignSignerDetail> recipientDetails = new list<DocusignSignerDetail>{};
        for (DocuSign_Recipient_Configuration__mdt configuration : recipientConfigurations) {
            // recipient detail object
            recipientDetails.add(DocusignSignerDetail.build(configuration, signingGroupsInfo, salesAgreement));
            // store recipient ID of embedded signer
            if (configuration.Signing_Method__c == 'Direct') embeddedSignerOrder = configuration.Signing_Order__c;
        }

        // build recipients collection object
        DocusignSigners recipients = new DocusignSigners(recipientDetails);
        
        /**
         -- build document object
         -- change the return file name for DSA
         */
        integer currentVersion = salesAgreement.DSA_Version__c ==  null? 1 : (integer) salesAgreement.DSA_Version__c;
        list<DocusignDocument> documents = new list<DocusignDocument>{}; // documents configuration
        list<string> documentContents = new list<string>{}; // documents binary content
        integer documentIdIndex = 1;
        // @ webmerge route
        // string documentNamePattern = 'Digital Sales Agreement_%' + salesAgreement.Name + '%';
        // list<Attachment> cvs = [SELECT ID, Body FROM Attachment WHERE Name LIKE :documentNamePattern AND ParentId = :mySAId];
        // documents.add(new DocusignDocument('TEST', 'pdf', '1'));
        // documentContents.add(documentContentMultiform_2(cvs[0].Body, 'pdf', 'TEST', '1'));
        
        // @depreciated by Webmerge
        for (ContentVersion cv : contentVersions) {
            string name = cv.Title.contains(salesAgreement.Name) ? salesAgreement.SOH_SONO__c + '_Sales Agreement_' + Datetime.now().format('dd/MM/yyyy') + '_v' + string.valueOf(currentVersion) : cv.Title;
            documents.add(new DocusignDocument(name, cv.FileExtension, string.valueOf(documentIdIndex)));
            documentContents.add(documentContentMultiform(cv, cv.FileExtension, name, string.valueOf(documentIdIndex))); 
            documentIdIndex++;
        }

        // build enevelope object
        string emailSubject = 'Sales Agreement ' + salesAgreement.SOH_SONO__c + '_v' + string.valueOf(currentVersion) + ' by ' + salesAgreement.Owner.Name;
        emailSubject = emailSubject.left(100); // cap at 100 characters for safe
        DocusignEnvelope envelopeObj = new DocusignEnvelope('sent', emailSubject, recipients, documents);
        envelopeObj.emailBlurb = 'Dear all,' +'\n' +'\n' + 'Please help sign / review this Sales Agreement. See the private message of this email for more detail.' + '\n' +'\n' + 'Thank you, ' + salesAgreement.Owner.Name + '.';
        envelopeObj.brandId = EnvelopeSendController.getBrandID(salesAgreement.Branch_Code__c, salesAgreement.DS_Model__c);
        
        // populate record number to envelope custom field
        envelopeObj.customFields.addRecordAutoNumber(salesAgreement.Name);
        
        // assign reminder settings
        // DocuSign_Reminder_Configuration__mdt[] reminderSettings = EnvelopeSendController.getReminderSettings();
        // if (reminderSettings.size() > 0) {
        //     envelopeObj.notification = new DocuSignNotificationSettings('true', reminderSettings[0].Reminder_Delay__c, reminderSettings[0].Reminder_Frequency__c);
        // } else system.debug('EnvelopeSendController: No reminder setting found');

        /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 -- START --------*/
        DocuSignNotificationSettings notiSettings = new DocuSignNotificationSettings();
        notiSettings.useAccountDefaults = 'false';
        // Assign Expiration Settings
        DocuSign_Expiration_Configuration__mdt[] expirationSettings = EnvelopeSendController.getExpirationSettings();
        if (expirationSettings.size() > 0) {
            envelopeObj.notification = notiSettings.addExpirationSettings('true', expirationSettings[0].Expire_After__c	, expirationSettings[0].Expire_Warn__c);
        } else {
            system.debug('EnvelopeSendController: No expiration setting found');
        }
        // Assign Reminder Settings
        DocuSign_Reminder_Configuration__mdt[] reminderSettings = EnvelopeSendController.getReminderSettings();
        if (reminderSettings.size() > 0) {
            envelopeObj.notification = notiSettings.addReminderSettings('true', reminderSettings[0].Reminder_Delay__c, reminderSettings[0].Reminder_Frequency__c);
        } else {
            system.debug('EnvelopeSendController: No reminder setting found');
        }
        system.debug('NOTIFICATION JSON:: ' + JSON.serialize(envelopeObj.notification));
        /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 -- END --------*/

        // serrialize envelope object to JSON
        string body = JSON.serialize(envelopeObj);

        // put JSON body into multiform (https://developers.docusign.com/esign-rest-api/guides/requests-and-responses)
        body = multiFormStarting(BOUNDARY_START, body);
        if (documentContents.size() > 0) {
            for (integer i = 0; i < documentContents.size(); i++) {
                body = body + documentContents[i];
            }
        }
        body = body + '\n' + BOUNDARY_END;
        

        // send envelope create request
        string ACCESS_TOKEN = '';
        if (!Test.isRunningTest()) {
            ACCESS_TOKEN = DocusignJWT.accessTokenResponseProcess(DocusignJWT.getAccessToken(salesAgreement.OwnerId));
            if (string.isBlank(ACCESS_TOKEN)) throw new AuraHandledException('Error on sending envelope -- Can not get access token');
        }
        
        Continuation con = new Continuation(120);
        HttpRequest request = CalloutUtils.envelopeCreateRequest(ACCOUNT_ID, ACCESS_TOKEN, BOUNDARY, body);
        con.ContinuationMethod = Test.isRunningTest()? 'processResponse_ForTest' : 'processResponse';
        
        if (!Test.isRunningTest()) {
            string recipientFullName = string.isEmpty(salesAgreement.Customer_Full_Name__c) ? salesAgreement.Company_Name__c : salesAgreement.Customer_Full_Name__c;
            //@depreciated by Webmerge
            con.state = new StateInfo(salesAgreement.ID, contentDocuments[0].ContentDocumentId, embeddedSignerOrder, recipientFullName, salesAgreement.emailaddress__c, signViaEmail, currentVersion + 1, 'SA');
            // con.state = new StateInfo(salesAgreement.ID, null, embeddedSignerOrder, recipientFullName, salesAgreement.emailaddress__c, signViaEmail, currentVersion + 1, 'SA');
            con.addHttpRequest(request);
        } else STATE_FOR_TEST = signViaEmail? 'SA.true' : 'SA.false';
        
        system.debug(con);
        system.debug('---------- Signing Process end ----------');
        system.debug(datetime.now());
        return con;
    }

    /**
     -- Webmerge POC - DONT DEPLOY
     */
    /*@AuraEnabled(continuation = true cacheable = true)
    public static object signingProcess_WM(ID mySAId, Boolean signViaEmail) {
        system.debug('---------- Signing Process begin ----------');
        system.debug(Datetime.now());
        
        // get sales agreement
        Sales_Agreement__c salesAgreement = getSalesAgreementById(mySAId);

        // get signing groups
        if (salesAgreement.Branch_Code__c == null) throw new AuraHandledException('Error in getting signing group -- Invalid branch code: [' + salesAgreement.Branch_Code__c + ']');
        // list<Signing_Group__c> signingGroups = getSigningGroupsByBranchCode(salesAgreement.Branch_Code__c);
        list<Signing_Group__c> signingGroups = getSigningGroupByUserRole(salesAgreement.Branch_Code__c);
        string endorserID = signingGroups[0].Endorse_Group_ID__c;
        string endorserName = signingGroups[0].Endorse_Group_Name__c;
        string approverID = signingGroups[0].Approve_Group_ID__c;
        string approverName = signingGroups[0].Approve_Group_Name__c;

        // put signing group info to map for later reference
        Map<string, Map<string, string>> signingGroupsInfo = new Map<string, map<string, string>>{};
        signingGroupsInfo.put('Endorser', new Map<string, string> {'ID' => endorserID, 'Name' => endorserName});
        signingGroupsInfo.put('Approver', new Map<string, string> {'ID' => approverID, 'Name' => approverName});

        // get recipient configurations
        list<DocuSign_Recipient_Configuration__mdt> recipientConfigurations = new list<DocuSign_Recipient_Configuration__mdt>();
        if (!signViaEmail) recipientConfigurations = getRecipientConfiguration('A'); // sign in-place
        if (signViaEmail) recipientConfigurations = getRecipientConfiguration('B'); // sign via email

        /**
         -- build recipient detail objects
         -- for now the signing process accept only first signer to be embedded signer (if sign in-place)
         -- if this configuration change in the future then this block of code need modification
         * */ 
        /*string embeddedSignerOrder = '';
        list<DocusignSignerDetail> recipientDetails = new list<DocusignSignerDetail>{};
        for (DocuSign_Recipient_Configuration__mdt configuration : recipientConfigurations) {
            // recipient detail object
            recipientDetails.add(DocusignSignerDetail.build(configuration, signingGroupsInfo, salesAgreement));
            // store recipient ID of embedded signer
            if (configuration.Signing_Method__c == 'Direct') embeddedSignerOrder = configuration.Signing_Order__c;
        }

        // build recipients collection object
        DocusignSigners recipients = new DocusignSigners(recipientDetails);
        
        /**
         -- build document object
         -- change the return file name for DSA
         */
        /*integer currentVersion = salesAgreement.DSA_Version__c ==  null? 1 : (integer) salesAgreement.DSA_Version__c;
        list<DocusignDocument> documents = new list<DocusignDocument>{}; // documents configuration
        list<string> documentContents = new list<string>{}; // documents binary content
        integer documentIdIndex = 1;

        // @ webmerge route
        string documentNamePattern = 'Digital Sales Agreement_%' + salesAgreement.Name + '%';
        list<Attachment> cvs = [SELECT ID, Body, BodyLength FROM Attachment WHERE Name LIKE :documentNamePattern AND ParentId = :mySAId ORDER BY CreatedDate DESC];
        string returnDocName = salesAgreement.SOH_SONO__c + '_Sales Agreement_' + Datetime.now().format('dd/MM/yyyy') + '_v' + string.valueOf(currentVersion);
        documents.add(new DocusignDocument(returnDocName, 'docx', '1'));
        documentContents.add(documentContentMultiform_2(cvs[0].Body, 'docx', returnDocName, '1'));

        // build enevelope object
        string emailSubject = 'Sales Agreement ' + salesAgreement.SOH_SONO__c + '_v' + string.valueOf(currentVersion) + ' by ' + salesAgreement.Owner.Name;
        emailSubject = emailSubject.left(100); // cap at 100 characters for safe
        DocusignEnvelope envelopeObj = new DocusignEnvelope('sent', emailSubject, recipients, documents);
        envelopeObj.emailBlurb = 'Dear all,' +'\n' +'\n' + 'Please help sign / review this Sales Agreement. See the private message of this email for more detail.' + '\n' +'\n' + 'Thank you, ' + salesAgreement.Owner.Name + '.';
        envelopeObj.brandId = EnvelopeSendController.getBrandID(salesAgreement.Branch_Code__c, salesAgreement.DS_Model__c);
        
        // populate record number to envelope custom field
        envelopeObj.customFields.addRecordAutoNumber(salesAgreement.Name);
        
        // assign reminder settings
        DocuSign_Reminder_Configuration__mdt[] reminderSettings = EnvelopeSendController.getReminderSettings();
        if (reminderSettings.size() > 0) {
            envelopeObj.notification = new DocuSignNotificationSettings('true', reminderSettings[0].Reminder_Delay__c, reminderSettings[0].Reminder_Frequency__c);
        } else system.debug('EnvelopeSendController: No reminder setting found');
        
        // serrialize envelope object to JSON
        string body = JSON.serialize(envelopeObj);

        // put JSON body into multiform (https://developers.docusign.com/esign-rest-api/guides/requests-and-responses)
        body = multiFormStarting(BOUNDARY_START, body);
        if (documentContents.size() > 0) {
            for (integer i = 0; i < documentContents.size(); i++) {
                body = body + documentContents[i];
            }
        }
        body = body + '\n' + BOUNDARY_END;
        
        // send envelope create request
        string ACCESS_TOKEN = '';
        if (!Test.isRunningTest()) {
            ACCESS_TOKEN = DocusignJWT.accessTokenResponseProcess(DocusignJWT.getAccessToken(salesAgreement.OwnerId));
            if (string.isBlank(ACCESS_TOKEN)) throw new AuraHandledException('Error on sending envelope -- Can not get access token');
        }
        
        Continuation con = new Continuation(120);
        HttpRequest request = CalloutUtils.envelopeCreateRequest(ACCOUNT_ID, ACCESS_TOKEN, BOUNDARY, body);
        
        con.ContinuationMethod = Test.isRunningTest()? 'processResponse_ForTest' : 'processResponse';
        
        if (!Test.isRunningTest()) {
            string recipientFullName = string.isEmpty(salesAgreement.Customer_Full_Name__c) ? salesAgreement.Company_Name__c : salesAgreement.Customer_Full_Name__c;
            con.state = new StateInfo(salesAgreement.ID, null, embeddedSignerOrder, recipientFullName, salesAgreement.emailaddress__c, signViaEmail, currentVersion + 1, 'SA');
            // con.state = new StateInfo(salesAgreement.ID, null, '1', 'Mai Dang Phap', 'dangphap.mai@aodigy.com', signViaEmail, currentVersion + 1, 'SA');
            con.addHttpRequest(request);
        } else STATE_FOR_TEST = signViaEmail? 'SA.true' : 'SA.false';
        
        system.debug('---------- Signing Process end ----------');
        system.debug(Datetime.now());
        return con;
    }

    // This method for Webmerge Demo
    @AuraEnabled
    public static boolean webmerge(string SalesAgreementId){
        boolean wmResult = webm.WebmergeGenerator.generateDocument('a2lO0000000hJ4ZIAU', SalesAgreementId, 'Sales_Agreement__c');
        return wmResult;
    }

    /**
    -- Wrap processResponse() method in an instance method for testing
    -- This method will return arbitrary result: [null, cc40cebc-fa98-4dec-9494-af96f487e7a9.0690k000000suVSAAY]
    **/
    public map<string, string> processResponse_ForTest() {
        list<string> labels = new list<string> {EnvelopeSendController.STATE_FOR_TEST};
        system.debug(labels);
        string signProcessType = labels[0].split('\\.')[0];
        string emailSign = labels[0].split('\\.')[1];
        Boolean signViaEmail = emailSign == 'true'? true : false;
        object state = new StateInfo('a1R0k000002MH5oEAG', '0690k000000suVSAAY', '1', 'Test Cumtomer Name', 'Test Customer Email', signViaEmail, 1, signProcessType);
        map<string, string> results = EnvelopeSendController.processResponse(labels, state);
        return results;
    }

    /**
    -- Callback method for signingProcess()
    **/
    @AuraEnabled(cacheable = true)
    public static map<string, string> processResponse(List<String> labels, object state){
        system.debug('---------- processResponse begin ----------');
        system.debug(datetime.now());
        // restore information from Continuation state
        StateInfo stateAsObject = (StateInfo) state;
        ID salesAgreementId = stateAsObject.salesAgreementId;
        string documentId = stateAsObject.documentId;
        string embeddedSignerOrder = stateAsObject.embeddedSignerOrder;
        string customerName = stateAsObject.customerName;
        string customerEmail = stateAsObject.customerEmail;
        Boolean signViaEmail = stateAsObject.signViaEmail;
        integer nextVersion = stateAsObject.nextVersion;
        string processType = stateAsObject.processType;
        // string ACCESS_TOKEN = stateAsObject.ACCESS_TOKEN;

        HttpResponse response = Continuation.getResponse(labels[0]);
        integer responseStatusCode = response.getStatusCode();
        map<string, string> results = new map<string, string>{'sign_channel' => '', 'payload' => ''};
        
        if (responseStatusCode == 201) {
            DocusignEnvelope returnedEnvelope = (DocusignEnvelope) JSON.deserialize(response.getBody(), DocusignEnvelope.class);
            string embeddedSigningURL = '';

            if (!Test.isRunningTest() && !string.isEmpty(embeddedSignerOrder)) {
                string ACCESS_TOKEN = DocusignJWT.accessTokenResponseProcess(DocusignJWT.getAccessToken());
                if (string.isBlank(ACCESS_TOKEN)) throw new AuraHandledException('Can not get access token when process response.');
                embeddedSigningURL = embeddedSignSession(ACCOUNT_ID, returnedEnvelope.envelopeID, ACCESS_TOKEN, customerName, customerEmail, embeddedSignerOrder, embeddedSignerOrder);
            }

            if (signViaEmail) {
                results.put('sign_channel', 'Email');
                results.put('payload', 'The signing email has been sent to ' + customerEmail);
            } else {
                results.put('sign_channel', 'URL');
                results.put('payload', embeddedSigningURL);
            }

            if (!Test.isRunningTest()) EnvelopeSendController.updateEnvelopeID(salesAgreementId, returnedEnvelope.envelopeId.toUpperCase(), documentId, nextVersion, processType);
            system.debug(results);
        }

        // if callout error
        if (responseStatusCode != 201) {
            throw new AuraHandledException('The envelope creating is failed due to following reason: ' + response.getBody());
        }
        system.debug('---------- processResponse end ----------');
        system.debug(datetime.now());
        return results;
    }

    /** 
    -- Update SA record's DocuSign_Envelope_ID__c field
    -- Later Docusign Status record will link to SA by a trigger through this field
    -- Delete newly created non-sign DSA attach to SA
    **/
    @future
    public static void updateEnvelopeID(string currentSAID, string envId, string docId, integer nextVersion, string processType) {
        system.debug('---------- updateEnvelopeID begin ----------');
        system.debug(' currentSAID: ' + currentSAID);
        system.debug(' envelopeID: ' + envId);
        system.debug(' documentId: ' + docId);
        Sales_Agreement__c salesAgreement = [SELECT DocuSign_Envelope_ID__c, Name, DSA_Version__c, Unsigned_DSA_Id__c, UCA_Version__c FROM Sales_Agreement__c WHERE ID = :currentSAID];
        list<ContentDocument> contentToDelete = (list<ContentDocument>) [SELECT ID FROM ContentDocument WHERE ID = :docId LIMIT 1];
        if (processType == 'SA') {
            salesAgreement.DocuSign_Envelope_ID__c = envId;
            salesAgreement.DSA_Version__c = nextVersion;
        } else if (processType == 'UCA') {
            salesAgreement.UCA_Docusign_Envelope_ID__c = envId;
            salesAgreement.UCA_Version__c = nextVersion;
        } else {} // reverse for future use
        
        salesAgreement.Unsigned_DSA_Id__c = docId; // store both DSA & UCA in this field to by pass trigger that prevent deleting document
        update salesAgreement;
        if (contentToDelete.size() > 0) delete contentToDelete;
        system.debug('---------- updateEnvelopeID end ----------');
    }

    /**
    -- Add or delete members from a signing group
    -- If isDelete = true the operation is DELETE, else PUT
    -- The body of the request is described in: https://developers.docusign.com/esign-rest-api/reference/SigningGroups/SigningGroupUsers
    **/
    @future(callout=true)
    public static void updateSigningGroupsUsers(string signingGroupID, List<ID> userIDsToUpdate, boolean isDelete) {
        
        // get usernames and emails
        List<DocuSign_Recipient__c> usersInformation = (List<DocuSign_Recipient__c>) [SELECT Recipient_Name__c, Recipient_Email__c FROM DocuSign_Recipient__c 
                                                                                      WHERE User__c IN :userIDsToUpdate];
        // create signing group users detail object
        List<DocuSignSigningGroupUserDetail> userDetails = new List<DocuSignSigningGroupUserDetail>{};
        for (DocuSign_Recipient__c userDetail : usersInformation) {
            string userName = userDetail.Recipient_Name__c;
            string email = userDetail.Recipient_Email__c;
            userDetails.add(new DocuSignSigningGroupUserDetail(userName, email));
        }
        // put all user details in to a signing group users object
        DocuSignSigningGroupUsers signingGroupUsers = new DocuSignSigningGroupUsers(userDetails);

        // parse signing group users object to JSON for request's body
        string body = JSON.serialize(signingGroupUsers);

        // get access token
        string ACCESS_TOKEN = '';
        if (!Test.isRunningTest()) {
            ACCESS_TOKEN = DocusignJWT.accessTokenResponseProcess(DocusignJWT.getAccessToken());
            if (string.isBlank(ACCESS_TOKEN)) {
                system.debug('EnvelopeSendController: Can not get access token');
                return;
            }
        }
        
        // create the request and send
        if (!Test.isRunningTest()) {
            HttpResponse response = CalloutUtils.signingGroupUsersUpdate(ACCOUNT_ID, ACCESS_TOKEN, signingGroupID, body, isDelete);
            integer responseStatusCode = response.getStatusCode();
            if (responseStatusCode == 200) {
                if(!isDelete) {
                    system.debug('EnvelopeSendController: Signing Group has been updated');
                } else {
                    system.debug('EnvelopeSendController: Signing Group members has been deleted');
                }
            } else {
                system.debug('EnvelopeSendController: Signing Groups updating failed');
            }
        }
    }


    /**
    -- Add or delete a specific member from a signing group
    -- If isDelete = true then the operation is DELETE, else PUT
    -- The body of the request is described in: https://developers.docusign.com/esign-rest-api/reference/SigningGroups/SigningGroupUsers
    **/
    @future(callout=true)
    public static void updateSigningGroupsUser(string signingGroupID, string userName, string Email, boolean isDelete) {
        
        // create signing group users detail object
        List<DocuSignSigningGroupUserDetail> userDetails = new List<DocuSignSigningGroupUserDetail>{};
        userDetails.add(new DocuSignSigningGroupUserDetail(userName, email));

        // put all user details in to a signing group users object
        DocuSignSigningGroupUsers signingGroupUsers = new DocuSignSigningGroupUsers(userDetails);
        // parse signing group users object to JSON for request's body
        string body = JSON.serialize(signingGroupUsers);
        // get access token
        string ACCESS_TOKEN = '';
        if (!Test.isRunningTest()) {
            ACCESS_TOKEN = DocusignJWT.accessTokenResponseProcess(DocusignJWT.getAccessToken());
            if (string.isBlank(ACCESS_TOKEN)) {
                system.debug('EnvelopeSendController: Can not get access token');
                return;
            }
        }
        
        // create the request and send
        if (!Test.isRunningTest()) {
            HttpResponse response = CalloutUtils.signingGroupUsersUpdate(ACCOUNT_ID, ACCESS_TOKEN, signingGroupID, body, isDelete);
            integer responseStatusCode = response.getStatusCode();
            if (responseStatusCode == 200) {
                if(!isDelete) {
                    system.debug('EnvelopeSendController: Signing Group has been updated');
                } else {
                    system.debug('EnvelopeSendController: Signing Group members has been deleted');
                }
            } else {
                system.debug('EnvelopeSendController: Signing Groups updating failed');
            }
        }
    }
    
    /**
    -- Get the embedded signing URL of an envelope
    **/
    @testVisible
    private static string embeddedSignSession(string accountID, string envelopeId, string ACCESS_TOKEN, string userName, string email, string recipientID, string clientUserId) {
        // get base URI
        string baseURI;
        if (!Test.isRunningTest()) {
            baseURI = CalloutUtils.baseUriResponseProcess(CalloutUtils.getBaseURI(ACCESS_TOKEN));
        } else {
            baseURI = 'https://eu.docusign.net/';
        }
        
        // create request to call API for embedded signing URL
        HttpRequest request = new HttpRequest();
        string endpoint = baseURI + 'restapi/v2.1/accounts/' + accountID + '/envelopes/' + envelopeId + '/views/recipient';
        request.setHeader('grant_type', 'Bearer');
        request.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endpoint);
        string body = '{"userName": "' + userName + '",' +
            '"email": "' + email + '",' +
            '"recipientId": "' + recipientID + '",' +
            '"clientUserId": "' + clientUserId + '",' +
            '"authenticationMethod": "email",' +
            '"returnUrl": "https://www.cyclecarriage.com/our-business"}';
        request.setBody(body);
        request.setMethod('POST');

        // launch request
        string embeddedSigningURL;
        if (!Test.isRunningTest()) {
            Http httpProtocol = new Http();
            HttpResponse response = httpProtocol.send(request);

            // parse response result
            String responseStatus = response.getStatus();
            if (responseStatus == 'Created') {
                Map<string, string> responseMap = (Map<string, string>)JSON.deserialize(response.getBody(), Map<string, string>.class);
                embeddedSigningURL = responseMap.get('url');
            } else {
                system.debug(response.getBody());
            }
        }
        system.debug('Signing URL: ' + embeddedSigningURL);
        return embeddedSigningURL;
    }

    /**
     -- wrap the binary content of document into multiform for request body
     */
    private static string documentContentMultiform(ContentVersion cv, string extension, string name, string documentID) {
        string documentBase64 = EncodingUtil.Base64Encode(cv.VersionData);
        return  BOUNDARY_START + '\n' +
                'Content-Type: application/' + extension + ';base64' + '\n' +
                'Content-Disposition: file; filename="' + name + '"; documentid=' + documentID + '\n' +
                'Content-Transfer-Encoding: base64' +
                '\n' + '\n' + documentBase64 + '\n' + '\n';
    }

    // This method for Webmerge Demo
    private static string documentContentMultiform_2(blob data, string extension, string name, string documentID) {
        string documentBase64 = EncodingUtil.Base64Encode(data);
        return  BOUNDARY_START + '\n' +
                'Content-Type: application/' + extension + ';base64' + '\n' +
                'Content-Disposition: file; filename="' + name + '"; documentid=' + documentID + '\n' +
                'Content-Transfer-Encoding: base64' +
                '\n' + '\n' + documentBase64 + '\n' + '\n';
    }

    private static string multiFormStarting(string BOUNDARY_START, string body) {
        return BOUNDARY_START + '\n' + 'Content-Type: application/json' + '\n' + 'Content-Disposition: form-data' + '\n' + '\n' + body + '\n';
    }

    /**
     -- Get Sales Agreement's template from metadata
     */
    @AuraEnabled (cacheable = true)
    public static ID getTemplateID(string SArecordID) {
        Sales_Agreement__c salesAgreement = [SELECT Branch_Code__c, DS_Model__c FROM Sales_Agreement__c WHERE ID = :SArecordID];
        
        string templateLabel = salesAgreement.DS_Model__c && salesAgreement.Branch_Code__c == 'CCF' ? 'DSA_' + salesAgreement.Branch_Code__c + '_DS' : 'DSA_' + salesAgreement.Branch_Code__c;
        DocuSignTemplate__mdt DSTemplte = [SELECT DocuSign_Template_Id__c FROM DocuSignTemplate__mdt WHERE DeveloperName = :templateLabel LIMIT 1];
        return DSTemplte.DocuSign_Template_Id__c;
    }

    /**
     -- Get Docusign brand ID from metadata
     */
    private static string getBrandID(string branchCode, boolean DSModel) {
        system.debug('---------- getBrandID begin ----------');
        string templateLabel = DSModel && branchCode == 'CCF' ? 'DSA_' + branchCode + '_DS' : 'DSA_' + branchCode;
        DocuSignTemplate__mdt DSTemplte = [SELECT DocuSign_Brand_ID__c FROM DocuSignTemplate__mdt WHERE DeveloperName = :templateLabel LIMIT 1];
        system.debug(DSTemplte);
        system.debug('---------- getBrandID end ----------');
        return DSTemplte.DocuSign_Brand_ID__c;
    }

    /**
     -- Get reminder settings from metadata
     */
    private static DocuSign_Reminder_Configuration__mdt[] getReminderSettings() {
        system.debug('---------- getReminderSettings begin ----------');
        DocuSign_Reminder_Configuration__mdt[] reminderSettings = (List<DocuSign_Reminder_Configuration__mdt>) [SELECT Active__c, Reminder_Delay__c, Reminder_Frequency__c, Identifier__c
                                                                                                                FROM DocuSign_Reminder_Configuration__mdt
                                                                                                                WHERE Active__c = true AND Identifier__c = 'MF'
                                                                                                                LIMIT 1];
        system.debug(reminderSettings);
        system.debug('---------- getReminderSettings end ----------');
        return reminderSettings;
    }

    /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 -- START --------*/
    /**
     * Get expiration settings from Metadata
     */
    private static DocuSign_Expiration_Configuration__mdt[] getExpirationSettings() {
        system.debug('---------- getExpirationSettings begin ----------');
        DocuSign_Expiration_Configuration__mdt[] expirationSettings = (List<DocuSign_Expiration_Configuration__mdt>) [SELECT Active__c, Expire_After__c, Expire_Warn__c, Identifier__c
                                                                                                                    FROM DocuSign_Expiration_Configuration__mdt
                                                                                                                    WHERE Active__c = true AND Identifier__c = 'MF'
                                                                                                                    LIMIT 1];
        system.debug(expirationSettings);
        system.debug('---------- getExpirationSettings end ----------');
        return expirationSettings;
    }
    /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 -- END --------*/

    /**
     -- Get SA record by ID
     */
    private static Sales_Agreement__c getSalesAgreementById(string recordID) {
        system.debug('---------- getSalesAgreementById begin ----------');
        // instaniate query factory class
        Schema.SObjectType objType = Sales_Agreement__c.sObjectType;
        ADGLIB_QueryFactory queryFactory = new ADGLIB_QueryFactory(objType);

        // check accessibility
        queryFactory.assertIsAccessible();
        
        // set field level security setting
        queryFactory.setEnforceFLS(true);

        // get fields list
        List<Schema.SObjectField> fields = ADGLIB_UtilityHelper.getSObjectFieldListByObj(objType.getDescribe().getName());
        queryFactory.selectFields(fields);

        // add Owner.Name field
        queryFactory.selectField('Owner.Name');
        queryFactory.selectField('Owner.Email');

        // set condition filter by ID
        queryFactory.setCondition('ID = :recordId');

        // build SOQL query statement, query and return result
        Sales_Agreement__c returnSA = Database.query(queryFactory.toSOQL());
        system.debug(returnSA);
        system.debug('---------- getSalesAgreementById end ----------');
        return returnSA;
    }

    /**
     -- Get signing group by branch code, should return a list of one signing group
     */
    // private static list<Signing_Group__c> getSigningGroupsByBranchCode(string branchCode) {
    //     system.debug('---------- getSigningGroupsByBranchCode begin ----------');
    //     // instaniate query factory class
    //     Schema.SObjectType objType = Signing_Group__c.sObjectType;
    //     ADGLIB_QueryFactory queryFactory = new ADGLIB_QueryFactory(objType);

    //     // get fields list
    //     list<Schema.SObjectField> fields = ADGLIB_UtilityHelper.getSObjectFieldListByObj(objType.getDescribe().getName());
    //     queryFactory.selectFields(fields);

    //     // set condition filter by ID
    //     queryFactory.setCondition('Branch_Code__c = :branchCode');
        
    //     // build SOQL query statement, query and return result
    //     list<Signing_Group__c> returnSigningGroups = Database.query(queryFactory.toSOQL());
    //     if (returnSigningGroups.size() < 1) throw new AuraHandledException('Error on getting signing group -- Found no signing group for branch code: [' + branchCode + ']');
    //     if (returnSigningGroups.size() > 1) throw new AuraHandledException('Error on getting signing group -- Found more than 1 signing group for branch code: [' + branchCode + ']');
    //     system.debug(returnSigningGroups);
    //     system.debug('---------- getSigningGroupsByBranchCode end ----------');
    //     return returnSigningGroups;
    // }

    /* -------- MODIFIED BY THIEU DANG VU - Thu 28th Jan 2021 -- START --------*/
    private static List<Signing_Group__c> getSigningGroupByUserRole(String userRole) {
        system.debug('---------- getSigningGroupsByUserRole begin ----------');
        // instaniate query factory class
        Schema.SObjectType objType = Signing_Group__c.sObjectType;
        ADGLIB_QueryFactory queryFactory = new ADGLIB_QueryFactory(objType);

        // get fields list
        list<Schema.SObjectField> fields = ADGLIB_UtilityHelper.getSObjectFieldListByObj(objType.getDescribe().getName());
        queryFactory.selectFields(fields);

        // set condition filter by ID
        queryFactory.setCondition('Unique_Identifier__c = :userRole');
        
        // build SOQL query statement, query and return result
        list<Signing_Group__c> returnSigningGroups = Database.query(queryFactory.toSOQL());
        if (returnSigningGroups.size() < 1) throw new AuraHandledException('Error on getting signing group -- Found no signing group for user role: [' + userRole + ']');
        if (returnSigningGroups.size() > 1) throw new AuraHandledException('Error on getting signing group -- Found more than 1 signing group for user role: [' + userRole + ']');
        system.debug(returnSigningGroups);
        system.debug('---------- getSigningGroupsByUserRole end ----------');
        return returnSigningGroups;
    }
    /* -------- MODIFIED BY THIEU DANG VU - Thu 28th Jan 2021 -- END --------*/

    /**
     -- Get Docusign recipients settings from metadata
     */
    private static List<DocuSign_Recipient_Configuration__mdt> getRecipientConfiguration(string signingScenarioCode) {
        system.debug('---------- getRecipientConfiguration begin ----------');
        system.debug('Signing Scenario: ' + signingScenarioCode);
        // instaniate query factory class
        Schema.SObjectType objType = DocuSign_Recipient_Configuration__mdt.sObjectType;
        ADGLIB_QueryFactory queryFactory = new ADGLIB_QueryFactory(objType);

        // get fields list
        list<Schema.SObjectField> fields = ADGLIB_UtilityHelper.getSObjectFieldListByObj(objType.getDescribe().getName());
        queryFactory.selectFields(fields);

        // set condition filter by ID
        queryFactory.setCondition('Active__c = true AND Signing_Scenario__c = \'' + signingScenarioCode + '\'');

        // set ordering
        ADGLIB_QueryFactory.SortOrder direction = ADGLIB_QueryFactory.SortOrder.ASCENDING;
        queryFactory.setOrdering('Signing_Order__c', direction);

        // build SOQL query statement, query and return result
        list<DocuSign_Recipient_Configuration__mdt> returnConfigurations = Database.query(queryFactory.toSOQL());
        if (returnConfigurations.size() < 1) throw new AuraHandledException('Error on getting recipient configuration -- Found no recipient configuration data');
        system.debug(returnConfigurations);
        system.debug('---------- getRecipientConfiguration end ----------');
        return returnConfigurations;
    }

    /**
     -- Get a CDL that attach to a SA with specific name pattern
     */
    private static List<ContentDocumentLink> getDocumentsByIdAndName(string salesAgreementId, string namePattern) {
        system.debug('---------- getDocumentsByIdAndName begin ----------');
        // instaniate query factory class
        Schema.SObjectType objType = ContentDocumentLink.sObjectType;
        ADGLIB_QueryFactory queryFactory = new ADGLIB_QueryFactory(objType);

        // get fields list
        list<Schema.SObjectField> fields = ADGLIB_UtilityHelper.getSObjectFieldListByObj(objType.getDescribe().getName());
        queryFactory.selectFields(fields);
        queryFactory.selectField('ContentDocument.title');
        queryFactory.selectField('ContentDocument.CreatedDate');

        // set condition filter by ID
        queryFactory.setCondition('LinkedEntityId = :salesAgreementId AND ContentDocument.title LIKE :namePattern');

        // set ordering
        queryFactory.setOrdering('ContentDocument.CreatedDate', ADGLIB_QueryFactory.SortOrder.DESCENDING, false);

        // set limit
        queryFactory.setLimit(1);

        // build SOQL query statement, query and return result
        list<ContentDocumentLink> returnCDL = Database.query(queryFactory.toSOQL());
        if (!Test.isRunningTest() && returnCDL.size() < 1) throw new AuraHandledException('Error on getting envelope document -- Found no document');
        system.debug(returnCDL);
        system.debug('---------- getDocumentsByIdAndName end ----------');
        return returnCDL;
    }

    /**
     -- Get content version record by documentID
     */
    private static list<ContentVersion> getContentVersionByDocumentId(string documentId) {
        system.debug('---------- getContentVersionByDocumentId begin ----------');
        // instaniate query factory class
        Schema.SObjectType objType = ContentVersion.sObjectType;
        ADGLIB_QueryFactory queryFactory = new ADGLIB_QueryFactory(objType);

        // get fields list
        list<Schema.SObjectField> fields = ADGLIB_UtilityHelper.getSObjectFieldListByObj(objType.getDescribe().getName());
        queryFactory.selectFields(fields);
        
        // set condition filter by ID
        queryFactory.setCondition('ContentDocumentId = :documentId');

        // set ordering
        queryFactory.setOrdering('ContentModifiedDate', ADGLIB_QueryFactory.SortOrder.DESCENDING, false);

        // set limit
        queryFactory.setLimit(1);

        // build SOQL query statement, query and return result
        list<ContentVersion> returnCVs = Database.query(queryFactory.toSOQL());
        if (returnCVs.size() < 1) throw new AuraHandledException('Error on getting envelope document -- Found no binary content for this DSA');
        system.debug(returnCVs);
        system.debug('---------- getContentVersionByDocumentId end ----------');
        return returnCVs;
    }

    @AuraEnabled 
    public static Boolean createSalesOrder(Id SalesAgreementId){

        Boolean isSuccess = false;
        try {
            /**
            VSMS_Callout.insertSalesOrderToVSMS(SalesAgreementId);
            isSuccess = true;
			**/
            isSuccess = VSMS_Callout.insertSalesOrderToVSMS(SalesAgreementId);
            
            /** ADDED BY TPHAN ON 23/07/2021 - PA MERGING */
            DigitalSalesAgreementApplication.updateRelatedPA(SalesAgreementId);
        } catch (Exception e) {
            throw new CalloutException('false');
        }
        
        return isSuccess;
    }

    /**
     -- Wrapper class for state in Continuation method
     */
    public class StateInfo {
        public string salesAgreementId;
        public string documentId;
        public string embeddedSignerOrder;
        public string customerName;
        public string customerEmail;
        public Boolean signViaEmail;
        public integer nextVersion;
        public string processType;
        // public string ACCESS_TOKEN;

        @testVisible
        StateInfo (string salesAgreementId, string documentId, string embeddedSignerOrder, string customerName, string customerEmail, Boolean signViaEmail, integer nextVersion, string processType) {
            this.salesAgreementId = salesAgreementId;
            this.documentId = documentId;
            this.embeddedSignerOrder = embeddedSignerOrder;
            this.customerName = customerName;
            this.customerEmail = customerEmail;
            this.signViaEmail = signViaEmail;
            this.nextVersion = nextVersion;
            this.processType = processType;
            // this.ACCESS_TOKEN = ACCESS_TOKEN;
        }
    }  

    /**
     -- Get UCA's template from metadata
     */
    @AuraEnabled 
    public static ID getUCATemplateID(string SArecordID) {
        system.debug('---------- UCA_GetTemplateID begin ----------');
        Sales_Agreement__c salesAgreement = [SELECT Branch_Code__c, DS_Model__c FROM Sales_Agreement__c WHERE ID = :SArecordID];
        string templateLabel = salesAgreement.DS_Model__c && salesAgreement.Branch_Code__c == 'CCF' ? 'DSA_' + salesAgreement.Branch_Code__c + '_DS' : 'DSA_' + salesAgreement.Branch_Code__c;
        DocuSignTemplate__mdt DSTemplate = [SELECT Used_Car_Agreement_Template__c FROM DocuSignTemplate__mdt WHERE DeveloperName = :templateLabel LIMIT 1];
        system.debug(DSTemplate);
        system.debug('---------- UCA_GetTemplateID end ----------');
        return DSTemplate.Used_Car_Agreement_Template__c;
    }

    /**
     -- Create envelope for UCA signing
     -- Seperate from signingProcess() because we dont want to risk with current process, this method is developed later
     */
    @AuraEnabled(continuation = true cacheable = true)
    public static object UCA_SigningProcess(ID mySAId, Boolean signViaEmail) {
        system.debug('---------- UCA Signing Process begin ----------');

        // get sales agreement
        Sales_Agreement__c salesAgreement = getSalesAgreementById(mySAId);

        // get signing groups
        // if (salesAgreement.Branch_Code__c == null) throw new AuraHandledException('Error in getting signing group -- Invalid branch code: [' + salesAgreement.Branch_Code__c + ']');
        // list<Signing_Group__c> signingGroups = getSigningGroupsByBranchCode(salesAgreement.Branch_Code__c);
        /* -------- MODIFIED BY THIEU DANG VU - Thu 28th Jan 2021 -- START --------*/
        // Change logic get signing groups by User Role
        User owner = [SELECT UserRole.Name, UserRole.DeveloperName, Name FROM USER WHERE ID = :salesAgreement.OwnerId];
        List<Signing_Group__c> signingGroups = getSigningGroupByUserRole(owner.UserRole.DeveloperName);
        /* -------- MODIFIED BY THIEU DANG VU - Thu 28th Jan 2021 -- END --------*/
        string endorserID = signingGroups[0].Endorse_Group_ID__c;
        string endorserName = signingGroups[0].Endorse_Group_Name__c;
        string approverID = signingGroups[0].Approve_Group_ID__c;
        string approverName = signingGroups[0].Approve_Group_Name__c;

        // put signing group info to map for later reference
        Map<string, Map<string, string>> signingGroupsInfo = new Map<string, map<string, string>>{};
        signingGroupsInfo.put('Endorser', new Map<string, string> {'ID' => endorserID, 'Name' => endorserName});
        signingGroupsInfo.put('Approver', new Map<string, string> {'ID' => approverID, 'Name' => approverName});


        // get recipient configurations
        list<DocuSign_Recipient_Configuration__mdt> recipientConfigurations = new list<DocuSign_Recipient_Configuration__mdt>();
        if (!signViaEmail) recipientConfigurations = getRecipientConfiguration('C'); // sign in-place
        if (signViaEmail) recipientConfigurations = getRecipientConfiguration('D'); // sign via email
        
        // get newly created DSA
        string documentNamePattern = 'Third Party Trade-In Agreement%_' + salesAgreement.Name + '_%';
        list<ContentDocumentLink> contentDocuments = getDocumentsByIdAndName(salesAgreement.ID, documentNamePattern);
        

        // get binary content of DSA
        list<ContentVersion> contentVersions = new list<ContentVersion>{};
        contentVersions.addAll(getContentVersionByDocumentId(contentDocuments[0].ContentDocumentId)); // for now, expect only 1 document per envelope
        

        /**
         -- build recipient detail objects
         -- for now the signing process accept only first signer to be embedded signer (if sign in-place)
         -- if this configuration change in the future then this block of code need modification
         * */ 
        string embeddedSignerOrder = '';
        string embeddedSignerName = '[Recipient]';
        string embeddedSignerEmail = '[Registration Number]';
        list<DocusignSignerDetail> recipientDetails = new list<DocusignSignerDetail>{};
        for (DocuSign_Recipient_Configuration__mdt configuration : recipientConfigurations) {
            // recipient detail object
            DocusignSignerDetail recipient = DocusignSignerDetail.build(configuration, signingGroupsInfo, salesAgreement);
            recipientDetails.add(recipient);
            // store recipient ID, name & email of embedded signer
            if (configuration.Signing_Method__c == 'Direct') {
                embeddedSignerOrder = configuration.Signing_Order__c;
                embeddedSignerName = recipient.name;
                embeddedSignerEmail = recipient.email;
            }
        }
        // build recipients collection object
        DocusignSigners recipients = new DocusignSigners(recipientDetails);
        
        /**
         -- build document object
         -- change the return file name for UCA
         */
        integer currentVersion = salesAgreement.UCA_Version__c ==  null? 1 : (integer) salesAgreement.UCA_Version__c;
        // define envelope documents for the general situation that we have multiple documents
        List<DocusignDocument> documents = new List<DocusignDocument>{}; // documents configuration
        List<string> documentContents = new List<string>{}; // documents binary content
        integer documentIdIndex = 1;
        for (ContentVersion cv : contentVersions) {
            string name = cv.Title.contains(salesAgreement.Name) ? salesAgreement.SOH_SONO__c + '_Third Party Trade-In Agreement_' + Datetime.now().format('dd/MM/yyyy') + '_v' + string.valueOf(currentVersion) : cv.Title;
            documents.add(new DocusignDocument(name, cv.FileExtension, string.valueOf(documentIdIndex)));
            documentContents.add(documentContentMultiform(cv, cv.FileExtension, name, string.valueOf(documentIdIndex))); 
            documentIdIndex++;
        }

        // build enevelope object
        string emailSubject = 'Third Party Trade-In Agreement_v' + string.valueOf(currentVersion) + ' for Sales Agreement No. ' + salesAgreement.SOH_SONO__c + ' by ' + salesAgreement.Owner.Name;
        emailSubject = emailSubject.left(100);
        DocusignEnvelope envelopeObj = new DocusignEnvelope('sent', emailSubject, recipients, documents);
        string usedCarNumber = salesAgreement.Trade_In_Used_Car_Registration_Number__c == null? '' : salesAgreement.Trade_In_Used_Car_Registration_Number__c;
        string sellerName = salesAgreement.Seller_Full_Name__c == null? salesAgreement.Seller_Company_Name__c : salesAgreement.Seller_Full_Name__c;
        envelopeObj.emailBlurb = 'Dear ' + sellerName + ',' +'\n' +'\n' + 'Your vehicle ' + usedCarNumber + ' has been nominated for trade in with Cycle & Carriage. Please review and sign the Third Party Trade-In Agreement for us to proceed with the trade-in.' + '\n' +'\n' + 'Thank you, ' + salesAgreement.Owner.Name + '.';
        envelopeObj.brandId = EnvelopeSendController.getBrandID(salesAgreement.Branch_Code__c, salesAgreement.DS_Model__c);

        // populate record number to envelope custom field
        envelopeObj.customFields.addRecordAutoNumber(salesAgreement.Name);
        
        // assign reminder settings
        DocuSign_Reminder_Configuration__mdt[] reminderSettings = EnvelopeSendController.getReminderSettings();
        if (reminderSettings.size() > 0) {
            envelopeObj.notification = new DocuSignNotificationSettings('true', reminderSettings[0].Reminder_Delay__c, reminderSettings[0].Reminder_Frequency__c);
        } else system.debug('EnvelopeSendController: No reminder setting found');

        // serrialize envelope object to JSON
        string body = JSON.serialize(envelopeObj);

        // put JSON body into multiform (https://developers.docusign.com/esign-rest-api/guides/requests-and-responses)
        body = multiFormStarting(BOUNDARY_START, body);
        if (documentContents.size() > 0) {
            for (integer i = 0; i < documentContents.size(); i++) {
                body = body + documentContents[i];
            }
        }
        body = body + '\n' + BOUNDARY_END;
        

        // send envelope create request
        string ACCESS_TOKEN = '';
        if (!Test.isRunningTest()) {
            ACCESS_TOKEN = DocusignJWT.accessTokenResponseProcess(DocusignJWT.getAccessToken(salesAgreement.OwnerId));
            if (string.isBlank(ACCESS_TOKEN)) throw new AuraHandledException('Error on sending envelope -- Can not get access token');
        }
        
        Continuation con = new Continuation(120);
        HttpRequest request = CalloutUtils.envelopeCreateRequest(ACCOUNT_ID, ACCESS_TOKEN, BOUNDARY, body);
        con.ContinuationMethod = Test.isRunningTest()? 'processResponse_ForTest' : 'processResponse';
        
        if (!Test.isRunningTest()) {
            string recipientFullName = string.isEmpty(salesAgreement.Customer_Full_Name__c) ? salesAgreement.Company_Name__c : salesAgreement.Customer_Full_Name__c;
            con.state = new StateInfo(salesAgreement.ID, contentDocuments[0].ContentDocumentId, embeddedSignerOrder, embeddedSignerName, embeddedSignerEmail, signViaEmail, currentVersion + 1, 'UCA');
            con.addHttpRequest(request);
        } else STATE_FOR_TEST = signViaEmail? 'UCA.true' : 'UCA.false';
        
        system.debug(con);
        system.debug('---------- UCA Signing Process end ----------');
        return con;
    }
}
@isTest
private with sharing class EnvelopeSendController_Test {

    @testSetup
    static void createSalesAgreement(){
        // create a sales agreement record for test
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';
        string customerEMail = 'test@123.com';
        string CUSTOMER_SIGN_ORDER = '1';
        
        // create Account and Opportunity
        Account personAcc = Test_DataFactory.createPerson(true, customerName, 'Customer');
        Opportunity oppt = Test_DataFactory.createOpportunity(false, customerName + '-Opp', personAcc.Id);
        oppt.Branch_Code__c = 'CCK';
        oppt.Opportunity_Score__c = 40;
        insert oppt;

        TriggerExclusion.excludeTrigger('Opportunity', true);
        //* create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', Model_Master__c = modelMaster.ID);
        insert modelYearMaster;
        
        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelMaster.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        
        //* create stock reservation from master data
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Opportunity__c                  = oppt.Id;
        insert stockReservation;
        

        // create signing group for the sales agreement
        // Signing_Group__c testSigningGroup = new Signing_Group__c(Name = 'Test', Branch_Code__c = branchCode, Endorse_Group_ID__c = '123456', Endorse_Group_Name__c = 'Test', Approve_Group_ID__c = '123457', Approve_Group_Name__c = 'Test');
        Signing_Group__c testSigningGroup = new Signing_Group__c(Name = 'Test', Unique_Identifier__c = 'KIA_PC_1', Endorse_Group_ID__c = '123456', Endorse_Group_Name__c = 'Test', Approve_Group_ID__c = '123457', Approve_Group_Name__c = 'Test');
        insert testSigningGroup;

        // create testing user
        User testUser = Test_DataFactory.createUser(true, 'Test DocuSign Callout', 'Test');

        // create endorser user for testing
        DocuSign_Recipient__c testSigningUser = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Endorser', User__c = testUser.ID);
        insert testSigningUser;

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            // Create role
            UserRole r = new UserRole(DeveloperName = 'KIA_PC_1', Name = 'KIA PC 1');
            insert r;
            // create sc user
            User sc = Test_DataFactory.createUser(false, 'SC Test', 'Test');
            sc.UserRoleId = r.Id;
            insert sc;
            System.runAs (sc) {
                //* sales agreement
                Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.ID, customerName);

                salesAgreement.emailaddress__c = 'test@aodigy.com';
                salesAgreement.Package_Header__c = pckHeader.Id;
                insert salesAgreement;
                salesAgreement.Branch_Code__c = branchCode;
                update salesAgreement;
                //* attach a document to sales agreement
                ID documentContentID = Test_DataFactory.attachDSA(salesAgreement.ID);
            }
        }
    }

    // test static initializer
    @isTest
    static void staticInitializer_Test(){
        EnvelopeSendController temp = new EnvelopeSendController();
        DocuSignCredential__mdt credentials = [SELECT AccountNumber__c, Multiform_Boundary__c FROM DocuSignCredential__mdt WHERE Active__c = true];
        system.assertEquals(EnvelopeSendController.ACCOUNT_ID, credentials.AccountNumber__c);
        system.assertEquals(EnvelopeSendController.BOUNDARY, credentials.Multiform_Boundary__c);
    }

    // test signing process method
    @isTest
    static void signingProcess_TestSignViaEmail() {
        // query test sales agreement
        Sales_Agreement__c salesAgreement = [SELECT ID, Name, Customer_Full_Name__c, Email__c, SOH_SONO__c, Branch_Code__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
        
        // query the content document and update name
        ID cdID = [SELECT ID, ContentDocumentID, Title FROM ContentVersion WHERE Title LIKE '%TEST%'].ContentDocumentID;
        ContentDocument cd = [SELECT ID, Title FROM ContentDocument WHERE ID = :cdID];
        cd.Title = 'Digital Sales Agreement_' + salesAgreement.Name + '_';
        update cd;
        EnvelopeSendController controller = new EnvelopeSendController();
        Continuation signingContinuation = (Continuation) EnvelopeSendController.signingProcess(salesAgreement.ID, true);
        
        // verify that the continuation has the proper requests
        string state = EnvelopeSendController.STATE_FOR_TEST;
        Map<string, HttpRequest> requests = signingContinuation.getRequests();
        
        // perform mock callout (i.e skip the callout and invoke callback method)
        Test.setContinuationResponse(state, DocusignMockHttpResponseGenerator.envelopeCreateRespond(requests.get(state)));
        
        // invoke call back
        Object callbackResults = Test.invokeContinuationMethod(controller, signingContinuation);
        
        // verify that callback method return a list of string
        map<string, string> results = (map<string, string>) callbackResults;
        system.assert(results.get('sign_channel') == 'Email'); // verify the embedded signing URL is null because this is just a mock callout
        system.debug(results.get('payload'));
        system.assert(results.get('payload') == 'The signing email has been sent to Test Customer Email'); // verify the envelope ID & document ID is not null, this is arbitrary result            
    }
    
    @isTest
    static void signingProcess_TestSignInPlace() {
        // query test sales agreement
        Sales_Agreement__c salesAgreement = [SELECT ID, Name, Customer_Full_Name__c, Email__c, SOH_SONO__c, Branch_Code__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
		
        // query the content document and update name
        ID cdID = [SELECT ID, ContentDocumentID, Title FROM ContentVersion WHERE Title LIKE '%TEST%'].ContentDocumentID;
        ContentDocument cd = [SELECT ID, Title FROM ContentDocument WHERE ID = :cdID];
        cd.Title = 'Digital Sales Agreement_' + salesAgreement.Name + '_';
        update cd;
        
        // create the continuation
        EnvelopeSendController controller = new EnvelopeSendController();
        Continuation signingContinuation = (Continuation) EnvelopeSendController.signingProcess(salesAgreement.ID, false);
        
        // verify that the continuation has the proper requests
        string state = EnvelopeSendController.STATE_FOR_TEST;
        Map<string, HttpRequest> requests = signingContinuation.getRequests();
        
        // perform mock callout (i.e skip the callout and invoke callback method)
        Test.setContinuationResponse(state, DocusignMockHttpResponseGenerator.envelopeCreateRespond(requests.get(state)));
        
        // invoke call back
        Object callbackResults = Test.invokeContinuationMethod(controller, signingContinuation);

        // verify that callback method return a list of string
        map<string, string> results = (map<string, string>) callbackResults;
        system.assert(results.get('sign_channel') == 'URL'); // verify the embedded signing URL is null because this is just a mock callout
        system.debug(results.get('payload'));
        system.assert(results.get('payload') == ''); // verify the envelope ID & document ID is not null, this is arbitrary result
    }

    @isTest
    static void UCA_TestSignViaEmail() {
        // query test sales agreement
        Sales_Agreement__c salesAgreement = [SELECT ID, Name, Customer_Full_Name__c, Email__c, SOH_SONO__c, Branch_Code__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];

        // update the sales agreement to have UCA information
        salesAgreement.isSellerNotBuyer__c = true;
        salesAgreement.Seller_Full_Name__c = 'Used Car Seller';
        salesAgreement.Seller_NRIC__c = 'NRIC279';
        salesAgreement.Seller_Mobile_Number__c = '98347231';
        salesAgreement.Seller_Email_Address__c = 'test@gmail.com';
        salesAgreement.Seller_Date_Of_Birth__c = Date.newInstance(1990, 09, 02);
        salesAgreement.Seller_Street_Name__c = '175 Bencollen street';
        update salesAgreement;
		
        // query the content document and update name
        ID cdID = [SELECT ID, ContentDocumentID, Title FROM ContentVersion WHERE Title LIKE '%TEST%'].ContentDocumentID;
        ContentDocument cd = [SELECT ID, Title FROM ContentDocument WHERE ID = :cdID];
        cd.Title = 'Third Party Trade-In Agreement_' + salesAgreement.Name + '_';
        update cd;
        
        // create the continuation
        EnvelopeSendController controller = new EnvelopeSendController();
        Continuation signingContinuation = (Continuation) EnvelopeSendController.UCA_SigningProcess(salesAgreement.ID, true);
        
        // verify that the continuation has the proper requests
        string state = EnvelopeSendController.STATE_FOR_TEST;
        Map<string, HttpRequest> requests = signingContinuation.getRequests();
        
        // perform mock callout (i.e skip the callout and invoke callback method)
        Test.setContinuationResponse(state, DocusignMockHttpResponseGenerator.envelopeCreateRespond(requests.get(state)));
        
        // invoke call back
        Object callbackResults = Test.invokeContinuationMethod(controller, signingContinuation);

        // verify that callback method return a list of string
        map<string, string> results = (map<string, string>) callbackResults;
        system.assert(results.get('sign_channel') == 'Email'); // verify the embedded signing URL is null because this is just a mock callout
        system.debug(results.get('payload'));
        system.assert(results.get('payload') == 'The signing email has been sent to Test Customer Email'); // verify the envelope ID & document ID is not null, this is arbitrary result
    }

    @isTest
    static void UCA_TestSignInPlace() {
        // query test sales agreement
        Sales_Agreement__c salesAgreement = [SELECT ID, Name, Customer_Full_Name__c, Email__c, SOH_SONO__c, Branch_Code__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];

        // update the sales agreement to have UCA information
        salesAgreement.isSellerNotBuyer__c = true;
        salesAgreement.Seller_Full_Name__c = 'Used Car Seller';
        salesAgreement.Seller_NRIC__c = 'NRIC279';
        salesAgreement.Seller_Mobile_Number__c = '98347231';
        salesAgreement.Seller_Email_Address__c = 'test@gmail.com';
        salesAgreement.Seller_Date_Of_Birth__c = Date.newInstance(1990, 09, 02);
        salesAgreement.Seller_Street_Name__c = '175 Bencollen street';
        update salesAgreement;
		
        // query the content document and update name
        ID cdID = [SELECT ID, ContentDocumentID, Title FROM ContentVersion WHERE Title LIKE '%TEST%'].ContentDocumentID;
        ContentDocument cd = [SELECT ID, Title FROM ContentDocument WHERE ID = :cdID];
        cd.Title = 'Third Party Trade-In Agreement_' + salesAgreement.Name + '_';
        update cd;
        
        // create the continuation
        EnvelopeSendController controller = new EnvelopeSendController();
        Continuation signingContinuation = (Continuation) EnvelopeSendController.UCA_SigningProcess(salesAgreement.ID, false);
        
        // verify that the continuation has the proper requests
        string state = EnvelopeSendController.STATE_FOR_TEST;
        Map<string, HttpRequest> requests = signingContinuation.getRequests();
        
        // perform mock callout (i.e skip the callout and invoke callback method)
        Test.setContinuationResponse(state, DocusignMockHttpResponseGenerator.envelopeCreateRespond(requests.get(state)));
        
        // invoke call back
        Object callbackResults = Test.invokeContinuationMethod(controller, signingContinuation);

        // verify that callback method return a list of string
        map<string, string> results = (map<string, string>) callbackResults;
        system.assert(results.get('sign_channel') == 'URL'); // verify the embedded signing URL is null because this is just a mock callout
        system.debug(results.get('payload'));
        system.assert(results.get('payload') == ''); // verify the envelope ID & document ID is not null, this is arbitrary result
    }

    // test update envelope ID method
    @isTest
    static void updateEnvelopeID_Test() {
        
        // query test sales agreement
        Sales_Agreement__c salesAgreement = [SELECT ID, Customer_Full_Name__c, Email__c, SOH_SONO__c, Branch_Code__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
        string currentSAID = salesAgreement.ID;

        // get the content version
        ContentDocumentLink cv = [SELECT ID, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :currentSAID];
        
        // invoke test method
        Test.startTest();
        EnvelopeSendController.updateEnvelopeID(currentSAID, '123456', (string) cv.ContentDocumentId, 2, 'SA');
        Test.stopTest();

        // query test sales agreement to check update result
        salesAgreement = [SELECT ID, DocuSign_Envelope_ID__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
        system.assertEquals('123456', salesAgreement.DocuSign_Envelope_ID__c);
    }

    // test delete signing group users
    @isTest
    static void updateSigningGroupsUsers_Test_Delete() {
        // query the signing group member need to delete
        DocuSign_Recipient__c deleteMember = [SELECT User__c, Signing_Group__c FROM DocuSign_Recipient__c WHERE Recipient_Email__c = 'test@jcc.com'];
        string signingGroupID = deleteMember.Signing_Group__c;
        List<ID> userIDsToUpdate = new List<ID> {deleteMember.User__c};

        // set mock response
        Test.setMock(HttpCalloutMock.class, new DocusignMockHttpResponseGenerator());

        // invoke the delete callout
        Test.startTest();
        EnvelopeSendController.updateSigningGroupsUsers(signingGroupID, userIDsToUpdate, true);
        Test.stopTest();
    }

    // test insert signing group users
    @isTest
    static void updateSigningGroupsUsers_Test_Add() {
        // query the signing group member need to add
        DocuSign_Recipient__c deleteMember = [SELECT User__c, Signing_Group__c FROM DocuSign_Recipient__c WHERE Recipient_Email__c = 'test@jcc.com'];
        string signingGroupID = deleteMember.Signing_Group__c;
        List<ID> userIDsToUpdate = new List<ID> {deleteMember.User__c};

        // set mock response
        Test.setMock(HttpCalloutMock.class, new DocusignMockHttpResponseGenerator());

        // invoke the delete callout
        Test.startTest();
        EnvelopeSendController.updateSigningGroupsUsers(signingGroupID, userIDsToUpdate, false);
        Test.stopTest();
    }

    // test delete signing group user
    @isTest
    static void updateSigningGroupsUser_Test_Delete() {
        // query the signing group member need to delete
        DocuSign_Recipient__c deleteMember = [SELECT Signing_Group__c, Recipient_Name__c, Recipient_Email__c FROM DocuSign_Recipient__c WHERE Recipient_Email__c = 'test@jcc.com'];
        string signingGroupID = deleteMember.Signing_Group__c;
        string userName = deleteMember.Recipient_Name__c;
        string userEmail = deleteMember.Recipient_Email__c;

        // set mock response
        Test.setMock(HttpCalloutMock.class, new DocusignMockHttpResponseGenerator());

        // invoke the delete callout
        Test.startTest();
        EnvelopeSendController.updateSigningGroupsUser(signingGroupID, userName, userEmail, true);
        Test.stopTest();
    }

    // test insert signing group user
    @isTest
    static void updateSigningGroupsUser_Test_Add() {
        // query the signing group member need to add
        DocuSign_Recipient__c deleteMember = [SELECT Signing_Group__c, Recipient_Name__c, Recipient_Email__c FROM DocuSign_Recipient__c WHERE Recipient_Email__c = 'test@jcc.com'];
        string signingGroupID = deleteMember.Signing_Group__c;
        string userName = deleteMember.Recipient_Name__c;
        string userEmail = deleteMember.Recipient_Email__c;

        // set mock response
        Test.setMock(HttpCalloutMock.class, new DocusignMockHttpResponseGenerator());

        // invoke the delete callout
        Test.startTest();
        EnvelopeSendController.updateSigningGroupsUser(signingGroupID, userName, userEmail, false);
        Test.stopTest();
    }

    @isTest
    static void getTemplateID_Test() {

        // get the testing salesagreement
        Sales_Agreement__c salesAgreement = [SELECT ID, SOH_SONO__c, Branch_Code__c FROM Sales_Agreement__c];
        system.debug('*********************');
        system.debug(salesAgreement.Branch_Code__c);

        
        // invoke method
        ID templateID = EnvelopeSendController.getTemplateID(salesAgreement.ID);

        // assertion
        system.assert(!string.isBlank(templateID));
    }

    @isTest
    static void getUCATemplateID_Test() {
        // get the testing salesagreement
        Sales_Agreement__c salesAgreement = [SELECT ID, SOH_SONO__c, Branch_Code__c FROM Sales_Agreement__c];
        system.debug('*********************');
        system.debug(salesAgreement.Branch_Code__c);

        
        // invoke method
        ID templateID = EnvelopeSendController.getUCATemplateID(salesAgreement.ID);

        // assertion
        //system.assert(string.isBlank(templateID));
    }

    @isTest
    static void embeddedSignSession_Test() {

        // prepare arguments
        string ACCOUNT_ID = '123456';
        string ENVELOPE_ID = '654321';
        string ACCESS_TOKEN = 'ACCESSTOKEN';
        string RECIPIENT_ID = '1';
        string CLIENT_USER_ID = '1';
        DocuSign_Recipient__c deleteMember = [SELECT Recipient_Name__c, Recipient_Email__c FROM DocuSign_Recipient__c WHERE Recipient_Email__c = 'test@jcc.com'];
        string userName = deleteMember.Recipient_Name__c;
        string userEmail = deleteMember.Recipient_Email__c;

        // invoke method
        string embeddedURL = EnvelopeSendController.embeddedSignSession(ACCOUNT_ID, ENVELOPE_ID, ACCESS_TOKEN, userName, userEmail, RECIPIENT_ID, CLIENT_USER_ID);

        // assertion
        system.assertEquals(null, embeddedURL);
    }
    
    @isTest
    static void createSalesOrder_Test() {
        Sales_Agreement__c salesAgreement = [SELECT ID, Customer_Full_Name__c, Email__c, SOH_SONO__c, Branch_Code__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
        Test.setMock(HttpCalloutMock.class, new VSMS_CalloutMock());
        Test.startTest();
        Boolean o = EnvelopeSendController.createSalesOrder(salesAgreement.ID);
        Test.stopTest();
        system.assertEquals(true, o);
    }
}
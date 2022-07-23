@isTest
private class DocusignEnvelopeTest {
    
    @testSetup
    private static void setUp() {
        // create a sales agreement record for test
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';
        string customerEMail = 'test@123.com';
        string CUSTOMER_SIGN_ORDER = '1';

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
        insert stockReservation;

        //* sales agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.ID, customerName);
        
        salesAgreement.emailaddress__c = 'test@aodigy.com';
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
        salesAgreement.Branch_Code__c = branchCode;
        update salesAgreement;
        
        //* attach a document to sales agreement
        ID documentContentID = Test_DataFactory.attachDSA(salesAgreement.ID);

        // create signing group for the sales agreement
        Signing_Group__c testSigningGroup = new Signing_Group__c(Name = 'Test', Branch_Code__c = branchCode, Endorse_Group_ID__c = '123456', Endorse_Group_Name__c = 'Test', Approve_Group_ID__c = '123457', Approve_Group_Name__c = 'Test');
        insert testSigningGroup;

        // create testing user
        User testUser = Test_DataFactory.createUser(true, 'Test DocuSign Callout', 'Test');

        // create endorser user for testing
        DocuSign_Recipient__c testSigningUser = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Endorser', User__c = testUser.ID);
        insert testSigningUser;
    }
    
	@isTest
    private static void testConstructor1() {
        
        // customer configuration metadata
        DocuSign_Recipient_Configuration__mdt recipientConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = true, Recipient_Type__c = 'Signer', Signing_Order__c = '1', Signing_Tab_Anchor_String__c = '\\s1\\');
        // signing group information map
        Map<string, string> endorserInfo = new Map<string, string> {'ID' => '123', 'Name' => 'Endorser'};
        Map<string, string> approverInfo = new Map<string, string> {'ID' => '456', 'Name' => 'Approver'};
        Map<string, Map<string, string>> signingGroupInfo = new Map<string, Map<string, string>> {'Endorser' => endorserInfo, 'Approver' => approverInfo};
        // query SA
        Sales_Agreement__c SA = [SELECT Customer_Full_Name__c, Company_Name__c, emailaddress__c, GMS_Package__c, SOH_SONO__c, Proposed_Commission__c, Seller_Email_Address__c, Seller_Full_Name__c, Proposed_Commission_Reason__c, Registration_Type__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
		
        // recipient
        DocusignSignerDetail signer = DocusignSignerDetail.build(recipientConfiguration, signingGroupInfo, SA);
        
        // document
        DocusignDocument doc = new DocusignDocument('Document', 'pdf', '1');
        
        DocusignEnvelope o = new DocusignEnvelope('sent', 'subject', new DocusignSigners(new List<DocusignSignerDetail>{signer}), new List<DocusignDocument>{doc});
        system.assertEquals('sent', o.status);
        system.assertEquals('subject', o.emailSubject);
        system.assertEquals(1, o.recipients.signers.size());
        system.assertEquals(1, o.documents.size());
    }
    
    @isTest
    private static void testConstructor2() {
        // customer configuration metadata
        DocuSign_Recipient_Configuration__mdt recipientConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = true, Recipient_Type__c = 'Signer', Signing_Order__c = '1', Signing_Tab_Anchor_String__c = '\\s1\\');
        // signing group information map
        Map<string, string> endorserInfo = new Map<string, string> {'ID' => '123', 'Name' => 'Endorser'};
        Map<string, string> approverInfo = new Map<string, string> {'ID' => '456', 'Name' => 'Approver'};
        Map<string, Map<string, string>> signingGroupInfo = new Map<string, Map<string, string>> {'Endorser' => endorserInfo, 'Approver' => approverInfo};
        // query SA
        Sales_Agreement__c SA = [SELECT Customer_Full_Name__c, Company_Name__c, emailaddress__c, GMS_Package__c, SOH_SONO__c, Proposed_Commission__c, Seller_Email_Address__c, Seller_Full_Name__c, Proposed_Commission_Reason__c, Registration_Type__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
		
        // recipient
        DocusignSignerDetail signer = DocusignSignerDetail.build(recipientConfiguration, signingGroupInfo, SA);
        
        DocusignEnvelope o = new DocusignEnvelope('sent', 'subject', new DocusignSigners(new List<DocusignSignerDetail>{signer}));
        system.assertEquals('sent', o.status);
        system.assertEquals('subject', o.emailSubject);
        system.assertEquals(1, o.recipients.signers.size());
    }
}
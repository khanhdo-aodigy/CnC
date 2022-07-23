@isTest
private class DocusignSignersTest {
	@testSetup
    private static void setUp() {
        // create a sales agreement record for test
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';
        string customerEMail = 'test@123.com';
        string CUSTOMER_SIGN_ORDER = '1';

        // create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', Model_Master__c = modelMaster.ID);
        insert modelYearMaster;
        
        // create stock reservation from master data
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(true, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);

        // sales agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(true, branchCode, agreementNo, stockReservation.ID, customerName);
        salesAgreement.Branch_Code__c = branchCode;
        salesAgreement.emailaddress__c = customerEMail;
        update salesAgreement; 
    }
    
    @isTest
    private static void testRecipients() {
        // customer configuration metadata
        DocuSign_Recipient_Configuration__mdt customerConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = true, Recipient_Type__c = 'Signer', Signing_Order__c = '1', Signing_Tab_Anchor_String__c = '\\s1\\');
        DocuSign_Recipient_Configuration__mdt carbonCopyConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = true, Recipient_Type__c = 'Carbon copy', Signing_Order__c = '2');
        DocuSign_Recipient_Configuration__mdt endorserConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = false, Recipient_Type__c = 'Signer', Signing_Order__c = '2', Signing_Tab_Anchor_String__c = '\\s2\\', Signing_Group__c = 'Endorser');
        DocuSign_Recipient_Configuration__mdt approverConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = false, Recipient_Type__c = 'Signer', Signing_Order__c = '3', Signing_Tab_Anchor_String__c = '\\s3\\', Signing_Group__c = 'Approver');
        // signing group information map
        Map<string, string> endorserInfo = new Map<string, string> {'ID' => '123', 'Name' => 'Endorser'};
        Map<string, string> approverInfo = new Map<string, string> {'ID' => '456', 'Name' => 'Approver'};
        Map<string, Map<string, string>> signingGroupInfo = new Map<string, Map<string, string>> {'Endorser' => endorserInfo, 'Approver' => approverInfo};
        // query SA
        Sales_Agreement__c SA = [SELECT Customer_Full_Name__c, Company_Name__c, emailaddress__c, GMS_Package__c, SOH_SONO__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
		List<DocusignSignerDetail> recipients = new List<DocusignSignerDetail>();
        // build recipients
        recipients.add(DocusignSignerDetail.build(customerConfiguration, signingGroupInfo, SA));
        recipients.add(DocusignSignerDetail.build(carbonCopyConfiguration, signingGroupInfo, SA));
        recipients.add(DocusignSignerDetail.build(endorserConfiguration, signingGroupInfo, SA));
        recipients.add(DocusignSignerDetail.build(approverConfiguration, signingGroupInfo, SA));
        DocusignSigners o = new DocusignSigners(recipients);
        
        system.assertEquals(1, o.carbonCopies.size());
        system.assertEquals(3, o.signers.size());
    }
}
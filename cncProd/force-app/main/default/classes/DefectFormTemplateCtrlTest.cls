@isTest
private class DefectFormTemplateCtrlTest {
    @testSetup
    static void setUp() {
        // Create a sales agreement record for test
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';

        // Create master data
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
        
        // Create stock reservation from master data
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation;

        // Create Sales agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.ID, customerName);
        
        salesAgreement.emailaddress__c = 'test@aodigy.com';
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
        salesAgreement.Branch_Code__c = branchCode;
        update salesAgreement;

        // Create defect for sales agreement
        Defect__c defect = new Defect__c(Sales_Agreement__c = salesAgreement.Id,
                                         Description_of_Defect__c = 'Defect test',
                                         Type_of_Defect__c = 'Other');
        
        insert defect;

        ContentVersion contentVersion = new ContentVersion(Title = 'Image_01',
                                                           PathOnClient = 'Image_01.jpg',
                                                           VersionData = Blob.valueOf('Image_01'),
                                                           IsMajorVersion = true);
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = defect.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
     }

	@isTest
    static void test() {
        Sales_Agreement__c salesAgreement = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, Service_Center_Email__c FROM Sales_Agreement__c];
        salesAgreement.emailaddress__c = 'abc@test.com';
        salesAgreement.PreferredServiceCenter__c = 'Alexandra';
        update salesAgreement;
        Test.startTest();
        DefectFormTemplateCtrl.sendEmail(salesAgreement.Id);
		Integer invocations = Limits.getEmailInvocations();
		system.assertEquals(1, invocations, 'Send 1 email');
        Test.stopTest();
    }
}
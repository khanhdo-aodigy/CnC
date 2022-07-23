@isTest
private with sharing class VDCpdfCtrl_Test {
    @testSetup
    private static void makeData() {
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

        //* create handover items and vehicle checklist
        SA_Vehicle_Checklist__c hi1 = new SA_Vehicle_Checklist__c(Checklist_Type__c = 'Handover Items', Franchise_Code__c = 'KIAPC', Details__c = 'hi1', Position__c = 1, Additional_Notes__c = '');
        SA_Vehicle_Checklist__c hi2 = new SA_Vehicle_Checklist__c(Checklist_Type__c = 'Handover Items', Franchise_Code__c = 'KIAPC', Details__c = 'hi2', Position__c = 2, Additional_Notes__c = '');
        SA_Vehicle_Checklist__c hi3 = new SA_Vehicle_Checklist__c(Checklist_Type__c = 'Handover Items', Franchise_Code__c = 'KIAPC', Details__c = 'hi3', Position__c = 3, Additional_Notes__c = '');
        SA_Vehicle_Checklist__c vc1 = new SA_Vehicle_Checklist__c(Checklist_Type__c = 'Vehicle Checklist', Franchise_Code__c = 'KIAPC', Details__c = 'vc1', Position__c = 1, Additional_Notes__c = '');
        SA_Vehicle_Checklist__c vc2 = new SA_Vehicle_Checklist__c(Checklist_Type__c = 'Vehicle Checklist', Franchise_Code__c = 'KIAPC', Details__c = 'vc2', Position__c = 1, Additional_Notes__c = '');
        insert hi1; insert hi2; insert vc1; insert vc2;
    }

    @istest
    private static void testConstructor() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c];
        Test.startTest();
        PageReference page = Page.VehicleDeliveryCertificate_pdf;
        page.getParameters().put('id', sa.ID);
        Test.setCurrentPage(page);
        VehicleDeliveryCertificate_pdfCtrl instance = new VehicleDeliveryCertificate_pdfCtrl();
        Test.stopTest();
    }
}
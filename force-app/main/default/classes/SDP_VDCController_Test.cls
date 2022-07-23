@isTest
private with sharing class SDP_VDCController_Test {
    @testSetup
    private static void makeData(){
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
    }

    @isTest
    private static void testGetRecords() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c];
        list<sObject> result = SDP_VehicleDeliveryCertificateController.getRecords('Sales_Agreement__c', 'Id', sa.Id, '');
        system.assertEquals(1, result.size());
    }

    @isTest
    private static void testSaveCertificate() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c];
        map<string, string> changes = new map<string, string>();
        changes.put('VDC_Main_Accessories_Cart__c', '');
        changes.put('VDC_Additional_Accessories_Cart__c', '');
        changes.put('Car_Collection_Date__c', 'true');
        SDP_VehicleDeliveryCertificateController.saveCertificate(sa.Id, changes);

        Sales_Agreement__c sa2 = [SELECT ID, Acknowledgement_Vehicle_Delivery__c, Car_Collection_Date__c FROM Sales_Agreement__c];
        system.assertEquals(Date.today(), sa2.Car_Collection_Date__c);
    }
    
    @isTest
    private static void testCreateAttachment() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c];
        Id documentID = SDP_VehicleDeliveryCertificateController.createAttachment(sa.ID);
        ContentDocument cd = [SELECT ID FROM ContentDocument];
        system.assertEquals(documentID, cd.ID);
    }
    
    @isTest
    private static void testSendEmail() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c];
        Id documentID = SDP_VehicleDeliveryCertificateController.createAttachment(sa.ID);
        SDP_VehicleDeliveryCertificateController.sendEmail(sa.ID);
    }
}
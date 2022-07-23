@isTest
public with sharing class BPETemplatePreviewCtrl_Test {
    
    @testSetup
    static void makeData(){
        
        // Foler
        
        
        // Email Template
        /*EmailTemplate NORMAL = new EmailTemplate(developerName = 'NORMAL', FolderId = 'folder', TemplateType = 'Text', Name = 'NORMAL', Subject = 'NORMAL', HtmlValue = 'NORMAL', Body = 'NORMAL');
        insert NORMAL;
        EmailTemplate DEFICIT = new EmailTemplate(developerName = 'DEFICIT', FolderId = 'folder', TemplateType = 'Text', Name = 'DEFICIT', Subject = 'DEFICIT', HtmlValue = 'DEFICIT', Body = 'DEFICIT');
        insert DEFICIT;
        EmailTemplate DEFICIT_RA = new EmailTemplate(developerName = 'DEFICIT_RA', FolderId = 'folder', TemplateType = 'Text', Name = 'DEFICIT_RA', Subject = 'DEFICIT_RA', HtmlValue = 'DEFICIT_RA', Body = 'DEFICIT_RA');
        insert DEFICIT_RA;
        EmailTemplate CUSTOMER_REFUND = new EmailTemplate(developerName = 'CUSTOMER_REFUND', FolderId = 'folder', TemplateType = 'Text', Name = 'CUSTOMER_REFUND', Subject = 'CUSTOMER_REFUND', HtmlValue = 'CUSTOMER_REFUND', Body = 'CUSTOMER_REFUND');
        insert CUSTOMER_REFUND;*/
        
        // create a sales agreement with arbitrary envelope ID
        string branchCode = 'CCK';
        string agreementNo_CF = 'ALOHA_CF';
        string agreementNo_NORMAL = 'ALOHA_NORM';
        string agreementNo_DEFICIT = 'ALOHA_DEF';
        string agreementNo_DEFICIT_RA = 'ALOHA_RA';
        string customerName = 'Imaginary Customer';
        string customerEMail = 'test@123.com';

        // create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', Model_Master__c = modelMaster.ID);
        insert modelYearMaster;

        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test', ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;

        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC', Model_Master__c = modelMaster.Id, PKH_STATUS__c = 'A');
        insert pckHeader;
        
        // create stock reservation from master data (CF)
        Stock_Reservation__c stockReservation_CF = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation_CF.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation_CF;
        // create stock reservation from master data (NORMAL)
        Stock_Reservation__c stockReservation_NORM = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation_NORM.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation_NORM;
        // create stock reservation from master data (DEFICIT)
        Stock_Reservation__c stockReservation_DEF = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation_DEF.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation_DEF;
        // create stock reservation from master data (DEFICIT_RA)
        Stock_Reservation__c stockReservation_DEF_RA = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation_DEF_RA.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation_DEF_RA;
        
        //CUSTOMER_FUND SA
        Sales_Agreement__c salesAgreement_CUSTOMER_REFUND = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo_CF, stockReservation_CF.ID, customerName);
        salesAgreement_CUSTOMER_REFUND.Package_Header__c = pckHeader.Id;
        salesAgreement_CUSTOMER_REFUND.Branch_Code__c = 'CCK';
        salesAgreement_CUSTOMER_REFUND.emailaddress__c = 'test@gmail.com';

        //NORMAL SA
        Sales_Agreement__c salesAgreement_NORMAL = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo_NORMAL, stockReservation_NORM.ID, customerName);
        salesAgreement_NORMAL.Vehicle_Purchase_Price__c = 11000;
        salesAgreement_NORMAL.Trade_in_Value__c  = 900;
        salesAgreement_NORMAL.Package_Header__c = pckHeader.Id;
        salesAgreement_NORMAL.Branch_Code__c = 'CCK';
        salesAgreement_NORMAL.emailaddress__c = 'test@gmail.com';

        //DEFICIT SA
        Sales_Agreement__c salesAgreement_DEFICIT = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo_DEFICIT, stockReservation_DEF.ID, customerName);
        salesAgreement_DEFICIT.Vehicle_Purchase_Price__c = 11000;
        salesAgreement_DEFICIT.Trade_in_Value__c  = -900;
        salesAgreement_DEFICIT.GMS_Package__c = 1000;
        salesAgreement_DEFICIT.Package_Header__c = pckHeader.Id;
        salesAgreement_DEFICIT.Branch_Code__c = 'CCK';
        salesAgreement_DEFICIT.emailaddress__c = 'test@gmail.com';

        //DEFICIT_RA SA
        Sales_Agreement__c salesAgreement_DEFICIT_RA = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo_DEFICIT_RA, stockReservation_DEF_RA.ID, customerName);
        salesAgreement_DEFICIT_RA.Vehicle_Purchase_Price__c = 11000;
        salesAgreement_DEFICIT_RA.Trade_in_Value__c  = -900;
        salesAgreement_DEFICIT_RA.Package_Header__c = pckHeader.Id;
        salesAgreement_DEFICIT_RA.Branch_Code__c = 'CCK';
        salesAgreement_DEFICIT_RA.emailaddress__c = 'test@gmail.com';

        List<Sales_Agreement__c> SA = new List<Sales_Agreement__c> {salesAgreement_CUSTOMER_REFUND, salesAgreement_NORMAL, salesAgreement_DEFICIT, salesAgreement_DEFICIT_RA};
        insert SA;
        
        
    }

    @isTest
    static void getSalesAgreement_Test() {
        Sales_Agreement__c salesAgreement = [SELECT ID, SOH_SONO__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_CF'];

        // render VF page
        PageReference pageRef = Page.BPETemplatePreview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', salesAgreement.ID);
        BPETemplatePreviewCtrl ctrl = new BPETemplatePreviewCtrl();

        // invoke getSalesAgreement() and assert
        Sales_Agreement__c salesAgreement_VfPage = ctrl.getSalesAgreement();
        system.assertEquals(salesAgreement.SOH_SONO__c, salesAgreement_VfPage.SOH_SONO__c);
    }

    @isTest
    static void getBPETemplate_CUSTOMER_REFUND_Test() {
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_CF'];

        // render VF page
        PageReference pageRef = Page.BPETemplatePreview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', salesAgreement.ID);
        BPETemplatePreviewCtrl ctrl = new BPETemplatePreviewCtrl();

        // invoke getBPETemplate() and assert
        string htmlBody = ctrl.getBPETemplate();
        system.assert(htmlBody != null);
    }

    @isTest
    static void getBPETemplate_NORMAL_Test() {
        Sales_Agreement__c salesAgreement = [SELECT ID, BalancePayment__c, TradeInBalance__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_NORM'];
        system.debug(salesAgreement.BalancePayment__c);
        system.debug(salesAgreement.TradeInBalance__c);
        // render VF page
        PageReference pageRef = Page.BPETemplatePreview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', salesAgreement.ID);
        BPETemplatePreviewCtrl ctrl = new BPETemplatePreviewCtrl();

        // invoke getBPETemplate() and assert
        string htmlBody = ctrl.getBPETemplate();
        system.assert(htmlBody != null);
    }

    @isTest
    static void getBPETemplate_DEFICIT_Test() {
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_DEF'];

        // render VF page
        PageReference pageRef = Page.BPETemplatePreview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', salesAgreement.ID);
        BPETemplatePreviewCtrl ctrl = new BPETemplatePreviewCtrl();

        // invoke getBPETemplate() and assert
        string htmlBody = ctrl.getBPETemplate();
        system.assert(htmlBody != null);
    }

    @isTest
    static void getBPETemplate_DEFICIT_RA_Test() {
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_RA'];

        // render VF page
        PageReference pageRef = Page.BPETemplatePreview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', salesAgreement.ID);
        BPETemplatePreviewCtrl ctrl = new BPETemplatePreviewCtrl();

        // invoke getBPETemplate() and assert
        string htmlBody = ctrl.getBPETemplate();
        system.assert(htmlBody != null);
    }

    @isTest
    static void emailToCustomer_Test() {
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_CF'];

        // render VF page
        PageReference pageRef = Page.BPETemplatePreview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', salesAgreement.ID);
        BPETemplatePreviewCtrl ctrl = new BPETemplatePreviewCtrl();

        // invoke email method
        ctrl.emailToCustomer();
    }
}
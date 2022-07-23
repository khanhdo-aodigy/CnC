@isTest
private class EmailNotificationServiceTest {
    @testSetup
    static void setUp() {
        // Create a sales agreement record for test
        //string branchCode = 'CCK';
        //string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';

        // Create model master datas
        Model_Master__c modelMasterCCK = new Model_Master__c(Name = 'Test Model Code CCK', Branch_Code__c = 'CCK', Franchise_Code__c = 'KIAPC');
        insert modelMasterCCK;
        Model_Master__c modelMasterCCA = new Model_Master__c(Name = 'Test Model Code CCA', Branch_Code__c = 'CCA', Franchise_Code__c = 'MITPC');
        insert modelMasterCCA;
        Model_Master__c modelMasterCCF = new Model_Master__c(Name = 'Test Model Code CCF', Branch_Code__c = 'CCF', Franchise_Code__c = 'CITPC');
        insert modelMasterCCF;
        Model_Master__c modelMasterDS = new Model_Master__c(Name = 'Test Model Code DS', Major_Group_Code__c = 'DS5', Branch_Code__c = 'CCF', Franchise_Code__c = 'CITPC');
        insert modelMasterDS;

        // Create color master datas
        Color_Master__c colorMasterCCK = new Color_Master__c(Name = 'Test Color Code CCK', Branch_Code__c = 'CCK', Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMasterCCK;
        Color_Master__c colorMasterCCA = new Color_Master__c(Name = 'Test Color Code CCA', Branch_Code__c = 'CCA', Franchise_Code__c = 'MITPC', ColorCode__c = 'Z3P1');
        insert colorMasterCCA;
        Color_Master__c colorMasterCCF = new Color_Master__c(Name = 'Test Color Code CCF', Branch_Code__c = 'CCF', Franchise_Code__c = 'CITPC', ColorCode__c = 'Z3P2');
        insert colorMasterCCF;
        Color_Master__c colorMasterDS = new Color_Master__c(Name = 'Test Color Code DS', Branch_Code__c = 'CCF', Franchise_Code__c = 'CITPC', ColorCode__c = 'Z3P3');
        insert colorMasterDS;

        // Create trim master datas
        Trim_Master__c trimMasterCCK = new Trim_Master__c(Name = 'Test Trim Code CCK', Branch_Code__c = 'CCK', Franchise_Code__c = 'KIAPC');
        insert trimMasterCCK;
        Trim_Master__c trimMasterCCA = new Trim_Master__c(Name = 'Test Trim Code CCA', Branch_Code__c = 'CCA', Franchise_Code__c = 'MITPC');
        insert trimMasterCCA;
        Trim_Master__c trimMasterCCF = new Trim_Master__c(Name = 'Test Trim Code CCF', Branch_Code__c = 'CCF', Franchise_Code__c = 'CITPC');
        insert trimMasterCCF;
        Trim_Master__c trimMasterDS = new Trim_Master__c(Name = 'Test Trim Code DS', Branch_Code__c = 'CCF', Franchise_Code__c = 'CITPC');
        insert trimMasterDS;

        // Create model year master datas
        Model_Year_Master__c modelYearMasterCCK = new Model_Year_Master__c(Name = 'Test Model Year Code CCK', Branch_Code__c = 'CCK', Franchise_Code__c = 'KIAPC', Model_Master__c = modelMasterCCK.ID);
        insert modelYearMasterCCK;
        Model_Year_Master__c modelYearMasterCCA = new Model_Year_Master__c(Name = 'Test Model Year Code CCA', Branch_Code__c = 'CCA', Franchise_Code__c = 'MITPC', Model_Master__c = modelMasterCCA.ID);
        insert modelYearMasterCCA;
        Model_Year_Master__c modelYearMasterCCF = new Model_Year_Master__c(Name = 'Test Model Year Code CCF', Branch_Code__c = 'CCF', Franchise_Code__c = 'CITPC', Model_Master__c = modelMasterCCF.ID);
        insert modelYearMasterCCF;
        Model_Year_Master__c modelYearMasterDS = new Model_Year_Master__c(Name = 'Test Model Year Code DS', Branch_Code__c = 'CCF', Franchise_Code__c = 'CITPC', Model_Master__c = modelMasterDS.ID);
        insert modelYearMasterDS;
        
        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Create Package Header
		Package_Header__c pckHeaderCCK = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                               Model_Master__c = modelMasterCCK.Id,
                                                               PKH_STATUS__c = 'A');
        insert pckHeaderCCK;
        Package_Header__c pckHeaderCCA = new Package_Header__c(PKH_FRN_FRNCD__c = 'MITPC',
                                                               Model_Master__c = modelMasterCCA.Id,
                                                               PKH_STATUS__c = 'A');
        insert pckHeaderCCA;
        Package_Header__c pckHeaderCCF = new Package_Header__c(PKH_FRN_FRNCD__c = 'CITPC',
                                                               Model_Master__c = modelMasterCCF.Id,
                                                               PKH_STATUS__c = 'A');
        insert pckHeaderCCF;
        Package_Header__c pckHeaderDS = new Package_Header__c(PKH_FRN_FRNCD__c = 'CITPC',
                                                              Model_Master__c = modelMasterDS.Id,
                                                              PKH_STATUS__c = 'A');
        insert pckHeaderDS;

        // Create stock reservation from master data
        Stock_Reservation__c srCCK = Test_DataFactory.StockReservation(false, modelMasterCCK.ID, colorMasterCCK.ID, trimMasterCCK.ID, modelYearMasterCCK.ID);
        srCCK.Package_Header_From_PickList__c = pckHeaderCCK.Id;
        insert srCCK;
        Stock_Reservation__c srCCA = Test_DataFactory.StockReservation(false, modelMasterCCA.ID, colorMasterCCA.ID, trimMasterCCA.ID, modelYearMasterCCA.ID);
        srCCA.Package_Header_From_PickList__c = pckHeaderCCA.Id;
        insert srCCA;
        Stock_Reservation__c srCCF = Test_DataFactory.StockReservation(false, modelMasterCCF.ID, colorMasterCCF.ID, trimMasterCCF.ID, modelYearMasterCCF.ID);
        srCCF.Package_Header_From_PickList__c = pckHeaderCCF.Id;
        insert srCCF;
        Stock_Reservation__c srDS = Test_DataFactory.StockReservation(false, modelMasterDS.ID, colorMasterDS.ID, trimMasterDS.ID, modelYearMasterDS.ID);
        srDS.Package_Header_From_PickList__c = pckHeaderDS.Id;
        insert srDS;
        
        // Create BAM
		Business_Associate_Master__c bam = new Business_Associate_Master__c(Name = 'Test BAM', BAM_TYPE__c = 'FIN', BAM_INHOUSE__c = 'Y');
        insert bam;

        // Create sales agreement
        Sales_Agreement__c saCCK = Test_DataFactory.createSalesAgreement(false, 'CCK', 'AK12345', srCCK.ID, customerName);
        saCCK.emailaddress__c = 'test@aodigy.com';
        saCCK.Package_Header__c = pckHeaderCCK.Id;
        saCCK.Finance_Company_Lookup__c = bam.Id;
        insert saCCK;
        saCCK.Branch_Code__c = 'CCK';
        update saCCK;

        Sales_Agreement__c saCCA = Test_DataFactory.createSalesAgreement(false, 'CCA', 'AJ12345', srCCA.ID, customerName);
        saCCA.emailaddress__c = 'test@aodigy.com';
        saCCA.Package_Header__c = pckHeaderCCA.Id;
        saCCA.Finance_Company_Lookup__c = bam.Id;
        insert saCCA;
        saCCA.Branch_Code__c = 'CCA';
        update saCCA;

        Sales_Agreement__c saCCF = Test_DataFactory.createSalesAgreement(false, 'CCF', 'AC12345', srCCF.ID, customerName);
        saCCF.emailaddress__c = 'test@aodigy.com';
        saCCF.Package_Header__c = pckHeaderCCF.Id;
        saCCF.Finance_Company_Lookup__c = bam.Id;
        insert saCCF;
        saCCF.Branch_Code__c = 'CCF';
        update saCCF;

        Sales_Agreement__c saDS = Test_DataFactory.createSalesAgreement(false, 'CCF', 'AC123456', srDS.ID, customerName);
        saDS.emailaddress__c = 'test@aodigy.com';
        saDS.Package_Header__c = pckHeaderDS.Id;
        insert saDS;
        saDS.Branch_Code__c = 'CCF';
        update saDS;

        // Create document
        Document document;
        
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'KIA_VDAF_Private';
        document.IsPublic = true;
        document.Name = 'Authorization Form';
        document.FolderId = UserInfo.getUserId();
        insert document;


        // Create Email settings
        // For CCK
        Email_Setting__c es = new Email_Setting__c(Name = 'Test Email Setting 1', Branch_Code__c = 'CCK', Registration_Type__c = 'All',
                                                   Email_To__c = 'test1@gmail.com', Email_Cc__c = 'test2@gmail.com;test3@gmai.com',
                                                   Finance_Company_Lookup__c = bam.Id);
       	insert es;
        // For CCA
        Email_Setting__c es1 = new Email_Setting__c(Name = 'Test Email Setting 2', Branch_Code__c = 'CCA', Registration_Type__c = 'All',
                                                   Email_To__c = 'test1@gmail.com', Email_Cc__c = 'test2@gmail.com;test3@gmai.com',
                                                   Finance_Company_Lookup__c = bam.Id);
       	insert es1;
        // For CCF
        Email_Setting__c es2 = new Email_Setting__c(Name = 'Test Email Setting 3', Branch_Code__c = 'CCF', Registration_Type__c = 'All',
                                                   Email_To__c = 'test1@gmail.com', Email_Cc__c = 'test2@gmail.com;test3@gmai.com',
                                                   Finance_Company_Lookup__c = bam.Id);
       	insert es2;

        ContentVersion contentVersion = new ContentVersion(Title = 'AJ20040031_Sales Agreement_27-08-2020_v2',
                                                           PathOnClient = 'AJ20040031_Sales Agreement_27-08-2020_v2.PDF',
                                                           VersionData = Blob.valueOf('AJ20040031_Sales Agreement_27-08-2020_v2'),
                                                           IsMajorVersion = true);
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = saCCK.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }

    @isTest
    static void Test_renderToEmail_private_CCK() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AK12345'];
        String templateNm = 'Registration_Email_Notification';

        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderToEmail(sa.Id, templateNm);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderToEmail_private_CCA() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AJ12345'];
        String templateNm = 'Registration_Email_Notification';

        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderToEmail(sa.Id, templateNm);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderToEmail_private_CCF() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AC12345'];
        String templateNm = 'Registration_Email_Notification';

        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderToEmail(sa.Id, templateNm);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderToEmail_private_CCF_DSModel() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AC123456'];
        String templateNm = 'Registration_Email_Notification';

        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderToEmail(sa.Id, templateNm);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderToEmail_company_CCK() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AK12345'];
        sa.Registration_Type__c = 'C';
        update sa;
        String templateNm = 'Registration_Email_Notification';

        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderToEmail(sa.Id, templateNm);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderToEmail_company_CCA() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AJ12345'];
        sa.Registration_Type__c = 'C';
        update sa;
        String templateNm = 'Registration_Email_Notification';

        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderToEmail(sa.Id, templateNm);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderToEmail_company_CCF() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AC12345'];
        sa.Registration_Type__c = 'C';
        update sa;
        String templateNm = 'Registration_Email_Notification';

        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderToEmail(sa.Id, templateNm);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderToEmail_company_CCF_DSModel() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AC123456'];
        sa.Registration_Type__c = 'C';
        update sa;
        String templateNm = 'Registration_Email_Notification';

        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderToEmail(sa.Id, templateNm);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderFinanceEmail_CCK() {
        Sales_Agreement__c sa = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, COE__r.Id, COE__r.COH_COENO__c, 
                                 		COE__r.COH_SUCCESSFROMDT__c, COE__r.COH_SUCCESSTODT__c, COE__r.COH_EXPMONTH__c,
                                 		Registration_Type__c, Branch_Code__c, DS_Model__c, Finance_Company_Lookup__c,
                                 		Finance_Company_In_House__c, Emailed_BAM__c
                                 FROM Sales_Agreement__c
                                 WHERE SOH_SONO__c = 'AK12345'];
		EmailTemplate template = EmailNotificationsService.getTemplate('Finance_Email');
        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderFinanceEmail(sa, template.Id);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderFinanceEmail_CCA() {
        Sales_Agreement__c sa = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, COE__r.Id, COE__r.COH_COENO__c, 
                                 		COE__r.COH_SUCCESSFROMDT__c, COE__r.COH_SUCCESSTODT__c, COE__r.COH_EXPMONTH__c,
                                 		Registration_Type__c, Branch_Code__c, DS_Model__c, Finance_Company_Lookup__c,
                                 		Finance_Company_In_House__c, Emailed_BAM__c
                                 FROM Sales_Agreement__c
                                 WHERE SOH_SONO__c = 'AJ12345'];
		EmailTemplate template = EmailNotificationsService.getTemplate('Finance_Email');
        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderFinanceEmail(sa, template.Id);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_renderFinanceEmail_CCF() {
        Sales_Agreement__c sa = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, COE__r.Id, COE__r.COH_COENO__c, 
                                 		COE__r.COH_SUCCESSFROMDT__c, COE__r.COH_SUCCESSTODT__c, COE__r.COH_EXPMONTH__c,
                                 		Registration_Type__c, Branch_Code__c, DS_Model__c, Finance_Company_Lookup__c,
                                 		Finance_Company_In_House__c, Emailed_BAM__c
                                 FROM Sales_Agreement__c
                                 WHERE SOH_SONO__c = 'AC12345'];
		EmailTemplate template = EmailNotificationsService.getTemplate('Finance_Email');
        Messaging.SingleEmailMessage singleEmailMsg = EmailNotificationsService.renderFinanceEmail(sa, template.Id);
		System.assertNotEquals(singleEmailMsg, null);
    }

    @isTest
    static void Test_sendFinanceEmail_InHouse() {
        Sales_Agreement__c sa = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, COE__r.Id, COE__r.COH_COENO__c, 
                                 		COE__r.COH_SUCCESSFROMDT__c, COE__r.COH_SUCCESSTODT__c, COE__r.COH_EXPMONTH__c,
                                 		Registration_Type__c, Branch_Code__c, DS_Model__c, Finance_Company_Lookup__c,
                                 		Finance_Company_In_House__c, Emailed_BAM__c
                                 FROM Sales_Agreement__c
                                 WHERE SOH_SONO__c = 'AK12345'];
        sa.Finance_Company_In_House__c = true;
        update sa;

        EmailNotificationsService.sendFinanceEmail(sa.Id);
    }

    @isTest
    static void Test_sendFinanceEmail_NotInHouse() {
        Sales_Agreement__c sa = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, COE__r.Id, COE__r.COH_COENO__c, 
                                 		COE__r.COH_SUCCESSFROMDT__c, COE__r.COH_SUCCESSTODT__c, COE__r.COH_EXPMONTH__c,
                                 		Registration_Type__c, Branch_Code__c, DS_Model__c, Finance_Company_Lookup__c,
                                 		Finance_Company_In_House__c, Emailed_BAM__c
                                 FROM Sales_Agreement__c
                                 WHERE SOH_SONO__c = 'AK12345'];
        try {
           EmailNotificationsService.sendFinanceEmail(sa.Id);
        } catch (Exception e) {
            
        }
    }
}
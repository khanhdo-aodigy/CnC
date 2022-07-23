@isTest
private class DocusignSignerDetailTest {
    
    @testSetup
    private static void setUp() {
        // create a sales agreement record for test
        /*string branchCode = 'CCK';
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
        
        
        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelMaster.Id,
                                                            PKH_STATUS__c = 'A');
        
        // create stock reservation from master data
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation;
		
        insert pckHeader;
        // sales agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.ID, customerName);
        salesAgreement.Branch_Code__c = branchCode;
        salesAgreement.emailaddress__c = customerEMail;
        salesAgreement.Date_Of_Birth__c = Date.today();
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.ARCA_Number__c = 'ABC123';
        salesAgreement.Registration_Type__c = 'C';
        insert salesAgreement;*/
        
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');       

        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        
        //Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation;
        
        //Create Accs Master
        Accessories_Master__c accMaster1 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Acc Test',
                                                                     ACM_ACCSCD__c = 'GMS5000',
                                                                     Rate__c = 5000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster1;
        
        Accessories_Master__c accMaster2 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Service Credit',
                                                                     ACM_ACCSCD__c = 'SVC1000',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster2;
        
        Accessories_Master__c accMaster3 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Accessories Credit',
                                                                     ACM_ACCSCD__c = 'ACC1000',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster3;
        
        // Create Accs Rate Master
        Accs_Rate_Master__c accRateMaster = new Accs_Rate_Master__c(Accessories__c = accMaster1.Id,
                                                                    ARM_ACM_FRNCD__c = 'KIAPC');
        insert accRateMaster;

        // Create Package Accessories
        List<Package_Accs__c> pckAccList = new List<Package_Accs__c>();
        for (Integer i = 0; i < 3; i++) {
            Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                    	Accessories_Master__c = accMaster1.Id,
                                                        PKA_PKH_FRNCD__c = 'KIAPC');
            pckAccList.add(pckAcc);
        }
        Package_Accs__c pckAcc2 = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                    Accessories_Master__c = accMaster2.Id,
                                                    PKA_PKH_FRNCD__c = 'KIAPC');
        pckAccList.add(pckAcc2);
        Package_Accs__c pckAcc3 = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                      Accessories_Master__c = accMaster3.Id,
                                                      PKA_PKH_FRNCD__c = 'KIAPC');
        pckAccList.add(pckAcc3); 
		insert pckAccList;

		// Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;

        // Create Package Addtional Charges
        List<Package_Additional_Charges__c> pckAddnlChargeList = new List<Package_Additional_Charges__c>();
        Package_Additional_Charges__c pckAddnlCharge1 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckHeader.Id,
                                                                                         PKC_ADM_CHRGCD__c ='R002',
                                                                                         PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge1);
        Package_Additional_Charges__c pckAddnlCharge2 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckHeader.Id,
                                                                                         PKC_ADM_CHRGCD__c ='R002',
                                                                                         PKC_INCPRICE__c = 'INC',
                                                                                         PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge2);
        Package_Additional_Charges__c pckAddnlCharge3 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckHeader.Id,
                                                                                         PKC_INCPRICE__c = 'INC');
        pckAddnlChargeList.add(pckAddnlCharge3);
        for (Integer i = 0; i < 5; i++) {
			Package_Additional_Charges__c pckAddnlCharge = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                            Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                            Package_Header__c = pckHeader.Id);
            pckAddnlChargeList.add(pckAddnlCharge);
        }
		insert pckAddnlChargeList;
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'ALOHA_TEST', stockReservation.ID, 'Thieu Dang Vu'); 
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
    }
    
	@isTest
    private static void testCustomer() {
        // customer configuration metadata
        DocuSign_Recipient_Configuration__mdt recipientConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = true, Recipient_Type__c = 'Signer', Signing_Order__c = '1', Signing_Tab_Anchor_String__c = '\\s1\\');
        // signing group information map
        Map<string, string> endorserInfo = new Map<string, string> {'ID' => '123', 'Name' => 'Endorser'};
        Map<string, string> approverInfo = new Map<string, string> {'ID' => '456', 'Name' => 'Approver'};
        Map<string, Map<string, string>> signingGroupInfo = new Map<string, Map<string, string>> {'Endorser' => endorserInfo, 'Approver' => approverInfo};
        // query SA
        Sales_Agreement__c SA = [SELECT Proposed_Commission__c, Proposed_Commission_Reason__c, Registration_Type__c, ARCA_Number__c, Customer_Full_Name__c, Company_Name__c, emailaddress__c, GMS_Package__c, SOH_SONO__c, Date_Of_Birth__c, NRIC_Number__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
		DocusignSignerDetail o = DocusignSignerDetail.build(recipientConfiguration, signingGroupInfo, SA);
        
        system.assertEquals('ABC TEST', o.name);
        system.assertEquals('', o.signingGroupId);
        system.assertEquals('', o.signingGroupName);
        system.assertEquals('1', o.routingOrder);
        system.assertEquals('Signer 1', o.roleName);
        system.assertEquals('Signer', o.recipientType);
    }
    
    @isTest
    private static void testCarbonCopy() {
        // customer configuration metadata
        DocuSign_Recipient_Configuration__mdt recipientConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = true, Recipient_Type__c = 'Carbon copy', Signing_Order__c = '2');
        // signing group information map
        Map<string, string> endorserInfo = new Map<string, string> {'ID' => '123', 'Name' => 'Endorser'};
        Map<string, string> approverInfo = new Map<string, string> {'ID' => '456', 'Name' => 'Approver'};
        Map<string, Map<string, string>> signingGroupInfo = new Map<string, Map<string, string>> {'Endorser' => endorserInfo, 'Approver' => approverInfo};
        // query SA
        Sales_Agreement__c SA = [SELECT Proposed_Commission__c, Proposed_Commission_Reason__c, Registration_Type__c, ARCA_Number__c, Customer_Full_Name__c, Company_Name__c, emailaddress__c, GMS_Package__c, SOH_SONO__c, Date_Of_Birth__c, NRIC_Number__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
		DocusignSignerDetail o = DocusignSignerDetail.build(recipientConfiguration, signingGroupInfo, SA);
        
        system.assert(o.name.contains('ABC TEST'));
        system.assertEquals('', o.signingGroupId);
        system.assertEquals('', o.signingGroupName);
        system.assertEquals('2', o.routingOrder);
        system.assertEquals('Carbon copy 2', o.roleName);
        system.assertEquals('Carbon copy', o.recipientType);
    }
    
    @isTest
    private static void testEndorser() {
        // customer configuration metadata
        DocuSign_Recipient_Configuration__mdt recipientConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = false, Recipient_Type__c = 'Signer', Signing_Order__c = '2', Signing_Tab_Anchor_String__c = '\\s2\\', Signing_Group__c = 'Endorser');
        // signing group information map
        Map<string, string> endorserInfo = new Map<string, string> {'ID' => '123', 'Name' => 'Endorser'};
        Map<string, string> approverInfo = new Map<string, string> {'ID' => '456', 'Name' => 'Approver'};
        Map<string, Map<string, string>> signingGroupInfo = new Map<string, Map<string, string>> {'Endorser' => endorserInfo, 'Approver' => approverInfo};
        // query SA
        Sales_Agreement__c SA = [SELECT Proposed_Commission__c, Proposed_Commission_Reason__c, Registration_Type__c, ARCA_Number__c, Customer_Full_Name__c, Company_Name__c, emailaddress__c, GMS_Package__c, SOH_SONO__c, Date_Of_Birth__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
		DocusignSignerDetail o = DocusignSignerDetail.build(recipientConfiguration, signingGroupInfo, SA);
        
        system.assertEquals('', o.name);
        system.assertEquals('', o.email);
        system.assertEquals('123', o.signingGroupId);
        system.assertEquals('Endorser', o.signingGroupName);
        system.assertEquals('2', o.routingOrder);
        system.assertEquals('Signer 2', o.roleName);
        system.assertEquals('Signer', o.recipientType);
    }
    
    @isTest
    private static void testApprover() {
        // customer configuration metadata
        DocuSign_Recipient_Configuration__mdt recipientConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = false, Recipient_Type__c = 'Signer', Signing_Order__c = '3', Signing_Tab_Anchor_String__c = '\\s3\\', Signing_Group__c = 'Approver');
        // signing group information map
        Map<string, string> endorserInfo = new Map<string, string> {'ID' => '123', 'Name' => 'Endorser'};
        Map<string, string> approverInfo = new Map<string, string> {'ID' => '456', 'Name' => 'Approver'};
        Map<string, Map<string, string>> signingGroupInfo = new Map<string, Map<string, string>> {'Endorser' => endorserInfo, 'Approver' => approverInfo};
        // query SA
        Sales_Agreement__c SA = [SELECT Proposed_Commission__c, Proposed_Commission_Reason__c, Registration_Type__c, ARCA_Number__c, Customer_Full_Name__c, Company_Name__c, emailaddress__c, GMS_Package__c, SOH_SONO__c, Date_Of_Birth__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
		DocusignSignerDetail o = DocusignSignerDetail.build(recipientConfiguration, signingGroupInfo, SA);
        
        system.assertEquals('', o.name);
        system.assertEquals('', o.email);
        system.assertEquals('456', o.signingGroupId);
        system.assertEquals('Approver', o.signingGroupName);
        system.assertEquals('3', o.routingOrder);
        system.assertEquals('Signer 3', o.roleName);
        system.assertEquals('Signer', o.recipientType);
    }

    @isTest
    static void Test_addSignHereTab_MB() {
        Test.startTest();
        // customer configuration metadata
        DocuSign_Recipient_Configuration__mdt recipientConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = true, Recipient_Type__c = 'Signer', Signing_Order__c = '1', Signing_Tab_Anchor_String__c = '\\s1\\', Date_Signed_Tab_Anchor_String__c = '\\d1\\');
        DocusignSignerDetail o = new DocusignSignerDetail();
        o.addSignHereTab_MB(recipientConfiguration);
        Test.stopTest();
    }

    @isTest
    static void Test_addAnotherSignHereTab_MB() {
        Test.startTest();
        // customer configuration metadata
        DocuSign_Recipient_Configuration__mdt recipientConfiguration = new DocuSign_Recipient_Configuration__mdt(Active__c = true, Customer__c = true, Recipient_Type__c = 'Signer', Signing_Order__c = '1', Signing_Tab_Anchor_String__c = '\\s1\\', Date_Signed_Tab_Anchor_String__c = '\\d1\\');
        DocusignSignerDetail o = new DocusignSignerDetail();
        o.addSignHereTab_MB(recipientConfiguration);
        o.addAnotherSignHereTab_MB(recipientConfiguration);
        Test.stopTest();
    }
}
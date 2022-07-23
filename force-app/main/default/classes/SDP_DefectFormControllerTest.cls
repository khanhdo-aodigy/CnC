@isTest
private class SDP_DefectFormControllerTest {
    @testSetup
    static void setUp() {
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID);
        insert vMaster;

        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;

        //Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Vehicle_Master__c = vMaster.ID;
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
                                                                                         PKC_ADM_CHRGCD__c ='R004',
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
        // Create Account
        Account acc = Test_DataFactory.createAccount(true, 'Test Account 1');
        // Create Lead
        Lead lead = Test_DataFactory.createLead(false, 'Aodigy 1', 'Test Lead 1');
        lead.Email = 'testLead@123.com';
        insert lead;
        // Create Contact
        Contact cont = Test_DataFactory.createContact(false, 'Test Name 1', 'Test Name 1', acc.Id);
        cont.Birthdate = Date.newInstance(2001, 3, 21);
        cont.Email = 'testContact@123.com';
        insert cont;
        // Create Opp
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'Test Opportunity 1', acc.Id);
        opp.Lead__c = lead.Id;
        opp.Contact_Person__c = cont.Id;
        update opp;
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.Id, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Registration_Type__c = 'P';
        salesAgreement.PreferredServiceCenter__c = 'Alexandra';
        salesAgreement.Opportunity__c = opp.Id;
        insert salesAgreement;
    }

    @isTest
    static void createDefect_Test_SA_Has_Defect_Header() {
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c LIMIT 1];
        Defect_Header__c dh = new Defect_Header__c(Status__c = 'New',
                                                   Service_Center__c = 'Alexandra',
                                                   Sales_Agreement__c = salesAgreement.Id);
        insert dh;
       	Defect__c defect = SDP_DefectFormController.createDefect(salesAgreement.Id);
        system.assertNotEquals(null, defect);
    }

    @isTest
    static void createDefect_Test_SA_Not_Have_Defect_Header() {
        Sales_Agreement__c salesAgreement = [SELECT ID, Defect_Header_URL__c FROM Sales_Agreement__c LIMIT 1];
       	Defect__c defect = SDP_DefectFormController.createDefect(salesAgreement.Id);
        salesAgreement = [SELECT ID, Defect_Header_URL__c FROM Sales_Agreement__c LIMIT 1];
        system.assertNotEquals(null, defect);
        system.assertNotEquals(null, salesAgreement.Defect_Header_URL__c);
    }

    @isTest
    static void creatOA_Test_SA_Has_Defect_Header() {
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c LIMIT 1];
        Defect_Header__c dh = new Defect_Header__c(Status__c = 'New',
                                                   Service_Center__c = 'Alexandra',
                                                   Sales_Agreement__c = salesAgreement.Id);
        insert dh;
        Outstanding_Accessory__c oa = SDP_DefectFormController.createOA(salesAgreement.Id);
        system.assertNotEquals(null, oa);
    }

    @isTest
    static void creatOA_Test_SA_Not_Have_Defect_Header() {
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c LIMIT 1];
        Outstanding_Accessory__c oa = SDP_DefectFormController.createOA(salesAgreement.Id);
        salesAgreement = [SELECT ID, Defect_Header_URL__c FROM Sales_Agreement__c LIMIT 1];
        system.assertNotEquals(null, oa);
        system.assertNotEquals(null, salesAgreement.Defect_Header_URL__c);
    }

    @isTest
    static void updateServiceCenter_Test() {
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c LIMIT 1];
        Defect_Header__c dh = new Defect_Header__c(Status__c = 'New',
                                                   Service_Center__c = 'Alexandra',
                                                   Sales_Agreement__c = salesAgreement.Id);
        insert dh;
        Test.startTest();
        String sCenter = 'Sin Ming';
        SDP_DefectFormController.updateServiceCenter(salesAgreement.Id, sCenter);
        Test.stopTest();
        salesAgreement = [SELECT ID, PreferredServiceCenter__c FROM Sales_Agreement__c LIMIT 1];
        dh = [SELECT ID, Service_Center__c FROM Defect_Header__c LIMIT 1];
        System.assertEquals(sCenter, salesAgreement.PreferredServiceCenter__c);
        System.assertEquals(sCenter, dh.Service_Center__c);
    }

    @isTest
    static void SDP_DefectFormControllerTest() {
        Sales_Agreement__c salesAgreement = [SELECT ID FROM Sales_Agreement__c LIMIT 1];
        Test.startTest();
        Sales_Agreement__c TestingInitialise = SDP_DefectFormController.initializeSalesAgreement(salesAgreement.Id);
        List<sObject> TestGetRecord = SDP_DefectFormController.getRelatedRecords(String.valueOf(salesAgreement.Id), 'Sales_Agreement__c', 'Id', 0);
        system.assertEquals(TestGetRecord.size(), 1);
        Test.stopTest();
    }
}
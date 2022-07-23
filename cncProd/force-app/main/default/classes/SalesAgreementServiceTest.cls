@isTest
private class SalesAgreementServiceTest 
{
	@testSetup
    static void setUp() 
    {     
        //Create Account and Opportunity
        Account personAcc = Test_DataFactory.createPerson(true, 'Test', 'Customer');
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        insert oppt;
        
        // Create master data
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Rate_Master__c modelRateMaster = new Model_Rate_Master__c(Model_Master__c = modelCode.Id,
                                                                       	MRM_MYM_FRNCD__c = 'KIAPC');
        insert modelRateMaster;

        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Accessories_Master__c accMaster = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                    ACM_ACCSDESC__c = 'Acc Master Test',
                                                                    ACM_ACCSCD__c = 'GRABSVC1',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'F');
        insert accMaster;

        Additional_Charges_Master__c addnlChargeMaster = Test_DataFactory.createAdditionalChargesMaster(true, 'R004');
        
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                           	Model_Master__c = modelCode.Id,
                                                           	PKH_PKGNO__c = '99',
                                                           	PKH_STATUS__c = 'A');
        insert pckHeader;

        // Create Stock Reservation
        Stock_Reservation__c stockReservation1 = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation1.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation1.Opportunity__c                  = oppt.Id;
		insert stockReservation1;
        Stock_Reservation__c stockReservation2 = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation2.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation2.Opportunity__c                  = oppt.Id;
		insert stockReservation2;
   
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', stockReservation1.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
	}

    @isTest
    static void Test_getSalesAgrmnt() {
        Sales_Agreement__c salesAgreement = [SELECT Id, Package_Header__r.PKH_PKGNO__c, Finance_Company_Lookup__r.BAM_ASSOCIATECD__c,
                                             		Stock_Reservation__r.Model_Code__c, Insurance_Company_Lookup__r.BAM_ASSOCIATECD__c
                                             FROM Sales_Agreement__c];
        Sales_Agreement__c sa = SalesAgreementService.getSalesAgrmnt(salesAgreement.Id);

        System.assertNotEquals(null, sa);
    }

    @isTest
    static void Test_getSaAccs() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        Accessories_Master__c accMaster = [SELECT Id FROM Accessories_Master__c];

        List<SA_Accessory__c> saAccList = new List<SA_Accessory__c>();
        for (Integer i = 0; i < 5; i++) {
            SA_Accessory__c saAcc = new SA_Accessory__c(Sales_Agreement__c = salesAgreement.Id,
                                                    	Accessories_Master__c = accMaster.Id);
            saAccList.add(saAcc);
        }
		insert saAccList;
        List<SA_Accessory__c> saAccs = SalesAgreementService.getSaAccs(salesAgreement.Id);

        System.assertEquals(5, saAccs.size());
    }

    @isTest
    static void Test_getSaAddnlCharges() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        Additional_Charges_Master__c addnlChargeMaster = [SELECT Id FROM Additional_Charges_Master__c];
        SA_Additional_Charge__c saAdditionalCharge = Test_DataFactory.createSAAdditionalCharge(true, addnlChargeMaster.Id, salesAgreement.Id);
        List<SA_Additional_Charge__c> saAddnlCharges = SalesAgreementService.getSaAddnlCharges(salesAgreement.Id);

        System.assertEquals(1, saAddnlCharges.size());
    }
 
    @isTest
    static void Test_getPackageAddnlCharges() {
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Additional_Charges_Master__c addnlChargeMaster = [SELECT Id FROM Additional_Charges_Master__c];

        List<Package_Additional_Charges__c> pckAddnlChargeList = new List<Package_Additional_Charges__c>();
        for (Integer i = 0; i < 5; i++) {
			Package_Additional_Charges__c pckAddnlCharge = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                            Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                            Package_Header__c = pckHeader.Id);
            pckAddnlChargeList.add(pckAddnlCharge);
        }
		insert pckAddnlChargeList;
        List<Package_Additional_Charges__c> pckAddnlCharges = SalesAgreementService.getPackageAddnlCharges(pckHeader.Id);

        System.assertEquals(5, pckAddnlCharges.size());
    }

    @isTest
    static void Test_getPkgAccs() {
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Accessories_Master__c accMaster = [SELECT Id FROM Accessories_Master__c];

        List<Package_Accs__c> pckAccList = new List<Package_Accs__c>();
        for (Integer i = 0; i < 5; i++) {
            Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                         Accessories_Master__c = accMaster.Id,
                                                         PKA_PKH_FRNCD__c = 'KIAPC');
            pckAccList.add(pckAcc);
        }
		insert pckAccList;
        List<Package_Accs__c> pckAccs = SalesAgreementService.getPkgAccs(pckHeader.Id);

        System.assertEquals(5, pckAccs.size());
    }

    @isTest
    static void Test_getAccsMaster() {
        Accessories_Master__c accessoriesMaster = [SELECT Id FROM Accessories_Master__c];
        Accessories_Master__c accMaster = SalesAgreementService.getAccsMaster(accessoriesMaster.Id);

        System.assertNotEquals(null, accMaster);
    }

    @isTest
    static void Test_getModelRateMaster() {
        //Model_Rate_Master__c modelRateMaster = [SELECT Id FROM Model_Rate_Master__c];
        Model_Master__c modelCode = [SELECT Id FROM Model_Master__c];
        List<Model_Rate_Master__c> modelRateMasters = SalesAgreementService.getModelRateMaster(modelCode.Id);

        System.assertEquals(1, modelRateMasters.size());
    }

    @isTest
    static void Test_getSaAccsBySaIdandAccCode() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        SA_Accessory__c saAccSVC = new SA_Accessory__c(Sales_Agreement__c = salesAgreement.Id,
                                                       Acc_Code_Trigger__c = 'SVC2000');
        insert saAccSVC;
        SA_Accessory__c saAcc = SalesAgreementService.getSaAccsBySaIdandAccCode(salesAgreement.Id, 'SVC2000');

        System.assertEquals('SVC2000', saAcc.Acc_Code_Trigger__c);
    }

    @isTest
    static void Test_processOffPeakCar() {
        // Previous Sales Agreement
        Sales_Agreement__c prevSalesAgreement = [SELECT Id FROM Sales_Agreement__c];
        prevSalesAgreement.Registration_Number_Type__c = 'Normal';
        prevSalesAgreement.SOH_SONO__c = 'AK123456';
        update prevSalesAgreement;
        // Create current Sales Agreement
        List<Stock_Reservation__c> stockReservations = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c currSalesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'AK654321', stockReservations[1].ID, 'Thieu Dang Vu');
		currSalesAgreement.Registration_Number_Type__c = 'Off Peak Car';
        insert currSalesAgreement;

        Sales_Agreement__c sa = SalesAgreementService.processOffPeakCar(prevSalesAgreement, currSalesAgreement);
        System.assertEquals('O', sa.SOH_RTM_REGTYPECD__c);
        System.assertEquals('AK654321', sa.SOH_SONO__c);
    }

    @isTest
    static void Test_getStockReservationInformation() {
        List<Stock_Reservation__c> stockReservations = [SELECT Id FROM Stock_Reservation__c];
        Set<Id> stockResIds = new Set<Id>();
        for (Stock_Reservation__c stock : stockReservations) {
            stockResIds.add(stock.Id);
        }
        Map<Id, Stock_Reservation__c> stockMap = SalesAgreementService.getStockReservationInformation(stockResIds);

        System.assertEquals(2, stockMap.size());
    }

    @isTest
    static void Test_getPackageHeaderIdBasedOnModel() {
        List<Stock_Reservation__c> stockReservations = [SELECT Id, Model_Code__c FROM Stock_Reservation__c];
        Map<String, Id> pckAndModelMap = SalesAgreementService.getPackageHeaderIdBasedOnModel(stockReservations);

        //Return 1 because 2 stock reservation belongs to 1 model master
        System.assertEquals(1, pckAndModelMap.size());
    }

    //Start of RN2020Q1010 
    @isTest
    static void Test_getPackageHeadersBasedOnModel () {
        List<Stock_Reservation__c> stockReservations = [SELECT Id, Model_Code__c FROM Stock_Reservation__c];
        Map<String, Package_Header__c> pckAndModelMap = SalesAgreementService.getPackageHeadersBasedOnModel(stockReservations);
        System.assertEquals(1, pckAndModelMap.size());
    }

    static void Test_processCalculation() {
        List<Stock_Reservation__c> stockReservations = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c currSalesAgreement = Test_DataFactory.createSalesAgreement(true, 'CCK', 'AK654321', stockReservations[1].ID, 'Thieu Dang Vu');
		currSalesAgreement.Package_List_Price__c = 1000000;
        update currSalesAgreement;

        System.assertEquals(currSalesAgreement.Package_List_Price__c, currSalesAgreement.Vehicle_Purchase_Price__c);

    }
    
    //End of RN2020Q1010 

    @isTest
    static void Test_retrieveDeleteAccessories() {
		Sales_Agreement__c salesAgreement = [SELECT Id, Package_Header__c FROM Sales_Agreement__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Accessories_Master__c accMaster = [SELECT Id FROM Accessories_Master__c];

        List<SA_Accessory__c> saAccList = new List<SA_Accessory__c>();
        for (Integer i = 0; i < 5; i++) {
            SA_Accessory__c saAcc = new SA_Accessory__c(Sales_Agreement__c = salesAgreement.Id,
                                                    	Accessories_Master__c = accMaster.Id,
                                                        SAC_PACKAGE__c = 'Y');
            saAccList.add(saAcc);
        }
		insert saAccList;

        Map<Id, List<SA_Accessory__c>> saAccsToBeDeleted = SalesAgreementService.retrieveDeleteAccessories(new Map<Id, Id>{salesAgreement.Id => pckHeader.Id});
        System.assertEquals(5, saAccsToBeDeleted.get(salesAgreement.Id).size());
    }

    @isTest
    static void Test_retrieveNewAccessories() {
        Sales_Agreement__c salesAgreement = [SELECT Id, Package_Header__c FROM Sales_Agreement__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Accessories_Master__c accMaster = [SELECT Id FROM Accessories_Master__c];
        List<Package_Accs__c> pckAccList = new List<Package_Accs__c>();
        for (Integer i = 0; i < 5; i++) {
            Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                         Accessories_Master__c = accMaster.Id,
                                                         PKA_PKH_FRNCD__c = 'KIAPC');
            pckAccList.add(pckAcc);
        }
		insert pckAccList;
        Map<Id, List<Package_Accs__c>> pckAccMap = SalesAgreementService.retrieveNewAccessories(new Map<Id, Id>{salesAgreement.Id => pckHeader.Id});
        system.debug(pckAccMap.get(pckHeader.Id));
        System.assertEquals(5, pckAccMap.get(pckHeader.Id).size());
    }

    @isTest
    static void Test_retrieveDeleteAdditionCharges() {
		Sales_Agreement__c salesAgreement = [SELECT Id, Package_Header__c FROM Sales_Agreement__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Additional_Charges_Master__c addnlChargeMaster = [SELECT Id FROM Additional_Charges_Master__c];
		List<SA_Additional_Charge__c> saAddnlChrages = new List<SA_Additional_Charge__c>();
        for (Integer i = 0; i < 5; i++) {
            SA_Additional_Charge__c saAddnlCharge = new SA_Additional_Charge__c(Sales_Agreement__c = salesAgreement.Id,
                                                                                AdditionalChargesMaster__c = addnlChargeMaster.Id);
            saAddnlChrages.add(saAddnlCharge);
        }
		insert saAddnlChrages;
        Map<Id, List<SA_Additional_Charge__c>> saAddnlChargeToBeDeleted = SalesAgreementService.retrieveDeleteAdditionCharges(new Map<Id, Id>{salesAgreement.Id => pckHeader.Id});
        System.assertEquals(5, saAddnlChargeToBeDeleted.get(salesAgreement.Id).size());        
    }

    @isTest
    static void Test_retrieveNewAdditionalCharges() {
		Sales_Agreement__c salesAgreement = [SELECT Id, Package_Header__c FROM Sales_Agreement__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Additional_Charges_Master__c addnlChargeMaster = [SELECT Id FROM Additional_Charges_Master__c];
        List<Package_Additional_Charges__c> pckAddnlCharges = new List<Package_Additional_Charges__c>();
        for (Integer i = 0; i < 5; i++) {
            Package_Additional_Charges__c pckAddnlCharge = new Package_Additional_Charges__c(Package_Header__c = pckHeader.Id,
                                                                                             Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                             PKC_PKH_FRNCD__c = 'KIAPC');
            pckAddnlCharges.add(pckAddnlCharge);
        }
		insert pckAddnlCharges;
        Map<Id, List<Package_Additional_Charges__c>> pckAddnlChargeMap = SalesAgreementService.retrieveNewAdditionalCharges(new Map<Id, Id>{salesAgreement.Id => pckHeader.Id});

        System.assertEquals(5, pckAddnlChargeMap.get(pckHeader.Id).size());        
    }

    @isTest
    static void Test_findPackagesBasedOnSalesAgreement() {
        Sales_Agreement__c sa = [SELECT Id, Package_Header__c FROM Sales_Agreement__c];
        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'MITPC');
        insert pckHeader;
        Sales_Agreement__c saClone = sa.Clone();
        sa.Package_Header__c = pckHeader.Id;
        update sa;
		Map<Id, Id> changedPackageHeader = SalesAgreementService.findPackagesBasedOnSalesAgreement(new Map<Id, SObject>{sa.Id => saClone}, new List<Sales_Agreement__c>{sa});

        System.assertNotEquals(saClone.Package_Header__c, sa.Package_Header__c);
    }

    @isTest
    static void Test_getACMByBranchCodeandAccCode() {
        Accessories_Master__c currAccMaster = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                        ACM_ACCSDESC__c = 'Acc Master Test',
                                                                        ACM_ACCSCD__c = 'SER2000',
                                                                        Rate__c = 5000,
                                                                        ACM_ACCSTYPE__c = 'F',
                                                                        ACM_MNM_MAJGROUPCD__c = 'FREE_ACC');
        insert currAccMaster;
        Accessories_Master__c accMaster = SalesAgreementService.getACMByBranchCodeandAccCode('CCK', 'SER2000');

        System.assertEquals('CCK', accMaster.BranchCode__c);
    }
    
    @isTest
    static void Test_getACMByVSMSCompoundPrimaryKey() {
        Accessories_Master__c currAccMaster = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                        ACM_ACCSDESC__c = 'Acc Master Test 2',
                                                                        ACM_ACCSCD__c = 'SER5000',
                                                                        Rate__c = 5000,
                                                                        ACM_ACCSTYPE__c = 'F',
                                                                        ACM_MNM_MAJGROUPCD__c = 'FREE_ACC',
                                                                        ACM_BRM_UNIQUEBRCD__c = 'CCLCCKSGDCCK003');
        insert currAccMaster;
        Accessories_Master__c accMaster = SalesAgreementService.getACMByVSMSCompoundPrimaryKey('KIAPC', 'SER5000', 'CCLCCKSGDCCK003');

        System.assertEquals('CCLCCKSGDCCK003', accMaster.ACM_BRM_UNIQUEBRCD__c);   
    }  
}
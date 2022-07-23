@isTest
private class SalesAgreementTriggerTest {
	@testSetup
    static void setUp() {
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        // Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        insert stockReservation;
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC');
        insert pckHeader;
        
        Accessories_Master__c accMaster1 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Acc Test',
                                                                     ACM_ACCSCD__c = 'GMS5000',
                                                                     Rate__c = 5000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster1;

        // Create Accs Rate Master
		Accs_Rate_Master__c accRateMaster = new Accs_Rate_Master__c(Accessories__c = accMaster1.Id,
                                                                    ARM_ACM_FRNCD__c = 'KIAPC');
        insert accRateMaster;

        // Create Package Accessories
        List<Package_Accs__c> pckAccList = new List<Package_Accs__c>();
        for (Integer i = 0; i < 5; i++) {
            Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                    	Accessories_Master__c = accMaster1.Id,
                                                        PKA_PKH_FRNCD__c = 'KIAPC');
            pckAccList.add(pckAcc);
        }
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
    }

    /**
     * Covered method in SalesAgreement.cls:
     * onApplyDefaults()
     * onAfterInsert()
     * defaultAccessoriesRelatedList()
     */
    @isTest
    static void Test_afterInsert_Case1() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];

		// Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', stockReservation.ID, 'Thieu Dang Vu'); 
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
    }

    /**
     * Covered method in SalesAgreement.cls:
     * onApplyDefaults()
     * onAfterInsert()
     * defaultAccessoriesRelatedList()
     */
    @isTest
    static void Test_afterInsert_Case2() {
        Model_Master__c modelCode = [SELECT Id FROM Model_Master__c];
        Model_Year_Master__c modelYearCode = [SELECT Id FROM Model_Year_Master__c];
        Color_Master__c colorCode = [SELECT Id FROM Color_Master__c];
        Trim_Master__c trimCode = [SELECT Id FROM Trim_Master__c];

        // Create Stock Reservation
        Stock_Reservation__c stockReservation2 = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation2.Registration_Type__c = 'C';
		insert stockReservation2;

        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];

		// Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', stockReservation2.ID, 'Thieu Dang Vu'); 
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
    }

    /**
     * Covered method in SalesAgreement.cls:
     * onAfterUpdate()
     * updateStockReservationVehicleMaster()
     * defaultAccessoriesRelatedList()
     * upsertRelatedAccessories()
     */
    @isTest 
    static void Test_afterUpdate() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Accessories_Master__c accMaster = [SELECT Id FROM Accessories_Master__c];
        Additional_Charges_Master__c addnlChargeMaster = [SELECT Id FROM Additional_Charges_Master__c];

        Package_Header__c pckHeader1 = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC');
        insert pckHeader1;

        List<Package_Header__c> pckList = [SELECT Id FROM Package_Header__c];
        Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckList[1].Id,
                                                     Accessories_Master__c = accMaster.Id,
                                                     PKA_PKH_FRNCD__c = 'KIAPC');
        insert pckAcc;
        List<Package_Additional_Charges__c> pckAddnlChargeList = new List<Package_Additional_Charges__c>();
        Package_Additional_Charges__c pckAddnlCharge1 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckList[1].Id,
                                                                                         PKC_ADM_CHRGCD__c ='R002',
                                                                                         PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge1);
        Package_Additional_Charges__c pckAddnlCharge2 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckList[1].Id,
                                                                                         PKC_ADM_CHRGCD__c ='R002',
                                                                                         PKC_INCPRICE__c = 'INC',
                                                                                         PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge2);
        Package_Additional_Charges__c pckAddnlCharge3 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckList[1].Id,
                                                                                         PKC_INCPRICE__c = 'INC');
        pckAddnlChargeList.add(pckAddnlCharge3);
        Package_Additional_Charges__c pckAddnlCharge4 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckList[1].Id);
        pckAddnlChargeList.add(pckAddnlCharge4);
        insert pckAddnlChargeList;
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckList[0].Id;
        insert salesAgreement;

        // Create SA Acc
        SA_Accessory__c sa = new SA_Accessory__c(Sales_Agreement__c = salesAgreement.Id,
                                                 Accessories_Master__c = accMaster.Id,
                                                 SAC_PACKAGE__c = 'Y');
        insert sa;
        // Create SA Addnl Charge
        SA_Additional_Charge__c saAddnlCharge = Test_DataFactory.createSAAdditionalCharge(true, addnlChargeMaster.Id, salesAgreement.Id);

        salesAgreement.Package_Header__c = pckList[1].Id;
        update salesAgreement;
    }

    /**
     * Covered method in SalesAgreement.cls:
     * createCOESAAcc()
     * createGMSSAAcc()
     */
    @isTest 
    static void Test_afterUpdate_Case1() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        List<Package_Header__c> pckHeader = [SELECT Id FROM Package_Header__c];

        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader[0].Id;
        insert salesAgreement;
        
        salesAgreement.COE_Refund__c = 4050;
        salesAgreement.GMS_Package__c = 5000;
        update salesAgreement;
    }

    /**
     * Covered method in SalesAgreement.cls:
     * createCOESAAcc()
     * createGMSSAAcc()
     * createSVCSAAcc()
     */
    @isTest 
    static void Test_afterUpdate_Case2() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        List<Package_Header__c> pckHeader = [SELECT Id FROM Package_Header__c];
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader[0].Id;
        salesAgreement.COE_Refund__c = 4050;
        salesAgreement.GMS_Package__c = 5000;
        insert salesAgreement;
        
        salesAgreement.COE_Refund__c = null;
        salesAgreement.GMS_Package__c = null;
        salesAgreement.Service_Credit__c = null;
        update salesAgreement;     
    }

    /**
     * Covered method in SalesAgreement.cls:
     * createCOESAAcc()
     * createGMSSAAcc()
     * createSVCSAAcc()
     */
    @isTest 
    static void Test_afterUpdate_Case3() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.COE_Refund__c = 4050;
        salesAgreement.GMS_Package__c = 5000;
        insert salesAgreement;

        salesAgreement.COE_Refund__c = 3050;
        salesAgreement.GMS_Package__c = 5005;
        salesAgreement.Service_Credit__c = 3000;
        update salesAgreement;     
        
          
        Test.setMock(HttpCalloutMock.class, new VSMS_CallOutToCreateACMMock());
        Test.startTest();
        VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.Branch_Code__c, 'COE4050');
        Test.stopTest();
    }

    /**
     * Covered method in SalesAgreement.cls:
     * createCOESAAcc()
     */
    @isTest
    static void Test_afterUpdate_Case4() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.COE_Refund__c = 4050;
        insert salesAgreement;

        salesAgreement.COE_Refund__c = 0;
        update salesAgreement;
    }

    /**
     * Covered method in SalesAgreement.cls:
     * createCOESAAcc()
     */    
    @isTest
    static void Test_afterUpdate_Case5() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.COE_Refund__c = 0;
        insert salesAgreement;

        salesAgreement.COE_Refund__c = 4050;
        update salesAgreement;
        
        Test.setMock(HttpCalloutMock.class, new VSMS_CallOutToCreateACMMock());
        Test.startTest();
        VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.Branch_Code__c, 'COE4050');
        Test.stopTest();
    }
    
    /**
     * Covered method in SalesAgreement.cls:
     * createSVCSAAcc()
     */
    @isTest
    static void Test_afterUpdate_Case6() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
        insert salesAgreement;
        
        salesAgreement.Service_Credit__c = null;
        update salesAgreement;
        
        salesAgreement.Service_Credit__c = 4050;
        update salesAgreement;
        
        Test.setMock(HttpCalloutMock.class, new VSMS_CallOutToCreateACMMock());
        Test.startTest();
        VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.Branch_Code__c, 'COE4050');
        Test.stopTest();
    }

    /**
     * Covered method in SalesAgreement.cls:
     * setVSMSKeyOfAdditionalCharges()
     */
    @isTest
    static void Test_afterUpdate_Case7() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Additional_Charges_Master__c addnlChargeMaster = [SELECT Id FROM Additional_Charges_Master__c];
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
        insert salesAgreement;

        salesAgreement.SOH_SONO__c = 'AK19119999';
        update salesAgreement;

        // Create SA Addnl Charge
        SA_Additional_Charge__c saAddnlCharge = Test_DataFactory.createSAAdditionalCharge(false, addnlChargeMaster.Id, salesAgreement.Id);
		insert saAddnlCharge;
    }

    /**
     * Covered method in SalesAgreement.cls:
     * updateStockReservationVehicleMaster()
     */
    @isTest
    static void Test_afterUpdate_Case8() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
		/*Model_Master__c modelCode = [SELECT Id FROM Model_Master__c];
        Model_Year_Master__c modelYearCode = [SELECT Id FROM Model_Year_Master__c];
        Color_Master__c colorCode = [SELECT Id FROM Color_Master__c];
        Trim_Master__c trimCode = [SELECT Id FROM Trim_Master__c];

        // Create Stock Reservation
        Stock_Reservation__c stockReservation2 = Test_DataFactory.StockReservation(true, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);*/

        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'AK19115678', stockReservation.Id, 'Thieu Dang Vu');
        salesAgreement.CommcaseNo__c = '12-0059 15';
        insert salesAgreement;

        //salesAgreement.Stock_Reservation__c = stockReservation2.Id;
        salesAgreement.CommcaseNo__c = '12-0059 16';
        update salesAgreement;
    }
}
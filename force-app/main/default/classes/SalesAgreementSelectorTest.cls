/**
 * @File Name          : SalesAgreementSelectorTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/21/2020, 10:41:01 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/21/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class SalesAgreementSelectorTest {
	@testSetup
    static void setUp() {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc.Id];
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = personAcc.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt.Contact_Person__c = personAcc.PersonContactId;
        insert oppt;

         /** == MASTER TEST DATA - BEGIN == */

        // Model Master
        Model_Master__c modelCode = Test_DataFactory.createModelCode(false, 'Test Model Code');
        modelCode.Engine_Capacity__c = 1600;    // To test COE Category
        modelCode.BHP__c = 130;                 // To test COE Category
        modelCode.Franchise_Code__c = 'KIAPC';
        insert modelCode;
        // Model Year Master
        //Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);     
        Model_Year_Master__c modelYearCode = new Model_Year_Master__c(ModelYear__c = Date.today().addYears(-1), Model_Master__c = modelCode.Id, VSMS_Compound_Primary_Key__c='1');
        insert modelYearCode;
        // Color Master
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        // Trim Master
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        // Stock Vehicle Master
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
        // Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        // Stock Reservation
        Stock_Reservation__c sr = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        sr.Package_Header_From_PickList__c = pckHeader.Id;
        sr.Vehicle_Master__c = vMaster.ID;
        sr.Opportunity__c    = oppt.Id;
        sr.Customer_Mobile_Number__c = '6587546859';
        insert sr;

        /** == MASTER TEST DATA - END ==*/


        // Accessories Master
        List<Accessories_Master__c> accMasters = new List<Accessories_Master__c>();
        Accessories_Master__c accMaster = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                    ACM_ACCSDESC__c = 'ACC',
                                                                    ACM_ACCSCD__c = 'TESTACCMASTER',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'C');
        accMasters.add(accMaster);
        
        Accessories_Master__c accMaster2 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Service Credit',
                                                                     ACM_ACCSCD__c = 'SVC1000',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        accMasters.add(accMaster2);
 
        insert accMasters;
        
        // Create Accs Rate Master
        Accs_Rate_Master__c accRateMaster = new Accs_Rate_Master__c(Accessories__c = accMasters[0].Id,
                                                                    ARM_ACM_FRNCD__c = 'KIAPC');
        insert accRateMaster;

        // Create Package Accessories
        List<Package_Accs__c> pckAccList = new List<Package_Accs__c>();
        Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                     Accessories_Master__c = accMasters[0].Id,
                                                     PKA_PKH_FRNCD__c = 'KIAPC',
                                                     PKA_VALUE__c = null);
        pckAccList.add(pckAcc);

        Package_Accs__c pckAcc2 = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                      Accessories_Master__c = accMasters[1].Id,
                                                      PKA_PKH_FRNCD__c = 'KIAPC');
        pckAccList.add(pckAcc2);
		insert pckAccList;

		// Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;

        // Package Addtional Charges
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
        insert pckAddnlChargeList;
 
        //Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', sr.Id, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Vehicle_Deposit__c = 1;
        salesAgreement.COE_Deposit__c = 1;
        salesAgreement.Verified_by_Sales_Consultant__c = true;
        salesAgreement.Stage__c = 'Confirmation of Sale';
        salesAgreement.Expected_Delivery_Month__c = Date.today();
        insert salesAgreement;
    }

    @isTest
    static void Test_selectByStockReservationId() {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        SalesAgreementSelector saSelector = new SalesAgreementSelector();
        Sales_Agreement__c salesAgreement = saSelector.selectByStockReservationId(stockReservation.Id);
        
		System.assertNotEquals(null, salesAgreement);
    }

    @isTest
    static void Test_selectById() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        Stock_Reservation__c stockReservation = [SELECT Id, Model_Code__c FROM Stock_Reservation__c];
        SalesAgreementSelector saSelector = new SalesAgreementSelector();
        Sales_Agreement__c sa = saSelector.selectById(salesAgreement.Id);

		System.assertEquals(stockReservation.Id, sa.Stock_Reservation__c);
        System.assertEquals(stockReservation.Model_Code__c, sa.Stock_Reservation__r.Model_Code__c);
    }
//Start of RN2020Q1010
    @isTest
    static void Test_selectByIdWithAdditionalCharges(){
        Sales_Agreement__c salesAgreement = [SELECT Id, Package_List_Price__c, VehicleListPrice__c FROM Sales_Agreement__c];
        Set <Id> ids = new set<id>();
        ids.add(salesAgreement.Id);
        SalesAgreementSelector saSelector = new SalesAgreementSelector();
        LIST<Sales_Agreement__c> saList = saSelector.selectByIdWithAdditionalCharges(ids);
        System.assertNotEquals(null, saList);
    }
    @isTest
    static void Test_selectByPackageIdsWithNoSalesOrder(){
        Package_Header__c pckHeader = [SELECT Id, PKH_PKGPRICE__c FROM Package_Header__c];
        pckHeader.PKH_PKGPRICE__c = 1200000;
        update pckHeader;

        Set<ID> ids = new set<id>();
        ids.add(pckHeader.Id);
        SalesAgreementSelector saSelector = new SalesAgreementSelector();
        LIST<Sales_Agreement__c> saList = saSelector.selectByPackageIdsWithNoSalesOrder(ids);
        System.assertNotEquals(null, saList);

        /*
        test.startTest();
            Package_Header__c pckHeader = [SELECT Id, PKH_PKGPRICE__c FROM Package_Header__c];
            pckHeader.PKH_PKGPRICE__c = 1200000;
            update pckHeader;
        test.stopTest();
        Sales_Agreement__c salesAgreement = [SELECT Id, Package_List_Price__c, VehicleListPrice__c FROM Sales_Agreement__c];

        system.assertEquals(salesAgreement.Package_List_Price__c, pckHeader.PKH_PKGPRICE__c);
        */
    }

    @isTest 
    static void Test_selectByIds(){
        Sales_Agreement__c sa = [SELECT Id FROM Sales_Agreement__c LIMIT 1];
        SalesAgreementSelector saSelector = new SalesAgreementSelector();
        List<Sales_Agreement__c> saList = saSelector.selectByIds(new Set<String>{sa.Id});
    }

    @isTest 
    static void Test_selectSAForCOEBiddingByFranchise(){
        SalesAgreementSelector saSelector = new SalesAgreementSelector();
        List<Sales_Agreement__c> saList = saSelector.selectSAForCOEBiddingByFranchise('KIAPC', '');
    }

    @isTest 
    static void Test_selectSalesAgreementForThresholdCalculation(){
        Sales_Agreement__c sa = [SELECT Id FROM Sales_Agreement__c LIMIT 1];
        SalesAgreementSelector saSelector = new SalesAgreementSelector();
        List<Sales_Agreement__c> saList = saSelector.selectSalesAgreementForThresholdCalculation(new List<Id>{sa.Id});
    }
}
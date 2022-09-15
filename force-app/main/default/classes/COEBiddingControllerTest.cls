/**
 * Description: test class for COE Bidding Controller
 * Created By: Van Thanh (thanh.ly@aodigy.com)
 * History
 * =================================================================================================================================================================================================================
 *          DATE:                                      BY::                                            CHANGELOG
 *      10 August 2022                                 Van Thanh                                       Create Initial
 *    
 * =================================================================================================================================================================================================================
 */
@isTest
private class COEBiddingControllerTest {
    @TestSetup
    static void setup(){
        // Create Sales Agreement 1
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
        modelCode.Fuel_Type__c = '123';
        insert modelCode;
        // Model Year Master
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(false, modelCode.Id);
        modelYearCode.VSMS_Compound_Primary_Key__c = '1';
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
                                                            Trim_Code__c = trimCode.ID,
                                                            ETA_Date__c = Date.today(),
                                                            OMV__c = 1);
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
                                                                                          ADM_CHRGCD__c = 'R004',
                                                                                          VSMS_Compound_Primary_Key__c = '1');
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

        Sales_Agreement__c sAgree = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', sr.Id, 'Test'); 
        sAgree.Package_Header__c = pckHeader.Id;
        sAgree.Bid_Price__c = 100.05;
        sAgree.Bid_Category__c = 'A1';
        sAgree.Verified_by_Sales_Consultant__c = true;
        sAgree.Vehicle_Deposit__c = 1;
        sAgree.COE_Deposit__c = 1;
        sAgree.Stage__c = 'Confirmation of Sale';
        sAgree.Expected_Delivery_Month__c = Date.today();
        insert sAgree;

        COE_Bid_Period__c nextCOEPeriod = Test_DataFactory.createCOEPeriod(true, Date.today(), Date.today()+7);
        COE_Bid_Period__c lastCOEPeriod = Test_DataFactory.createCOEPeriod(true, Date.today()-8, Date.today()-1);
    
        Custom_Exchange_Rate__c exchangeRate = new Custom_Exchange_Rate__c();
        exchangeRate.Currency_Code__c = 'USD';
        exchangeRate.Valid_From__c = Date.today();
        exchangeRate.Custom_Exchange_Rate__c = 1.1;
        insert exchangeRate;


        // Create Sales Agreement 2
        Account personAcc2 = Test_DataFactory.createPerson(false, 'Test 2', 'Prospect');
        personAcc2.PersonEmail = 'patest123@mail.com';
        insert personAcc2;
        personAcc2 = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc2.Id];
        Opportunity oppt2 = Test_DataFactory.createOpportunity(false,'testRun2', personAcc2.Id);
        oppt2.Branch_Code__c = 'CCK';
        oppt2.Opportunity_Score__c = 40;
        oppt2.Account__c = personAcc2.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt2.Contact_Person__c = personAcc2.PersonContactId;
        insert oppt2;

         /** == MASTER TEST DATA - BEGIN == */

        // Model Master
        Model_Master__c modelCode2 = Test_DataFactory.createModelCode(false, 'Test Model Code 2');
        modelCode2.Engine_Capacity__c = 1601;    // To test COE Category
        modelCode2.BHP__c = 131;                 // To test COE Category
        modelCode2.Franchise_Code__c = 'KIAPC';
        insert modelCode2;
        // Model Year Master
        //Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);     
        Model_Year_Master__c modelYearCode2 = new Model_Year_Master__c(ModelYear__c = Date.today().addYears(-2), Model_Master__c = modelCode2.Id, VSMS_Compound_Primary_Key__c='2');
        insert modelYearCode2;
        // Color Master
        Color_Master__c colorCode2 = Test_DataFactory.createColorCode(true, 'Test Color Code 2', 'Test 2', 'CCK', 'KIAPC');
        // Trim Master
        Trim_Master__c trimCode2 = Test_DataFactory.createTrimCode(true, 'Test Trim Code 2');
        Date productionMonth2 = Date.newInstance(2019, 08, 02);  
        // Stock Vehicle Master
        Vehicle_Master2__c vMaster2 = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190087', 
                                                            Model_Year_Code__c = modelYearCode2.ID,
                                                            System_Commcase__c = 'KIAPC0120190087', 
                                                            Engine_No__c = 'ENGINE279832',
                                                            Chassis__c = 'CHAS279832', 
                                                            Model_Code__c = modelCode2.ID, 
                                                            ProductionMonth__c = productionMonth2,
                                                            Color_Code__c = colorCode2.ID, 
                                                            Trim_Code__c = trimCode2.ID,
                                                            ETA_Date__c = Date.today()+1);
        insert vMaster2;
        // Package Header
		Package_Header__c pckHeader2 = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode2.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader2;
        // Stock Reservation
        Stock_Reservation__c sr2 = Test_DataFactory.StockReservation(false, modelCode2.ID, colorCode2.ID, trimCode2.ID, modelYearCode2.ID);
        sr2.Package_Header_From_PickList__c = pckHeader2.Id;
        // sr2.Vehicle_Master__c = vMaster2.ID;
        sr2.Opportunity__c    = oppt2.Id;
        sr2.Customer_Mobile_Number__c = '6587546860';
        insert sr2;

        /** == MASTER TEST DATA - END ==*/


        // Accessories Master
        List<Accessories_Master__c> accMasters2 = new List<Accessories_Master__c>();
        Accessories_Master__c accMaster3 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                    ACM_ACCSDESC__c = 'ACC2',
                                                                    ACM_ACCSCD__c = 'TESTACCMASTER2',
                                                                    Rate__c = 5001,
                                                                    ACM_ACCSTYPE__c = 'C');
        accMasters2.add(accMaster3);
        
        Accessories_Master__c accMaster4 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Service Credit',
                                                                     ACM_ACCSCD__c = 'SVC1001',
                                                                     Rate__c = 1001,
                                                                     ACM_ACCSTYPE__c = 'C');
        accMasters2.add(accMaster4);
 
        insert accMasters2;
        
        // Create Accs Rate Master
        Accs_Rate_Master__c accRateMaster2 = new Accs_Rate_Master__c(Accessories__c = accMasters2[0].Id,
                                                                    ARM_ACM_FRNCD__c = 'KIAPC');
        insert accRateMaster2;

        // Create Package Accessories
        List<Package_Accs__c> pckAccList2 = new List<Package_Accs__c>();
        Package_Accs__c pckAcc3 = new Package_Accs__c(Package_Header__c = pckHeader2.Id,
                                                     Accessories_Master__c = accMasters2[0].Id,
                                                     PKA_PKH_FRNCD__c = 'KIAPC',
                                                     PKA_VALUE__c = null);
        pckAccList2.add(pckAcc3);

        Package_Accs__c pckAcc4 = new Package_Accs__c(Package_Header__c = pckHeader2.Id,
                                                      Accessories_Master__c = accMasters2[1].Id,
                                                      PKA_PKH_FRNCD__c = 'KIAPC');
        pckAccList2.add(pckAcc4);
		insert pckAccList2;

		// Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster2 = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test 2',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster2;

        // Package Addtional Charges
        List<Package_Additional_Charges__c> pckAddnlChargeList2 = new List<Package_Additional_Charges__c>();
        Package_Additional_Charges__c pckAddnlCharge3 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster2.Id,
                                                                                          Package_Header__c = pckHeader2.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R004',
                                                                                          PKC_CHARGES__c = 101);
        pckAddnlChargeList2.add(pckAddnlCharge3);
        Package_Additional_Charges__c pckAddnlCharge4 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster2.Id,
                                                                                          Package_Header__c = pckHeader2.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R002',
                                                                                          PKC_INCPRICE__c = 'INC',
                                                                                          PKC_CHARGES__c = 101);
        pckAddnlChargeList2.add(pckAddnlCharge4);
        insert pckAddnlChargeList2;
 
        //Create Sales Agreement
        Sales_Agreement__c salesAgreement2 = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9998', sr2.Id, 'Ly Van Thanh');
        salesAgreement2.Package_Header__c = pckHeader2.Id;
        insert salesAgreement2;
    }

    @isTest
    static void Test_getNextCOE(){
        COEBiddingController.getNextCOE();
    }

    @isTest
    static void Test_getLastCOE(){
        COEBiddingController.getLastCOE();
    }

    @isTest
    static void Test_retriveDSAsForBidding(){
        COEBiddingController.retrieveDSAsForBidding('KIAPC', null);
    }

    @isTest
    static void Test_getExchangeRate(){
        COEBiddingController.getExchangeRate('USD');
    }

    @isTest
    static void Test_saveInputData(){
        Sales_Agreement__c sa = [SELECT Id FROM Sales_Agreement__c LIMIT 1];
        Map<String, String> info = new Map<String, String>();
        info.put('saId', String.valueOf(sa.Id));
        info.put('api', 'true');

        COEBiddingController.saveInputData(new List<Map<String, String>>{info});
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_1(){
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_2(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_3(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_4(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c, Bid_3_Amount__c FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        sa.Bid_3_Amount__c = 100;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_5(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c, Bid_3_Amount__c, Bid_4_Amount__c FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        sa.Bid_3_Amount__c = 100;
        sa.Bid_4_Amount__c = 100;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_6(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c, Bid_3_Amount__c, Bid_4_Amount__c, Bid_5_Amount__c FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        sa.Bid_3_Amount__c = 100;
        sa.Bid_4_Amount__c = 100;
        sa.Bid_5_Amount__c = 100;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_7(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c, Bid_3_Amount__c, Bid_4_Amount__c, Bid_5_Amount__c, Bid_6_Amount__c FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        sa.Bid_3_Amount__c = 100;
        sa.Bid_4_Amount__c = 100;
        sa.Bid_5_Amount__c = 100;
        sa.Bid_6_Amount__c = 100;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_8(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c, Bid_3_Amount__c, Bid_4_Amount__c, Bid_5_Amount__c, Bid_6_Amount__c, Bid_7_Amount__c FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        sa.Bid_3_Amount__c = 100;
        sa.Bid_4_Amount__c = 100;
        sa.Bid_5_Amount__c = 100;
        sa.Bid_6_Amount__c = 100;
        sa.Bid_7_Amount__c = 100;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_9(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c, Bid_3_Amount__c, Bid_4_Amount__c, Bid_5_Amount__c, Bid_6_Amount__c, Bid_7_Amount__c, Bid_8_Amount__c FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        sa.Bid_3_Amount__c = 100;
        sa.Bid_4_Amount__c = 100;
        sa.Bid_5_Amount__c = 100;
        sa.Bid_6_Amount__c = 100;
        sa.Bid_7_Amount__c = 100;
        sa.Bid_8_Amount__c = 100;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_10(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c, Bid_3_Amount__c, Bid_4_Amount__c, Bid_5_Amount__c, Bid_6_Amount__c, Bid_7_Amount__c, Bid_8_Amount__c,
                                        Bid_9_Amount__c
                                FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        sa.Bid_3_Amount__c = 100;
        sa.Bid_4_Amount__c = 100;
        sa.Bid_5_Amount__c = 100;
        sa.Bid_6_Amount__c = 100;
        sa.Bid_7_Amount__c = 100;
        sa.Bid_8_Amount__c = 100;
        sa.Bid_9_Amount__c = 1;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_11(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c, Bid_3_Amount__c, Bid_4_Amount__c, Bid_5_Amount__c, Bid_6_Amount__c, Bid_7_Amount__c, Bid_8_Amount__c,
                                        Bid_9_Amount__c, Bid_10_Amount__c
                                FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        sa.Bid_3_Amount__c = 100;
        sa.Bid_4_Amount__c = 100;
        sa.Bid_5_Amount__c = 100;
        sa.Bid_6_Amount__c = 100;
        sa.Bid_7_Amount__c = 100;
        sa.Bid_8_Amount__c = 100;
        sa.Bid_9_Amount__c = 1;
        sa.Bid_10_Amount__c = 1;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_submitForCOEBidding_BidAmountIsNull_12(){
        Sales_Agreement__c sa = [SELECT Bid_1_Amount__c, Bid_2_Amount__c, Bid_3_Amount__c, Bid_4_Amount__c, Bid_5_Amount__c, Bid_6_Amount__c, Bid_7_Amount__c, Bid_8_Amount__c,
                                        Bid_9_Amount__c, Bid_10_Amount__c, Bid_11_Amount__c
                                FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_1_Amount__c = 100;
        sa.Bid_2_Amount__c = 100;
        sa.Bid_3_Amount__c = 100;
        sa.Bid_4_Amount__c = 100;
        sa.Bid_5_Amount__c = 100;
        sa.Bid_6_Amount__c = 100;
        sa.Bid_7_Amount__c = 100;
        sa.Bid_8_Amount__c = 100;
        sa.Bid_9_Amount__c = 1;
        sa.Bid_10_Amount__c = 1;
        sa.Bid_11_Amount__c = 2;
        update sa;
        
        submitForCOEBidding();
    }

    @isTest
    static void Test_calculateFieldsPresave_VehicleMasterIsNotNull(){
        Sales_Agreement__c sa = [SELECT Id, FranchiseCode__c, Stock_Reservation__r.Vehicle_Master__c, Stock_Reservation__r.Model_Code__c,
                                        Stock_Reservation__r.Vehicle_Master__r.FOB_Amount__c, Stock_Reservation__r.Vehicle_Master__r.Insurance_Charges__c,
                                        Stock_Reservation__r.Vehicle_Master__r.Freight_Charges__c , Stock_Reservation__r.Vehicle_Master__r.Model_Code__r.Fuel_Type__c,
                                        Stock_Reservation__r.Vehicle_Master__r.OMV__c, VES__c, Proposed_Commission__c, Registration_Type__c,
                                        Stock_Reservation__r.Vehicle_Master__r.Duty_Amount__c, Net_Transaction_Price__c, GMS_Package__c, Additional_Charges__c,
                                        Cost_of_Standard_Accessories__c, Cost_of_Accessories_Traded_Sold__c, GST_Charge__c, CPF_on_Comm__c
                                 FROM Sales_Agreement__c 
                                 WHERE SOH_SONO__c = 'NO9999' 
                                 LIMIT 1];
        COEBiddingController.calculateFieldsPresave(new List<Sales_Agreement__c>{sa}, 'CCK', 1000, 1.1, 0, 0, 0);
    }

    @isTest
    static void Test_calculateFieldsPresave_VehicleMasterIsNull(){
        Sales_Agreement__c sa = [SELECT Id, FranchiseCode__c, Stock_Reservation__r.Model_Code__c, Stock_Reservation__r.Vehicle_Master__r.Model_Code__r.Fuel_Type__c,
                                        Stock_Reservation__r.Vehicle_Master__r.OMV__c, VES__c, Proposed_Commission__c, Registration_Type__c,
                                        Stock_Reservation__r.Vehicle_Master__r.Duty_Amount__c, Net_Transaction_Price__c, GMS_Package__c, Additional_Charges__c,
                                        Cost_of_Standard_Accessories__c, Cost_of_Accessories_Traded_Sold__c, GST_Charge__c, CPF_on_Comm__c
                                 FROM Sales_Agreement__c 
                                 WHERE SOH_SONO__c = 'NO9998' 
                                 LIMIT 1];

        Model_Master__c vm = [SELECT Id, 
                                    (SELECT Freight_Charges__c, FOB_Amount__c, Insurance_Charges__c FROM Vehicle_Master__r LIMIT 1)
                              FROM Model_Master__c 
                              WHERE Name = 'Test Model Code 2'
                              LIMIT 1];
        COEBiddingController.calculateFieldsPresave(new List<Sales_Agreement__c>{sa}, 'CCK', 1000, 1.1, 0, 0, 0);
    }

    @isTest
    static void Test_calculateCIF(){
        COEBiddingController.calculateCIF(1, 2, 3, 'KIA', 1.1, 0, 0, 0);
    }

    @isTest
    static void Test_sendEmailToBSD(){
        Sales_Agreement__c sa = [SELECT Id, Name, Agreement_Date__c, Sales_Consultant__c, Customer_Full_Name__c, Bid_Category__c, Bid_Price__c, Bid_2_Amount__c FROM Sales_Agreement__c LIMIT 1];

        UserRole userRole = [ SELECT Id from UserRole WHERE Name = 'BSD'];
        User user = Test_DataFactory.createUser(false, 'Thanh', 'tly');
        user.UserRoleId = userRole.Id;
        user.IsActive = true;
        insert user;

        COEBiddingController.sendEmailToBSD('KIAPC', String.valueOf(Date.today()), String.valueOf(Date.today()+7), '', new List<Sales_Agreement__c>{sa});
    }

    @isTest
    static void Test_sendEmailToSC(){
        Sales_Agreement__c sa = [SELECT Id, Name, Verified_by_Sales_Consultant__c FROM Sales_Agreement__c LIMIT 1];
        sa.Verified_by_Sales_Consultant__c = false;
        update sa;

        Profile profile = [ SELECT Id from Profile WHERE Name = 'CITCV Sales Manager'];
        User user = Test_DataFactory.createUserWithProfileID(false, 'Thanh', 'Ly', 'test123@gmail.com', profile.Id);
        user.IsActive = true;
        insert user;

        COEBiddingController.sendEmailToSC(new List<Id>{sa.Id}, user.Id);
    }

    @isTest
    static void Test_getBidCategoryValue(){
        Sales_Agreement__c sa = [SELECT Id, Bid_Category__c FROM Sales_Agreement__c LIMIT 1];
        sa.Bid_Category__c = 'A1';
        update sa;

        COEBiddingController.getBidCategoryValue();
    }

    @isTest
    static void Test_getFranchisePicklist(){
        Vehicle_Master2__c vm = [SELECT Id, Franchise_Code__c FROM Vehicle_Master2__c LIMIT 1];
    
        COEBiddingController.getFranchisePicklist();
    }

    @isTest
    static void Test_convertFilterWrapperToString(){
        COEBiddingController.FilterWrapper filter = new COEBiddingController.FilterWrapper();
        filter.category = 'A';
        filter.guaranteeStatus = 'Guaranteed COE';
        filter.svmStatus = 'Stock to Indent';
        filter.approvalStatus = 'Approved';
        filter.bidCategory = 'A1';
        filter.submitStatus = String.valueOf(false);

        COEBiddingController.convertFilterWrapperToString(filter);
    }

    // @isTest
    // static void Test_getModelCodeAndLastestSVM(){
    //     Model_Master__c vm = [SELECT Id, 
    //                           (SELECT Freight_Charges__c, FOB_Amount__c, Insurance_Charges__c FROM Vehicle_Master__r LIMIT 1)
    //                           FROM Model_Master__c LIMIT 1];
    
    //     COEBiddingController.getModelCodeAndLastestSVM(new List<String>{vm.Id});
    // }

    @isTest
    static void Test_getSVMHasLatestETA(){
        Vehicle_Master2__c vm = [SELECT Id FROM Vehicle_Master2__c LIMIT 1];
    
        COEBiddingController.getSVMHasLatestETA(vm.Id);
    }

    static void submitForCOEBidding(){
        Sales_Agreement__c sa = [SELECT Id, Bid_Price__c, Bid_Category__c FROM Sales_Agreement__c LIMIT 1];
        COE_Bid_Period__c coePeriod = [SELECT Id FROM COE_Bid_Period__c WHERE From_Date__c >= :Date.today() LIMIT 1];

        List<Map<String, String>> info = new List<Map<String, String>>();
        Map<String, String> m1 = new Map<String, String>();
        m1.put('Id', String.valueOf(sa.Id));
        m1.put('Bid_Price__c', String.valueOf(sa.Bid_Price__c));
        m1.put('Bid_Category__c', String.valueOf(sa.Bid_Category__c));
        info.add(m1);

        COEBiddingController.submitForCOEBidding(info, String.valueOf(coePeriod.Id));
    }
}
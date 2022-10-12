@isTest
private class COETriggerTest {

    @testSetup
    static void setUp() {
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
        insert salesAgreement;

        COE_Bid_Period__c coePeriod1 = Test_DataFactory.createCOEPeriod(true, Date.today(), Date.today()+7);
        COE_Bid_Period__c coePeriod2 = Test_DataFactory.createCOEPeriod(true, Date.today()+8, Date.today()+15);

        SA_COE_Bid_Period__c saCOEPeriod1 = new SA_COE_Bid_Period__c();
        saCOEPeriod1.Sales_Agreement__c = salesAgreement.Id;
        saCOEPeriod1.COE_Bid_Period__c = coePeriod1.Id;
        insert saCOEPeriod1;

        SA_COE_Bid_Period__c saCOEPeriod2 = new SA_COE_Bid_Period__c();
        saCOEPeriod2.Sales_Agreement__c = salesAgreement.Id;
        saCOEPeriod2.COE_Bid_Period__c = coePeriod2.Id;
        insert saCOEPeriod2;

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
                                                            Trim_Code__c = trimCode2.ID);
        insert vMaster2;
        // Package Header
		Package_Header__c pckHeader2 = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode2.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader2;
        // Stock Reservation
        Stock_Reservation__c sr2 = Test_DataFactory.StockReservation(false, modelCode2.ID, colorCode2.ID, trimCode2.ID, modelYearCode2.ID);
        sr2.Package_Header_From_PickList__c = pckHeader2.Id;
        sr2.Vehicle_Master__c = vMaster2.ID;
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
        salesAgreement.Package_Header__c = pckHeader2.Id;
        insert salesAgreement2;
    }

	@isTest
    static void Test_onBeforeInsert() {
    	Sales_Agreement__c sa = [SELECT Id FROM Sales_Agreement__c LIMIT 1];
        COE__c coe = new COE__c();
        coe.COH_EXPMONTH__c = Date.today()+1;
        coe.COH_SOH_SONO__c = '5678';
        coe.Sales_Agreement__c = sa.Id;
        insert coe;

        coe = [SELECT Id,Sales_Agreement__c FROM COE__c WHERE Sales_Agreement__c = :sa.Id];
    }

    @isTest
    static void Test_onBeforeInsert_Error_SA() {
    	Sales_Agreement__c sa = [SELECT Id FROM Sales_Agreement__c LIMIT 1];
        COE__c coe = new COE__c();
        coe.COH_EXPMONTH__c = Date.today()+1;
        coe.COH_SOH_SONO__c = '5678';
        coe.Sales_Agreement__c = sa.Id;
        insert coe;

        COE__c coe2 = new COE__c();
        coe2.COH_EXPMONTH__c = Date.today() + 2;
        coe2.COH_SOH_SONO__c = '56789';
        coe2.Sales_Agreement__c = sa.Id;
        try
        {
            insert coe2;
        }
        catch(Exception e)
        {
            System.assertEquals(true, e.getMessage().contains('has been linked to this Sales Agreement. Please check again!'));
        }
    }

    @isTest
    static void Test_onBeforeInsert_Error_MBSA() {
        // Create Model
        Model__c model = Test_DataFactory.createmodelId(true, 'MB A Class Test', 'CCI', 'MBP');

        // Create Variant
        Variant__c variant = new Variant__c(Name = 'MB A 250 Test',
                                           Model_ID__c = model.Id,
                                           Franchise__c = 'MBP',
                                           Branch__c = 'CCI',
                                           Allow_Indent__c = false,
                                           Description__c = 'MB A 250 Test',
                                           Active__c = true,
                                           Engine_Capacity__c = '1600',
                                           BHP__c = '130');
        insert variant;

        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;

        // Create Indent Variant 
        Variant__c variant1 = new Variant__c(Name = 'MB A 200 Indent',
                                                  Model_ID__c = model.Id,
                                                  Franchise__c = 'MBP',
                                                  Branch__c = 'CCI',
                                                  Allow_Indent__c = true,
                                                  Description__c = 'MB A 200 Indent',
                                                  Engine_Capacity__c = '1700',
                                                  BHP__c = '150');
        insert variant1;

        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA1 = new MB_Sales_Agreement__c();
        mbSA1.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA1.Customer_Full_Name__c = 'X1111Test';
        mbSA1.CNRIC_Number__c = 'SXXXX1111';
        mbSA1.Submit_COE_Bidding__c = true;
        insert mbSA1;

        COE__c coe = new COE__c();
        coe.COH_EXPMONTH__c = Date.today()+1;
        coe.COH_SOH_SONO__c = '5678';
        coe.MB_Sales_Agreement__c = mbSA1.Id;
        insert coe;

        COE__c coe2 = new COE__c();
        coe2.COH_EXPMONTH__c = Date.today() + 2;
        coe2.COH_SOH_SONO__c = '56789';
        coe2.MB_Sales_Agreement__c = mbSA1.Id;
        try
        {
            insert coe2;
        }
        catch(Exception e)
        {
            System.assertEquals(true, e.getMessage().contains('has been linked to this Sales Agreement. Please check again!'));
        }
    }

    @isTest
    static void Test_onBeforeUpdate() {
        Sales_Agreement__c oldSA = [SELECT Id FROM Sales_Agreement__c WHERE SOH_SONO__c = 'NO9999' LIMIT 1];
        Sales_Agreement__c newSA = [SELECT Id, COE__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'NO9998' LIMIT 1];

        COE_Bid_Period__c coePeriod = [SELECT Id FROM COE_Bid_Period__c LIMIT 1];

        COE__c coe = new COE__c(COH_EXPMONTH__c = System.today(), COH_SOH_SONO__c = '1234', Sales_Agreement__c = oldSA.Id, COE_Bid_Period__c = coePeriod.Id);
        insert coe;

        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        oldSA.COE__c = null;
        update oldSA;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);

        coe.Sales_Agreement__c = newSA.Id;
        update coe;
    }

    @isTest
    static void Test_onBeforeUpdate_Error_SA() {
        Sales_Agreement__c oldSA = [SELECT Id FROM Sales_Agreement__c WHERE SOH_SONO__c = 'NO9999' LIMIT 1];
        Sales_Agreement__c newSA = [SELECT Id, COE__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'NO9998' LIMIT 1];

        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        COE__c coe = new COE__c();
        coe.COH_EXPMONTH__c = Date.today()+1;
        coe.COH_SOH_SONO__c = '5678';
        coe.Sales_Agreement__c = oldSA.Id;
        insert coe;

        COE__c coe2 = new COE__c();
        coe2.COH_EXPMONTH__c = Date.today() + 2;
        coe2.COH_SOH_SONO__c = '56789';
        coe2.Sales_Agreement__c = newSA.Id;
        insert coe2;

        try
        {
            coe2.Sales_Agreement__c = oldSA.Id;
            update coe2;
            TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
        }
        catch(Exception e)
        {
            System.assertEquals(true, e.getMessage().contains('has been linked to this COE. Please check again!'));
        }
    }

    /*@isTest
    static void Test_onBeforeUpdate_Error_MBSA() {
        // Create Model
        Model__c model = Test_DataFactory.createmodelId(true, 'MB A Class Test', 'CCI', 'MBP');

        // Create Variant
        Variant__c variant = new Variant__c(Name = 'MB A 250 Test',
                                           Model_ID__c = model.Id,
                                           Franchise__c = 'MBP',
                                           Branch__c = 'CCI',
                                           Allow_Indent__c = false,
                                           Description__c = 'MB A 250 Test',
                                           Active__c = true,
                                           Engine_Capacity__c = '1600',
                                           BHP__c = '130');
        insert variant;

        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;

        // Create Indent Variant 
        Variant__c variant1 = new Variant__c(Name = 'MB A 200 Indent',
                                             Model_ID__c = model.Id,
                                             Franchise__c = 'MBP',
                                             Branch__c = 'CCI',
                                             Description__c = 'MB A 200 Indent',
                                             Engine_Capacity__c = '1700',
                                             BHP__c = '150');
        insert variant1;
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM2 = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '2',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant1.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM2;

        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA1 = new MB_Sales_Agreement__c();
        mbSA1.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA1.Customer_Full_Name__c = 'X1111Test';
        mbSA1.CNRIC_Number__c = 'SXXXX1111';
        mbSA1.Submit_COE_Bidding__c = true;
        insert mbSA1;

        MB_Sales_Agreement__c mbSA2 = new MB_Sales_Agreement__c();
        mbSA2.MB_Stock_Vehicle_Master__c = mbSVM2.Id;
        mbSA2.Customer_Full_Name__c = 'X1111Test';
        mbSA2.CNRIC_Number__c = 'SXXXX1111';
        mbSA2.Submit_COE_Bidding__c = true;
        insert mbSA2;

        COE__c coe = new COE__c();
        coe.COH_EXPMONTH__c = Date.today()+1;
        coe.COH_SOH_SONO__c = '5678';
        coe.MB_Sales_Agreement__c = mbSA1.Id;
        insert coe;

        COE__c coe2 = new COE__c();
        coe2.COH_EXPMONTH__c = Date.today() + 2;
        coe2.COH_SOH_SONO__c = '56789';
        coe2.MB_Sales_Agreement__c = mbSA2.Id;
        insert coe2;

        try
        {
            coe.MB_Sales_Agreement__c = mbSA2.Id;
            update coe;
        }
        catch(Exception e)
        {
            System.assertEquals(true, e.getMessage().contains('has been linked to this COE'));
        }
    }*/

	@isTest
    static void Test_afterInsert_SA() {
        Sales_Agreement__c sa = [SELECT Id FROM Sales_Agreement__c LIMIT 1];
        COE_Bid_Period__c coePeriod = [SELECT Id FROM COE_Bid_Period__c LIMIT 1];

        COE__c coe = new COE__c();
        coe.COH_EXPMONTH__c = Date.today();
        coe.COH_SOH_SONO__c = '5678';
        coe.Sales_Agreement__c = sa.Id;
        coe.COE_Bid_Period__c = coePeriod.Id;
        insert coe;
    }

    @isTest
    static void Test_afterInsert_MBSA(){
        // Create Model
        Model__c model = Test_DataFactory.createmodelId(true, 'MB A Class Test', 'CCI', 'MBP');

        // Create Variant
        Variant__c variant = new Variant__c(Name = 'MB A 250 Test',
                                           Model_ID__c = model.Id,
                                           Franchise__c = 'MBP',
                                           Branch__c = 'CCI',
                                           Allow_Indent__c = false,
                                           Description__c = 'MB A 250 Test',
                                           Active__c = true,
                                           Engine_Capacity__c = '1600',
                                           BHP__c = '130');
        insert variant;
        system.debug('variant ::' + variant);

        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;

        // Create Indent Variant 
        Variant__c variant1 = new Variant__c(Name = 'MB A 200 Indent',
                                                  Model_ID__c = model.Id,
                                                  Franchise__c = 'MBP',
                                                  Branch__c = 'CCI',
                                                  Allow_Indent__c = true,
                                                  Description__c = 'MB A 200 Indent',
                                                  Engine_Capacity__c = '1700',
                                                  BHP__c = '150');
        insert variant1;

        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM2 = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '2',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant1.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM2;

        Account personAcc = Test_DataFactory.createPerson(false, 'Thanh', 'Prospect');
        personAcc.PersonEmail = 'thanhly@mail.com';
        insert personAcc;

        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA1 = new MB_Sales_Agreement__c();
        mbSA1.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA1.Customer_Full_Name__c = 'X1111Test';
        mbSA1.CNRIC_Number__c = 'SXXXX1111';
        mbSA1.Submit_COE_Bidding__c = true;
        mbSA1.Account__c = personAcc.Id;
        insert mbSA1;
        system.debug('mbSA1 ::' + mbSA1.MB_Stock_Vehicle_Master__r.Status__c);

        COE_Bid_Period__c coePeriod = [SELECT Id FROM COE_Bid_Period__c LIMIT 1];

        COE__c coe = new COE__c();
        coe.COH_EXPMONTH__c = Date.today();
        coe.COH_SOH_SONO__c = '5678';
        coe.MB_Sales_Agreement__c = mbSA1.Id;
        coe.COE_Bid_Period__c = coePeriod.Id;
        insert coe;
    }
    
	@isTest
    static void Test_afterUpdate() {
        Sales_Agreement__c oldSA = [SELECT Id FROM Sales_Agreement__c WHERE SOH_SONO__c = 'NO9999' LIMIT 1];
        Sales_Agreement__c newSA = [SELECT Id FROM Sales_Agreement__c WHERE SOH_SONO__c = 'NO9998' LIMIT 1];
        COE_Bid_Period__c coePeriod = [SELECT Id FROM COE_Bid_Period__c LIMIT 1];

        COE__c coe = new COE__c(COH_EXPMONTH__c = System.today(), COH_SOH_SONO__c = '1234', COE_Bid_Period__c = coePeriod.Id);
        insert coe;

        coe.Sales_Agreement__c = newSA.Id;
        update coe;
    }

    @isTest
    static void Test_afterUpdate_MBSA() {
        // Create Model
        Model__c model = Test_DataFactory.createmodelId(true, 'MB A Class Test', 'CCI', 'MBP');

        // Create Variant
        Variant__c variant = new Variant__c(Name = 'MB A 250 Test',
                                           Model_ID__c = model.Id,
                                           Franchise__c = 'MBP',
                                           Branch__c = 'CCI',
                                           Allow_Indent__c = false,
                                           Description__c = 'MB A 250 Test',
                                           Active__c = true,
                                           Engine_Capacity__c = '1600',
                                           BHP__c = '130');
        insert variant;
        system.debug('variant ::' + variant);

        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;

        // Create Indent Variant 
        Variant__c variant1 = new Variant__c(Name = 'MB A 200 Indent',
                                                  Model_ID__c = model.Id,
                                                  Franchise__c = 'MBP',
                                                  Branch__c = 'CCI',
                                                  Allow_Indent__c = true,
                                                  Description__c = 'MB A 200 Indent',
                                                  Engine_Capacity__c = '1700',
                                                  BHP__c = '150');
        insert variant1;

        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM2 = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '2',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant1.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM2;

        Account personAcc = Test_DataFactory.createPerson(false, 'Thanh', 'Prospect');
        personAcc.PersonEmail = 'thanhly@mail.com';
        insert personAcc;

        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA1 = new MB_Sales_Agreement__c();
        mbSA1.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA1.Customer_Full_Name__c = 'X1111Test';
        mbSA1.CNRIC_Number__c = 'SXXXX1111';
        mbSA1.Submit_COE_Bidding__c = true;
        mbSA1.Account__c = personAcc.Id;
        insert mbSA1;

        MB_Sales_Agreement__c mbSA2 = new MB_Sales_Agreement__c();
        mbSA2.MB_Stock_Vehicle_Master__c = mbSVM2.Id;
        mbSA2.Customer_Full_Name__c = 'X1111Test';
        mbSA2.CNRIC_Number__c = 'SXXXX1111';
        mbSA2.Submit_COE_Bidding__c = true;
        insert mbSA2;

        COE_Bid_Period__c coePeriod = [SELECT Id FROM COE_Bid_Period__c LIMIT 1];

        COE__c coe = new COE__c();
        coe.COH_EXPMONTH__c = Date.today();
        coe.COH_SOH_SONO__c = '5678';
        coe.MB_Sales_Agreement__c = mbSA1.Id;
        coe.COE_Bid_Period__c = coePeriod.Id;
        insert coe;

        TriggerExclusion.excludeTrigger('MB_Sales_Agreement__c', true);
        mbSA1.COE__c = null;
        update mbSA1;
        TriggerExclusion.excludeTrigger('MB_Sales_Agreement__c', false);

        coe.MB_Sales_Agreement__c = mbSA2.Id;
        update coe;
    }
}
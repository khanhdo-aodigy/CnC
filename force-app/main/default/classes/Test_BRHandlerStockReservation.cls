@isTest
global class Test_BRHandlerStockReservation {

    @isTest(/*SeeAllData=true*/) public static void createStk(){
    	user uc = Test_DataFactory.createUser(true, 'testuser', 'myusr');
        Account acc = Test_DataFactory.createAccount(true, 'testAccount');
        Contact con = Test_DataFactory.createContact(true,'testContactfname','testContactlname',acc.Id);
        Model_Master__c mm =  Test_DataFactory.createModelCode(true, 'Test Model');
        Color_Master__c cm =  Test_DataFactory.createColorCode(true, 'testModelColor','KIAvs','CCF','CITCV');          
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'testTrim');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id);
        Opportunity op1 = Test_DataFactory.createOpportunity(false, 'test', acc.id);
        op1.OwnerId = uc.Id;
        op1.Contact_Person__c   =con.Id;
        insert op1; 
        Stock_Reservation__c sr1 = Test_DataFactory.StockReservation(false, mm.id, cm.id, tm.id, mym.Id);        
        sr1.Franchise_Code__c = 'KIACV';
        sr1.Opportunity__c = op1.Id;
        sr1.OwnerId = uc.Id;
        sr1.Reservation_Status__c = 'Reserve';
        insert sr1; 
        
        
        sr1.Reservation_Status__c = 'Print';
        Update sr1;
    }

    /**
     * Added by: Phap (dangphap.mai@aodigy.com) on 28/08/2020 to test notifying BAM when vehicle master change
     */
    @isTest
    private static void testNotifyBAM() {
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

        Vehicle_Master2__c vMaster_new = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086_', 
                                                                Model_Year_Code__c = modelYearCode.ID,
                                                                System_Commcase__c = 'KIAPC0120190086_', 
                                                                Engine_No__c = 'ENGINE279831',
                                                                Chassis__c = 'CHAS279831', 
                                                                Model_Code__c = modelCode.ID, 
                                                                ProductionMonth__c = productionMonth,
                                                                Color_Code__c = colorCode.ID, 
                                                                Trim_Code__c = trimCode.ID);
        insert vMaster_new;

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
        
        Business_Associate_Master__c BAM = new Business_Associate_Master__c(Name = 'Test BAM', BAM_ASSOCIATECD__c = 'IF100005',
                                                                            BAM_INHOUSE__c = 'Y', BAM_TYPE__c = 'FIN', BAM_STATUS__c = 'A');
        insert BAM;
        Email_Setting__c emailSetting = new Email_Setting__c(Name = 'Test Setting', 
                                                            Email_To__c = 'dangphap.mai@aodigy.com', 
                                                            Email_Cc__c = 'dangphap.mai@aodigy.com', 
                                                            Registration_Type__c = 'All',
                                                            //CCA__c = true, 
                                                            //CCF__c = true, 
                                                            //CCK__c = true, 
                                                            Finance_Company_Lookup__c = BAM.ID,
                                                            Branch_Code__c = 'CCK;CCA;CCF');
        insert emailSetting;

        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.CommcaseNo__c = 'KIAPC0120190086';
        salesAgreement.Finance_Company_Lookup__c = BAM.ID;
        salesAgreement.Finance_Company_In_House__c = true;
        salesAgreement.Registration_Type__c = 'P';
        salesAgreement.Emailed_BAM__c = true;
        insert salesAgreement;

        Test.startTest();
        stockReservation.Vehicle_Master__c = vMaster_new.ID;
        update stockReservation;
        Test.stopTest();
    }

    /**
     * Added by: Phap (dangphap.mai@aodigy.com) on 28/08/2020 to test notifying BAM when vehicle master change
     */
    @isTest
    private static void testNotifyBAM_errorHandle() {
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

        Vehicle_Master2__c vMaster_new = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086_', 
                                                                Model_Year_Code__c = modelYearCode.ID,
                                                                System_Commcase__c = 'KIAPC0120190086_', 
                                                                Engine_No__c = 'ENGINE279831',
                                                                Chassis__c = 'CHAS279831', 
                                                                Model_Code__c = modelCode.ID, 
                                                                ProductionMonth__c = productionMonth,
                                                                Color_Code__c = colorCode.ID, 
                                                                Trim_Code__c = trimCode.ID);
        insert vMaster_new;

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
        
        Business_Associate_Master__c BAM = new Business_Associate_Master__c(Name = 'Test BAM', BAM_ASSOCIATECD__c = 'IF100005',
                                                                            BAM_INHOUSE__c = 'Y', BAM_TYPE__c = 'FIN', BAM_STATUS__c = 'A');
        insert BAM;

        Email_Setting__c emailSetting2 = new Email_Setting__c(Name = 'Test Setting', 
                                                            Email_To__c = null, 
                                                            Email_Cc__c = null, 
                                                            Registration_Type__c = 'All',
                                                            //CCA__c = true, 
                                                            //CCF__c = true, 
                                                            //CCK__c = true, 
                                                            Finance_Company_Lookup__c = BAM.ID,
                                                            Branch_Code__c = 'CCK;CCA;CCF');
        insert emailSetting2;

        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.CommcaseNo__c = 'KIAPC0120190086';
        salesAgreement.Finance_Company_Lookup__c = BAM.ID;
        salesAgreement.Finance_Company_In_House__c = true;
        salesAgreement.Registration_Type__c = 'P';
        salesAgreement.Emailed_BAM__c = true;
        insert salesAgreement;

        Test.startTest();
        stockReservation.Vehicle_Master__c = vMaster_new.ID;
        update stockReservation;
        Test.stopTest();
    }
}
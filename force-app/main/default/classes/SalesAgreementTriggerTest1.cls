@isTest
private class SalesAgreementTriggerTest1 {
    @TestSetup
    static void setUp(){
        /*Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        automationSetting.Bypass_Flows__c            = true;
        automationSetting.Bypass_Processes__c        = true;
        // automationSetting.Bypass_Triggers__c         = true;
        automationSetting.Bypass_Workflows__c        = true;
        insert automationSetting;*/

        TriggerExclusion.excludeTrigger('Account', true);
		TriggerExclusion.excludeTrigger('Opportunity', true);
        TriggerExclusion.excludeTrigger('Model_Master__c', true);
        TriggerExclusion.excludeTrigger('Model_Year_Master__c', true);
        TriggerExclusion.excludeTrigger('Color_Master__c', true);
        TriggerExclusion.excludeTrigger('Trim_Master__c', true);
        TriggerExclusion.excludeTrigger('Vehicle_Master2__c', true);
        TriggerExclusion.excludeTrigger('Package_Header__c', true);
        TriggerExclusion.excludeTrigger('Stock_Reservation__c', true);
        TriggerExclusion.excludeTrigger('Accessories_Master__c', true);
        TriggerExclusion.excludeTrigger('Package_Accs__c', true);
        TriggerExclusion.excludeTrigger('Package_Additional_Charges__c', true);
        TriggerExclusion.excludeTrigger('Additional_Charges_Master__c', true);
        //TriggerExclusion.excludeTrigger('SA_Accessory__c', true);
        TriggerExclusion.excludeTrigger('SA_Additional_Charge__c', true);
        TriggerExclusion.excludeTrigger('Business_Associate_Master__c', true);
        TriggerExclusion.excludeTrigger('Email_Setting__c', true);
        // TriggerExclusion.excludeTrigger('COE__c', true);
        // TriggerExclusion.excludeTrigger('Delivery_Bay_Booking__c', true);

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
        
        // Business Associate Master
        Business_Associate_Master__c BAM = new Business_Associate_Master__c(Name = 'Test BAM', BAM_ASSOCIATECD__c = 'IF100005',
                                                                            BAM_INHOUSE__c = 'Y', BAM_TYPE__c = 'FIN', BAM_STATUS__c = 'A');
        insert BAM;
        // Email Setting
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



        // COE
        /*COE__c coe = new COE__c(COH_EXPMONTH__c = System.today(),
                                COH_SOH_SONO__c = '1234',
                                COH_DEPOSIT__c = 23456,
                                COH_COECATEGORY__c = 'A');
        coe.COH_COENO__c = '2034245282132342W';
        insert coe;*/

        Delivery_Bay_Configuration__c dbConfig = new Delivery_Bay_Configuration__c();
        dbConfig.Name= 'Delivery Bay Booking Config';
        dbConfig.Email_Template_Cancel_Delivery__c = 'Cancel Booking Slot';
        dbConfig.Email_Template_Delivery_Bay_Booking__c = 'After Booking Slot';
        dbConfig.Email_Template_Ready_for_Delivery__c = 'Ready For Delivery';
        dbConfig.Location_Delivery_Complete__c = 'Test Location';
        dbConfig.Location_QC_Complete__c = 'Test Location';
        insert dbConfig;

    }

    @isTest
    static void Test_AfterInsert() {
    	Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];

        Test.startTest();
        Sales_Agreement__c salesAgreement = createSalesAgreement(false, 'CCK', 'NO9999', stockReservation.ID, 'Thieu Dang Vu'); 
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
        Test.stopTest();
    }
    
    @isTest
    static void Test_AfterUpdate_CreateCOESAAcc() 
    {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.CommcaseNo__c = '12-0059 15';
        insert salesAgreement;
        
        salesAgreement.COE_Refund__c = 4050;
        update salesAgreement;
        
        salesAgreement.COE_Refund__c = 4051;
        update salesAgreement;
        
        salesAgreement.COE_Refund__c = 0;
        update salesAgreement;
        
        salesAgreement.COE_Refund__c = 4050;
        update salesAgreement;
        
        salesAgreement.COE_Refund__c = null;
        update salesAgreement;
    }
    
    @isTest
    static void Test_AfterUpdate_CreateGMSSAAcc() 
    {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
        
        salesAgreement.GMS_Package__c = 4050;
        update salesAgreement;
        
        salesAgreement.GMS_Package__c = 4051;
        update salesAgreement;
        
        salesAgreement.GMS_Package__c = 0;
        update salesAgreement;
        
        salesAgreement.GMS_Package__c = 4050;
        update salesAgreement;
        
        salesAgreement.GMS_Package__c = null;
        update salesAgreement;
    }
    
    @isTest
    static void Test_AfterUpdate_CreateSVCSAAcc() 
    {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
        
        salesAgreement.Service_Credit__c = 4050;
        update salesAgreement;
        
        salesAgreement.Service_Credit__c = 4051;
        update salesAgreement;
        
        salesAgreement.Service_Credit__c = 0;
        update salesAgreement;
        
        salesAgreement.Service_Credit__c = 4000;
        update salesAgreement;
        
        salesAgreement.Service_Credit__c = null;
        update salesAgreement;
    }
    
    @isTest
    static void Test_AfterUpdate_CreateACCSAAcc() 
    {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Accessories_Credit__c = null;
        insert salesAgreement;
        
        salesAgreement.Accessories_Credit__c = 4050;
        update salesAgreement;
        
        salesAgreement.Accessories_Credit__c = 4051;
        update salesAgreement;
        
        salesAgreement.Accessories_Credit__c = 0;
        update salesAgreement;
        
        salesAgreement.Accessories_Credit__c = 4050;
        update salesAgreement;
        
        salesAgreement.Accessories_Credit__c = null;
        update salesAgreement;
    }  
    
    @isTest
    static void Test_UpdateSalesAgreementTotalFees() 
    {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Additional_Charges_Master__c additionalChargesMaster = [SELECT Id FROM Additional_Charges_Master__c];
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Vehicle_Purchase_Price__c = 90000;
        salesAgreement.Total_VES_Roadtax_and_fees__c = 1000;
        insert salesAgreement;
        
        SA_Additional_Charge__c saAdditionalCharge = Test_DataFactory.createSAAdditionalCharge(true, additionalChargesMaster.Id, salesAgreement.Id);
        
        SalesAgreements.updateSalesAgreementTotalFees(new Set<Id> {salesAgreement.Id});       
    }  
    
    @isTest
    static void Test_AfterUpdate_CreateUser() 
    {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
		salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Stage__c          = 'Draft';
        insert salesAgreement;
        
        salesAgreement.Stage__c = 'Confirmation of Sale';
        update salesAgreement;
    }  

    @isTest
    static void Test_AfterInsert_CompanyType() {
      //  Account personAcc = Test_DataFactory.createPerson(true, 'Test 2', 'Customer');
        Account personAcc = Test_DataFactory.createPerson(false, 'Test 2', 'Customer');
        personAcc.PersonEmail = 'patest123@mail.com';
        insert personAcc;
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun2', personAcc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        insert oppt;
        Model_Master__c modelCode = [SELECT Id FROM Model_Master__c];
        Model_Year_Master__c modelYearCode = [SELECT Id FROM Model_Year_Master__c];
        Color_Master__c colorCode = [SELECT Id FROM Color_Master__c];
        Trim_Master__c trimCode = [SELECT Id FROM Trim_Master__c];
        
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];

        // Create Stock Reservation
        Stock_Reservation__c stockReservation2 = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation2.Registration_Type__c = 'C';
        stockReservation2.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation2.Opportunity__c = oppt.Id;
		insert stockReservation2;
        
		// Create Sales Agreement
        Sales_Agreement__c salesAgreement = createSalesAgreement(false, 'CCK', 'NO9999', stockReservation2.ID, 'Thieu Dang Vu'); 
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;

    }
    
    @isTest
    static void Test_NotifyBAM() {
		Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Business_Associate_Master__c BAM = [SELECT ID FROM Business_Associate_Master__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', stockReservation.ID, 'Thieu Dang Vu');
	 	sa.Package_Header__c = pckHeader.Id;
        sa.CommcaseNo__c = 'KIAPC0120190086';
        sa.Finance_Company_Lookup__c = BAM.ID;
        sa.Finance_Company_In_House__c = true;
        sa.Registration_Type__c = 'P';

        Test.startTest();
        insert sa;
        sa.Balance_Payment_Email__c = true;
        update sa;
        Test.stopTest();

        sa = [SELECT Emailed_BAM__c FROM Sales_Agreement__c WHERE ID = :sa.ID];
        System.assert(sa.Emailed_BAM__c);
    }
 
    /*@isTest
    static void Test_AfterUpdate_AutoLink_COE() {
        COE__c coe = [SELECT Id, Sales_Agreement__c, MB_Sales_Agreement__c, Sales_Agreement_Unique_Id__c FROM COE__c WHERE COH_SOH_SONO__c = '1234'];
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];

        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', 'AK1234', stockReservation.ID, 'Thieu Dang Vu');
	 	sa.Package_Header__c = pckHeader.Id;
        sa.CommcaseNo__c = 'KIAPC0120190086';
        sa.Finance_Company_In_House__c = true;
        sa.Registration_Type__c = 'P';

		Test.startTest();
        insert sa;
        sa = [SELECT ID, COE__c, COECategory__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AK1234'];
        sa.COE__c = coe.Id;
        update sa;
        Test.stopTest();

        coe = [SELECT Id, Sales_Agreement__c, MB_Sales_Agreement__c, Sales_Agreement_Unique_Id__c FROM COE__c WHERE COH_SOH_SONO__c = '1234'];
        sa =  [SELECT Id, COE__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'AK1234'];
        system.assertEquals(coe.Sales_Agreement__c, sa.Id);
        system.assertEquals(sa.COE__c, coe.Id);
    }*/

    @isTest
    static void Test_AfterUpdate_ConvertPA() {
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
    	Account pa = [SELECT ID, RecordType.Name FROM Account WHERE PersonEmail = 'patest@mail.com'];
    	Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
		sa.Account__c = pa.Id;
    	Test.startTest();
    	insert sa;
    	sa.Stage__c = 'Car Collected';
    	update sa;
    	Test.stopTest();
    	pa = [SELECT ID, RecordType.Name FROM Account WHERE Id = :sa.Account__c];
    	System.assertEquals('Customer', pa.RecordType.Name);
    }
    
    @isTest
    static void Test_AfterUpdate_updateDeliveryBayBooking() {
                
        Delivery_Bay_In_Charge__c dbic = new Delivery_Bay_In_Charge__c();
        dbic.Active__c = true;
        dbic.Email__c = 'test@gmail.com';
        dbic.Franchise_Code__c = 'KIAPC';
        insert dbic;
        
		Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        insert sa;
        Delivery_Bay_Booking__c dbb = new Delivery_Bay_Booking__c(Sales_Agreement__c = sa.id);
        insert dbb;
        Test.startTest();
        dbb.Status__c ='Booked';
        update dbb;
        sa.Stage__c = 'Car Collected';
        update sa;
        Test.stopTest();
        Delivery_Bay_Booking__c dbb_result = [Select Id, Status__c, Sales_Agreement__c from Delivery_Bay_Booking__c Where Sales_Agreement__c =: sa.Id LIMIT 1];
        System.assertEquals('Completed', dbb_result.Status__c);
    }
    
    @isTest
    static void Test_AfterUpdate_sendEmailForBookingDeliveryBaySlot() {
		Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        Test.startTest();
       	insert sa;
        sa.Vehicle_Movement_Completed__c = true;
        sa.Stage__c = 'Ready for Registration';
        update sa;
        Test.stopTest();
    }

    @isTest
    static void Test_AfterUpdate_createVehicleMovementTracker() {

        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');

        // Create Location
        Id recordTypeIdLocation = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get('Vehicle Movement').getRecordTypeId();
        Location__c location = new Location__c(Name = 'Test Location',
                                               Email_Subject__c = '{!Name} Test Subject',
                                               Email_Body__c = '{!Name} Test Body',
                                               Email_Communication_Vehicle_Movement__c = true,
                                               RecordTypeId = recordTypeIdLocation);
        insert location;
        Test.startTest();
       	insert sa;
        sa.Stage__c = 'Car Collected';
        update sa;
        Test.stopTest();
        List<Vehicle_Movement_Tracker__c> newRecords = [Select Id from Vehicle_Movement_Tracker__c];
        System.assertEquals(1, newRecords.size());
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
		Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
		Sales_Agreement__c sa = createSalesAgreement(true, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
    }

    /**
    * create sales agreement [Thang added 29/08/2021]
    **/
    private static Sales_Agreement__c createSalesAgreement(Boolean doInsert, string branchCode, string agreementNo, ID stockReservationId, string customerName) {
        
        // create sales agreement
        Sales_Agreement__c SA = new Sales_Agreement__c();
        SA.Branch_Code__c = branchCode;
        SA.SOH_SONO__c = agreementNo;
        SA.Stock_Reservation__c = stockReservationId;
        //SA.Customer_Full_Name__c = customerName;
        SA.NCD__c = 20;
        SA.Promo_Discount__c = 200;
        SA.Accessories_Discount__c = 500;
        SA.Expected_Delivery_From__c = Date.today();
        SA.Expected_Delivery_To__c = Date.today();
        SA.Payment__c = 'Car Loan';
        SA.ARCA_Number__c = 'UEN123456';
        SA.Company_Name__c = 'ABC TEST';
        if (doInsert) {insert SA;}
        return SA;
    }
    
    @isTest
    static void Test_BeforeUpdate_calculateCarReadyAndJITDate() {
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        sa.Car_Ready_Date__c = Date.today();
        insert sa;
        
        Duty_JIT_Calculation__c djc = new Duty_JIT_Calculation__c();
        djc.JIT_Work_Days_PC__c = 6;
     	insert djc;
   
        Blocked_Off_Day__c offDays = new Blocked_Off_Day__c();
        offDays.Date__c = Date.today() -2;
        offDays.Is_Active__c = true;
        insert offDays;

        Test.startTest();
        sa.Car_Ready_Date__c = Date.today() + 10;
        update sa;
        Sales_Agreement__c saAfter = [SELECT Id, Car_Ready_Date__c, JIT_Date__c FROM Sales_Agreement__c WHERE Id =: sa.Id];
        System.assertEquals((Date.today()+10).addDays(- (Integer)djc.JIT_Work_Days_PC__c), saAfter.JIT_Date__c);
        Test.stopTest();
    }
    
    @isTest
    static void Test_BeforeUpdate_calculateCarReadyAndJITDate_Error_ReadyCarDayIsNull() {
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        sa.Car_Ready_Date__c = Date.today();
        insert sa;
        
        Duty_JIT_Calculation__c djc = new Duty_JIT_Calculation__c();
        djc.JIT_Work_Days_PC__c = 6;
     	insert djc;
   
        Blocked_Off_Day__c offDays = new Blocked_Off_Day__c();
        offDays.Date__c = Date.today() -2;
        offDays.Is_Active__c = true;
        insert offDays;

        Test.startTest();
        sa.Car_Ready_Date__c = null;
        update sa;
        Sales_Agreement__c saAfter = [SELECT Id, Car_Ready_Date__c, JIT_Date__c FROM Sales_Agreement__c WHERE Id =: sa.Id];
        System.assertEquals(null, saAfter.JIT_Date__c);
        Test.stopTest();
    }
    
    @isTest
    static void Test_BeforeUpdate_calculateCarReadyAndJITDate_Error_CarReadyDdtBeforEarliestAvailableDdt() {
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        sa.Car_Ready_Date__c = Date.today();
        insert sa;
        
        Duty_JIT_Calculation__c djc = new Duty_JIT_Calculation__c();
        djc.JIT_Work_Days_PC__c = 6;
     	insert djc;
   
        Blocked_Off_Day__c offDays = new Blocked_Off_Day__c();
        offDays.Date__c = Date.today()-2;
        offDays.Is_Active__c = true;
        insert offDays;
        
        Date earliestDay = Date.today() + 8;

        Test.startTest();
        Try
        {
        	sa.Car_Ready_Date__c = Date.today()+1;
        	update sa;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Earliest available Car Ready Date is after '+ earliestDay.format() +'. Please choose another date!') ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    @isTest
    static void Test_BeforeUpdate_calculateCarReadyAndJITDate_Error_CarReadyDayIsBlockedOffDay() {
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        sa.Car_Ready_Date__c = Date.today();
        insert sa;
        
        Duty_JIT_Calculation__c djc = new Duty_JIT_Calculation__c();
        djc.JIT_Work_Days_PC__c = 6;
     	insert djc;
   
        Blocked_Off_Day__c offDays = new Blocked_Off_Day__c();
        offDays.Date__c = Date.today() + 10;
        offDays.Is_Active__c = true;
        insert offDays;
        
        Date earliestDay = Date.today() + 8;

        Test.startTest();
        Try
        {
        	sa.Car_Ready_Date__c = Date.today() + 10;
        	update sa;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Selected date is Blocked Off Day. Earliest available Car Ready Date is after '+ earliestDay.format() +'. Please choose another date!') ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    @isTest
    static void Test_AfterUpdate_updateDutyRequestDate() {
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Vehicle_Master2__c vm2 = [SELECT Id FROM Vehicle_Master2__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        sa.Stock_Reservation__c = sr.Id;
        sa.Car_Ready_Date__c = Date.today();
        insert sa;
        
        Duty_JIT_Calculation__c djc = new Duty_JIT_Calculation__c();
        djc.JIT_Work_Days_PC__c = 6;
        djc.Duty_Request_Days_PC__c = 2;
     	insert djc;

        Blocked_Off_Day__c offDays = new Blocked_Off_Day__c();
        offDays.Date__c = Date.today();
        offDays.Is_Active__c = true;
        insert offDays;

        Test.startTest();
        sa.Car_Ready_Date__c = Date.today() + 10;
        update sa;
        Sales_Agreement__c saAfter = [SELECT Id, Car_Ready_Date__c, JIT_Date__c FROM Sales_Agreement__c];
        Vehicle_Master2__c vMaster2 = [SELECT Id, Duty_Request_Date__c FROM Vehicle_Master2__c];
        System.assertEquals(saAfter.JIT_Date__c - 2, vMaster2.Duty_Request_Date__c);
        Test.stopTest();
    }

    @isTest
    static void Test_AfterUpdate_updateDutyRequestDate_CarReadyDayIsNull() {
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Package_Header__c pckHeader = [SELECT Id FROM Package_Header__c];
        Vehicle_Master2__c vm2 = [SELECT Id FROM Vehicle_Master2__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        sa.Stock_Reservation__c = sr.Id;
        sa.Car_Ready_Date__c = Date.today();
        insert sa;
        
        Duty_JIT_Calculation__c djc = new Duty_JIT_Calculation__c();
        djc.JIT_Work_Days_PC__c = 6;
        djc.Duty_Request_Days_PC__c = 2;
     	insert djc;

        Blocked_Off_Day__c offDays = new Blocked_Off_Day__c();
        offDays.Date__c = Date.today();
        offDays.Is_Active__c = true;
        insert offDays;

        Test.startTest();
        sa.Car_Ready_Date__c = null;
        update sa;
        Vehicle_Master2__c vMaster2 = [SELECT Id, Duty_Request_Date__c, JIT_Date__c FROM Vehicle_Master2__c];
        System.assertEquals(null, vMaster2.JIT_Date__c);
        System.assertEquals(null, vMaster2.Duty_Request_Date__c);
        Test.stopTest();
    }
    
    @isTest
    static void Test_BeforeUpdate_updateCOEThresholdCalculation(){
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        sa.Verified_by_Sales_Consultant__c = false;
        insert sa;
        
        Additional_Charges_Master__c aCM = new Additional_Charges_Master__c(ADM_CHRGCD__c = 'R001');
        insert aCM;
        SA_Additional_Charge__c sAC = new SA_Additional_Charge__c();
        sAC.AdditionalChargesMaster__c = aCM.Id;
        sAC.Sales_Agreement__c = sa.Id;
        insert sAC;
        
        Test.startTest();
        sa.Verified_by_Sales_Consultant__c = true;
        sa.VES__c = -100;
        sa.Additional_Charges__c = 958;
        sa.Cost_of_Standard_Accessories__c = 1881;
        sa.Cost_of_Accessories_Traded_Sold__c = 0;
        sa.GST_Charge__c = 0;
        
        sa.Package_List_Price__c  = 94999;
        sa.Sum_of_SA_Addnl_Charges_for_CEVS__c = 0;
        sa.Sum_of_In_House_Support_Discount__c  = 0;
        sa.Accessories_Discount__c  = 0;
        sa.Promo_Discount__c = 0;
        sa.COE_Refund__c = 0;
        sa.Total_Exclusive_SA_Acc_List_Prices__c = 0;
        sa.GMS_Package__c = 0;
        sa.Proposed_Commission__c = 600;
        update sa;
        
        Test.stopTest();
    }
    
    @isTest
    static void Test_BeforeUpdate_preSubmitFieldCalculation(){
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        sa.Verified_by_Sales_Consultant__c = false;
        sa.Stage__c = 'Confirmation of Sale';
        insert sa;
        
        SA_Accessory__c sAss = new SA_Accessory__c();
        sAss.SAC_INCPRICE__c = 'INC';
        sAss.SAC_PACKAGE__c = 'N';
        sAss.Sales_Agreement__c = sa.Id;
        insert sAss;
        
        Test.startTest();
        sa.Verified_by_Sales_Consultant__c = true;
        sa.VES__c = 0;
        sa.Additional_Charges__c = 958;
        sa.Cost_of_Standard_Accessories__c = 1881;
        sa.Cost_of_Accessories_Traded_Sold__c = 0;
        sa.GST_Charge__c = 0;
        
        sa.Package_List_Price__c  = 94999;
        sa.Sum_of_SA_Addnl_Charges_for_CEVS__c = 0;
        sa.Sum_of_In_House_Support_Discount__c  = 0;
        sa.Accessories_Discount__c  = 0;
        sa.Promo_Discount__c = 0;
        sa.COE_Refund__c = 0;
        sa.Paid_Accessories__c = 0;
        sa.Total_Exclusive_SA_Acc_List_Prices__c = 0;
        sa.GMS_Package__c = 0;
        sa.Proposed_Commission__c = 600;
        update sa;
        Test.stopTest();
    }
}
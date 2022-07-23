@isTest
private class VSMS_CallOutToCreateACMTest {
    
    @testSetup
    static void testSetUp() {
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        // Create Package Header
        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        Account tempAccount = Test_DataFactory.createAccount(true, 'Test Account 1');
        Lead tempLead = Test_DataFactory.createLead(true, 'Aodigy 1', 'Test Lead 1');
        Contact tempCt = Test_DataFactory.createContact(false, 'Test Name 1', 'Test Name 1', tempAccount.Id);
        tempCt.Birthdate = date.newInstance(2001, 3, 21);
        insert tempCt;
        Opportunity tempOpportunity = Test_DataFactory.createOpportunity(true, 'Test Opportunity 1', tempAccount.ID);
        tempOpportunity.Lead__c = tempLead.ID;
        tempOpportunity.Contact_Person__c = tempCt.Id;
        update tempOpportunity;
        // Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation.Opportunity__c = tempOpportunity.Id;
        insert stockReservation;  
        // Create Accs Master
        Accessories_Master__c accMaster1 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Acc Test',
                                                                     ACM_ACCSCD__c = 'GMS3000',
                                                                     Rate__c = 30000,
                                                                     ACM_ACCSTYPE__c = 'C', 
                                                                     ACM_BRM_UNIQUEBRCD__c = 'CCLCCKSGDCCK003');
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
                                                         PKA_PKH_FRNCD__c = 'KIAPC',
                                                         PKA_VALUE__c = 300);
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
                                                                                          PKC_ADM_CHRGCD__c ='R004',
                                                                                          PKC_REBATE__c = 738);
        pckAddnlChargeList.add(pckAddnlCharge1);
        insert pckAddnlChargeList;  
    }
    
    @IsTest
    private static void testCalloutToCreateACM_createCOE() {
        Accessories_Master__c accMaster1 = [Select Id from Accessories_Master__c];
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        Stock_Reservation__c stockReservation = [Select Id from Stock_Reservation__c];
        
        stockReservation.Registration_Type__c = 'P';
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Reservation_Status__c = 'Reserve';
        update stockReservation;
  
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'N00009', stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Road_Tax_Top_Up__c = true;
        insert salesAgreement; 
        
        //Create SA Accessory
        SA_Accessory__c saAcc2 = new SA_Accessory__c (Sales_Agreement__c = salesAgreement.Id,
                                                      Acc_Code_Trigger__c = 'COE3050',
                                                      SAC_LINENO__c = 2,
                                                      Price_Trigger__c = 3050);
        insert saAcc2;

        Test.setMock(HttpCalloutMock.class, new VSMS_CallOutToCreateACMMock());    
        Test.startTest();
        VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c , 'COE3050', salesAgreement.UniqueBranchCode__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testCalloutToCreateACM_createSVC() {
        Accessories_Master__c accMaster1 = [Select Id from Accessories_Master__c];
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        Stock_Reservation__c stockReservation = [Select Id from Stock_Reservation__c];
        
        stockReservation.Registration_Type__c = 'P';
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Reservation_Status__c = 'Reserve';
        update stockReservation;
       
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'N00009', stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Road_Tax_Top_Up__c = true;
        insert salesAgreement; 
        
        //Create SA Accessory
        List<SA_Accessory__c> saAccs = new List<SA_Accessory__c>();
        SA_Accessory__c saAcc1 = new SA_Accessory__c (Sales_Agreement__c = salesAgreement.Id,
                                                      Acc_Code_Trigger__c = 'SVC2000',
                                                      SAC_LINENO__c = 1,
                                                      Price_Trigger__c = 2000);
        saAccs.add(saAcc1);
        
        Test.setMock(HttpCalloutMock.class, new VSMS_CallOutToCreateACMMock());
        Test.startTest();
        VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, salesAgreement.FranchiseCode__c , 'SVC2000', salesAgreement.UniqueBranchCode__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testCalloutToCreateACM_createGMS() {
        Accessories_Master__c accMaster1 = [Select Id from Accessories_Master__c];
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        Stock_Reservation__c stockReservation = [Select Id from Stock_Reservation__c];
       
        stockReservation.Registration_Type__c = 'P';
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Reservation_Status__c = 'Reserve';
        update stockReservation;
   
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'N00009', stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Road_Tax_Top_Up__c = true;
        insert salesAgreement; 
        
        //Create SA Accessory
		SA_Accessory__c saAcc1 = new SA_Accessory__c (Sales_Agreement__c = salesAgreement.Id,
                                                      Acc_Code_Trigger__c = 'GMS3000',
                                                      SAC_LINENO__c = 1,
                                                      Price_Trigger__c = 3000);
        insert saAcc1;      
        
        Test.setMock(HttpCalloutMock.class, new VSMS_CallOutToCreateACMMock());
        Test.startTest();
        VSMS_CallOutToCreateACM.callOutToCreateACM(salesAgreement.Id, 'KIAPC', 'GMS3000', 'CCLCCKSGDCCK003');
        Test.stopTest();
    }
}
@isTest
private class VSMS_SalesAgrmntMappingSalesOrderTest {    
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
        Lead tempLead = Test_DataFactory.createLead(true, 'Aodigy 1', 'TestLead1');
        Contact tempCt = Test_DataFactory.createContact(false, 'Test Name 1', 'Test Name 1', tempAccount.Id);
        tempCt.Birthdate = date.newInstance(2001, 3, 21);
        tempCt.Gender__c = null;
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
    
    @isTest
    static void Test_generateRequestBody() {
        Accessories_Master__c accMaster1 = [Select Id from Accessories_Master__c];
        Additional_Charges_Master__c addnlChargeMaster = [Select Id from Additional_Charges_Master__c];
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        Stock_Reservation__c stockReservation = [Select Id from Stock_Reservation__c];
        
        stockReservation.Registration_Type__c = 'P';
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Reservation_Status__c = 'Reserve';
        update stockReservation;
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', null, stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Road_Tax_Top_Up__c = true;
        insert salesAgreement; 
        
        //Create SA Accessory
        List<SA_Accessory__c> saAccs = new List<SA_Accessory__c>();
        SA_Accessory__c saAcc1 = new SA_Accessory__c (Sales_Agreement__c = salesAgreement.Id,
                                                      Acc_Code_Trigger__c = 'GMS3000',
                                                      SAC_LINENO__c = 1,
                                                      Price_Trigger__c = 3000);
        saAccs.add(saAcc1);
        SA_Accessory__c saAcc2 = new SA_Accessory__c (Sales_Agreement__c = salesAgreement.Id,
                                                      Acc_Code_Trigger__c = 'COE3050',
                                                      SAC_LINENO__c = 2,
                                                      Price_Trigger__c = 3050);
        saAccs.add(saAcc2);
        SA_Accessory__c saAcc3 = new SA_Accessory__c (Sales_Agreement__c = salesAgreement.Id,
                                                      Accessories_Master__c = accMaster1.Id,
                                                      SAC_LINENO__c = 3,
                                                      SAC_ACCSTRADE__c = 'N',
                                                      SAC_PACKAGE__c = 'N');
        saAccs.add(saAcc3);
        insert saAccs;
        
        //Create SA Additional Charge
        SA_Additional_Charge__c saAddnlCharge = new SA_Additional_Charge__c (Sales_Agreement__c = salesAgreement.Id,
                                                                             SAD_CHARGES__c = 7000,
                                                                             SAD_REBATE__c = 1000,
                                                                             SAD_INCPRICE__c = 'INC',
                                                                             AdditionalChargesMaster__c = addnlChargeMaster.Id);
        insert saAddnlCharge;  
        
        Test.startTest();
        VSMS_SalesAgrmntMappingSalesOrder.generateRequestBody(salesAgreement.Id, false);
        Test.stopTest();
    }
    
    @isTest
    static void Test_generateRequestBody_CompanyType() {
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        Stock_Reservation__c stockReservation = [Select Id from Stock_Reservation__c];
        stockReservation.Registration_Type__c = 'C';
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        update stockReservation;
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', null, stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Finance_Company_In_House__c = true;
        salesAgreement.Road_Tax_Top_Up__c = false;
        insert salesAgreement;
        
        // Create Additional Charges Master
        Additional_Charges_Master__c addnlChargeMaster1 = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                           ADM_CHRGCD__c = 'R002');
        insert addnlChargeMaster1;
        Additional_Charges_Master__c addnlChargeMaster2 = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                           ADM_CHRGCD__c = '1000');
        insert addnlChargeMaster2;
        Additional_Charges_Master__c addnlChargeMaster3 = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                           ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster3;
        
        //Create SA Additional Charge
        SA_Additional_Charge__c saAddnlCharge1 = new SA_Additional_Charge__c (Sales_Agreement__c = salesAgreement.Id,
                                                                              SAD_CHARGES__c = 7000,
                                                                              SAD_REBATE__c = 1000,
                                                                              SAD_INCPRICE__c = 'INC',
                                                                              AdditionalChargesMaster__c = addnlChargeMaster1.Id);
        insert saAddnlCharge1;   
        SA_Additional_Charge__c saAddnlCharge2 = new SA_Additional_Charge__c (Sales_Agreement__c = salesAgreement.Id,
                                                                              SAD_CHARGES__c = 7000,
                                                                              SAD_REBATE__c = 1000,
                                                                              SAD_INCPRICE__c = 'INC',
                                                                              AdditionalChargesMaster__c = addnlChargeMaster2.Id);
        insert saAddnlCharge2;  
        SA_Additional_Charge__c saAddnlCharge3 = new SA_Additional_Charge__c (Sales_Agreement__c = salesAgreement.Id,
                                                                              SAD_CHARGES__c = 7000,
                                                                              SAD_REBATE__c = 1000,
                                                                              SAD_INCPRICE__c = 'INC',
                                                                              AdditionalChargesMaster__c = addnlChargeMaster3.Id);
        insert saAddnlCharge3;  
        
        // Create Accs Master
        Accessories_Master__c accMaster2 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Acc Test',
                                                                     ACM_ACCSCD__c = '10YRS',
                                                                     Rate__c = 5000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster2;
        
        // Create SA Acc
        SA_Accessory__c saAcc1 = new SA_Accessory__c (Sales_Agreement__c = salesAgreement.Id,
                                                      Accessories_Master__c = accMaster2.Id,
                                                      SAC_LINENO__c = 1,
                                                      SAC_PACKAGE__c = 'Y');
        insert saAcc1;
        
        Test.startTest();
        VSMS_SalesAgrmntMappingSalesOrder.generateRequestBody(salesAgreement.Id, false);
        Test.stopTest();
    }
    
    @isTest
    static void Test_generateSellerDataRequestBody() {
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        Stock_Reservation__c stockReservation = [Select Id from Stock_Reservation__c];
        stockReservation.Registration_Type__c = 'C';
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        update stockReservation;
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', null, stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Finance_Company_In_House__c = true;
        salesAgreement.Road_Tax_Top_Up__c = false;
        insert salesAgreement;
        
        Test.startTest();
        VSMS_SalesAgrmntMappingSalesOrder.generateSellerDataRequestBody(salesAgreement.Id);
        Test.stopTest();
    }
    
    @isTest
    static void Test_generateSellerDataRequestBody_UsedCarUnderCompany() {
        Package_Header__c pckHeader = [Select Id from Package_Header__c];
        Stock_Reservation__c stockReservation = [Select Id from Stock_Reservation__c];
        stockReservation.Registration_Type__c = 'C';
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        update stockReservation;
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', null, stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Finance_Company_In_House__c = true;
        salesAgreement.Road_Tax_Top_Up__c = false;
        salesAgreement.isUsedCarUnderCompany__c = true;
        salesAgreement.Seller_Type__c = 'FLEET';
        insert salesAgreement;
        
        Test.startTest();
        VSMS_SalesAgrmntMappingSalesOrder.generateSellerDataRequestBody(salesAgreement.Id);
        Test.stopTest();
    }
}
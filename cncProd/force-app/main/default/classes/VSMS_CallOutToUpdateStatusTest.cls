@isTest
public class VSMS_CallOutToUpdateStatusTest {
    
    @IsTest
    private static void testCallOutToUpdateStatus() {
        
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        // Create Package Header
        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        // Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        insert stockReservation;
        Account tempAccount = Test_DataFactory.createAccount(true, 'Test Account 1');
        Lead tempLead = Test_DataFactory.createLead(true, 'Aodigy 1', 'Test Lead 1');
        Contact tempCt = Test_DataFactory.createContact(false, 'Test Name 1', 'Test Name 1', tempAccount.Id);
        tempCt.Birthdate = date.newInstance(2001, 3, 21);
        insert tempCt;
        Opportunity tempOpportunity = Test_DataFactory.createOpportunity(true, 'Test Opportunity 1', tempAccount.ID);
        tempOpportunity.Lead__c = tempLead.ID;
        tempOpportunity.Contact_Person__c = tempCt.Id;
        update tempOpportunity;
        stockReservation.Opportunity__c = tempOpportunity.Id;
        stockReservation.Registration_Type__c = 'P';
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Reservation_Status__c = 'Reserve';
        update stockReservation;
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
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'N00009', stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.Road_Tax_Top_Up__c = true;
        insert salesAgreement; 
        
        Test.setMock(HttpCalloutMock.class, new VSMS_CallOutToCreateACMMock());    
        Test.startTest();
        VSMS_CallOutToUpdateStatus.callOutToUpdateStatus(salesAgreement.Id);
        Test.stopTest();
    }
    
    @IsTest
    private static void testCallOutToUpdateStatus_Error2() {
        
        Test.setMock(HttpCalloutMock.class, new VSMS_CalloutToDeleteSoAccMock());
        try {
            Test.startTest();
            VSMS_CallOutToUpdateStatus.callOutToUpdateStatus(null);
            Test.stopTest();
        } catch (Exception e ) {
            System.assertEquals('Invalid id: ', e.getMessage());
        }
    }
}
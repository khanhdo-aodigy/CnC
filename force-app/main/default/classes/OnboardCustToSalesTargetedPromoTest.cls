/** ******
 * Description: Test Class For OnboardCustToSalesTargetedPromo class
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		         Description
 * 20220512             thanh.ly@aodigy              Created Initial Version. 
** ******/
@isTest
private class OnboardCustToSalesTargetedPromoTest {
    @TestSetup
    private static void setup(){
        Account acc = Test_DataFactory.createAccount(true, 'Bob');
        Contact con = Test_DataFactory.createContact(true, 'Bob', 'Lee', acc.Id);

        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc.Id];
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCK';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = personAcc.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt.Contact_Person__c = personAcc.PersonContactId;
        insert oppt;

        /** == MASTER TEST DATA - BEGIN == */

        // Model Master
        Model_Master__c modelCode = Test_DataFactory.createModelCode(false, 'CER1.6AEXG333');
        modelCode.Engine_Capacity__c = 1600;    // To test COE Category
        modelCode.BHP__c = 130;                 // To test COE Category
        modelCode.Franchise_Code__c = 'KIAPC';
        modelCode.Branch_Code__c = 'CCK';
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
        sr.Branch_Code__c = 'CCK';
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

        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        Sales_Agreement__c sAgree = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', sr.Id, 'Test'); 
        sAgree.Package_Header__c = pckHeader.Id;
        sAgree.Contact__c = con.Id;
        sAgree.Account__c = acc.Id;
        sAgree.Stage__c = 'Request Registration';
        insert sAgree;


        // Create other Sales Agreement 
        Account personAcc2 = Test_DataFactory.createPerson(false, 'Test2', 'Prospect');
        personAcc2.PersonEmail = 'patest2@mail.com';
        insert personAcc2;
        personAcc2 = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc2.Id];
        Opportunity oppt2 = Test_DataFactory.createOpportunity(false,'testRun2', personAcc2.Id);
        oppt2.Branch_Code__c = 'CCK';
        oppt2.Opportunity_Score__c = 40;
        oppt2.Account__c = personAcc2.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt2.Contact_Person__c = personAcc2.PersonContactId;
        insert oppt2;

        // Model Year Master
        Model_Year_Master__c modelYearCode2 = Test_DataFactory.createModelYearCode(false, modelCode.Id);
        modelYearCode2.VSMS_Compound_Primary_Key__c = '2';
        insert modelYearCode2;
        // Color Master
        Color_Master__c colorCode2 = Test_DataFactory.createColorCode(true, 'Test Color Code 2', 'Test 2', 'CCK', 'KIACV');
        // Trim Master
        Trim_Master__c trimCode2 = Test_DataFactory.createTrimCode(true, 'Test Trim Code 2');
        Date productionMonth2 = Date.newInstance(2019, 08, 02);  
        // Stock Vehicle Master
        Vehicle_Master2__c vMaster2 = new Vehicle_Master2__c(Original_Commcase__c = 'KIACV0120190086', 
                                                            Model_Year_Code__c = modelYearCode2.ID,
                                                            System_Commcase__c = 'KIACV0120190086', 
                                                            Engine_No__c = 'ENGINE279833',
                                                            Chassis__c = 'CHAS279833', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth2,
                                                            Color_Code__c = colorCode2.ID, 
                                                            Trim_Code__c = trimCode2.ID);
        insert vMaster2;

        Package_Header__c pckHeader2 = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIACV',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader2;

        Stock_Reservation__c sr2 = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode2.ID, trimCode2.ID, modelYearCode2.ID);
        sr2.Package_Header_From_PickList__c = pckHeader2.Id;
        sr2.Vehicle_Master__c = vMaster2.ID;
        sr2.Opportunity__c    = oppt2.Id;
        sr2.Customer_Mobile_Number__c = '6587546859';
        sr2.Branch_Code__c = 'CCK';
        insert sr2;

        /** == MASTER TEST DATA - END ==*/


        // Accessories Master
        List<Accessories_Master__c> accMasters2 = new List<Accessories_Master__c>();
        Accessories_Master__c accMaster3 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIACV',
                                                                    ACM_ACCSDESC__c = 'ACC',
                                                                    ACM_ACCSCD__c = 'TESTACCMASTER',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'C');
        accMasters2.add(accMaster3);
        
        Accessories_Master__c accMaster4 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIACV',
                                                                     ACM_ACCSDESC__c = 'Service Credit',
                                                                     ACM_ACCSCD__c = 'SVC1001',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        accMasters2.add(accMaster4);
 
        insert accMasters2;
        
        // Create Accs Rate Master
        Accs_Rate_Master__c accRateMaster2 = new Accs_Rate_Master__c(Accessories__c = accMasters2[1].Id,
                                                                    ARM_ACM_FRNCD__c = 'KIACV');
        insert accRateMaster2;

        // Create Package Accessories
        List<Package_Accs__c> pckAccList2 = new List<Package_Accs__c>();
        Package_Accs__c pckAcc3 = new Package_Accs__c(Package_Header__c = pckHeader2.Id,
                                                     Accessories_Master__c = accMasters2[0].Id,
                                                     PKA_PKH_FRNCD__c = 'KIACV',
                                                     PKA_VALUE__c = null);
        pckAccList2.add(pckAcc3);

        Package_Accs__c pckAcc4 = new Package_Accs__c(Package_Header__c = pckHeader2.Id,
                                                      Accessories_Master__c = accMasters2[1].Id,
                                                      PKA_PKH_FRNCD__c = 'KIACV');
        pckAccList2.add(pckAcc4);
		insert pckAccList2;

		// Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster2 = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test 2',
                                                                                          ADM_CHRGCD__c = 'R005',
                                                                                          VSMS_Compound_Primary_Key__c = '2');
        insert addnlChargeMaster2;

        // Package Addtional Charges
        List<Package_Additional_Charges__c> pckAddnlChargeList2 = new List<Package_Additional_Charges__c>();
        Package_Additional_Charges__c pckAddnlCharge3 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIACV',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster2.Id,
                                                                                          Package_Header__c = pckHeader2.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R005',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList2.add(pckAddnlCharge3);
        Package_Additional_Charges__c pckAddnlCharge4 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIACV',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster2.Id,
                                                                                          Package_Header__c = pckHeader2.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R002',
                                                                                          PKC_INCPRICE__c = 'INC',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList2.add(pckAddnlCharge4);
        insert pckAddnlChargeList2;

        Sales_Agreement__c sAgree2 = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9998', sr2.Id, 'Test2'); 
        sAgree2.Package_Header__c = pckHeader2.Id;
        sAgree2.Contact__c = con.Id;
        sAgree2.Account__c = acc.Id;
        sAgree2.Stage__c = 'Request Registration';
        insert sAgree2;
       
        Id camRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('C&C Campaign RT (Sales Targeted Promo)').getRecordTypeId();
        Campaign cam = Test_DataFactory.createCamp(false, 'Test', 'New', 'CCK');
        cam.IsActive = true;
        cam.Type = 'Sales Targeted Promo';
        cam.RecordTypeId = camRT;
        cam.StartDate = Date.today();
        cam.Model_Master__c = modelCode.Id;
        cam.Brand__c = 'KIA';
        insert cam;
    }

    @isTest
    private static void test_OnboardCustomerToSalesTargetedPromoBatch() {
        Test.startTest();
        OnboardCustToSalesTargetedPromo.OnboardCustToSalesTargetedPromo();
        OnboardCustToSalesTargetedPromo onboard = new OnboardCustToSalesTargetedPromo();
        Database.executeBatch(onboard);
        Test.stopTest();
    }
}
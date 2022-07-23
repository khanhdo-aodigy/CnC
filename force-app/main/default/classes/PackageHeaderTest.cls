/**
 * @File Name          : PackageHeaderTest.cls
 * @Description        : 
 * @Author             : Joseph Tey
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/21/2020, 10:47:54 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/21/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
//Start of RN2020Q1010
@isTest
private class PackageHeaderTest {

    @TestSetup
    static void makeData(){
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

        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');

       	// Create Package Header
        Package_Header__c pckHeader = new Package_Header__c(Model_Master__c = modelCode.Id, PKH_FRN_FRNCD__c = 'KIAPC', PKH_STATUS__c='A', PKH_PKGPRICE__c=1000000);
        insert pckHeader;

        // Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Opportunity__c = oppt.Id;
        insert stockReservation;

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
        
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(true, 'CCK', null, stockReservation.ID, 'Thieu Dang Vu'); 
    }

    @isTest
    static void Test_processPriceChangeToSA(){
             
        test.startTest();
            Package_Header__c pckHeader = [SELECT Id, PKH_PKGPRICE__c FROM Package_Header__c];
            pckHeader.PKH_PKGPRICE__c = 1200000;
            update pckHeader;
        test.stopTest();
        Sales_Agreement__c salesAgreement = [SELECT Id, Package_List_Price__c, VehicleListPrice__c FROM Sales_Agreement__c];

        system.assertEquals(salesAgreement.Package_List_Price__c, pckHeader.PKH_PKGPRICE__c);
        
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Package_Header__c', true);
        Package_Header__c pckHeader = [SELECT Id, PKH_PKGPRICE__c FROM Package_Header__c];
        pckHeader.PKH_PKGPRICE__c = 1200000;
        update pckHeader;
        TriggerExclusion.excludeTrigger('Package_Header__c', false);
    }
}
//End of RN2020Q1010
@isTest
private class SDP_FormControllerPDFCtrlTest {
	@testSetup
    static void setUp() {
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        modelCode.Major_Group_Code__c = 'DSTest';
        update modelCode;
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCF', 'CITPC');
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

        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'CITPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        
        //Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Vehicle_Master__c = vMaster.ID;
        insert stockReservation;
        
        //Create Accs Master
        Accessories_Master__c accMaster1 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'CITPC',
                                                                     ACM_ACCSDESC__c = 'Acc Test',
                                                                     ACM_ACCSCD__c = 'GMS5000',
                                                                     Rate__c = 5000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster1;
        
        Accessories_Master__c accMaster2 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'CITPC',
                                                                     ACM_ACCSDESC__c = 'Service Credit',
                                                                     ACM_ACCSCD__c = 'SVC1000',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster2;
        
        Accessories_Master__c accMaster3 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'CITPC',
                                                                     ACM_ACCSDESC__c = 'Accessories Credit',
                                                                     ACM_ACCSCD__c = 'ACC1000',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster3;
        
        // Create Accs Rate Master
        Accs_Rate_Master__c accRateMaster = new Accs_Rate_Master__c(Accessories__c = accMaster1.Id,
                                                                    ARM_ACM_FRNCD__c = 'CITPC');
        insert accRateMaster;

        // Create Package Accessories
        List<Package_Accs__c> pckAccList = new List<Package_Accs__c>();
        for (Integer i = 0; i < 3; i++) {
            Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                    	Accessories_Master__c = accMaster1.Id,
                                                        PKA_PKH_FRNCD__c = 'CITPC');
            pckAccList.add(pckAcc);
        }
        Package_Accs__c pckAcc2 = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                    Accessories_Master__c = accMaster2.Id,
                                                    PKA_PKH_FRNCD__c = 'CITPC');
        pckAccList.add(pckAcc2);
        Package_Accs__c pckAcc3 = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                      Accessories_Master__c = accMaster3.Id,
                                                      PKA_PKH_FRNCD__c = 'CITPC');
        pckAccList.add(pckAcc3); 
		insert pckAccList;

		// Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;

        // Create Package Addtional Charges
        List<Package_Additional_Charges__c> pckAddnlChargeList = new List<Package_Additional_Charges__c>();
        Package_Additional_Charges__c pckAddnlCharge1 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'CITPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckHeader.Id,
                                                                                         PKC_ADM_CHRGCD__c ='R002',
                                                                                         PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge1);
        Package_Additional_Charges__c pckAddnlCharge2 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'CITPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckHeader.Id,
                                                                                         PKC_ADM_CHRGCD__c ='R002',
                                                                                         PKC_INCPRICE__c = 'INC',
                                                                                         PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge2);
        Package_Additional_Charges__c pckAddnlCharge3 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'CITPC',
                                                                                         Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                         Package_Header__c = pckHeader.Id,
                                                                                         PKC_INCPRICE__c = 'INC');
        pckAddnlChargeList.add(pckAddnlCharge3);
        for (Integer i = 0; i < 5; i++) {
			Package_Additional_Charges__c pckAddnlCharge = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'CITPC',
                                                                                            Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                            Package_Header__c = pckHeader.Id);
            pckAddnlChargeList.add(pckAddnlCharge);
        }
        insert pckAddnlChargeList;
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCF', 'NO9999', stockReservation.ID, 'Thieu Dang Vu'); 
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
        // Create Form Controller
        Forms_Controller__c fc = new Forms_Controller__c(	Start_Date__c = Date.today(),
            												End_Date__c = Date.today().addDays(30),
                                                         	Form_Title__c = 'Test',
                                                         	Form_Body__c = '{!SOH_SONO__c} Body',
                                                          	File_Naming_Convention__c = '{!SOH_SONO__c}_Form',
                                                         	Display_Order__c = 10,
                                                         	Object_API_Name__c = 'Sales_Agreement__c',
                                                         	Signature_Placeholder_Field_API__c = 'VDC_Customer_Signature__c'
        												);
        insert fc;
    }

    @isTest
    static void test() {
        Sales_Agreement__c sa = [SELECT ID, Branch_Code__c FROM Sales_Agreement__c];
        sa.Branch_Code__c = 'CCF';
        sa.VDC_Customer_Signature__c = 'test';
        update sa;
        system.debug('SA:: ' + sa);
        Sales_Agreement__c salesAgreemnt = [SELECT ID, Branch_Code__c, VDC_Customer_Signature__c FROM Sales_Agreement__c];
        Forms_Controller__c fc = [SELECT ID FROM Forms_Controller__c][0];
        Test.startTest();
        PageReference page = Page.SDP_FormControllerPDF;
        page.getParameters().put('id', sa.Id);
        page.getParameters().put('formId', fc.Id);
        Test.setCurrentPage(page);
        SDP_FormControllerPDFCtrl myController = new SDP_FormControllerPDFCtrl();
        System.assertEquals(myController.record.Id, salesAgreemnt.Id);
        System.assertEquals(myController.fc.Id, fc.Id);
        Test.stopTest();
    }
}
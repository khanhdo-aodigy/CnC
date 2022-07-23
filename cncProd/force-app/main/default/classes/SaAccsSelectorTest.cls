@isTest
private class SaAccsSelectorTest {
	@testSetup
    static void setUp() {
        // Create master data
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Accessories_Master__c accMaster = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                    ACM_ACCSDESC__c = 'Acc Master Test',
                                                                    ACM_ACCSCD__c = 'SER2000',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'F');
        insert accMaster;
        
                
        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
              
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC', PKH_STATUS__c='A',PKH_PKGPRICE__c=1000000,Model_Master__c = modelCode.Id);
        insert pckHeader;

        // Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
		insert stockReservation;
        
        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', stockReservation.ID, 'Thieu Dang Vu');
        //salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;


        // Create SA Accessory belongs to Package
        List<SA_Accessory__c> saAccsPck = new List<SA_Accessory__c>();
        for (Integer i = 0; i < 5; i++) {
            SA_Accessory__c saAcc = new SA_Accessory__c(Sales_Agreement__c = salesAgreement.Id,
                                                        SAC_PACKAGE__c = 'Y',
                                                    	Accessories_Master__c = accMaster.Id,
                                                        Acc_Code_Trigger__c = 'SVC2000');
            saAccsPck.add(saAcc);
        }
		insert saAccsPck;

        // Create SA Accessory not belong to Package
        List<SA_Accessory__c> saAccsNonePck = new List<SA_Accessory__c>();
        for (Integer i = 0; i < 5; i++) {
            SA_Accessory__c saAcc = new SA_Accessory__c(Sales_Agreement__c = salesAgreement.Id,
                                                        SAC_PACKAGE__c = 'N',
                                                    	Accessories_Master__c = accMaster.Id,
                                                        Acc_Code_Trigger__c = 'COE4500');
            saAccsNonePck.add(saAcc);
        }
		insert saAccsNonePck;
    }

    @isTest
    static void Test_selectAccBySalesAgreementId() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        SaAccsSelector saAccSelector = new SaAccsSelector();
        List<SA_Accessory__c> saAccsPck = saAccSelector.selectAccBySalesAgreementId(new Set<Id>{salesAgreement.Id});

        System.assertEquals(5, saAccsPck.size());
    }

    @isTest
    static void Test_selectAddonAccBySalesAgreementId() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
		SaAccsSelector saAccSelector = new SaAccsSelector();
        List<SA_Accessory__c> addonAccs = saAccSelector.selectAddonAccBySalesAgreementId(new Set<Id>{salesAgreement.Id});

        System.assertEquals(5, addonAccs.size());
    }

    @isTest
    static void Test_selectAccsBySaIdandAccCode() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        SaAccsSelector saAccSelector = new SaAccsSelector();
        SA_Accessory__c saAcc = saAccSelector.selectAccsBySaIdandAccCode(salesAgreement.Id, 'SVC2000');

        System.assertEquals('SVC2000', saAcc.Acc_Code_Trigger__c);
    }

    @isTest
    static void Test_selectAccessoriesBySalesAgreementId() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        SaAccsSelector saAccSelector = new SaAccsSelector();
        List<SA_Accessory__c> saAccs = saAccSelector.selectAccessoriesBySalesAgreementId(salesAgreement.Id);

        System.assertEquals(10, saAccs.size());        
    }

    @isTest
    static void Test_selectOffpeakRecord() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        Accessories_Master__c accMaster = [SELECT Id FROM Accessories_Master__c];
        SaAccsSelector saAccSelector = new SaAccsSelector();
        SA_Accessory__c saAcc = saAccSelector.selectOffpeakRecord(salesAgreement.Id, accMaster.Id);

		System.assertNotEquals(null, saAcc);
    }
}
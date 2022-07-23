@isTest
private class SaAddnlChargeSelectorTest {
	@testSetup
    static void setUp() {
        // Create master data
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');

        Additional_Charges_Master__c addnlChargeMaster1 = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test1',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster1;
        Additional_Charges_Master__c addnlChargeMaster2 = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test2',
                                                                                          ADM_CHRGCD__c = 'R002');
        insert addnlChargeMaster2;
        
        // Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
		insert stockReservation;

        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC');
        insert pckHeader;

        // Create Sales Agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;

        // Create SA Accessory belongs to Package
        SA_Additional_Charge__c saAddnlCharge1 = new SA_Additional_Charge__c(Sales_Agreement__c = salesAgreement.Id,
                                                                             SAD_PACKAGE__c = 'Y',
                                                                             SAD_INCPRICE__c = 'INC',
                                                                             AdditionalChargesMaster__c = addnlChargeMaster1.Id);
		insert saAddnlCharge1;
        SA_Additional_Charge__c saAddnlCharge2 = new SA_Additional_Charge__c(Sales_Agreement__c = salesAgreement.Id,
                                                                             SAD_PACKAGE__c = 'Y',
                                                                             SAD_INCPRICE__c = 'INC',
                                                                             AdditionalChargesMaster__c = addnlChargeMaster2.Id);
		insert saAddnlCharge2;
        SA_Additional_Charge__c saAddnlCharge3 = new SA_Additional_Charge__c(Sales_Agreement__c = salesAgreement.Id,
                                                                             SAD_PACKAGE__c = 'N',
                                                                             AdditionalChargesMaster__c = addnlChargeMaster1.Id);
		insert saAddnlCharge3;
    }

    @isTest
    static void Test_selectbySalesAgreementIdAndChargeCodes() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        SaAddnlChargeSelector saAddnlChargeSelector = new SaAddnlChargeSelector();
        List<SA_Additional_Charge__c> saAddnlCharges = saAddnlChargeSelector.selectbySalesAgreementIdAndChargeCodes(salesAgreement.Id, new List<String>{'R002','R004'});

        System.assertEquals(3, saAddnlCharges.size());
    }

    @isTest
    static void Test_selectAddnlChargeBySalesAgreementIds() {
        Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        SaAddnlChargeSelector saAddnlChargeSelector = new SaAddnlChargeSelector();
        List<SA_Additional_Charge__c> saAddnlCharges = saAddnlChargeSelector.selectAddnlChargeBySalesAgreementIds(new Set<Id>{salesAgreement.Id});

        System.assertEquals(3, saAddnlCharges.size());
    }

    @isTest
    static void Test_selectAdditionalChargeBySalesAgreementId() {
		Sales_Agreement__c salesAgreement = [SELECT Id FROM Sales_Agreement__c];
        SaAddnlChargeSelector saAddnlChargeSelector = new SaAddnlChargeSelector();
        List<SA_Additional_Charge__c> saAddnlCharges = saAddnlChargeSelector.selectAdditionalChargeBySalesAgreementId(salesAgreement.Id);

        System.assertEquals(3, saAddnlCharges.size());
    }
}
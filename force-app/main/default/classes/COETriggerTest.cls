@isTest
private class COETriggerTest {

    @testSetup
    static void setUp() {
        createSalesAgreement('CCK', 'KIAPC', '1234');
    }

	@isTest
    static void Test_afterInsert_Success() {
        COE__c coe = new COE__c(COH_EXPMONTH__c = System.today(), COH_SOH_SONO__c = '1234');
        insert coe;
        
        Sales_Agreement__c salesAgreement = [Select COE__c, COE_Expiry_Date__c From Sales_Agreement__c Where SOH_SONO__c = '1234'];
        System.assertEquals(coe.Id, salesAgreement.COE__c);
        System.assertEquals(System.today(), salesAgreement.COE_Expiry_Date__c);
    }
    
	@isTest
    static void Test_afterInsert_Error() {
        COE__c coe = new COE__c(COH_EXPMONTH__c = System.today(), COH_SOH_SONO__c = '5678');
        
        Boolean exceptionThrownOnInvalidSalesAgreementNo = false;
        try {
            insert coe;
        } catch(Exception e) {
            exceptionThrownOnInvalidSalesAgreementNo = e.getMessage().contains('No Agreement found with Doc No of 5678');
        } finally {
            System.assert(exceptionThrownOnInvalidSalesAgreementNo);
        }
    }  
    
	@isTest
    static void Test_afterUpdate_CoeLinkedToAnotherSalesAgreement() {
        createSalesAgreement('CCA', 'MITCV', '5678');

        COE__c coe = new COE__c(COH_EXPMONTH__c = System.today(), COH_SOH_SONO__c = '1234');
        insert coe;
        
        Sales_Agreement__c newSalesAgreement = [Select COE__c, COE_Expiry_Date__c From Sales_Agreement__c Where SOH_SONO__c = '5678'];
        System.assertNotEquals(coe.Id, newSalesAgreement.COE__c);
        System.assertNotEquals(System.today(), newSalesAgreement.COE_Expiry_Date__c);        
        
        coe.COH_SOH_SONO__c = '5678';
        update coe;
        
        newSalesAgreement = [Select COE__c, COE_Expiry_Date__c From Sales_Agreement__c Where SOH_SONO__c = '5678'];
        System.assertEquals(coe.Id, newSalesAgreement.COE__c);
        System.assertEquals(System.today(), newSalesAgreement.COE_Expiry_Date__c);
    }    
    
	@isTest
    static void Test_afterUpdate_CoeDeleted() {
        COE__c coe = new COE__c(COH_EXPMONTH__c = System.today(), COH_SOH_SONO__c = '1234');
        insert coe;

        coe.COH_SOH_SONO__c = '5678';
        update coe;
        System.assertEquals(0, [Select COUNT() From COE__c]);
    }  
    
    private static void createSalesAgreement(String branchCode, String franchiseCode, String agreementNo) {
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = franchiseCode);
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = franchiseCode, ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = franchiseCode);
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = franchiseCode, Model_Master__c = modelMaster.Id);
        insert modelYearMaster;
        insert new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                ADM_CHRGCD__c = 'R004');      
        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = franchiseCode,
                                                            Model_Master__c = modelMaster.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;

        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.Id, colorMaster.Id, trimMaster.Id, modelYearMaster.Id);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation;

        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.Id, 'test customer');
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;        
	}    
       
}
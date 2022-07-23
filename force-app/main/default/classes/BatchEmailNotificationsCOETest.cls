@isTest
private class BatchEmailNotificationsCOETest {
	@testSetup
    static void setup() {
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';

        // Create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', Model_Master__c = modelMaster.ID);
        insert modelYearMaster;
        
        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelMaster.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;

        // Create stock reservation from master data
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation;

        // Create Sales agreement
        Sales_Agreement__c sa = Test_DataFactory.createSalesAgreement(false, branchCode, 'AK12345', stockReservation.ID, customerName);
        sa.Package_Header__c = pckHeader.Id;
        sa.COE_Expiry_Date__c = Date.today().addDays(30);
        insert sa;

        COE__c coe = new COE__c(COH_EXPMONTH__c = Date.today().addDays(30), COH_SOH_SONO__c = 'AK12345');
		insert coe;
    }

    @isTest
    static void test() {
        List<Sales_Agreement__c> sas = [SELECT ID FROM Sales_Agreement__c];
        system.debug('No Of. Sales Agreement: ' + sas.size());
        Test.startTest();
        BatchEmailNotificationsCOE b = new BatchEmailNotificationsCOE();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();
        // Number of sendEmail() called
        // system.assertEquals(1, BatchEmailNotificationsCOE.emailLimits);
    }
}
@isTest
private class StockReservationCancellingBatchJobTest {
    @testSetup
    static void setup(){
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
        Stock_Reservation__c sr1 = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        sr1.Package_Header_From_PickList__c = pckHeader.Id;
        sr1.Reservation_Status__c = 'Reserve';
        sr1.Cancellation_Reason__c = '';
        sr1.Franchise_Code__c = 'KIAPC';
        sr1.CreatedDate = Date.today()-12;
        insert sr1;

        Stock_Reservation__c sr2 = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        sr2.Package_Header_From_PickList__c = pckHeader.Id;
        sr2.Reservation_Status__c = 'Reserve';
        sr2.Cancellation_Reason__c = '';
        sr2.Franchise_Code__c = 'KIACV';
        sr2.CreatedDate = Date.today()-12;
        insert sr2;

        Stock_Reservation__c sr3 = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        sr3.Package_Header_From_PickList__c = pckHeader.Id;
        sr3.Reservation_Status__c = 'Reserve';
        sr3.Cancellation_Reason__c = '';
        sr3.Franchise_Code__c = 'CITCV';
        sr3.CreatedDate = Date.today()-12;
        insert sr3;


        // Create Sales agreement
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        Sales_Agreement__c sa1 = Test_DataFactory.createSalesAgreement(false, branchCode, 'AK12345', sr3.ID, customerName);
        sa1.Package_Header__c = pckHeader.Id;
        sa1.Stage__c = 'Confirmation of Sale';
        sa1.COE_Expiry_Date__c = Date.today().addDays(30);
        insert sa1;
        
    }

    @isTest
    private static void testBatchJob() {
        List<Stock_Reservation__c> stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Set<Id> parSet = new Set<Id>();
        for(Stock_Reservation__c sr : stockReservation){
            parSet.add(sr.Id);
        }
        StockReservationCancellingBatchJob sJob = new StockReservationCancellingBatchJob(parSet);
        Database.executeBatch(sJob);
    }
}
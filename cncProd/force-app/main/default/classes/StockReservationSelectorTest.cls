@isTest
private class StockReservationSelectorTest {
    @testSetup
    static void setUp() {
         // Create master data
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');

        // Create Stock Reservation
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
		insert stockReservation;
    }
    
    @isTest
    static void testSelectById() {
        Stock_Reservation__c stockRes = [Select Id from Stock_Reservation__c];
        Set<Id> ids = new Set<Id> {stockRes.Id};
        StockReservationSelector stockResSel = new StockReservationSelector();
        List<Stock_Reservation__c> stockResList = stockResSel.selectById(ids);
        System.assertEquals(1, stockResList.size());
    }
    
    @isTest
    static void testSelectStockReservationsAndVehicleMasters() {
        Stock_Reservation__c stockRes = [Select Id from Stock_Reservation__c];
        Set<Id> ids = new Set<Id> {stockRes.Id};
        StockReservationSelector stockResSel = new StockReservationSelector();
        List<Stock_Reservation__c> stockResList = stockResSel.selectStockReservationsAndVehicleMasters(ids);
        System.assertEquals(1, stockResList.size());
    }
}
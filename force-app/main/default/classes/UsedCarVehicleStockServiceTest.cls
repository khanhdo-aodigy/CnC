/** *****
 * Description : Test Class for UsedCarVehicleStockService class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210110             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class UsedCarVehicleStockServiceTest {
	private static String stockNumber = 'VEHDOC0000000000072580';
    
    @testSetup
    private static void setup() {
        Used_Car_Vehicle_Stock__c vehicleStock = Test_DataFactory.createOpenUsedCar(true, stockNumber, 'SG003', 'AUDI', 'SMM2857J');
    }
    
    @isTest
    private static void testGetVehicleStockByStockNumber() {
        Used_Car_Vehicle_Stock__c result = UsedCarVehicleStockService.getVehicleStockByStockNumber(stockNumber);
        System.assertNotEquals(null, result);
    }
    
    @isTest
    private static void testGetVehicleStockMapByStockNumbers() {
        Map<String, Used_Car_Vehicle_Stock__c> result = UsedCarVehicleStockService.getVehicleStockMapByStockNumbers(new Set<String>{stockNumber});
        System.assertNotEquals(null, result);
    }
    
    @isTest
    private static void testIsValidDocNo() {
        Boolean result = UsedCarVehicleStockService.checkIsValidDocNo(stockNumber);
        System.assertEquals(true, result);
    }
    
}
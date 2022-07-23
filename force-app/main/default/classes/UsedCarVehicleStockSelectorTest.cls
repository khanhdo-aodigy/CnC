/** *****
 * Description : Test Class for UsedCarVehicleStockSelector
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210110             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class UsedCarVehicleStockSelectorTest {
	private static String stockNumber = 'VEHDOC0000000000072580';
    
    @testSetup
    private static void setup() {
        Used_Car_Vehicle_Stock__c vehicleStock = Test_DataFactory.createOpenUsedCar(true, stockNumber, 'SG001', 'AUDI', 'SMM2857J');
    }
    
    @isTest
    private static void testGetVehicleStockByStockNumber() {
        UsedCarVehicleStockSelector selector = new UsedCarVehicleStockSelector();
        List<Used_Car_Vehicle_Stock__c> results = selector.getVehicleStockListByStockNumbers(new Set<String>{stockNumber});
        System.assertEquals(1, results.size());
    }
}
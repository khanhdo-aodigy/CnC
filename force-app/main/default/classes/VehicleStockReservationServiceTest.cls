/** *****
 * Description : Test Class for VehicleStockReservationService class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210110             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class VehicleStockReservationServiceTest {
	
    @testSetup
    private static void setup() {
        Account personAcc = Test_DataFactory.createPA(true, 'RA-Testing', 'test@ra.com', 'Prospect');
        Used_Car_Vehicle_Stock__c vehicleStock = Test_DataFactory.createSoldUsedCar(true, personAcc.Id, 'STOCK-001', 'OIYG1', 'AUDI', 'A2');
    	Sales_Opportunity__c salesOpp = Test_DataFactory.createSalesOpp(true, personAcc.Id, 'Open', 'Dummy-SC', 'dummy.sc@ra.com', '65343434');
        
        Datetime apptDatetime = Datetime.now().addDays(7);
        String location = 'Cycle & Carriage Service Centre - Sin Ming,600 Sin Ming Avenue, Singapore 575733';
        Vehicle_Stock_Reservation__c reservation = Test_DataFactory.createReservation(true, personAcc.Id, apptDatetime, location, 1000, salesOpp.Id,  vehicleStock.Id);
    }

    @isTest
    private static void testGetReservationByResevationNo() {
        Vehicle_Stock_Reservation__c reservation = [SELECT Name FROM Vehicle_Stock_Reservation__c LIMIT 1];
        Vehicle_Stock_Reservation__c result = VehicleStockReservationService.getReservationByResevationNo(reservation.Name);
        System.assertNotEquals(null, result);
    }

    @isTest
    private static void testGetReservationById() {
        Vehicle_Stock_Reservation__c reservation = [SELECT Id FROM Vehicle_Stock_Reservation__c LIMIT 1];
        Vehicle_Stock_Reservation__c result = VehicleStockReservationService.getReservationById(reservation.Id);
        System.assertNotEquals(null, result);
    }
    @isTest
    private static void testGetReservationByStockNo() {
        Vehicle_Stock_Reservation__c reservation = [SELECT Used_Car_Vehicle_Stock__r.Stock_Number__c FROM Vehicle_Stock_Reservation__c LIMIT 1];

        List<Vehicle_Stock_Reservation__c> result = VehicleStockReservationService.getReservationByStockNo(new Set<String>{reservation.Used_Car_Vehicle_Stock__r.Stock_Number__c});
        System.assertNotEquals(null, result);
    }
    
}
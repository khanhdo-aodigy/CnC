/** *****
 * Description : Service class for Vehicle Stock Reservation object
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * 20210105             khanh.do@aodigy.com              Created Initial Version
 * 
** *****/
public with sharing class VehicleStockReservationService {

    private static VehicleStockReservationSelector selector = new VehicleStockReservationSelector();

    public static Vehicle_Stock_Reservation__c getReservationByResevationNo(String reservationNo) {
        List<Vehicle_Stock_Reservation__c> resList = getReservationsByNumbers(new Set<String>{reservationNo});
        return resList.isEmpty() ? null : resList.get(0);
    }

    public static List<Vehicle_Stock_Reservation__c> getReservationsByNumbers(Set<String> reservationNumbers) {
        return selector.getReservationsByNumbers(reservationNumbers);
    }

    public static Vehicle_Stock_Reservation__c getReservationById(Id reservationId) {
        List<Vehicle_Stock_Reservation__c> resList = getReservationsByIds(new Set<Id>{reservationId});
        return resList.isEmpty() ? null : resList.get(0);
    }

    public static List<Vehicle_Stock_Reservation__c> getReservationsByIds(Set<Id> reservationIds) {
        return selector.getReservationsByIds(reservationIds);
    }
    
    public static List<Vehicle_Stock_Reservation__c> getReservationByStockNo(Set<String> stockNumbers) {
        return selector.getReservationByStockNo(stockNumbers);
    }
}
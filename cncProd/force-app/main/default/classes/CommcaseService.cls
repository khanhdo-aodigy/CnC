public inherited sharing class CommcaseService {
    
    public static void updateVehicleMaster(Map<Id, String> commcaseNoByStockReservationId) {
		List<Stock_Reservation__c> stockReservations = new StockReservationSelector().selectStockReservationsAndVehicleMasters(
            commcaseNoByStockReservationId.keySet()
        );
        List<Vehicle_Master2__c> stockVehicleMasters = new StockVehicleMasterSelector().selectStockVehicleMastersBySystemCommcases(
            new Set<String>(commcaseNoByStockReservationId.values())
        );
        
        for(Stock_Reservation__c stockReservation : stockReservations) {
            String commcaseNo = commcaseNoByStockReservationId.get(stockReservation.Id);
            for(Vehicle_Master2__c stockVhcMaster : stockVehicleMasters) {
                if(stockVhcMaster.System_Commcase__c == commcaseNo && stockReservation.Vehicle_Master__r.System_Commcase__c != commcaseNo) {
                    stockReservation.Vehicle_Master__c = stockVhcMaster.Id;
                    break;
                }
            } 
        }

        update stockReservations;
    } 
    
}
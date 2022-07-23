public with sharing class WHParkingLotService {
    /**
     * This method to check duplicate Warehouse Parking Lot
     * If any Warehouse Parking Lot already has MB Stock Vehicle Master/Stock Vehicle Master
     * Then no other Stock Vehicle Masters can be assigned to that Warehouse Parking Lot
     */
    public static void checkDuplicateWHParkingLot(Map<String, MB_Stock_Vehicle_Master__c> mbSVMByWHParkingLotIds, Map<String, Vehicle_Master2__c> mfSVMByWHParkingLotIds) {
        List<String> whParkingLotIds = new List<String>();
        if (mbSVMByWHParkingLotIds != null) whParkingLotIds.addAll(mbSVMByWHParkingLotIds.keySet());
        if (mfSVMByWHParkingLotIds != null) whParkingLotIds.addAll(mfSVMByWHParkingLotIds.keySet());
        List<Warehouse_Parking_Lot__c> records = [SELECT Id,
                                                  (SELECT Id FROM MB_Stock_Vehicle_Masters__r),
                                                  (SELECT Id FROM Stock_Vehicle_Masters__r)
                                                  FROM Warehouse_Parking_Lot__c
                                                  WHERE Id IN :whParkingLotIds];

        String errorMsg = 'Another Stock Vehicle Master has been assigned to this Warehouse Parking Lot. Please check again!';
        for (Warehouse_Parking_Lot__c whParkingLot : records) {
            Boolean isErrorRecord = false;
            if (whParkingLot.MB_Stock_Vehicle_Masters__r != null && whParkingLot.MB_Stock_Vehicle_Masters__r.size() > 0) {
                isErrorRecord = true;
            } else if (whParkingLot.Stock_Vehicle_Masters__r != null && whParkingLot.Stock_Vehicle_Masters__r.size() > 0) {
                isErrorRecord = true;
            }
            if (isErrorRecord) {
                if (mbSVMByWHParkingLotIds != null) {
                    MB_Stock_Vehicle_Master__c mbSVM = mbSVMByWHParkingLotIds.get(whParkingLot.Id);
                    mbSVM.addError(errorMsg);
                } else if (mfSVMByWHParkingLotIds != null) {
                    Vehicle_Master2__c svm = mfSVMByWHParkingLotIds.get(whParkingLot.Id);
                    svm.addError(errorMsg);
                }
            }
        }
    }
}
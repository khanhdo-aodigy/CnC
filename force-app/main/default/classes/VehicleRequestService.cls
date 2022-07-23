public without sharing class VehicleRequestService {
    private static VehicleRequestSelector sel = new VehicleRequestSelector();

    public static List<Vehicle_Request__c> getTestDriveById(Id requestId)
    {
        return sel.selectById(requestId);
    }

    public static List<Vehicle_Request__c> getTodayReqsByConditions(Set<Id> vehicleIds, Id ownerId, Id paId, String status, String type, String branchCode, String franchiseCode,
                                                                    String recordType, String moreCondition, String fieldOrdering, Boolean orderingDESC, Boolean limitOne)
    {
        return sel.selectTodayReqsByConditions(vehicleIds, ownerId, paId, status, type, branchCode, franchiseCode, recordType, moreCondition, fieldOrdering, orderingDESC, limitOne);
    }
}
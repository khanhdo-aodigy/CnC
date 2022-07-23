public with sharing class MBVehiclesConversionCtrl {
    static final string MB_TEST_DRIVE_RECORD_TYPE_ID = Schema.SObjectType.Courtesy_Vehicle__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive').getRecordTypeId();

    private ApexPages.StandardSetController standardController;

    public Boolean isDone { get; set; }

    public MBVehiclesConversionCtrl(ApexPages.StandardSetController standardController) {
        isDone = false;
        this.standardController = standardController;
    }

    public PageReference convertVehicles() {
        List<MB_Stock_Vehicle_Master__c> mbSVMs = (List<MB_Stock_Vehicle_Master__c>) standardController.getSelected();
        List<String> mbSVMIds = new List<String>();
        for (MB_Stock_Vehicle_Master__c mbSVM : mbSVMs) {
            mbSVMIds.add(mbSVM.Id);
        }

        Set<String> commNoforAvailableCourtesyVehicles = new Set<String>();
        for (Courtesy_Vehicle__c vehicle : [SELECT Id, Comm_No__c
                                            FROM Courtesy_Vehicle__c
                                            WHERE Status__c     = 'Available'
                                              AND RecordTypeId  = :MB_TEST_DRIVE_RECORD_TYPE_ID]) {
            if (String.isNotBlank(vehicle.Comm_No__c)) {
                commNoforAvailableCourtesyVehicles.add(vehicle.Comm_No__c);
            }
        }

        List<Courtesy_Vehicle__c> courtesyVehicles = new List<Courtesy_Vehicle__c>();
        for (MB_Stock_Vehicle_Master__c mbSVM : [SELECT Model__c, Variant__r.Model_ID__c, Variant__c, Colour__c, Trim__c, Comm__c, Autoline_Sales_Order__c, VariantDescription__c, Status__c
                                                 FROM MB_Stock_Vehicle_Master__c
                                                 WHERE Id IN :mbSVMIds]) {
            if (commNoforAvailableCourtesyVehicles.contains(mbSVM.Comm__c)) continue;

            mbSVM.Status__c = 'Test Drive';
            courtesyVehicles.add(new Courtesy_Vehicle__c(Name = mbSVM.VariantDescription__c,
                                                         Model__c = mbSVM.Variant__r.Model_ID__c,
                                                         Variant__c = mbSVM.Variant__c,
                                                         Colour__c = mbSVM.Colour__c,
                                                         Trim__c = mbSVM.Trim__c,
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                         Comm_No__c = mbSVM.Comm__c,
                                                         Autoline_Sales_Order__c = mbSVM.Autoline_Sales_Order__c,
                                                         Status__c = 'Available',
                                                         RecordTypeId = MB_TEST_DRIVE_RECORD_TYPE_ID));
        }
        try {
            insert courtesyVehicles;
            update mbSVMs;
            isDone = true;
        } catch (Exception e) {
            loggerDataPool.buildLogDataPool('MB_Test_Drive_Vehicles_Conversion', e);
        }

        return null;
    }
}
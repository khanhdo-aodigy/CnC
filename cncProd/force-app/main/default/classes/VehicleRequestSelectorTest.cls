@isTest
private class VehicleRequestSelectorTest {
    @isTest
    static void test_selectById()
    {
		Model__c model = Test_DataFactory.createmodelId(true, 'MB G-Class PC', 'CCI', 'MBP');
        Variant__c variant = Test_DataFactory.createVariant(true, 'MB G 63 AMG Station Wagon Long', model.Id, 'CCI');
        Courtesy_Vehicle__c veh = Test_DataFactory.createCourtesyVehicle(true, 'MB_Test_Drive', 'Available', 'CCI', 'MBP', model.Id, variant.Id);
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req = new Vehicle_Request__c(Courtesy_Vehicle__c = veh.Id,
                                                         Status__c = 'Queued',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req;
        VehicleRequestSelector sel = new VehicleRequestSelector();
        System.assertEquals(1, sel.selectById(req.Id).size());
    }

    @isTest
    static void test_selectTodayReqsByConditions()
    {
		Model__c model = Test_DataFactory.createmodelId(true, 'MB G-Class PC', 'CCI', 'MBP');
        Variant__c variant = Test_DataFactory.createVariant(true, 'MB G 63 AMG Station Wagon Long', model.Id, 'CCI');
        Courtesy_Vehicle__c veh = Test_DataFactory.createCourtesyVehicle(true, 'MB_Test_Drive', 'Available', 'CCI', 'MBP', model.Id, variant.Id);
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req = new Vehicle_Request__c(Courtesy_Vehicle__c = veh.Id,
                                                         Status__c = 'Queued',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req;
        VehicleRequestSelector sel = new VehicleRequestSelector();
        System.assertEquals(1, sel.selectTodayReqsByConditions(new Set<Id>{veh.Id}, null, acc.Id, 'Queued', null, 'CCI', 'MBP', 'MB Test Drive Request', null, 'CreatedDate', false, false).size());
    }
}
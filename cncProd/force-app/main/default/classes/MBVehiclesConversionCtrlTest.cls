@isTest
private class MBVehiclesConversionCtrlTest {
    @isTest
    static void test() {
		Model__c model = Test_DataFactory.createmodelId(true, 'MB G-Class PC', 'CCI', 'MBP');
        Variant__c variant = Test_DataFactory.createVariant(true, 'MB G 63 AMG Station Wagon Long', model.Id, 'CCI');
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black',
                                                                         Estimated_Delivery_Date__c = '01/02',
                                                                         VariantDescription__c = 'MB A 250 Test');
		insert mbSVM;
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
		List<MB_Stock_Vehicle_Master__c> mbSVMs = [SELECT ID FROM MB_Stock_Vehicle_Master__c];
        Test.startTest();
		Test.setCurrentPage(Page.MBVehiclesConversionPage);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(mbSVMs);
		stdSetController.setSelected(mbSVMs);
        MBVehiclesConversionCtrl ctrl = new MBVehiclesConversionCtrl(stdSetController);
		PageReference ref = ctrl.convertVehicles();
		Test.stopTest();
    }
}
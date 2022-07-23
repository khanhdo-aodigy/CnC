@isTest
private class MB_TestDrivePDFCtrlTest {
	@isTest
    static void test() {
        Model__c model = Test_DataFactory.createmodelId(true, 'MB G-Class PC', 'CCI', 'MBP');
        Variant__c variant = Test_DataFactory.createVariant(true, 'MB G 63 AMG Station Wagon Long', model.Id, 'CCI');
        Courtesy_Vehicle__c veh = Test_DataFactory.createCourtesyVehicle(true, 'MB_Test_Drive', 'Available', 'CCI', 'MBP', model.Id, variant.Id);
		Account acc = Test_DataFactory.createPA(false, 'Test', 'email_test@mail.com', 'Prospect');
        acc.Address_Line_1__pc = 'Test';
        acc.Address_Line_2__pc = 'Test2';
        acc.Address_Line_3__pc = 'Test3';
        acc.Address_Line_4__pc = 'Test4';
        acc.Unit_No_Floor__pc = 'Test5';
        acc.Country__pc = 'Vietnam';
        insert acc;
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
        Test.startTest();
        PageReference page = Page.MB_TestDrivePDF;
        page.getParameters().put('id', req.Id);
        Test.setCurrentPage(page);
        MB_TestDrivePDFCtrl myController = new MB_TestDrivePDFCtrl();
        Test.stopTest();
    }
}
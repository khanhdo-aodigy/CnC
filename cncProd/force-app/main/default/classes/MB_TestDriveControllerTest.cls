/** *****
 * Description : Test Class for MB_TestDriveController
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211101           TPhan@aodigy        Created Initial Version. 
 * ** *****/

@isTest
private class MB_TestDriveControllerTest 
{
    @testSetup
    static void setUp() {
		Model__c model = Test_DataFactory.createmodelId(true, 'MB G-Class PC', 'CCI', 'MBP');
        Variant__c variant = Test_DataFactory.createVariant(true, 'MB G 63 AMG Station Wagon Long', model.Id, 'CCI');
		Model__c model1 = Test_DataFactory.createmodelId(true, 'MB A-Class PC', 'CCI', 'MBP');
        Variant__c variant1 = Test_DataFactory.createVariant(true, 'MB A 250 AMG', model1.Id, 'CCI');
        List<Courtesy_Vehicle__c> vehList = new List<Courtesy_Vehicle__c>();
        Courtesy_Vehicle__c veh = Test_DataFactory.createCourtesyVehicle(false, 'MB_Test_Drive', 'Available', 'CCI', 'MBP', model.Id, variant.Id);
        Courtesy_Vehicle__c veh1 = Test_DataFactory.createCourtesyVehicle(false, 'MB_Test_Drive', 'Available', 'CCI', 'MBP', model1.Id, variant.Id);
        vehList.add(veh);
		vehList.add(veh1);
        insert vehList;
    }

    @isTest
    static void test_RetrieveCourtesyVehiclesForMBTestDrive()
    { 
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];
        MB_Test_Drive_Daily_Log__c log = Test_DataFactory.createMBTestDriveDailyLog(true, 1000, null, 'Opened', vehList[0].Id);
        MB_TestDriveController.retrieveCourtesyVehiclesForMBTestDrive();
    }

    @isTest
    static void test_CreateVehicleRequest_WithNewPA()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];

        Map<String, String> info = new Map<String, String>();
        info.put('Courtesy_Vehicle__c', vehList[0].Id);
        info.put('Test_Drive_Type__c', 'Test Drive');
        info.put('Trade_Plate__c', null);
        info.put('PersonMobilePhone', '6589563257');
        info.put('PersonEmail', 'vupa984594@test.com');
        info.put('Full_Name__pc', 'Thieu Dang Vu');
        info.put('FirstName', 'Vu');
        info.put('LastName', 'Thieu');
        info.put('Status__c', 'Ongoing');
        info.put('Address_Line_1__pc', '#3-40');
        info.put('Address_Line_2__pc', 'abc bulding');
        info.put('Address_Line_3__pc', '123 Secret St');
        info.put('Customer_Signature__c', '');

        Map<String, String> frontLicense = new Map<String, String>();
        frontLicense.put('body', 'abc');
        frontLicense.put('contentType', 'image/jpeg');
        frontLicense.put('fileName', 'Front_License.jpeg');

        Map<String, String> backLicense = new Map<String, String>();
        backLicense.put('body', 'def');
        backLicense.put('contentType', 'image/jpeg');
        backLicense.put('fileName', 'Back_License.jpeg');

        TriggerExclusion.excludeTrigger('Vehicle_Request__c', true);
        MB_TestDriveController.createVehicleRequest(info, frontLicense, backLicense);
        TriggerExclusion.excludeTrigger('Vehicle_Request__c', false);
    }

	@isTest
    static void test_CreateLoanVehicleRequest_WithNewPA()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];

        Map<String, String> info = new Map<String, String>();
        info.put('Courtesy_Vehicle__c', vehList[0].Id);
        info.put('Test_Drive_Type__c', 'Loan');
        info.put('Trade_Plate__c', null);
        info.put('PersonMobilePhone', '6589563257');
        info.put('PersonEmail', 'vupa984594@test.com');
        info.put('Full_Name__pc', 'Thieu Dang Vu');
        info.put('FirstName', 'Vu');
        info.put('LastName', 'Thieu');
        info.put('Status__c', 'Ongoing');
        info.put('Address_Line_1__pc', '#3-40');
        info.put('Address_Line_2__pc', 'abc bulding');
        info.put('Address_Line_3__pc', '123 Secret St');
        info.put('Customer_Signature__c', '');

        Map<String, String> frontLicense = new Map<String, String>();
        frontLicense.put('body', 'abc');
        frontLicense.put('contentType', 'image/jpeg');
        frontLicense.put('fileName', 'Front_License.jpeg');

        Map<String, String> backLicense = new Map<String, String>();
        backLicense.put('body', 'def');
        backLicense.put('contentType', 'image/jpeg');
        backLicense.put('fileName', 'Back_License.jpeg');

        TriggerExclusion.excludeTrigger('Vehicle_Request__c', true);
        MB_TestDriveController.createVehicleRequest(info, frontLicense, backLicense);
		vehList = [SELECT ID, Status__c FROM Courtesy_Vehicle__c];
        System.assertEquals('On Loan (Test Drive)', vehList[0].Status__c);
        TriggerExclusion.excludeTrigger('Vehicle_Request__c', false);
    }

    @isTest
    static void test_CreateVehicleRequest_WithExistingPA()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];

        Account pA = Test_DataFactory.createPA(true, 'Thieu', 'vupa123@test.com', 'Customer');

        Map<String, String> info = new Map<String, String>();
        info.put('Courtesy_Vehicle__c', vehList[0].Id);
        info.put('Test_Drive_Type__c', 'Test Drive');
        info.put('Trade_Plate__c', null);
        info.put('PersonMobilePhone', '6589563258');
        info.put('PersonEmail', 'vupa123@test.com');
        info.put('Full_Name__pc', 'Thieu Dang Vu');
        info.put('FirstName', 'Vu');
        info.put('LastName', 'Thieu');
        info.put('Status__c', 'Ongoing');
        info.put('Address_Line_1__pc', '#3-40');
        info.put('Address_Line_2__pc', 'abc bulding');
        info.put('Address_Line_3__pc', '123 Secret St');
        info.put('Customer_Signature__c', '');
        info.put('__matchPA', pA.Id);

        Map<String, String> frontLicense = new Map<String, String>();
        frontLicense.put('body', 'abc');
        frontLicense.put('contentType', 'image/jpeg');
        frontLicense.put('fileName', 'Front_License.jpeg');

        Map<String, String> backLicense = new Map<String, String>();
        backLicense.put('body', 'def');
        backLicense.put('contentType', 'image/jpeg');
        backLicense.put('fileName', 'Back_License.jpeg');

        MB_TestDriveController.createVehicleRequest(info, frontLicense, backLicense);
    }

    @isTest
    static void test_UpsertMBTDDailyLogs()
    {
        List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];
        MB_TestDriveController.upsertMBTDDailyLogs(new List<MB_Test_Drive_Daily_Log__c>{new MB_Test_Drive_Daily_Log__c(Status__c = 'Opened', Opening_Mileage__c = 1000, Courtesy_Vehicle__c = vehList[0].Id)});
    }

    @isTest
    static void test_constructTestDriveWrapper()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];

        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req1 = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Queued',
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP');
        insert req1;
        Vehicle_Request__c req2 = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Ongoing',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP');
        insert req2;
        MB_TestDriveController.constructTestDriveWrapper();
    }

    @isTest
    static void test_getTradePlates()
    {
        insert new Trade_Plate__c(Name = 'TESTPL',
                                 Active__c = true,
                                 Branch_Code__c = 'CCI');
        MB_TestDriveController.getTradePlates();
    }

    @isTest
    static void test_checkDailyLogExist()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];
        
        MB_Test_Drive_Daily_Log__c log = Test_DataFactory.createMBTestDriveDailyLog(true, 1000, null, 'Opened', vehList[0].Id);
		Boolean exist = MB_TestDriveController.checkDailyLogExist(vehList[0].Id);
        System.assertEquals(true, exist);
    }

    @isTest
    static void test_getProfile()
    {
        String profileNm = MB_TestDriveController.getProfile();
        System.assertEquals('System Administrator', profileNm);
    }

	@isTest
    static void test_searchPersonAccount()
    {
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
		List<Account> accs = MB_TestDriveController.searchPersonAccount(null, 'email_test@mail.com', null);
        System.assertEquals(1, accs.size());
    }

    @isTest
    static void test_generateIndemnityForm()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];		
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Ongoing',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP');
        insert req;
        MB_TestDriveController.generateIndemnityForm(req.Id);
    }

    @isTest
    static void test_getHistoryRequest()
    {
        List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];		
        
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Completed',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req;
        Test.startTest();
        List<Vehicle_Request__c> historyReqs = MB_TestDriveController.getHistoryRequest(vehList[0].Id, acc.Id);
        Test.stopTest();
        System.assertEquals(1, historyReqs.size());
    }

    @isTest
    static void test_processRequest_Check_Out()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Queued',
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req;
        Test.startTest();
        MB_TestDriveController.processVehicleRequest('Check Out', req.Id);
        Test.stopTest();
    }

    @isTest
    static void test_processRequest_Check_In()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Ongoing',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req;
        Test.startTest();
        MB_TestDriveController.processVehicleRequest('Check In', req.Id);
        Test.stopTest();
    }

    @isTest
    static void test_processRequest_Cancel()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Queued',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req;
        Test.startTest();
        MB_TestDriveController.processVehicleRequest('Cancel', req.Id);
        Test.stopTest();
    }

    @isTest
    static void test_processRequest_Check_Out_Have_Ongoing_Req()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];        
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req1 = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Ongoing',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req1;
        Vehicle_Request__c req2 = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Queued',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req2;
        Test.startTest();
        try {
			MB_TestDriveController.processVehicleRequest('Check Out', req2.Id);
        } catch (Exception e) {
            System.assert(true, e.getMessage().contains('being checked-out'));
        }
        Test.stopTest();
    }

    @isTest
    static void test_processRequest_Check_Out_Not_In_Turn()
    {
		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req1 = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Queued',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req1;
        Vehicle_Request__c req2 = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Queued',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id);
        insert req2;
        Test.startTest();
        try {
			MB_TestDriveController.processVehicleRequest('Check Out', req2.Id);
        } catch (Exception e) {
            System.assert(true, e.getMessage().contains('your turn to check-out!'));
        }
        Test.stopTest();
    }

    @isTest
    static void test_processRequest_Booking_TP_In_Used()
    {
        Trade_Plate__c tp =  new Trade_Plate__c(Name = 'TESTPL',
                                 				Active__c = true,
                                                Branch_Code__c = 'CCI');
        insert tp;

		List<Courtesy_Vehicle__c> vehList = [SELECT ID FROM Courtesy_Vehicle__c];        
		Account acc = Test_DataFactory.createPA(true, 'Test', 'email_test@mail.com', 'Prospect');
        String recordTypeId  = Schema.SObjectType.Vehicle_Request__c.getRecordTypeInfosByDeveloperName().get('MB_Test_Drive_Request').getRecordTypeId();
        Vehicle_Request__c req1 = new Vehicle_Request__c(Courtesy_Vehicle__c = vehList[0].Id,
                                                         Status__c = 'Ongoing',
                                                         Check_Out__c = DateTime.now(),
                                                         RecordTypeId = recordTypeId,
                                                         Test_Drive_Type__c = 'Test Drive',
                                                         Branch_Code__c = 'CCI',
                                                         Franchise_Code__c = 'MBP',
                                                       	 Account__c = acc.Id,
                                                         Trade_Plate__c = tp.Id);
        insert req1;
        Map<String, String> info = new Map<String, String>();
        info.put('Courtesy_Vehicle__c', vehList[1].Id);
        info.put('Test_Drive_Type__c', 'Loan');
        info.put('Trade_Plate__c', tp.Id);
        info.put('PersonMobilePhone', '6589563257');
        info.put('PersonEmail', 'vupa984594@test.com');
        info.put('Full_Name__pc', 'Thieu Dang Vu');
        info.put('FirstName', 'Vu');
        info.put('LastName', 'Thieu');
        info.put('Status__c', 'Ongoing');
        info.put('Address_Line_1__pc', '#3-40');
        info.put('Address_Line_2__pc', 'abc bulding');
        info.put('Address_Line_3__pc', '123 Secret St');
        info.put('Customer_Signature__c', '');

        TriggerExclusion.excludeTrigger('Vehicle_Request__c', true);
        try {
			MB_TestDriveController.createVehicleRequest(info, null, null);
        } catch (Exception e) {
            System.assert(true, e.getMessage().contains('Trade Plate has been used'));
        }
        TriggerExclusion.excludeTrigger('Vehicle_Request__c', false);
    }
}
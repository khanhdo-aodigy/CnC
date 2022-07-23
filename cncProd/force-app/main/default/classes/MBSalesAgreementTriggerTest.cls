@isTest
private with sharing class MBSalesAgreementTriggerTest {
    @testSetup
    static void setUp() {
        Delivery_Bay_Configuration__c dbConfig = new Delivery_Bay_Configuration__c();
        dbConfig.Name= 'Delivery Bay Booking Config';
        dbConfig.Email_Template_Cancel_Delivery__c = 'Cancel Booking Slot';
        dbConfig.Email_Template_Delivery_Bay_Booking__c = 'After Booking Slot';
        dbConfig.Email_Template_Ready_for_Delivery__c = 'Ready For Delivery';
        dbConfig.Location_Delivery_Complete__c = 'Test Location';
        dbConfig.Location_QC_Complete__c = 'Test Location';
        insert dbConfig;
        
        // Create Model
        Model__c model = Test_DataFactory.createmodelId(true, 'MB A Class Test', 'CCI', 'MBP');

        // Create Variant
        Variant__c variant = new Variant__c(Name = 'MB A 250 Test',
                                           Model_ID__c = model.Id,
                                           Franchise__c = 'MBP',
                                           Branch__c = 'CCI',
                                           Allow_Indent__c = false,
                                           Description__c = 'MB A 250 Test',
                                           Active__c = true,
                                           Engine_Capacity__c = '1600',
                                           BHP__c = '130');
        insert variant;
        system.debug('variant ::' + variant);

        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;

        // Create Indent Variant 
        Variant__c variant1 = new Variant__c(Name = 'MB A 200 Indent',
                                                  Model_ID__c = model.Id,
                                                  Franchise__c = 'MBP',
                                                  Branch__c = 'CCI',
                                                  Allow_Indent__c = true,
                                                  Description__c = 'MB A 200 Indent',
                                                  Engine_Capacity__c = '1700',
                                                  BHP__c = '150');
        insert variant1;

        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM2 = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '2',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant1.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM2;

        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;

        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA1 = new MB_Sales_Agreement__c();
        mbSA1.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA1.Customer_Full_Name__c = 'X1111Test';
        mbSA1.CNRIC_Number__c = 'SXXXX1111';
        mbSA1.Submit_COE_Bidding__c = true;
        mbSA1.Account__c = personAcc.Id;
        insert mbSA1;
        system.debug('mbSA1 ::' + mbSA1.MB_Stock_Vehicle_Master__r.Status__c);

        //Create COE
        // COE__c coe = new COE__c(COH_EXPMONTH__c = System.today(), COH_COENO__c = '2021060103000897W', COH_DEPOSIT__c = 23456, COH_COECATEGORY__c = 'B');
        // insert coe;
    }

 	/*  	@isTest
    static void Test_afterUpdate_COE_Success() {
        COE__c coe = [SELECT Id, Sales_Agreement__c, MB_Sales_Agreement__c, Sales_Agreement_Unique_Id__c FROM COE__c WHERE COH_COENO__c = '2021060103000897W'];
        MB_Sales_Agreement__c mbSA = [SELECT Id, COE__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];
        mbSA.COE__c = coe.Id;
        update mbSA;

        coe = [SELECT Id, Sales_Agreement__c, MB_Sales_Agreement__c, Sales_Agreement_Unique_Id__c FROM COE__c WHERE COH_COENO__c = '2021060103000897W'];
        mbSA = [SELECT Id, COE__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];
		system.debug('updated mbsa ' + mbSA);
        system.debug('updated coe ' + coe);
        system.assertEquals(coe.MB_Sales_Agreement__c, mbSA.Id);
        system.assertEquals(mbSA.COE__c, coe.Id);
    } */
    
    @isTest
    static void Test_AfterUpdate_updateDeliveryBayBooking() {
                
        MB_Sales_Agreement__c mbSA = [SELECT Id, COE__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];
        Delivery_Bay_Booking__c dbb = new Delivery_Bay_Booking__c(MB_Sales_Agreement__c = mbSA.id);
        insert dbb;
        Test.startTest();
        dbb.Status__c ='Booked';
        update dbb;
        mbSA.Status__c = 'Car Collected';
        update mbSA;
        Test.stopTest();
        Delivery_Bay_Booking__c dbb_result = [Select Id, Status__c, Sales_Agreement__c from Delivery_Bay_Booking__c Where MB_Sales_Agreement__c =: mbSA.Id LIMIT 1];
        System.assertEquals('Completed', dbb_result.Status__c);
    }
    
    @isTest
    static void Test_AfterUpdate_sendEmailForBookingDeliveryBaySlot() {
        MB_Sales_Agreement__c mbSA = [SELECT Id, COE__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];
        Test.startTest();
        mbSA.Vehicle_Movement_Completed__c = true;
        mbSA.Status__c = 'Ready for Delivery';
        update mbSA;
        Test.stopTest();
    }
    
    @isTest
    static void Test_AfterUpdate_createVehicleMovementTracker() {
        Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        automationSetting.Bypass_Flows__c            = true;
        automationSetting.Bypass_Processes__c        = true;
        automationSetting.Bypass_Workflows__c        = true;
        insert automationSetting;
        MB_Sales_Agreement__c mbSA = [SELECT Id, COE__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];

        // Create Location
        Id recordTypeIdLocation = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get('Vehicle Movement').getRecordTypeId();
        Location__c location = new Location__c(Name = 'Test Location',
                                               Email_Subject__c = '{!Name} Test Subject',
                                               Email_Body__c = '{!Name} Test Body',
                                               Email_Communication_Vehicle_Movement__c = true,
                                               RecordTypeId = recordTypeIdLocation);
        insert location;
        Test.startTest();
        mbSA.Status__c = 'Car Collected';
        update mbSA;
        Test.stopTest();
        List<Vehicle_Movement_Tracker__c> newRecords = [Select Id from Vehicle_Movement_Tracker__c];
        System.assertEquals(1, newRecords.size());
    }
    
    @isTest
    static void Test_AfterUpdate_ConvertPA() {
        MB_Sales_Agreement__c mbSA = [SELECT Id, Account__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];
        Test.startTest();
        mbSA.Status__c = 'Allocated';
        update mbSA;
        Test.stopTest();
        Account pa = [SELECT ID, RecordType.Name FROM Account WHERE Id = :mbSA.Account__c];
        System.assertEquals('Customer', pa.RecordType.Name);
    }

    @isTest
    static void Test_AfterUpdate_processCancelledSA() {
        MB_Sales_Agreement__c mbSA = [SELECT Id, Account__c, MB_Stock_Vehicle_Master__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];
        TriggerExclusion.excludeTrigger('MB_Stock_Vehicle_Master__c', true);
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT Id, Status__c FROM MB_Stock_Vehicle_Master__c WHERE Id = :mbSA.MB_Stock_Vehicle_Master__c];
        mbSVM.Status__c = 'Reserved';
        update mbSVM;
        Test.startTest();
        mbSA.Deposit_Collected__c = true;
        update mbSA;
        mbSA.Status__c = 'Cancelled';
        update mbSA;
        Test.stopTest();
        mbSVM = [SELECT Id, Status__c FROM MB_Stock_Vehicle_Master__c WHERE Id = :mbSA.MB_Stock_Vehicle_Master__c];
		System.assertEquals('Open', mbSVM.Status__c);
    }

    @isTest
    static void Test_AfterUpdate_deleteSensitiveDocs() {
        MB_Sales_Agreement__c mbSA = [SELECT Id, Account__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];
        Test_DataFactory.createFileAttachment(mbSA.Id);
        Test.startTest();
        mbSA.Status__c = 'Car Collected';
        update mbSA;
        Test.stopTest();
        System.assertEquals(1, [Select COUNT() From ContentDocument]);
    }

    @isTest
    static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('MB_Sales_Agreement__c', true);
        MB_Sales_Agreement__c mbSA = [SELECT Id, Account__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];
		mbSA.Status__c = 'Car Collected';
        update mbSA;
        TriggerExclusion.excludeTrigger('MB_Sales_Agreement__c', false);
    }
}
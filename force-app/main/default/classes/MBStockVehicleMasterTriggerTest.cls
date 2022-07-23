@isTest
private class MBStockVehicleMasterTriggerTest {
    @testSetup()
    static void setUp() {
        // Create Model
        List<Model__c> models = new List<Model__c>();
        for (Integer i = 0; i < 2; i++) {
            Model__c model = Test_DataFactory.createmodelId(false, 'MB A Class Test' + i, 'CCI', 'MBP');
            models.add(model);
        }
		insert models;
        // Create Variant
        Variant__c variant = new Variant__c(Name = 'MB A 250 Test',
                                           Model_ID__c = models[0].Id,
                                           Franchise__c = 'MBP',
                                           Branch__c = 'CCI',
                                           Allow_Indent__c = false,
                                           Description__c = 'MB A 250 Test',
                                           Active__c = true);
        insert variant;
        // Create Variant
        Variant__c variant2 = new Variant__c(Name = 'MB B 250 Test',
                                           Model_ID__c = models[1].Id,
                                           Franchise__c = 'MBP',
                                           Branch__c = 'CCI',
                                           Allow_Indent__c = false,
                                           Description__c = 'MB B 250 Test',
                                           Active__c = true);
        insert variant2;
        // Create Warehouse Parking Lot
        Warehouse_Parking_Lot__c whParkingLot = new Warehouse_Parking_Lot__c(Name = 'Test WHPL A',
                                                                            Status__c = 'Active');
        insert whParkingLot;

        Delivery_Bay_Configuration__c dbConfig = new Delivery_Bay_Configuration__c();
        dbConfig.Name= 'Delivery Bay Booking Config';
        dbConfig.Email_Template_Cancel_Delivery__c = 'Cancel Booking Slot';
        dbConfig.Email_Template_Delivery_Bay_Booking__c = 'After Booking Slot';
        dbConfig.Email_Template_Ready_for_Delivery__c = 'Ready For Delivery';
        dbConfig.Location_Delivery_Complete__c = 'NCC-OUT';
        dbConfig.Location_QC_Complete__c = 'NCC-QCOK';
        insert dbConfig;
        
    }

	@isTest
    static void Test_beforeInsert() {
        List<Variant__c> variants = [SELECT ID FROM Variant__c];
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variants[0].Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;
    }

    @isTest
    static void Test_beforeUpdate_duplicateWHPL() {
        List<Variant__c> variants = [SELECT ID FROM Variant__c];
        Warehouse_Parking_Lot__c whParkingLot = [SELECT ID FROM Warehouse_Parking_Lot__c LIMIT 1];
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variants[0].Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;
        MB_Stock_Vehicle_Master__c mbSVM2 = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '2',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variants[1].Id,
                                                                         Colour__c = '333 Mountain Grey',
                                                                         Trim__C = '444 ARTICO Black');
        insert mbSVM2;
        mbSVM.Warehouse_Parking_Lot__c = whParkingLot.Id;
        mbSVM2.Warehouse_Parking_Lot__c = whParkingLot.Id;
        try {
            update mbSVM;
        	update mbSVM2;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Another Stock Vehicle Master has been assigned') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
   	}

    @isTest
    static void Test_beforeUpdate_Update_Duty_Payment_Date() {
        List<Variant__c> variants = [SELECT ID FROM Variant__c];
        Warehouse_Parking_Lot__c whParkingLot = [SELECT ID FROM Warehouse_Parking_Lot__c LIMIT 1];
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variants[0].Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black',
                                                                         Warehouse_Parking_Lot__c = whParkingLot.Id);
        insert mbSVM;
        mbSVM.Duty_Payment_Date__c = Date.today();
        update mbSVM;
        mbSVM = [SELECT ID, Warehouse_Parking_Lot__c FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        System.assertEquals(null, mbSVM.Warehouse_Parking_Lot__c);
   	}

    @isTest
    static void Test_afterUpdate_populateVehicleMovement() {

    List<Variant__c> variants = [SELECT ID FROM Variant__c];
    Warehouse_Parking_Lot__c whParkingLot = [SELECT ID FROM Warehouse_Parking_Lot__c LIMIT 1];
    // Create MB Stock Vehicle Master
    MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                        Status__c = 'Open',
                                                                        Variant__c = variants[0].Id,
                                                                        Colour__c = '787 Mountain Grey',
                                                                        Trim__C = '101 ARTICO Black',
                                                                        Warehouse_Parking_Lot__c = whParkingLot.Id);
    insert mbSVM;
    
    // Create Account (Person Account)
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
    
    Test.startTest();
    mbSVM.Vehicle_Movement_Location__c = 'NCC-QCOK';
    update mbSVM;
    Test.stopTest();

    MB_Sales_Agreement__c resultMBSA = [SELECT Id, Vehicle_Movement_Completed__c
                                            FROM MB_Sales_Agreement__C
                                            LIMIT 1];

    System.assertEquals(true, resultMBSA.Vehicle_Movement_Completed__c);
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('MB_Stock_Vehicle_Master__c', true);
        List<Variant__c> variants = [SELECT ID FROM Variant__c];
        Warehouse_Parking_Lot__c whParkingLot = [SELECT ID FROM Warehouse_Parking_Lot__c LIMIT 1];
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variants[0].Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black',
                                                                         Warehouse_Parking_Lot__c = whParkingLot.Id);
        insert mbSVM;
        TriggerExclusion.excludeTrigger('MB_Stock_Vehicle_Master__c', false);
    }
}
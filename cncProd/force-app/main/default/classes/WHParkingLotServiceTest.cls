@isTest
private class WHParkingLotServiceTest {
	@testSetup
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
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black',
                                                                         Warehouse_Parking_Lot__c = whParkingLot.Id);
        insert mbSVM;
        MB_Stock_Vehicle_Master__c mbSVM2 = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '2',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant2.Id,
                                                                         Colour__c = '333 Mountain Grey',
                                                                         Trim__C = '444 ARTICO Black',
                                                                         Warehouse_Parking_Lot__c = whParkingLot.Id);
        insert mbSVM2;

        // Create Model
        List<Model_Master__c> modelCodes = new List<Model_Master__c>();
        for (Integer i = 0; i < 2; i++) {
        	Model_Master__c modelCode = Test_DataFactory.createModelCode(false, 'Test Model Code ' + i);
            modelCodes.add(modelCode);
        }
		insert modelCodes;
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCodes[0].Id);
        Model_Year_Master__c modelYearCode2 = Test_DataFactory.createModelYearCode(true, modelCodes[1].Id);

        // Create Color
        List<Color_Master__c> colorCodes = new List<Color_Master__c>();
        for (Integer i = 0; i < 2; i++) {
        	Color_Master__c colorCode = Test_DataFactory.createColorCode(false, 'Test Color Code' + i, 'Test', 'CCK', 'KIAPC');
            colorCodes.add(colorCode);
        }
		insert colorCodes;

        List<Trim_Master__c> trimCodes = new List<Trim_Master__c>();
        for (Integer i = 0; i < 2; i++) {
        	Trim_Master__c trimCode = Test_DataFactory.createTrimCode(false, 'Test Trim Code' + i);
            trimCodes.add(trimCode);
        }
		insert trimCodes;

        Date productionMonth = Date.today();
		Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCodes[0].ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCodes[0].ID, 
                                                            Trim_Code__c = trimCodes[0].ID,
                                                            Warehouse_Parking_Lot__c = whParkingLot.Id);
        insert vMaster;

        Vehicle_Master2__c vMaster2 = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode2.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCodes[1].ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCodes[1].ID, 
                                                            Trim_Code__c = trimCodes[1].ID,
                                                            Warehouse_Parking_Lot__c = whParkingLot.Id);
        insert vMaster2;
    }

    @isTest
    static void Test_MBSVM_DuplicateWHPL() {
        Map<String, MB_Stock_Vehicle_Master__c> mbSVMByWHParkingLotIds = new Map<String, MB_Stock_Vehicle_Master__c>();
        for (MB_Stock_Vehicle_Master__c mbSVM : [SELECT Id, Warehouse_Parking_Lot__c FROM MB_Stock_Vehicle_Master__c]) {
            mbSVMByWHParkingLotIds.put(mbSVM.Warehouse_Parking_Lot__c, mbSVM);
        }
        try {
            WHParkingLotService.checkDuplicateWHParkingLot(mbSVMByWHParkingLotIds, null);
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Another Stock Vehicle Master has been assigned') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }

    @isTest
    static void Test_MFSVM_DuplicateWHPL() {
        Map<String, Vehicle_Master2__c> mfSVMByWHParkingLotIds = new Map<String, Vehicle_Master2__c>();
        for (Vehicle_Master2__c svm : [SELECT Id, Warehouse_Parking_Lot__c FROM Vehicle_Master2__c]) {
            mfSVMByWHParkingLotIds.put(svm.Warehouse_Parking_Lot__c, svm);
        }
        try {
            WHParkingLotService.checkDuplicateWHParkingLot(null, mfSVMByWHParkingLotIds);
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Another Stock Vehicle Master has been assigned') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
}
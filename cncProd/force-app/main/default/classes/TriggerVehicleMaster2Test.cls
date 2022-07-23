@isTest
private class TriggerVehicleMaster2Test {
    @testSetup()
    static void setUp() {

        // setup custom setting
        Delivery_Bay_Configuration__c dbConfig = new Delivery_Bay_Configuration__c();
        dbConfig.Name= 'Delivery Bay Booking Config';
        dbConfig.Email_Template_Cancel_Delivery__c = 'Cancel Booking Slot';
        dbConfig.Email_Template_Delivery_Bay_Booking__c = 'After Booking Slot';
        dbConfig.Email_Template_Ready_for_Delivery__c = 'Ready For Delivery';
        dbConfig.Location_Delivery_Complete__c = 'Test Location';
        dbConfig.Location_QC_Complete__c = 'Test Location';
        insert dbConfig;

        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc.Id];
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = personAcc.Id;
        oppt.Contact_Person__c = personAcc.PersonContactId;
        insert oppt;

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

        // Create Warehouse Parking Lot
        Warehouse_Parking_Lot__c whParkingLot = new Warehouse_Parking_Lot__c(Name = 'Test A',
                                                                            Status__c = 'Active');
        insert whParkingLot;

        // Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
        Model_Master__c = modelCodes[0].Id,
        PKH_STATUS__c = 'A');
        insert pckHeader;

        // Additional Charges Master
        Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        Date productionMonth = Date.newInstance(2019, 08, 01); 
        // Stock Vehicle Master
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190087', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190087', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCodes[0].ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCodes[0].ID, 
                                                            Trim_Code__c = trimCodes[0].ID);
        insert vMaster;

        // Stock Reservation
        Stock_Reservation__c sr = Test_DataFactory.StockReservation(false, modelCodes[0].ID, colorCodes[0].ID, trimCodes[0].ID, modelYearCode.ID);
        sr.Package_Header_From_PickList__c = pckHeader.Id;
        sr.Vehicle_Master__c = vMaster.ID;
        sr.Opportunity__c    = oppt.Id;
        sr.Customer_Mobile_Number__c = '6587546859';
        insert sr;

    }
    @isTest
    private static void testBeforeInsert() {
        List<Model_Master__c> modelCodes = [SELECT ID FROM Model_Master__c];
		Model_Year_Master__c modelYearCode = [SELECT ID FROM Model_Year_Master__c LIMIT 1];
        List<Color_Master__c> colorCodes = [SELECT ID FROM Color_Master__c];
        List<Trim_Master__c> trimCodes = [SELECT ID FROM Trim_Master__c];
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCodes[0].ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCodes[0].ID, 
                                                            Trim_Code__c = trimCodes[0].ID);
        insert vMaster;
    }

    @isTest
    private static void testBeforeUpdate() {
        List<Model_Master__c> modelCodes = [SELECT ID FROM Model_Master__c];
		List<Model_Year_Master__c> modelYearCodes = [SELECT ID FROM Model_Year_Master__c];
        List<Color_Master__c> colorCodes = [SELECT ID FROM Color_Master__c];
        List<Trim_Master__c> trimCodes = [SELECT ID FROM Trim_Master__c];
        Date productionMonth = Date.today();
        Warehouse_Parking_Lot__c whParkingLot = [SELECT ID FROM Warehouse_Parking_Lot__c LIMIT 1];
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCodes[0].ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCodes[0].ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCodes[0].ID, 
                                                            Trim_Code__c = trimCodes[0].ID);
        insert vMaster;

        Vehicle_Master2__c vMaster2 = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCodes[1].ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCodes[1].ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCodes[1].ID, 
                                                            Trim_Code__c = trimCodes[1].ID);
        insert vMaster2;
        vMaster.Warehouse_Parking_Lot__c = whParkingLot.Id;
        vMaster2.Warehouse_Parking_Lot__c = whParkingLot.Id;
        try {
            update vMaster;
        	update vMaster2;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Another Stock Vehicle Master has been assigned to this Warehouse Parking Lot. Please check again!') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }

    @isTest
    static void Test_beforeUpdate_UpdateProdMnth() {
        List<Model_Master__c> modelCodes = [SELECT ID FROM Model_Master__c];
		Model_Year_Master__c modelYearCode = [SELECT ID FROM Model_Year_Master__c LIMIT 1];
        List<Color_Master__c> colorCodes = [SELECT ID FROM Color_Master__c];
        List<Trim_Master__c> trimCodes = [SELECT ID FROM Trim_Master__c];
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCodes[0].ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCodes[0].ID, 
                                                            Trim_Code__c = trimCodes[0].ID);
        insert vMaster;
        vMaster.ProductionMonth__c = Date.today().addDays(2);
        update vMaster;
        vMaster = [SELECT ID, ProductionMonth__c FROM Vehicle_Master2__c WHERE System_Commcase__c = 'KIAPC0120190086'];
        System.assertNotEquals(null, vMaster.ProductionMonth__c);
    }

    @isTest
    static void Test_afterUpdate_populateVehicleMovement() {
        Vehicle_Master2__c  vm = [SELECT Id FROM Vehicle_Master2__c];      
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        
        Sales_Agreement__c sa = new Sales_Agreement__c();
        sa.Branch_Code__c = 'CCK';
        sa.SOH_SONO__c = '';
        sa.Stock_Reservation__c = sr.ID;
        //SA.Customer_Full_Name__c = customerName;
        sa.NCD__c = 20;
        sa.Promo_Discount__c = 200;
        sa.Accessories_Discount__c = 500;
        sa.Expected_Delivery_From__c = Date.today();
        sa.Expected_Delivery_To__c = Date.today();
        sa.Payment__c = 'Car Loan';
        sa.ARCA_Number__c = 'UEN123456';
        sa.Company_Name__c = 'ABC TEST';
        insert sa;

        Delivery_Bay_Booking__c dbb = new Delivery_Bay_Booking__c(Sales_Agreement__c = sa.id);
        insert dbb;
        
        Test.startTest();
        vm.Vehicle_Movement_Location__c = 'Test Location';
        update vm;
        Test.stopTest();

        Sales_Agreement__c resultSA = [SELECT Id, Vehicle_Movement_Completed__c FROM Sales_Agreement__c LIMIT 1];
        System.assertEquals(true, resultSA.Vehicle_Movement_Completed__c);
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Vehicle_Master2__c', true);
        List<Model_Master__c> modelCodes = [SELECT ID FROM Model_Master__c];
		Model_Year_Master__c modelYearCode = [SELECT ID FROM Model_Year_Master__c LIMIT 1];
        List<Color_Master__c> colorCodes = [SELECT ID FROM Color_Master__c];
        List<Trim_Master__c> trimCodes = [SELECT ID FROM Trim_Master__c];
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCodes[0].ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCodes[0].ID, 
                                                            Trim_Code__c = trimCodes[0].ID);
        insert vMaster;
        TriggerExclusion.excludeTrigger('Vehicle_Master2__c', false);
    }
}
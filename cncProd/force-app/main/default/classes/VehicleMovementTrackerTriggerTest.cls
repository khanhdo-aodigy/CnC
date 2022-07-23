@isTest
private class VehicleMovementTrackerTriggerTest {
    @testSetup
    private static void setUp() {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc.Id];
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = personAcc.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt.Contact_Person__c = personAcc.PersonContactId;
        insert oppt;

        // Create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code',
                                                          Branch_Code__c = 'CCK', 
                                                          Franchise_Code__c = 'KIAPC',
                                                          Engine_Capacity__c = 1600,
                                                          BHP__c = 130);
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code',
                                                          Branch_Code__c = 'CCK',
                                                          Franchise_Code__c = 'KIAPC',
                                                          ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code',
                                                       Branch_Code__c = 'CCK',
                                                       Franchise_Code__c = 'KIAPC');
        insert trimMaster;
		Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code',
                                                                        Branch_Code__c = 'CCK',
                                                                        Franchise_Code__c = 'KIAPC',
                                                                        Model_Master__c = modelMaster.ID);
        insert modelYearMaster;
        Date productionMonth = Date.today();
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearMaster.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelMaster.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorMaster.ID, 
                                                            Trim_Code__c = trimMaster.ID);
        insert vMaster;
        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelMaster.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        // Create stock reservation from master data
        Stock_Reservation__c sr = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        sr.Package_Header_From_PickList__c = pckHeader.Id;
        sr.Reservation_Status__c = 'Reserved';
        sr.Vehicle_Master__c = vMaster.Id;
        sr.Opportunity__c = oppt.Id;
        insert sr;

        // Create SA - match condition
        Sales_Agreement__c SA = new Sales_Agreement__c();
        sa.Customer_Full_Name__c = 'X1111Test';
        sa.NRIC_Number__c = 'SXXXX1111';
        sa.Package_Header__c = pckHeader.Id;
        sa.Submit_COE_Bidding__c = true;
        SA.Branch_Code__c = 'CCK';
        SA.SOH_SONO__c = '1234';
        SA.Stock_Reservation__c = sr.Id;
        sa.Customer_Full_Name__c = 'X1111Test';
        SA.NCD__c = 20;
        SA.Promo_Discount__c = 200;
        SA.Accessories_Discount__c = 500;
        SA.Expected_Delivery_From__c = Date.today();
        SA.Expected_Delivery_To__c = Date.today();
        SA.Payment__c = 'Car Loan';
        SA.ARCA_Number__c = 'UEN123456';
        SA.Company_Name__c = 'ABC TEST';
        insert sa;

        // Create Model for MB
        Model__c model = Test_DataFactory.createmodelId(true, 'MB A Class Test', 'CCI', 'MBP');
        // Create Variant for MB
        Variant__c variant = new Variant__c(Name = 'MB A 250 Test',
                                           Model_ID__c = model.Id,
                                           Franchise__c = 'MBP',
                                           Branch__c = 'CCI',
                                           Allow_Indent__c = false,
                                           Description__c = 'MB A 250 Test',
                                           DWH_Variant_ID__c = 'CCI,MBP,17708422-SG2',
                                           Active__c = true);
        insert variant;
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black',
                                                                         Estimated_Delivery_Date__c = '01/02',
                                                                         VariantDescription__c = 'MB A 250 Test');
        insert mbSVM;
        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA = new MB_Sales_Agreement__c();
        mbSA.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA.Status__c = 'Draft';
        insert mbSA;
        // Create Location
       	Id recordTypeIdLocation = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get('Vehicle Movement').getRecordTypeId();
        Location__c location = new Location__c(Name = 'Test Location',
                                               Email_Subject__c = '{!Name} Test Subject',
                                               Email_Body__c = '{!Name} Test Body',
                                               Email_Communication_Vehicle_Movement__c = true,
                                               RecordTypeId = recordTypeIdLocation);
        insert location;
    }

    @isTest
    private static void Test_beforeInsert_SVM() {
        Vehicle_Master2__c vMaster = [SELECT ID FROM Vehicle_Master2__c WHERE System_Commcase__c = 'KIAPC0120190086' LIMIT 1];
        Location__c location = [SELECT ID FROM Location__c LIMIT 1];
        Vehicle_Movement_Tracker__c vmt1 = new Vehicle_Movement_Tracker__c(Stock_Vehicle_Master__c = vMaster.Id,
                                                                           Location__c = location.Id);
        insert vmt1;
        Boolean exceptionThrownOnInvalidVMT = false;
        try {
            Vehicle_Movement_Tracker__c vmt2 = new Vehicle_Movement_Tracker__c(Stock_Vehicle_Master__c = vMaster.Id,
                                                                               Location__c = location.Id);
            insert vmt2;
        } catch(Exception e) {
            exceptionThrownOnInvalidVMT = e.getMessage().contains('has already been moved to this Location');
        } finally {
            System.assert(exceptionThrownOnInvalidVMT);
        }
    }

    @isTest
    private static void Test_afterInsert_SVM() {
        Vehicle_Master2__c vMaster = [SELECT ID, Vehicle_Movement_Location__c FROM Vehicle_Master2__c WHERE System_Commcase__c = 'KIAPC0120190086' LIMIT 1];
        Stock_Reservation__c sr = [SELECT ID FROM Stock_Reservation__c WHERE Vehicle_Master__c = :vMaster.Id];
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c WHERE Stock_Reservation__c = :sr.Id];
        Location__c location = [SELECT ID FROM Location__c LIMIT 1];
        Vehicle_Movement_Tracker__c vmt1 = new Vehicle_Movement_Tracker__c(Stock_Vehicle_Master__c = vMaster.Id,
                                                                           Location__c = location.Id);
        insert vmt1;
        Vehicle_Movement_Tracker__c vmt = [SELECT ID, Location__r.Name 
                                           FROM Vehicle_Movement_Tracker__c
                                           WHERE Stock_Vehicle_Master__c = :vMaster.Id ORDER BY CreatedDate DESC LIMIT 1];
        vMaster = [SELECT ID, Vehicle_Movement_Location__c FROM Vehicle_Master2__c WHERE System_Commcase__c = 'KIAPC0120190086' LIMIT 1];
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(vMaster.Vehicle_Movement_Location__c, vmt.Location__r.Name);
        // System.assertEquals(1, invocations);
    }

    @isTest
    private static void Test_beforeInsert_MBSVM() {
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        Location__c location = [SELECT ID FROM Location__c LIMIT 1];
        Vehicle_Movement_Tracker__c vmt1 = new Vehicle_Movement_Tracker__c(MB_Stock_Vehicle_Master__c = mbSVM.Id,
                                                                           Location__c = location.Id);
        insert vmt1;
        Boolean exceptionThrownOnInvalidVMT = false;
        try {
            Vehicle_Movement_Tracker__c vmt2 = new Vehicle_Movement_Tracker__c(MB_Stock_Vehicle_Master__c = mbSVM.Id,
                                                                               Location__c = location.Id);
            insert vmt2;
        } catch(Exception e) {
            exceptionThrownOnInvalidVMT = e.getMessage().contains('has already been moved to this Location');
        } finally {
            System.assert(exceptionThrownOnInvalidVMT);
        }
    }
 
    @isTest
    private static void Test_afterInsert_MBSVM() {
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        MB_Sales_Agreement__c mbSA = [SELECT ID FROM MB_Sales_Agreement__c WHERE MB_Stock_Vehicle_Master__c = :mbSVM.Id];
        Location__c location = [SELECT ID FROM Location__c LIMIT 1];
        Vehicle_Movement_Tracker__c vmt1 = new Vehicle_Movement_Tracker__c(MB_Stock_Vehicle_Master__c = mbSVM.Id,
                                                                           Location__c = location.Id);
        insert vmt1;
        Vehicle_Movement_Tracker__c vmt = [SELECT ID, Location__r.Name 
                                           FROM Vehicle_Movement_Tracker__c
                                           WHERE MB_Stock_Vehicle_Master__c = :mbSVM.Id ORDER BY CreatedDate DESC LIMIT 1];
        mbSVM = [SELECT ID, Vehicle_Movement_Location__c FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(mbSVM.Vehicle_Movement_Location__c, vmt.Location__r.Name);
        // System.assertEquals(1, invocations);
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Vehicle_Movement_Tracker__c', true);
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        MB_Sales_Agreement__c mbSA = [SELECT ID FROM MB_Sales_Agreement__c WHERE MB_Stock_Vehicle_Master__c = :mbSVM.Id];
        Location__c location = [SELECT ID FROM Location__c LIMIT 1];
        Vehicle_Movement_Tracker__c vmt1 = new Vehicle_Movement_Tracker__c(MB_Stock_Vehicle_Master__c = mbSVM.Id,
                                                                           Location__c = location.Id);
        insert vmt1;
        TriggerExclusion.excludeTrigger('Vehicle_Movement_Tracker__c', false);
    }
}
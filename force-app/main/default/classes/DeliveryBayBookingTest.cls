/** ******
* Description: Tess Class for deliveryBayBookingCtl, DeliveryBayBookings, DeliveryBayBookingExpired_Schedulable
* 
* Change History:
* Date(YYYYMMDD)      Name        		    Description
* 20210826            nguyen.thang          Created Initial Version.
* 
** ******/

@isTest
private class DeliveryBayBookingTest {
    
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
                                            Allow_Indent__c = true,
                                            Description__c = 'MB A 250 Test',
                                            Active__c = true,
                                            Engine_Capacity__c = '1600',
                                            BHP__c = '130');
        insert variant;
        
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                          Status__c = 'Open',
                                                                          Variant__c = variant.Id,
                                                                          Colour__c = '787 Mountain Grey',
                                                                          Trim__C = '101 ARTICO Black');
        insert mbSVM;
        
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = personAcc.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt.Contact_Person__c = personAcc.PersonContactId;
        insert oppt;
        
        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA1 = new MB_Sales_Agreement__c();
        mbSA1.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA1.Customer_Full_Name__c = 'X1111Test';
        mbSA1.CNRIC_Number__c = 'SXXXX1111';
        mbSA1.Submit_COE_Bidding__c = true;
        mbSA1.Account__c = personAcc.Id;
        insert mbSA1;
        
        // Model Master
        Model_Master__c modelCode = Test_DataFactory.createModelCode(false, 'Test Model Code');
        modelCode.Engine_Capacity__c = 1600;    // To test COE Category
        modelCode.BHP__c = 130;                 // To test COE Category
        modelCode.Franchise_Code__c = 'KIAPC';
        insert modelCode;
        // Model Year Master
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        // Color Master
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        // Trim Master
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        // Stock Vehicle Master
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID);
        insert vMaster;
        // Package Header
        Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        
        // Additional Charges Master
        Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Stock Reservation
        Stock_Reservation__c sr = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        sr.Package_Header_From_PickList__c = pckHeader.Id;
        sr.Vehicle_Master__c = vMaster.ID;
        sr.Opportunity__c    = oppt.Id;
        sr.Customer_Mobile_Number__c = '6587546859';
        insert sr;
        
    }
    
    @isTest
    static void Test_ValidateDBB(){
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        insert sa;
        Delivery_Bay_Booking__c dbb = new Delivery_Bay_Booking__c(Sales_Agreement__c = sa.id, Status__c ='Booked');
        insert dbb;
        Delivery_Bay_Booking__c dbb2 = new Delivery_Bay_Booking__c(Sales_Agreement__c = sa.id, Status__c ='Completed');
        insert dbb2;
        
        Test.startTest();
        try{   
            dbb2.Status__c ='Booked';
            update dbb2;
        }
        catch(Exception e){
            Boolean expectedError=  e.getMessage().contains('Delivery bay have been booked, Please check!') ? true : false;
            System.AssertEquals(expectedError, true); 
            
        }
        Test.stopTest();
    }
    
    
    @isTest
    static void Test_DeliveryBayBookingExpired_Schedulable(){
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        insert sa;
        Delivery_Bay_Booking__c dbb = new Delivery_Bay_Booking__c(Sales_Agreement__c = sa.id, Status__c ='Booked', Delivery_Date__c = system.today().addDays(-1));
        insert dbb;
        
        
        Test.startTest();
        
        DeliveryBayBookingExpired_Schedulable sch = new DeliveryBayBookingExpired_Schedulable();
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        String jobId = System.schedule('DeliveryBayBookingExpired_Schedulable',str, new DeliveryBayBookingExpired_Schedulable() );
        DataBase.executeBatch(sch);
        Test.stopTest();
        Delivery_Bay_Booking__c record = [Select Id, Status__c from Delivery_Bay_Booking__c LIMIT 1];
        System.assertEquals('Expired', record.Status__c);
    }
    
    @isTest
    static void Test_sendEmailForBookingDeliveryBaySlot() {
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(true, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        
        MB_Sales_Agreement__c mbSA = [SELECT Id, COE__c FROM MB_Sales_Agreement__c WHERE CNRIC_Number__c = 'SXXXX1111'];
        mbSA.Status__c = 'Ready for Delivery';
        
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT Id, Vehicle_Movement_Location__c FROM MB_Stock_Vehicle_Master__c LIMIT 1];
        update mbSA;
        
        Test.startTest();
        mbSVM.Vehicle_Movement_Location__c = 'Test Location';
        update mbSVM;
        sa.Vehicle_Movement_Completed__c = true;
        sa.Stage__c = 'Ready for Registration';
        update sa;
        Test.stopTest();
    }
    
    @isTest
    static void Test_SendingEmailAfterBooking() {
        
        Delivery_Bay_In_Charge__c dbic = new Delivery_Bay_In_Charge__c();
        dbic.Active__c = true;
        dbic.Email__c = 'test@gmail.com';
        dbic.Franchise_Code__c = 'KIAPC';
        insert dbic;
        
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        insert sa;
        Delivery_Bay_Booking__c dbb = new Delivery_Bay_Booking__c(Sales_Agreement__c = sa.id);
        insert dbb;
        
        Test.startTest();
        dbb.Status__c ='Booked';
        update dbb;
        Test.stopTest();
    }
    
    @isTest
    static void Test_SendingEmailAfterCancelBooking() {
        
        Delivery_Bay_In_Charge__c dbic = new Delivery_Bay_In_Charge__c();
        dbic.Active__c = true;
        dbic.Email__c = 'test@gmail.com';
        dbic.Franchise_Code__c = 'KIAPC';
        insert dbic;
        
        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        insert sa;
        Delivery_Bay_Booking__c dbb = new Delivery_Bay_Booking__c(Sales_Agreement__c = sa.id);
        insert dbb;
        
        Test.startTest();
        dbb.Status__c ='Cancelled';
        update dbb;
        Test.stopTest();
    }
    
    @isTest
    static void Test_DeliveryBayBookingCtl() {
        User sysAdminUser = Test_DataFactory.createUserWithProfileID(
            true, 'SysAdm', 'LastName', 'test@sysadmin.com', [Select Id From Profile Where Name = 'System Administrator'].Id
        );
        sysAdminUser.Franchise_Code__c = 'KIAPC';
        update sysAdminUser;

        Stock_Reservation__c sr = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = createSalesAgreement(false, 'CCK', '', sr.ID, 'Thieu Dang Vu');
        insert sa;
        Delivery_Bay_Booking__c dbb = new Delivery_Bay_Booking__c(Sales_Agreement__c = sa.id);
        insert dbb;
        Service_Centre_Master__c  scm = new Service_Centre_Master__c (Franchise__c = 'KIAPC', Opening_Hours_Start__c = Time.newInstance(10,0,0,0), Opening_Hours_End__c = Time.newInstance(18,0,0,0));
        insert scm;
        Service_Category__c sc = new Service_Category__c(Category__c = 'Delivery Bay', Active__c = true, Service_Centre__c = scm.Id, Interval_Minutes__c = 60, Slots_per_Interval__c = 5);
        insert sc;
        System.runAs(sysAdminUser) {
        Test.startTest();
        deliveryBayBookingCtl.doGetInformation(dbb.Id);   
        deliveryBayBookingCtl.doSearchRecords(scm.Id, String.valueof(system.today().addDays(5)), String.valueof(system.today().addDays(4))); 
        deliveryBayBookingCtl.updateRecord(dbb.Id, String.valueof(system.today().addDays(5)), '10:00:00.000Z', 60, scm.Id, 2);
        Delivery_Bay_Booking__c record = [Select Id, Status__c from Delivery_Bay_Booking__c];
        System.assertEquals('Booked', record.Status__c);
        deliveryBayBookingCtl.rebookRecord(dbb.Id);
        List<Delivery_Bay_Booking__c> records = [Select Id, Status__c from Delivery_Bay_Booking__c];
        System.assertEquals(2, records.size());
        Delivery_Bay_Booking__c newRecords = [Select Id, Status__c from Delivery_Bay_Booking__c Where Status__c != 'Cancelled' ];
        deliveryBayBookingCtl.cancelRecord(newRecords.Id);
        Test.stopTest();
        List<Delivery_Bay_Booking__c> result = [Select Id, Status__c from Delivery_Bay_Booking__c Where Status__c = 'Cancelled'];
        System.assertEquals(2, result.size());
        }
    }
    
    /**
* create sales agreement
**/
    private static Sales_Agreement__c createSalesAgreement(Boolean doInsert, string branchCode, string agreementNo, ID stockReservationId, string customerName) {      
        // create sales agreement
        Sales_Agreement__c SA = new Sales_Agreement__c();
        SA.Branch_Code__c = branchCode;
        SA.SOH_SONO__c = agreementNo;
        SA.Stock_Reservation__c = stockReservationId;
        //SA.Customer_Full_Name__c = customerName;
        SA.NCD__c = 20;
        SA.Promo_Discount__c = 200;
        SA.Accessories_Discount__c = 500;
        SA.Expected_Delivery_From__c = Date.today();
        SA.Expected_Delivery_To__c = Date.today();
        SA.Payment__c = 'Car Loan';
        SA.ARCA_Number__c = 'UEN123456';
        SA.Company_Name__c = 'ABC TEST';
        if (doInsert) {insert SA;}
        return SA;
    }
}
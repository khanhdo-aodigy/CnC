@isTest
private with sharing class COEBiddingUploadCtrlTest {
    @testSetup
    static void setUp() {
        // Create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code',
                                                          Branch_Code__c = 'CCK', 
                                                          Franchise_Code__c = 'KIAPC',
                                                          Engine_Capacity__c = 1600,
                                                          BHP__c = 130);
        insert modelMaster;
        Model_Master__c modelMaster2 = new Model_Master__c(Name = 'Test Model Code2',
                                                          Branch_Code__c = 'CCK', 
                                                          Franchise_Code__c = 'KIAPC',
                                                          Engine_Capacity__c = 1700,
                                                          BHP__c = 150);
        insert modelMaster2;
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
        Model_Year_Master__c modelYearMaster2 = new Model_Year_Master__c(Name = 'Test Model Year Code',
                                                                        Branch_Code__c = 'CCK',
                                                                        Franchise_Code__c = 'KIAPC',
                                                                        Model_Master__c = modelMaster2.ID);
        insert modelYearMaster2;

        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelMaster.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        Package_Header__c pckHeader2 = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelMaster2.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader2;

        // Create stock reservation from master data
        Stock_Reservation__c sr = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        sr.Package_Header_From_PickList__c = pckHeader.Id;
        insert sr;
        Stock_Reservation__c sr2 = Test_DataFactory.StockReservation(false, modelMaster2.ID, colorMaster.ID, trimMaster.ID, modelYearMaster2.ID);
        sr2.Package_Header_From_PickList__c = pckHeader2.Id;
        insert sr2;

        // Create SA - match condition
        Sales_Agreement__c sa1 = Test_DataFactory.createSalesAgreement(false, 'CCK', null, sr.Id, null);
        sa1.Customer_Full_Name__c = 'X1111Test';
        sa1.NRIC_Number__c = 'SXXXX1111';
        sa1.Package_Header__c = pckHeader.Id;
        sa1.Submit_COE_Bidding__c = true;
        insert sa1;
        
        // Create SA 2 - not match COE Category
        Sales_Agreement__c sa2 = Test_DataFactory.createSalesAgreement(false, 'CCK', null, sr2.Id, null);
        sa2.Customer_Full_Name__c = 'X2222Test';
        sa2.NRIC_Number__c = 'SXXXX2222';
        sa2.Package_Header__c = pckHeader2.Id;
        sa2.Submit_COE_Bidding__c = true;
        insert sa2;

        
		// Below is for MB
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
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM2 = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '2',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant1.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM2;
        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA1 = new MB_Sales_Agreement__c();
        mbSA1.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA1.Customer_Full_Name__c = 'X1111Test';
        mbSA1.CNRIC_Number__c = 'SXXXX1111';
        mbSA1.Submit_COE_Bidding__c = true;
        insert mbSA1;
        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA2 = new MB_Sales_Agreement__c();
        mbSA2.MB_Stock_Vehicle_Master__c = mbSVM2.Id;
        mbSA2.Customer_Full_Name__c = 'X2222Test';
        mbSA2.CNRIC_Number__c = 'SXXXX2222';
        mbSA2.Submit_COE_Bidding__c = true;
        insert mbSA2;

        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            User sc = Test_DataFactory.createUser(false, 'SC Test', 'Test');
            sc.Franchise_Code__c = 'KIAPC';
            insert sc;
            sa1.OwnerId = sc.Id;
            update sa1;
            sa2.OwnerId = sc.Id;
            update sa2;
            system.debug('SC Franchise ' + sc.Franchise_Code__c);
        }
        // Create COE Bid Period record
		COE_Bid_Period__c coeBidPeriod = new COE_Bid_Period__c(Bid_Status__c = 'Active',
                                                              From_Date__c = Date.today(),
                                                              To_Date__c = Date.today().addDays(14));
        
        insert coeBidPeriod;
        // Create CSV File
        ContentVersion cv = new ContentVersion(
            Title = 'COE',   
            PathOnClient = 'coe' + '.csv',
            VersionData = Blob.valueOf(csvContent()),
            IsMajorVersion = true
        );
        insert cv;
        // Create wrong format CSV File
        ContentVersion cv2 = new ContentVersion(
            Title = 'COEWRONGFORMAT',   
            PathOnClient = 'coe' + '.csv',
            VersionData = Blob.valueOf(wrongFormatCSVContent()),
            IsMajorVersion = true
        );
        insert cv2;
        // Create duplicate data CSV File
        ContentVersion cv3 = new ContentVersion(
            Title = 'COEDUPLICATE',   
            PathOnClient = 'coe' + '.csv',
            VersionData = Blob.valueOf(duplicateSACSVContent()),
            IsMajorVersion = true
        );
        insert cv3;
        // Create empty data CSV File
        ContentVersion cv4 = new ContentVersion(
            Title = 'COEEMPTYFILE',   
            PathOnClient = 'coe' + '.csv',
            VersionData = Blob.valueOf(emptyCSVContent()),
            IsMajorVersion = true
        );
        insert cv4;
    }

    @isTest
    private static void testUploadCSVForMF() {
        COE_Bid_Period__c coeBidPeriod = [SELECT ID FROM COE_Bid_Period__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'COE' LIMIT 1];
        String franchise = 'KIAPC';
        Test.startTest();
        COEBiddingUploadCtrl.readCSVFile(cv.ContentDocumentId, coeBidPeriod.Id, franchise);
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVForMB() {
        COE_Bid_Period__c coeBidPeriod = [SELECT ID FROM COE_Bid_Period__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'COE' LIMIT 1];
        String franchise = 'MBP';
        Test.startTest();
        COEBiddingUploadCtrl.readCSVFile(cv.ContentDocumentId, coeBidPeriod.Id, franchise);
        Test.stopTest();
    }

    @isTest
    private static void testWrongFormatCSV() {
        COE_Bid_Period__c coeBidPeriod = [SELECT ID FROM COE_Bid_Period__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'COEWRONGFORMAT' LIMIT 1];
        String franchise = 'KIAPC';
        Test.startTest();
        try {
        	COEBiddingUploadCtrl.readCSVFile(cv.ContentDocumentId, coeBidPeriod.Id, franchise);
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    private static void testDuplicateSAFound() {
        COE_Bid_Period__c coeBidPeriod = [SELECT ID FROM COE_Bid_Period__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'COEDUPLICATE' LIMIT 1];
        String franchise = 'KIAPC';
        Test.startTest();
        try {
        	COEBiddingUploadCtrl.readCSVFile(cv.ContentDocumentId, coeBidPeriod.Id, franchise);
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    private static void testMultipleSAFoundUnderCOE() {
        Sales_Agreement__c sa = [SELECT ID, NRIC_Number__c, Customer_Full_Name__c FROM Sales_Agreement__C WHERE NRIC_Number__c = 'SXXXX2222'];
        sa.NRIC_Number__c = 'SXXXX1111';
        sa.Customer_Full_Name__c = 'X1111Test 1';
        update sa;
        system.debug('updated sa:: ' + sa);
        COE_Bid_Period__c coeBidPeriod = [SELECT ID FROM COE_Bid_Period__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'COE' LIMIT 1];
        String franchise = 'KIAPC';
        Test.startTest();
        COEBiddingUploadCtrl.readCSVFile(cv.ContentDocumentId, coeBidPeriod.Id, franchise);
        Test.stopTest();
    }

    @isTest
    private static void testUploadEmptyCSV() {
        COE_Bid_Period__c coeBidPeriod = [SELECT ID FROM COE_Bid_Period__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'COEEMPTYFILE' LIMIT 1];
        String franchise = 'KIAPC';
        Test.startTest();
        try {
        	COEBiddingUploadCtrl.readCSVFile(cv.ContentDocumentId, coeBidPeriod.Id, franchise);
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    private static void testUploadEmptyRowCSV() {
        COE_Bid_Period__c coeBidPeriod = [SELECT ID FROM COE_Bid_Period__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'COE' LIMIT 1];
        String franchise = 'KIAPC';
        Test.startTest();
        COEBiddingUploadCtrl.readCSVFile(cv.ContentDocumentId, coeBidPeriod.Id, franchise);
        Test.stopTest();
    }


    private static String csvContent() {
        String content =	'S/No.,TCOE No.,Veh Cat,Bidder Name,Bidder ID Type,Bidder ID,QP($),Deposit($),Balance($),Admin Fee($),TCOE Expiry Date,Status\n' +
                            '1,2021030101000217N,A,X1111Test 1,Singapore NRIC,SXXXX1111,"42,000.00","10,000.00","32,000.00",0,2021-08-14,Unused\n' +
                            '2,2021030101000218W,A,X2222Test 2,Singapore NRIC,SXXXX2222,"42,000.00","10,000.00","32,000.00",0,2021-08-14,Unused\n' +
							'3,2021030102399218W,A,X3333Test 3,Company ARCA,GXXXX3333,"42,000.00","10,000.00","32,000.00",0,2021-08-14,Unused\n' +
            				'4,2021030102300218W,E,X4444Test 4,Singapore NRIC,SXXXX4444,"42,000.00","10,000.00","32,000.00",0,2021-08-14,Unused\n' +
            				',,,,,,,,,,,';
        return content;
    }

    private static String wrongFormatCSVContent() {
        String content =	'S/No.,TCOE No.,Veh Cat,Bidder Name,Bidder ID Type,Bidder ID,QP($),Deposit($),Balance($),Admin Fee($),TCOE Expiry Date,Status\n' +
                            '12021030101000217N,A,X1111Test 1Singapore NRIC,SXXXX1111,42,000.00,"10,000.00","32,000.00",0,2021-08-14,Unused\n';
        return content;
    }

    private static String duplicateSACSVContent() {
        String content =	'S/No.,TCOE No.,Veh Cat,Bidder Name,Bidder ID Type,Bidder ID,QP($),Deposit($),Balance($),Admin Fee($),TCOE Expiry Date,Status\n' +
                            '1,2021030101000217N,A,X1111Test 1,Singapore NRIC,SXXXX1111,"42,000.00","10,000.00","32,000.00",0,2021-08-14,Unused\n' +
                            '2,2021030101000218W,A,X1111Test 1,Singapore NRIC,SXXXX1111,"35,000.00","10,000.00","32,000.00",0,2021-08-14,Unused\n';
        return content;
    }

    private static String emptyCSVContent() {
        String content = 'S/No.,TCOE No.,Veh Cat,Bidder Name,Bidder ID Type,Bidder ID,QP($),Deposit($),Balance($),Admin Fee($),TCOE Expiry Date,Status\n';
        return content;
    }
}
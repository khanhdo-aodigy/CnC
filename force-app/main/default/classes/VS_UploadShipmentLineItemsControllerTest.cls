/*==========================================================================================================================================================================
 * Test class for vs_UploadShipmentLineItemsController LWC
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           14 Sep 2022                       nam@aodigy.com                                                                               init
 * ========================================================================================================================================================================== 
 */
@isTest
public with sharing class VS_UploadShipmentLineItemsControllerTest {
    @TestSetup
    static void makeData()
    {
         // create manufacturer supplier
         Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');
         
         //create vehicle shipment 
         Vehicle_Shipment__c VehicleShipment         = Test_DataFactory.createVehicleShipment(true, supplier.Id);
         
         // create manufacturer invoice
         Manufacturer_Invoice__c manufacturerInvoice = Test_DataFactory.createManufacturerInvoice(false);
         manufacturerInvoice.Invoice_No__c = 'INV56789';
         insert manufacturerInvoice;
         
         //create shipment line item
          Shipment_Line_Item__c shipmentLineItem     = Test_DataFactory.createShipmentLineItem(true, VehicleShipment.Id, manufacturerInvoice.Id);
          
          //create hs code
          HS_Type__c hsCode = new HS_Type__c( Name = 'GG605');
          insert hsCode;

          //create product code
          Product_Code__c proCode = new Product_Code__c(Product_Code__c = '21-KI-0100-0001-G');
          insert proCode;

          // Create CSV File
          ContentVersion cv = new ContentVersion(
            Title = 'SLI',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContent()),
            IsMajorVersion = true
        );
        insert cv;

         // Create CSV File
         ContentVersion cv1 = new ContentVersion(
            Title = 'SLI1',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoModelCode()),
            IsMajorVersion = true
        );
        insert cv1;

        // Create wrong format CSV File
        ContentVersion cv2 = new ContentVersion(
            Title = 'SLIWRONGFORMAT',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(wrongFormatCSVContent()),
            IsMajorVersion = true
        );
        insert cv2;

        // Create duplicate data CSV File
        ContentVersion cv3 = new ContentVersion(
            Title = 'SLIDUPLICATE',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(duplicateCSVContent()),
            IsMajorVersion = true
        );
        insert cv3;
        // Create empty data CSV File
        ContentVersion cv4 = new ContentVersion(
            Title = 'SLIEMPTYFILE',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(emptyCSVContent()),
            IsMajorVersion = true
        );
        insert cv4;
    
        // Create CSV File no Color Code
        ContentVersion cv5 = new ContentVersion(
            Title = 'SLI2',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoColorCode()),
            IsMajorVersion = true

        );
        insert cv5;

        // Create CSV File no Trim Code
        ContentVersion cv6 = new ContentVersion(
            Title = 'SLI3',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoTrimCode()),
            IsMajorVersion = true

        );
        insert cv6;

        // Create CSV File no ChassisNo
        ContentVersion cv7 = new ContentVersion(
            Title = 'SLI4',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoChassisNo()),
            IsMajorVersion = true

        );
        insert cv7;

         // Create CSV File no EngineNo
         ContentVersion cv8 = new ContentVersion(
            Title = 'SLI5',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoEngineNo()),
            IsMajorVersion = true
        );
        insert cv8;

         // Create CSV File no Production Month
         ContentVersion cv9 = new ContentVersion(
            Title = 'SLI6',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoProductionMonth()),
            IsMajorVersion = true

        );
        insert cv9;

        // Create CSV File no FOB
        ContentVersion cv10 = new ContentVersion(
            Title = 'SLI7',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoFOB()),
            IsMajorVersion = true
        );
        insert cv10;

        // Create CSV File no InvoiceNo
        ContentVersion cv11 = new ContentVersion(
            Title = 'SLI8',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoInvoiceNo()),
            IsMajorVersion = true
        );
        insert cv11;

        // Create CSV File no TotalInvoiceAmount
        ContentVersion cv12 = new ContentVersion(
            Title = 'SLI9',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoTotalInvoiceAmount()),
            IsMajorVersion = true
        );
        insert cv12;

        // Create CSV File no TotalInvoiceAmtCurrencyCode
        ContentVersion cv13 = new ContentVersion(
            Title = 'SLI10',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoTotalInvoiceAmtCurrencyCode()),
            IsMajorVersion = true
        );
        insert cv13;

        // Create CSV File no InvoiceDate
        ContentVersion cv14 = new ContentVersion(
            Title = 'SLI11',   
            PathOnClient = 'SLI' + '.csv',
            VersionData = Blob.valueOf(csvContentNoInvoiceDate()),
            IsMajorVersion = true
        );
        insert cv14;
    } 
    @isTest
    private static void testUploadCSV() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI' LIMIT 1];
        Test.startTest();
        VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoModeCode() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI1' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoColorCode() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI2' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);    
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoTrimCode() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI3' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);
        } catch (Exception e) {}  
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoChassisNo() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI4' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);    
        } catch (Exception e) {}   
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoEngineNo() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI5' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);    
        } catch (Exception e) {} 
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoFOB() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI7' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);    
        } catch (Exception e) {}    
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoInvoiceNo() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI8' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);    
        } catch (Exception e) {}   
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoTotalInvoiceAmount() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI9' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);
        } catch (Exception e) {}    
        Test.stopTest();
    }
    
    @isTest
    private static void testUploadCSVNoTotalInvoiceAmtCurrencyCode() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI10' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);    
        } catch (Exception e) {}   
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoInvoiceDate() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI11' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);    
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    private static void testUploadCSVNoProductionMonth() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLI6' LIMIT 1];
        Test.startTest();
        try 
        {
            VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);    
        } catch (Exception e) {}    
        Test.stopTest();
    }

    @isTest
    private static void testWrongFormatCSV() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLIWRONGFORMAT' LIMIT 1];
        Test.startTest();
        try {
        	VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    private static void testDuplicate() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLIDUPLICATE' LIMIT 1];
        Test.startTest();
        try {
        	VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    private static void testUploadEmptyCSV() {
        Vehicle_Shipment__c shipment = [SELECT ID FROM Vehicle_Shipment__c LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Title = 'SLIEMPTYFILE' LIMIT 1];
        Test.startTest();
        try {
        	VS_UploadShipmentLineItemsController.readCSVFile(cv.ContentDocumentId, shipment.Id);
        } catch (Exception e) {}
        Test.stopTest();
    }
    
    private static String csvContent() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",DJS4D261F,KLG,WK,INV2331,KNAF1416MN5139961,G4FGNH700533,8430,503,22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,12500,USD,2022-09-05\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }
    
    private static String csvContentNoProductionMonth() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"",DJS4D261F,KLG,WK,INV2331,KNAF1416MN5139961,G4FGNH700533,8430,503,22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,12500,USD,2022-09-05\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }

    private static String csvContentNoModelCode() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022","","","",INV2331,"","","","",22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,"","",""\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }

    private static String csvContentNoColorCode() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",STINGER2.0,"",WK,INV2331,"","","","",22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,"","",""\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }

    private static String csvContentNoTrimCode() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",STINGER2.0,KLG,"",INV2331,"","","","",22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,"","",""\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }

    private static String csvContentNoChassisNo() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",STINGER2.0,KLG,WK,INV2331,"","","","",22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,"","",""\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }
    
    private static String csvContentNoEngineNo() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",STINGER2.0,KLG,WK,INV2331,KNAF1416MN5139961,"","","",22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,"","",""\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }

    private static String csvContentNoFOB() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",STINGER2.0,KLG,WK,INV2331,KNAF1416MN5139961,G4FGNH700533,"","",22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,"","",""\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }
    
    private static String csvContentNoInvoiceNo() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",DJS4D261F,KLG,WK,INV2331,KNAF1416MN5139961,G4FGNH700533,8430,503,22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,"",12500,USD,2022-09-05\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }

    private static String csvContentNoTotalInvoiceAmount() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",DJS4D261F,KLG,WK,INV2331,KNAF1416MN5139961,G4FGNH700533,8430,503,22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,"",USD,2022-09-05\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }

    private static String csvContentNoTotalInvoiceAmtCurrencyCode() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",DJS4D261F,KLG,WK,INV2331,KNAF1416MN5139961,G4FGNH700533,8430,503,22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,12500,"",2022-09-05\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }

    private static String csvContentNoInvoiceDate() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",DJS4D261F,KLG,WK,INV2331,KNAF1416MN5139961,G4FGNH700533,8430,503,22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,12500,USD,""\n' +
            				',,,,,,,,,,,,,,,,,,,';
        return content;
    }

    private static String wrongFormatCSVContent() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '12021030101000217N,A,X1111Test 1Singapore NRIC,SXXXX1111,42,000.00,"10,000.00","32,000.00",0,2021-08-14,Unused\n';
        return content;
    }

    private static String duplicateCSVContent() {
        String content =	'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n' +
                            '"08/2022",DJS4D261F,KLG,WK,INV2331,KNAF1416MN5139961,G4FGNH700533,8430,503,22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,12500,USD,2022-09-05\n' +
                            '"08/2022",DJS4D261F,KLG,WK,INV2331,KNAF1416MN5139961,G4FGNH700533,8430,503,22,50,65,123,12,GG605,21-KI-0100-0001-G,VES123,INV56789,12500,USD,2022-09-05\n';
        return content;
    }

    private static String emptyCSVContent() {
        String content =    'Production Date,Model Code,Color Code,Trim Code,Manufacturer Ref. No.,VIN/Chassis No.,Engine No,FOB,Freight,Insurance,Transport Charges,Ex Factory Charges,Other Charges,Key No.,HS Code,Product Code,Vessel Name,Invoice No.,Total Invoice Amount,Total Invoice Amount Currency Code,Invoice Date (YYYY-MM-DD)\n';
        return content;
    }   
}
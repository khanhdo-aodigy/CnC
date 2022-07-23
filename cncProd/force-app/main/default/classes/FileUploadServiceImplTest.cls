@isTest
private class FileUploadServiceImplTest {
    
    @testSetup
    private static void setUp() {
    	// create a sales agreement record for test
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';
        string customerEMail = 'test@123.com';
        string CUSTOMER_SIGN_ORDER = '1';

        // create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', Model_Master__c = modelMaster.ID);
        insert modelYearMaster;
        
        // create stock reservation from master data
        Stock_Reservation__c stockReservation_1 = Test_DataFactory.StockReservation(true, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        Stock_Reservation__c stockReservation_2 = Test_DataFactory.StockReservation(true, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);

        // sales agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(true, branchCode, agreementNo, stockReservation_1.ID, customerName);
        
        // content version
        ContentVersion cv = FileUploadServiceImpl.saveFileToRecord(salesAgreement.id, 'content to delete', 'content to delete', 'content to delete');
    }
    
	@isTest
    private static void saveFileToRecord() {
        Sales_Agreement__c SA = [SELECT id FROM Sales_Agreement__c];
        ContentVersion cv = FileUploadServiceImpl.saveFileToRecord(SA.id, 'test', 'test', 'prefix');
        system.assertEquals('test', cv.Title);
    }
    
    @isTest
    private static void saveFileToRecordCompressedFile() {
        Sales_Agreement__c SA = [SELECT id FROM Sales_Agreement__c];
        ContentVersion cv = FileUploadServiceImpl.saveFileToRecordCompressedFile(SA.id, 'test', 'test', 'prefix');
        system.assertEquals('test', cv.Title);
    }
    
    @isTest
    private static void removeFileFromRecord_Null() {
        try {
            Boolean result = FileUploadServiceImpl.removeFileFromRecord(null);
        } catch (Exception e) {
            system.assert(e.getMessage() != null);
        }
    }
    
    @isTest
    private static void removeFileFromRecord() {
        ContentVersion cv = [SELECT id, ContentDocumentId FROM ContentVersion WHERE Title = 'content to delete'];
        Boolean result = FileUploadServiceImpl.removeFileFromRecord(cv.id);
        system.assert(result);
    }
    
    @isTest
    private static void getrelatedFileByParentId() {
        Sales_Agreement__c SA = [SELECT id FROM Sales_Agreement__c];
        ContentVersion cv = FileUploadServiceImpl.saveFileToRecordCompressedFile(SA.id, 'test', 'test', 'prefix');
        list<ContentVersion> cvs = FileUploadServiceImpl.getrelatedFileByParentId(SA.id);
        system.assertEquals(2, cvs.size());
    }
    
    @isTest
    private static void getFileBySalesAgreementAndType() {
        Sales_Agreement__c SA = [SELECT id FROM Sales_Agreement__c];
        ContentVersion cv = FileUploadServiceImpl.getFileBySalesAgreementAndType(SA.id, 'delete');
        system.assertEquals('content to delete', cv.Title);
    }
}
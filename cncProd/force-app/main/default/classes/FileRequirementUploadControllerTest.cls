@isTest
private class FileRequirementUploadControllerTest {

    @TestSetup
    static void setUp() {
        Account acc = Test_DataFactory.createAccount(true, 'test');
        Test_DataFactory.createFileAttachment(acc.Id);
    }

    @isTest
    static void Test_getAllFilesPerRequirements() {
        FileRequirementUploadController.getAllFilesPerRequirements([Select Id From Account].Id);
    }

    @isTest
    static void Test_getConditionalFilesPerRequirements() {
        FileRequirementUploadController.getConditionalFilesPerRequirements([Select Id From Account].Id);
    }

    @isTest
    static void Test_renameAndTagFile() {
        Map<String, Object> fileReq = new Map<String, Object>{'Naming_Convention__c' => '{!Name}_Document'};
        
        FileRequirementUploadController.renameAndTagFile(
            [Select Id From ContentDocument].Id,
            [Select Id, Name From Account].Id,
			fileReq
        );
    }

    @isTest
    static void Test_getFileAfterUpload() {
        FileRequirementUploadController.getFileAfterUpload([Select Id From ContentDocument].Id);
    }   

    @isTest
    static void Test_deleteFile() {
        FileRequirementUploadController.deleteFile([Select Id From ContentDocument].Id);
    }

    @isTest
    static void Test_getAllFilesRequirementDetails() {
        FileRequirementUploadController.getAllFilesRequirementDetails([Select Id From Account].Id);
    }

    @isTest
    static void Test_getConditionalFilesRequirementDetails() {
        FileRequirementUploadController.getConditionalFilesRequirementDetails([Select Id From Account].Id);
    }


    @isTest
    static void testLog() {
        // Create Model
        Model__c model = Test_DataFactory.createmodelId(true, 'MB A Class Test', 'CCI', 'MBP');
        // Create Variant
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
        MB_Sales_Agreement__c mbSA = new MB_Sales_Agreement__c();
        mbSA.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA.DocStatusCoverNote__c = false;
        insert mbSA;
        
		FileRequirementUploadController.log(new Map<String, String>{'recordId' => mbSA.Id
            														, 'reUpdateMBSA' => 'true'
            														, 'checkboxField' => 'DocStatusRAPurchaseAgreement__c'
            														});
    }
}
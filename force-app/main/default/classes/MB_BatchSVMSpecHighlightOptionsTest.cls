@isTest
private class MB_BatchSVMSpecHighlightOptionsTest {
	@testSetup
    static void setUp() {
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
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;
        // Create MB Build Spec
        MB_Build_Spec__c spec1 = new MB_Build_Spec__c(Model__c = model.Id,
                                                    Variant__c = variant.Id,
                                                    Option_Code__c = '294',
                                                    Highlight_Option__c = true,
                                                    Description__c = '294 Spec',
                                                    MB_Build_Spec_ID__c = 'MB A17708422-SG2294');
        insert spec1;
        MB_Build_Spec__c spec2 = new MB_Build_Spec__c(Model__c = model.Id,
                                                    Variant__c = variant.Id,
                                                    Option_Code__c = '999',
                                                    Highlight_Option__c = false,
                                                    MB_Build_Spec_ID__c = 'MB A17708422-SG2999');
        insert spec2;
        // Create MB SVM Spec
        MB_SVM_Spec__c svmSpec = new MB_SVM_Spec__c(Product__c = '999',
                                                    MB_Stock_Vehicle_Master__c = mbSVM.Id,
                                                    Description__c = '999 Spec',
                                                    Build_Spec_Comparison__c = 'MB A17708422-SG2999');
        insert svmSpec;

        MB_SVM_Spec__c svmSpec2 = new MB_SVM_Spec__c(Product__c = '294',
                                                    MB_Stock_Vehicle_Master__c = mbSVM.Id,
                                                    Description__c = '294 Spec',
                                                    Build_Spec_Comparison__c = 'MB A17708422-SG2999');
        insert svmSpec2;
    }

    @isTest()
    static void test() {
        Test.startTest();
        MB_BatchSVMSpecHighlightOptions b = new MB_BatchSVMSpecHighlightOptions();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();
    }
}
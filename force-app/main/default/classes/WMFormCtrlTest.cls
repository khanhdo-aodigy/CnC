@isTest
private class WMFormCtrlTest {
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
                                           Active__c = true);
        insert variant;
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;
        MB_Sales_Agreement__c mbSA = new MB_Sales_Agreement__c();
        mbSA.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        insert mbSA;
    }

	@isTest
    static void Test_getForms() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        Test.startTest();
        List<WM_Form__mdt> wmFormMdts = WMFormCtrl.getForms(mbSA.Id);
        system.assert(wmFormMdts.size() > 0);
        Test.stopTest();
    }

    @isTest
    static void Test_generateForm() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        Test.startTest();
        Boolean mergeSuccess = WMFormCtrl.generateForm(mbSA.Id, '');
        system.assertEquals(true, mergeSuccess);
        Test.stopTest();
    }

}
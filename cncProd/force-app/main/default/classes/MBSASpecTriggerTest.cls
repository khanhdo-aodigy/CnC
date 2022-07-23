@isTest
private with sharing class MBSASpecTriggerTest {
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
        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA = new MB_Sales_Agreement__c();
        mbSA.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA.Status__c = 'Draft';
        mbSA.Registration_Type__c = 'P';
        mbSA.Customer_Full_Name__c = 'Thieu Dang Vu';
        mbSA.CNRIC_Number__c = 'S7340886E';
        mbSA.CEmail_Address__c = 'test@abc.com';
        // mbSA.Account__c = acc.Id;
        mbSA.Booking_Date__c = Date.today();
        mbSA.Validity_Date__c = Date.today().addDays(3);
        mbSA.Sales_Agreement_Version__c = 2;
        insert mbSA;
    }

    @isTest
    static void Test_afterInsert() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Newly_Added_SA_Spec__c, Removed_SA_Spec__c FROM MB_Sales_Agreement__c];
        MB_SA_Spec__c spec = new MB_SA_Spec__c(Description__c = 'Spec 1',
                                               Invoice_value__c = 1234,
                                               PRINT__c = 'Y',
                                               Fit_Type__c = 'O',
                                               MB_Sales_Agreement__c = mbSA.Id,
                                               Product_Code__c = '1');
        insert spec;
        mbSA = [SELECT ID, Newly_Added_SA_Spec__c, Removed_SA_Spec__c FROM MB_Sales_Agreement__c];
        System.assertNotEquals(null, mbSA.Newly_Added_SA_Spec__c);
        System.assertEquals(true, mbSA.Newly_Added_SA_Spec__c.contains('Spec 1'));
    }

    @isTest
    static void Test_afterInsert_Delete_and_Insert_Spec() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Newly_Added_SA_Spec__c, Removed_SA_Spec__c FROM MB_Sales_Agreement__c];
        mbSA.Removed_SA_Spec__c = '(1) Spec 1';
        update mbSA;
        MB_SA_Spec__c spec = new MB_SA_Spec__c(Description__c = 'Spec 1',
                                               Invoice_value__c = 1234,
                                               PRINT__c = 'Y',
                                               Fit_Type__c = 'O',
                                               MB_Sales_Agreement__c = mbSA.Id,
                                               Product_Code__c = '1');
        insert spec;
        MB_SA_Spec__c spec2 = new MB_SA_Spec__c(Description__c = 'Spec 2',
                                               Invoice_value__c = 1234,
                                               PRINT__c = 'Y',
                                               Fit_Type__c = 'O',
                                               MB_Sales_Agreement__c = mbSA.Id,
                                               Product_Code__c = '2');
        insert spec2;
        mbSA = [SELECT ID, Newly_Added_SA_Spec__c, Removed_SA_Spec__c FROM MB_Sales_Agreement__c];
        System.assertNotEquals(null, mbSA.Newly_Added_SA_Spec__c);
        System.assertNotEquals(true, mbSA.Newly_Added_SA_Spec__c.contains('Spec 1'));
        System.assertEquals(true, mbSA.Newly_Added_SA_Spec__c.contains('Spec 2'));
    }

    @isTest
    static void Test_afterDelete() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Newly_Added_SA_Spec__c, Removed_SA_Spec__c FROM MB_Sales_Agreement__c];
        TriggerExclusion.excludeTrigger('MB_SA_Spec__c', true);
        MB_SA_Spec__c spec = new MB_SA_Spec__c(Description__c = 'Spec 1',
                                               Invoice_value__c = 1234,
                                               PRINT__c = 'Y',
                                               Fit_Type__c = 'O',
                                               MB_Sales_Agreement__c = mbSA.Id,
                                               Product_Code__c = '1');
        insert spec;
        Test.startTest();
        TriggerExclusion.excludeTrigger('MB_SA_Spec__c', false);
        spec = [SELECT ID FROM MB_SA_Spec__c WHERE MB_Sales_Agreement__c = :mbSA.Id AND Product_Code__c = '1'];
        delete spec;
        Test.stopTest();
        mbSA = [SELECT ID, Newly_Added_SA_Spec__c, Removed_SA_Spec__c FROM MB_Sales_Agreement__c];
        System.assertNotEquals(null, mbSA.Removed_SA_Spec__c);
        System.assertEquals(true, mbSA.Removed_SA_Spec__c.contains('Spec 1'));
    }

    @isTest
    static void Test_afterUpdate_SVC() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Newly_Added_SA_Spec__c, Removed_SA_Spec__c FROM MB_Sales_Agreement__c];
        TriggerExclusion.excludeTrigger('MB_SA_Spec__c', true);
        MB_SA_Spec__c spec = new MB_SA_Spec__c(Description__c = '$1234 Service Credit',
                                               Invoice_value__c = 1234,
                                               PRINT__c = 'Y',
                                               Fit_Type__c = 'O',
                                               MB_Sales_Agreement__c = mbSA.Id,
                                               Product_Code__c = 'SVC1234');
        insert spec;
        TriggerExclusion.excludeTrigger('MB_SA_Spec__c', false);
        spec = [SELECT ID, Invoice_value__c, Description__c, Product_Code__c FROM MB_SA_Spec__c WHERE MB_Sales_Agreement__c = :mbSA.Id AND Product_Code__c = 'SVC1234'];
        spec.Invoice_value__c = 100;
        spec.Product_Code__c = 'SVC100';
        spec.Description__c = '$100 Service Credit';
        update spec;
        mbSA = [SELECT ID, Newly_Added_SA_Spec__c, Removed_SA_Spec__c FROM MB_Sales_Agreement__c WHERE Id = :mbSA.Id];
        System.assertEquals(true, mbSA.Newly_Added_SA_Spec__c.contains('SVC100'));
        System.assertEquals(true, mbSA.Removed_SA_Spec__c.contains('SVC1234'));
    }

    @isTest
    static void Test_bypassTrigger() {
        TriggerExclusion.excludeTrigger('MB_SA_Spec__c', true);
        MB_Sales_Agreement__c mbSA = [SELECT ID, Newly_Added_SA_Spec__c, Removed_SA_Spec__c FROM MB_Sales_Agreement__c];
        MB_SA_Spec__c spec = new MB_SA_Spec__c(Description__c = 'Spec 5',
                                               Invoice_value__c = 1234,
                                               PRINT__c = 'Y',
                                               Fit_Type__c = 'O',
                                               MB_Sales_Agreement__c = mbSA.Id,
                                               Product_Code__c = '' + 5 + '');
        insert spec;
    }
}
@isTest
private class MB_BatchPromoAutomationTest {
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
        // Create Indent Variant
        Variant__c indentVariant = new Variant__c(Name = 'MB A 200 Indent',
                                                   Model_ID__c = model.Id,
                                                   Franchise__c = 'MBP',
                                                   Branch__c = 'CCI',
                                                   Allow_Indent__c = true,
                                                   Description__c = 'MB A 200 Indent',
                                                   Active__c = true);
        insert indentVariant;
        
        // Create Promo
        List<MB_Promotion__c> promotions = new List<MB_Promotion__c>();
        MB_Promotion__c promo = new MB_Promotion__c(Name = 'Sample Promo',
                                                  Start_Date__c = Date.newInstance(2020, 11, 11),
                                                  End_Date__c = Date.newInstance(2022, 11, 30),
                                                  Flag__c = 'Return to Pool',
                                                  Description__c = 'Test Promo');
        // insert promo;
        promotions.add(promo);
        MB_Promotion__c promo2 = new MB_Promotion__c(Name = 'Sample Promo2',
                                                  Start_Date__c = Date.newInstance(2020, 11, 11),
                                                  End_Date__c = Date.newInstance(2022, 11, 30),
                                                  Flag__c = 'Return to Pool',
                                                  Description__c = 'Test Promo');
        // insert promo;
        promotions.add(promo2);
        insert promotions;
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;
        
        // Create MB Promo Stock
        List<MB_Promotion_Stock__c> promoStocks = new List<MB_Promotion_Stock__c>();
        MB_Promotion_Stock__c promoStock = new MB_Promotion_Stock__c(MB_Promotion__c = promo.Id,
                                                                     MB_Stock_Vehicle_Master__c = mbSVM.Id);
        // insert promoStock;
        promoStocks.add(promoStock);
        MB_Promotion_Stock__c promoStock2 = new MB_Promotion_Stock__c(MB_Promotion__c = promo2.Id,
                                                                     MB_Stock_Vehicle_Master__c = mbSVM.Id);
        promoStocks.add(promoStock2);
        insert promoStocks;
        // Create MB Build Spec
        MB_Build_Spec__c spec1 = new MB_Build_Spec__c(Model__c = model.Id,
                                                    Variant__c = variant.Id,
                                                    Option_Code__c = '294',
                                                    Highlight_Option__c = false);
        insert spec1;
        MB_Build_Spec__c spec2 = new MB_Build_Spec__c(Model__c = model.Id,
                                                    Variant__c = variant.Id,
                                                    Option_Code__c = '999',
                                                    Highlight_Option__c = true);
        insert spec2;
        // Create MB SVM Spec
        MB_SVM_Spec__c svmSpec = new MB_SVM_Spec__c(Product__c = '999',
                                                   MB_Stock_Vehicle_Master__c = mbSVM.Id);
        insert svmSpec;
        // Create Business Account
        Id BUSINESS_ACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
        Account ba = new Account(RecordTypeId = BUSINESS_ACCOUNT,
                                Name = 'ABC Corp',
                                ARCA_Number__c = 'ARCA9999',
                                Type = 'Prospect');
        insert ba;
        // Create Business Contact
        Contact bc = new Contact(Full_Name__c = 'Business Contact Test',
                                NRIC_Passport_No__c = 'BC12345',
                                NRIC__c = 'BC12345',
                                Email = 'bc@test.com',
                                FirstName = 'Business Contact',
                                LastName = 'Test');
        insert bc;
        // Create Person Account
        Account acc = Test_DataFactory.createPerson(false, 'Person Account Test', 'Customer');
        acc.NRIC_Passport_No__pc = 'PA12345';
        acc.NRIC__pc = 'PA12345';
        acc.PersonMobilePhone = '651234567';
        acc.PersonEmail = 'pa@test.com';
        if (acc != null) {
            TriggerExclusion.excludeTrigger( 'Account' , true );
            insert acc;
        }
    }

    @isTest
    static void Test_Promo_Active() {
        Test.startTest();
        MB_BatchPromoAutomation b = new MB_BatchPromoAutomation();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();
    }

    @isTest
    static void Test_Promo_Inactive() {
        List<MB_Promotion__c> tmpPromos = new List<MB_Promotion__c>();
        List<MB_Promotion__c> promos = [SELECT ID, Start_Date__c, End_Date__c FROM MB_Promotion__c];
        for (MB_Promotion__c promo : promos) {
            promo.Start_Date__c = Date.newInstance(2022, 10, 10);
            promo.End_Date__c = Date.newInstance(2010, 10, 10);
            tmpPromos.add(promo);
        }
        system.debug('tmp promo:: ' + tmpPromos);
        update tmpPromos;
        Test.startTest();
        MB_BatchPromoAutomation b = new MB_BatchPromoAutomation();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();
    }

    @isTest
    static void Test_Promo_Inactive2() {
        List<MB_Promotion__c> tmpPromos = new List<MB_Promotion__c>();
        List<MB_Promotion__c> promos = [SELECT ID, Start_Date__c, End_Date__c FROM MB_Promotion__c];
        for (MB_Promotion__c promo : promos) {
            promo.Start_Date__c = Date.newInstance(2022, 10, 10);
            promo.End_Date__c = Date.newInstance(2010, 10, 10);
            promo.Flag__c = 'Blocked';
            tmpPromos.add(promo);
        }
        system.debug('tmp promo:: ' + tmpPromos);
        update tmpPromos;
        Test.startTest();
        MB_BatchPromoAutomation b = new MB_BatchPromoAutomation();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();
    }
}
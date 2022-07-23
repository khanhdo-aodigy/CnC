@isTest
private class mbVehicleSpecsCtlTest {
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
        MB_Promotion__c promo = new MB_Promotion__c(Name = 'Sample Promo',
                                                  Start_Date__c = Date.newInstance(2020, 11, 11),
                                                  End_Date__c = Date.newInstance(2022, 11, 30),
                                                  Flag__c = 'Return to Pool',
                                                  Description__c = 'Test Promo');
        insert promo;
        // Create MB Stock Vehicle Master
        MB_Stock_Vehicle_Master__c mbSVM = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '1',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant.Id,
                                                                         Colour__c = '787 Mountain Grey',
                                                                         Trim__C = '101 ARTICO Black');
        insert mbSVM;
        // Create MB Promo Stock
        MB_Promotion_Stock__c promoStock = new MB_Promotion_Stock__c(MB_Promotion__c = promo.Id,
                                                                     MB_Stock_Vehicle_Master__c = mbSVM.Id);
        insert promoStock;
        // Create MB Build Spec
        MB_Build_Spec__c spec1 = new MB_Build_Spec__c(Model__c = model.Id,
                                                    Variant__c = variant.Id,
                                                    Option_Code__c = '294',
                                                    Highlight_Option__c = false,
                                                    AVCODE__c = 'O',
                                                    Option_Type__c = 'D',
                                                    Description__c = 'Spec test');
        insert spec1;
        MB_Build_Spec__c spec2 = new MB_Build_Spec__c(Model__c = model.Id,
                                                    Variant__c = variant.Id,
                                                    Option_Code__c = '999',
                                                    Highlight_Option__c = true,
                                                    AVCODE__c = 'S',
                                                    Option_Type__c = 'F',
                                                    Description__c = 'Spec test');
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
        if(acc != null){
            TriggerExclusion.excludeTrigger( 'Account' , true );
            insert acc;
        }
        // Create MB Sales Agreement
        MB_Sales_Agreement__c mbSA = new MB_Sales_Agreement__c();
        mbSA.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA.Status__c = 'Draft';
        mbSA.Registration_Type__c = 'P';
        mbSA.Customer_Full_Name__c = 'Thieu Dang Vu';
        mbSA.CNRIC_Number__c = 'S7340886E';
        mbSA.CEmail_Address__c = 'test@abc.com';
        mbSA.Account__c = acc.Id;
        mbSA.Booking_Date__c = Date.today();
        // mbSA.Validity_Date__c = Date.today().addDays(3);
    	mbSA.Used_Car_Registration_Number__c = 'SGD3888G';
        mbSA.Used_Car_Registration_Date__c = Date.today();
        mbSA.Used_Car_Registered_Name__c = 'Seller Test';
        mbSA.Used_Car_Asset_Type__c = 'Non-Company Asset';
        mbSA.Used_Car_GST_Type__c = 'Non-GST Registered';
        mbSA.Used_Car_Make__c = 'Honda';
        mbSA.Used_Car_Model__c = 'Civic';
        mbSA.Seller_is_Not_Buyer__c = true;
        mbSA.Relationship_to_Buyer__c = 'Family';
        mbSA.Seller_NRIC__c = 'S6938264I';
        mbSA.Seller_Email__c = 'seller@test.com';
        mbSA.Trade_In_Value__c = 45678;
        mbSA.Used_Car_Finance_Company__c = 'AUO';
        mbSA.HP_Loan_Due_Date__c = Date.today();
        mbSA.HP_Loan_Outstanding_Amount__c = 45000;
        mbSA.Partial_Payment_for_New_Vehicle__c = 68000;
        mbSA.Validity_Date__c = Date.today().addDays(3);
        mbSA.Sales_Agreement_Version__c = 1;
        mbSA.Total_Optional_Equipment__c = 0;
        insert mbSA;
        // Create MB SA Specs;
        List<MB_SA_Spec__c> specs = new List<MB_SA_Spec__c>();
        for (Integer i = 0; i < 5; i++) {
            MB_SA_Spec__c spec = new MB_SA_Spec__c(Description__c = 'Spec ' + i,
                                                   Invoice_value__c = 1234,
                                                   PRINT__c = 'Y',
                                                   Fit_Type__c = 'O',
                                                   MB_Sales_Agreement__c = mbSA.Id,
                                                   Product_Code__c = '' + i + '');
            specs.add(spec);
        }
        MB_SA_Spec__c svcSpec = new MB_SA_Spec__c(Description__c = '$2500 SvcCredit-5yrsFromRegDate(Non-Transferable)' ,
                                               Invoice_value__c = 2500,
                                               PRINT__c = 'Y',
                                               Fit_Type__c = 'O',
                                               MB_Sales_Agreement__c = mbSA.Id,
                                               Product_Code__c = 'SVC2500');
        specs.add(svcSpec);
        insert specs;
        system.debug('spec' + specs);

        // create signing group for the sales agreement
        /*Signing_Group__c testSigningGroup = new Signing_Group__c(Name = 'Test',
                                                                 Endorse_Group_ID__c = '123456',
                                                                 Endorse_Group_Name__c = 'Test',
                                                                 Approve_Group_ID__c = '123457',
                                                                 Approve_Group_Name__c = 'Test',
                                                                 Unique_Identifier__c = 'MB_Team_A');
        insert testSigningGroup;

        // create approver user for testing
        User testUser = Test_DataFactory.createUser(true, 'Test DocuSign Callout', 'Test');
        DocuSign_Recipient__c testSigningUser = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Approver', User__c = testUser.ID);
        insert testSigningUser;*/
    }
 
    @isTest
    static void Test_getSpecData() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        Test.startTest();
        mbVehicleSpecsCtl.SpecData specs = mbVehicleSpecsCtl.getSpecData(mbSA.Id);
		system.assertNotEquals(null, specs.SA);
        system.assertEquals(6, specs.specs.size());
        Test.stopTest();
    }

    @isTest
    static void Test_doGetAvailableSpecs() {
        Model__c model = [SELECT ID FROM Model__c][0];
        Variant__c variant = [SELECT ID FROM Variant__c][0];
        //String keyword = 'Spec test';
        Test.startTest();
        List<sObject> specs = mbVehicleSpecsCtl.doGetAvailableSpecs(variant.Id, model.Id, '');
        system.assertEquals(2, specs.size());
        Test.stopTest();
    }

    @isTest
    static void Test_deleteSpec() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        List<MB_SA_Spec__c> specs = [SELECT ID, MB_Sales_Agreement__c FROM MB_SA_Spec__c WHERE MB_Sales_Agreement__c =: mbSA.Id];
        Test.startTest();
        mbVehicleSpecsCtl.deleteSpec(mbSA.Id, specs[0].Id);
        Test.stopTest();
    }

    @isTest
    static void Test_updateTOEV() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        Test.startTest();
        mbVehicleSpecsCtl.updateTOEV(mbSA.Id);
        Test.stopTest();
    }
}
@isTest
private class termsAndConditionsCtlTest {
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
        insert mbSA;
    }

    @isTest
    static void Test_doGetInformation() {
        MB_Sales_Agreement__c mbSA = [SELECT ID FROM MB_Sales_Agreement__c];
        Test.startTest();
        termsAndConditionsCtl.ResponseWrapper wrapper = termsAndConditionsCtl.doGetInformation(mbSA.Id, 'MB Consent Clause', 'Term_and_Condition__mdt', 'Identifier__c');
        System.assertNotEquals(null, wrapper);
        Test.stopTest();
    }

    @isTest
    static void Test_updateInformation() {
        MB_Sales_Agreement__c mbSA = [SELECT ID FROM MB_Sales_Agreement__c];
        Test.startTest();
        String result = termsAndConditionsCtl.updateInformation('MB_Sales_Agreement__c', 'AcknowledgementConsentClause__c', 'true', mbSA.Id);
        System.assertEquals('updated', result);
        Test.stopTest();
    }
}
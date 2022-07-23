@isTest
private class MB_StockReservationCtrlTest {
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
        Variant__c variant2 = new Variant__c(Name = 'MB A 350 Test',
                                           Model_ID__c = model.Id,
                                           Franchise__c = 'MBP',
                                           Branch__c = 'CCI',
                                           Allow_Indent__c = false,
                                           Description__c = 'MB A 350 Test',
                                           DWH_Variant_ID__c = 'CCI,MBP,17708423-SG2',
                                           Active__c = true);
        insert variant2;
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
                                                                         Trim__C = '101 ARTICO Black',
                                                                         Estimated_Delivery_Date__c = '01/02',
                                                                         VariantDescription__c = 'MB A 250 Test');
        insert mbSVM;
        MB_Stock_Vehicle_Master__c mbSVM2 = new MB_Stock_Vehicle_Master__c(Vehicle_ID__c = '2',
                                                                         Status__c = 'Open',
                                                                         Variant__c = variant2.Id,
                                                                         Colour__c = '246 Mountain Grey',
                                                                         Trim__C = '153 ARTICO Black',
                                                                         Estimated_Delivery_Date__c = '02/03',
                                                                         VariantDescription__c = 'MB A 350 Test');
        insert mbSVM2;
        // Create MB Promo Stock
        MB_Promotion_Stock__c promoStock = new MB_Promotion_Stock__c(MB_Promotion__c = promo.Id,
                                                                     MB_Stock_Vehicle_Master__c = mbSVM.Id);
        insert promoStock;
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
        MB_Build_Spec__c spec3 = new MB_Build_Spec__c(Model__c = model.Id,
                                                    Variant__c = variant.Id,
                                                    Option_Code__c = '000',
                                                    Highlight_Option__c = false,
                                                    Option_Group__c = 'DEFAULT');
        insert spec3;
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
    static void getRecords_Test() {
        Variant__c variant = [SELECT ID, DWH_Variant_ID__c FROM Variant__c WHERE DWH_Variant_ID__c = 'CCI,MBP,17708422-SG2'];
        Test.startTest();
        List<MB_Stock_Vehicle_Master__c> mbSVMs = MB_StockReservationCtrl.getRecords('MB_Stock_Vehicle_Master__c', 'Variant__c', variant.Id, 'AND Status__c = \'Open\'');
        System.assertEquals(1, mbSVMs.size());
        Test.stopTest();
    }

    @isTest
    static void getAvailableTrimColour_Test() {
        Variant__c variant = [SELECT ID, Description__c, DWH_Variant_ID__c FROM Variant__c WHERE DWH_Variant_ID__c = 'CCI,MBP,17708422-SG2'];
        Test.startTest();
        MB_StockReservationCtrl.TrimColourWrapper wrapper = new MB_StockReservationCtrl.TrimColourWrapper();
        wrapper = MB_StockReservationCtrl.getAvailableTrimColour(variant.Description__c);
        system.debug('WRAPPER:: ' + wrapper);
        System.assertEquals(1, wrapper.colours.size());
        System.assertEquals(1, wrapper.trims.size());
        Test.stopTest();
    }

    @isTest
    static void getAvailableHighlightOptions_Test() {
        // Variant__c variant = [SELECT ID, Description__c, DWH_Variant_ID__c FROM Variant__c WHERE DWH_Variant_ID__c = 'CCI,MBP,17708422-SG2'];
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID, Variant__c FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        Test.startTest();
        List<MB_Build_Spec__c> specs = MB_StockReservationCtrl.getAvailableHighlightOptions(mbSVM.Variant__c);
        System.assertEquals(1, specs.size());
        Test.stopTest();
    }

    @isTest
    static void checkIndentable_Test() {
        Variant__c variant = [SELECT ID FROM Variant__c][0];
        Test.startTest();
        Boolean isIndent = MB_StockReservationCtrl.checkIndentable(variant.Id);
        System.assertEquals(false, isIndent);
        Test.stopTest();
    }

    @isTest
    static void getStock_Test() {
        Variant__c variant = [SELECT ID, Description__c, DWH_Variant_ID__c FROM Variant__c WHERE DWH_Variant_ID__c = 'CCI,MBP,17708422-SG2'];
        List<String> colours = new List<String>{'787'};
        List<String> trims = new List<String>{'101'};
        List<MB_Build_Spec__c> hlos = [SELECT ID FROM MB_Build_Spec__c WHERE Highlight_Option__c = true];
        List<String> HLO = new List<String>{hlos[0].Id};
        MB_Promotion__c promo = [SELECT ID FROM MB_Promotion__c];
        String promoId = promo.Id;
        String edd = '01';
        Test.startTest();
        List<MB_Stock_Vehicle_Master__c> mbSVMs = MB_StockReservationCtrl.getStock(variant.Description__c, colours, trims, HLO, promoId, edd);
        System.assertEquals(1, mbSVMs.size());
        Test.stopTest();
    }

    @isTest
    static void getStock_Test_Promo_Null() {
        Variant__c variant = [SELECT ID, Description__c, DWH_Variant_ID__c FROM Variant__c WHERE DWH_Variant_ID__c = 'CCI,MBP,17708422-SG2'];
        List<String> colours = new List<String>{'787'};
        List<String> trims = new List<String>{'101'};
        List<MB_Build_Spec__c> hlos = [SELECT ID FROM MB_Build_Spec__c WHERE Highlight_Option__c = true];
        List<String> HLO = new List<String>{hlos[0].Id};
        Test.startTest();
        List<MB_Stock_Vehicle_Master__c> mbSVMs = MB_StockReservationCtrl.getStock(variant.Description__c, colours, trims, HLO, null, null);
        System.assertEquals(1, mbSVMs.size());
        Test.stopTest();
    }

    @isTest
    static void getStock_Test_EDD_Null() {
		Variant__c variant = [SELECT ID, Description__c, DWH_Variant_ID__c FROM Variant__c WHERE DWH_Variant_ID__c = 'CCI,MBP,17708422-SG2'];
        List<String> colours = new List<String>{'787'};
        List<String> trims = new List<String>{'101'};
        List<MB_Build_Spec__c> hlos = [SELECT ID FROM MB_Build_Spec__c WHERE Highlight_Option__c = true];
        List<String> HLO = new List<String>{hlos[0].Id};
        Test.startTest();
        List<MB_Stock_Vehicle_Master__c> mbSVMs = MB_StockReservationCtrl.getStock(variant.Description__c, colours, trims, HLO, null, null);
        System.assertEquals(1, mbSVMs.size());
        Test.stopTest();
    }

    @isTest
    static void getVariantDescription_Test() {
        Model__c model = [SELECT ID FROM Model__c];
        Test.startTest();
        List<MB_Stock_Vehicle_Master__c> records = MB_StockReservationCtrl.getVariantDescription(model.Id);
        System.assertEquals(2, records.size());
        Test.stopTest();        
    }

    @isTest
    static void searchBusinessContact_Test() {
        Contact bc = [SELECT Id, MobilePhone, Email FROM Contact WHERE Email = 'bc@test.com'][0];
        // system.debug(bc);
        Test.startTest();
        List<Contact> contacts = MB_StockReservationCtrl.searchBusinessContact(bc.MobilePhone, bc.Email, 'AND isPersonAccount = false', null);
        System.assertEquals(1, contacts.size());
        Test.stopTest();
    }

    @isTest
    static void searchPersonAccount_Test() {
        Account pa = [SELECT Id, PersonMobilePhone, PersonEmail FROM Account WHERE PersonEmail = 'pa@test.com'][0];
        Test.startTest();
        List<Account> accs = MB_StockReservationCtrl.searchPersonAccount(pa.PersonMobilePhone, pa.PersonEmail, 'AND isPersonAccount = true', null);
        System.assertEquals(1, accs.size());
        Test.stopTest();
    }

    @isTest
    static void createSalesAgreement_Test1() {
        // Regis type: Private
        // Regis under Company
        // New BC
        // Existing Stock
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        String c_input = '{"__matchPA":null,"__matchBC":null,"Registration_Type__c":"P","CEmail_Address__c":"b@test.com","CMobile__c":"65987564356",' + 
            			  '"CFirst_Name__c":"Dummy","CSurname__c":"Test","CNRIC_Number__c":"S8492911E","Customer_Full_Name__c":"Test Dummy",' + 
            			  '"Company_Name__c":"ABC Corp","__isRegisterUnderCompany":true,"ARCA_Number__c":"ARCA3245","MB_Stock_Vehicle_Master__c":"' + mbSVM.Id + '"' + '}';
                                 
        Test.startTest();
        Id mbSAId = MB_StockReservationCtrl.createSalesAgreement(c_input, '{}');
        System.assertNotEquals(null, mbSAId);
        Test.stopTest();
    }
    @isTest
    static void createSalesAgreement_Test2() {
        // Regis type: Private
        // Regis under Company
        // Existing BC
		// Existing Stock
		Contact bc = [SELECT Account__c FROM Contact WHERE Email = 'bc@test.com'];
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        String c_input = '{"__matchPA":null,"__matchBC":"' + bc.Id + '","Registration_Type__c":"P","CEmail_Address__c":"b2@test.com","CMobile__c":"65987564356",' + 
            			  '"CFirst_Name__c":"Dummy","CSurname__c":"Test","CNRIC_Number__c":"S8492911E","Customer_Full_Name__c":"Test Dummy",' + 
            			  '"Company_Name__c":"ABC Corp","__isRegisterUnderCompany":true,"ARCA_Number__c":"ARCA3245","MB_Stock_Vehicle_Master__c":"' + mbSVM.Id + '"' + '}';
        Test.startTest();
        Id mbSAId = MB_StockReservationCtrl.createSalesAgreement(c_input, '{}');
        System.assertNotEquals(null, mbSAId);
        Test.stopTest();
    }

    @isTest
    static void createSalesAgreement_Test3() {
        // Regis type: Private
        // Not regis under Company
        // new PA
		// Existing Stock
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
		String c_input = '{"__matchPA":null,"__matchBC":"null","Registration_Type__c":"P","CEmail_Address__c":"pa2@test.com","CMobile__c":"65987564356",' + 
            			  '"CFirst_Name__c":"Dummy","CSurname__c":"Test","CNRIC_Number__c":"S8492911E","Customer_Full_Name__c":"Test Dummy",' + 
            			  '"__isRegisterUnderCompany":false,"MB_Stock_Vehicle_Master__c":"' + mbSVM.Id + '"' + '}';
        Test.startTest();
        Id mbSAId = MB_StockReservationCtrl.createSalesAgreement(c_input, '{}');
        System.assertNotEquals(null, mbSAId);
        Test.stopTest();        
    }

    @isTest
    static void createSalesAgreement_Test4() {
        // Regis type: Private
        // Not regis under Company
        // Existing PA
        // Existing Stock
        Account acc = [SELECT ID FROM Account WHERE isPersonAccount = true][0];
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        String c_input = '{"__matchPA":"' + acc.Id + '","__matchBC":"null","Registration_Type__c":"P","CEmail_Address__c":"pa3@test.com","CMobile__c":"65987564356",' + 
            			  '"CFirst_Name__c":"Dummy","CSurname__c":"Test","CNRIC_Number__c":"S8492911E","Customer_Full_Name__c":"Test Dummy",' + 
            			  '"__isRegisterUnderCompany":false,"MB_Stock_Vehicle_Master__c":"' + mbSVM.Id + '"' + '}';
        Test.startTest();
        Id mbSAId = MB_StockReservationCtrl.createSalesAgreement(c_input, '{}');
        System.assertNotEquals(null, mbSAId);
        Test.stopTest();
    }

    @isTest
    static void createSalesAgreement_Test5() {
        // Regis type: Company
        // New BC
        // Existing Stock
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
		String c_input = '{"__matchPA":null,"__matchBC":null,"Registration_Type__c":"C","CEmail_Address__c":"bc2@test.com","CMobile__c":"65987564996",' + 
            			  '"CFirst_Name__c":"Dummy","CSurname__c":"Test","CNRIC_Number__c":"S8499999E","Customer_Full_Name__c":"Test Dummy",' + 
            			  '"Company_Name__c":"ABC Corp","ARCA_Number__c":"ARCA5432","MB_Stock_Vehicle_Master__c":"' + mbSVM.Id + '"' + '}';
        Test.startTest();
        Id mbSAId = MB_StockReservationCtrl.createSalesAgreement(c_input, '{}');
        System.assertNotEquals(null, mbSAId);
        Test.stopTest();  
    }

    @isTest
    static void createSalesAgreement_Test6() {
        // Regis type: Company
        // Existing BC
        // Indent Stock
        Model__c model = [SELECT ID FROM Model__c][0];
        Variant__c variant = [SELECT ID FROM Variant__c where Allow_Indent__c = true][0];
        Contact bc = [SELECT Account__c FROM Contact WHERE Email = 'bc@test.com'];
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        String i_input = '{"Model__c":"' + model.Id + '","Variant__c":"' + variant.Id + '","Colour__c":"988","Trim__c":"444"}';
        String c_input = '{"__matchPA":null,"__matchBC":"' + bc.Id + '","Registration_Type__c":"C","CEmail_Address__c":"b3@test.com","CMobile__c":"65987564356",' + 
            			  '"CFirst_Name__c":"Dummy","CSurname__c":"Test","CNRIC_Number__c":"S8492911E","Customer_Full_Name__c":"Test Dummy",' + 
            			  '"Company_Name__c":"ABC Corp","__isRegisterUnderCompany":true,"ARCA_Number__c":"ARCA3245","MB_Stock_Vehicle_Master__c":"' + mbSVM.Id + '"' + '}';
        Test.startTest();
        Id mbSAId = MB_StockReservationCtrl.createSalesAgreement(c_input, i_input);
        System.assertNotEquals(null, mbSAId);
        Test.stopTest(); 
    }

    @isTest
    static void createSalesAgreement_Test_UnavailableStock() {
        // Regis type: Private
        // Not regis under Company
        // new PA
		// Existing Stock
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID, Status__c FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        mbSVM.Status__c = 'Reserved';
        update mbSVM;
		String c_input = '{"__matchPA":null,"__matchBC":"null","Registration_Type__c":"P","CEmail_Address__c":"pa@test.com","CMobile__c":"65987564356",' + 
            			  '"CFirst_Name__c":"Dummy","CSurname__c":"Test","CNRIC_Number__c":"S8492911E","Customer_Full_Name__c":"Test Dummy",' + 
            			  '"__isRegisterUnderCompany":false,"MB_Stock_Vehicle_Master__c":"' + mbSVM.Id + '"' + '}';
        Test.startTest();
        try {
        	Id mbSAId = MB_StockReservationCtrl.createSalesAgreement(c_input, '{}');
        } catch (Exception e) {
            // DO NOTHING 
       	}
        Test.stopTest();   
    }

    @isTest
    static void createSalesAgreement_Test_UnknownRegisType() {
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID, Status__c FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
		String c_input = '{"__matchPA":null,"__matchBC":"null","Registration_Type__c":"D","CEmail_Address__c":"pa@test.com","CMobile__c":"65987564356",' + 
            			  '"CFirst_Name__c":"Dummy","CSurname__c":"Test","CNRIC_Number__c":"S8492911E","Customer_Full_Name__c":"Test Dummy",' + 
            			  '"__isRegisterUnderCompany":false,"MB_Stock_Vehicle_Master__c":"' + mbSVM.Id + '"' + '}';
        Test.startTest();
        try {
        	Id mbSAId = MB_StockReservationCtrl.createSalesAgreement(c_input, '{}');
        } catch (Exception e) {
            // DO NOTHING 
       	}
        Test.stopTest();   
    }

    @isTest
    static void checkIndentable_Test_FoundNoVariant() {
        List<Variant__c> variants = [SELECT ID FROM Variant__c];
        delete variants;
        Test.startTest();
        try {
            Boolean isIndent = MB_StockReservationCtrl.checkIndentable(variants[0].Id);
        } catch (Exception e) {
            // DO NOTHING
        }
        Test.stopTest();
    }
    
	@isTest
    static void getPromotion_Test() {
        List<MB_Promotion__c> promotions = MB_StockReservationCtrl.getPromotion();
        System.assertEquals(1, promotions.size());        
    }

    @isTest
    static void processPrevPendingStock_Test() {
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID, Autoline_Sales_Order__c, Autoline_Order_Date__c, Status__c FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        mbSVM.Autoline_Sales_Order__c = '7777';
        mbSVM.Autoline_Order_Date__c = Date.today();
		mbSVM.Status__c = 'Pending';
        update mbSVM;

        MB_Sales_Agreement__c mbSA1 = new MB_Sales_Agreement__c();
        mbSA1.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA1.Status__c = 'Cancelled';
        mbSA1.Status_Autoline__c = 'C';
        insert mbSA1;

        MB_Stock_Vehicle_Master__c mbSVM2 = [SELECT ID FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '2'];
        MB_Sales_Agreement__c mbSA2 = new MB_Sales_Agreement__c();
        mbSA2.MB_Stock_Vehicle_Master__c = mbSVM2.Id;
        mbSA2.Submit_COE_Bidding__c = true;
        mbSA2.Previous_Stock_Number__c = '1';
        insert mbSA2;

        Test.startTest();
        MB_StockReservationCtrl.processPrevPendingStock(mbSA2.Id);
        mbSVM = [SELECT ID, Autoline_Sales_Order__c, Autoline_Order_Date__c, Status__c FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        mbSA1 = [SELECT ID, Status_Autoline__c FROM MB_Sales_Agreement__c WHERE MB_Stock_Vehicle_Master__c = :mbSVM.Id];
        mbSA2 = [SELECT ID, Previous_Stock_Number__c FROM MB_Sales_Agreement__c WHERE MB_Stock_Vehicle_Master__c = :mbSVM2.Id];
        System.assertEquals(null, mbSVM.Autoline_Sales_Order__c);
        System.assertEquals(null, mbSVM.Autoline_Order_Date__c);
        System.assertEquals('Open', mbSVM.Status__c);
        System.assertEquals(null, mbSA1.Status_Autoline__c);
        System.assertEquals(null, mbSA2.Previous_Stock_Number__c);
        Test.stopTest();
    }

    @isTest
    static void getStock_With_SA_Draft_Stage_Test() {
        MB_Stock_Vehicle_Master__c mbSVM = [SELECT ID, Autoline_Sales_Order__c, Autoline_Order_Date__c, Status__c FROM MB_Stock_Vehicle_Master__c WHERE Vehicle_ID__c = '1'];
        MB_Sales_Agreement__c mbSA1 = new MB_Sales_Agreement__c();
        mbSA1.MB_Stock_Vehicle_Master__c = mbSVM.Id;
        mbSA1.Status__c = 'Draft';
        insert mbSA1;

        Variant__c variant = [SELECT ID, Description__c, DWH_Variant_ID__c FROM Variant__c WHERE DWH_Variant_ID__c = 'CCI,MBP,17708422-SG2'];
        List<String> colours = new List<String>{'787'};
        List<String> trims = new List<String>{'101'};
        List<MB_Build_Spec__c> hlos = [SELECT ID FROM MB_Build_Spec__c WHERE Highlight_Option__c = true];
        List<String> HLO = new List<String>{hlos[0].Id};
        MB_Promotion__c promo = [SELECT ID FROM MB_Promotion__c];
        String promoId = promo.Id;
        String edd = '01';
        Test.startTest();
        List<MB_Stock_Vehicle_Master__c> mbSVMs = MB_StockReservationCtrl.getStock(variant.Description__c, colours, trims, HLO, promoId, edd);
        System.assertEquals(0, mbSVMs.size());
        Test.stopTest();
    }
}
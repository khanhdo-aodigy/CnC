@isTest
private class MB_DocusignTest {
	@testSetup
    static void setUp() {
        // Create role
        // UserRole r = new UserRole(DeveloperName = 'Sales_Consultant_A', Name = 'Sales Consultant A');
        // insert r;

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
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            // Create role
            UserRole r = [SELECT ID FROM UserRole WHERE Name = 'Sales Consultant A'];
            // create sc user
            User sc = Test_DataFactory.createUser(false, 'SC Test', 'Test');
            sc.UserRoleId = r.Id;
            insert sc;
            System.runAs(sc) {
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
                mbSA.Sales_Agreement_Version__c = 2;
                mbSA.Newly_Added_SA_Spec__c = 'Spec 1; Spec 2;';
                mbSA.Removed_SA_Spec__c = 'Spec 3; Spec 4;';
                mbSA.Seller_Email__c = 'sellermail@gmail.com';
                mbSA.Seller_NRIC__c = 'SE12344T';
                mbSA.Seller_Registered_Name__c = 'Seller Name';
                mbSA.Deposit_Collected__c = true;
                mbSA.Used_Car_Registration_Date__c = Date.today();
                mbSA.Used_Car_Registration_Number__c = 'SG123456X';
                mbSA.Used_Car_GST_Type__c = 'Non-GST Registered';
                mbSA.Used_Car_Asset_Type__c  = 'Non-Company Asset';
                mbSA.Used_Car_Finance_Company__c = 'TBA';
                mbSA.Used_Car_Make__c = 'Honda';
                mbSA.Used_Car_Model__c = 'Civic';
                mbSA.Used_Car_Engine_Number__c = 'E12345A';
                mbSA.Used_Car_Chassis_Number__c = 'C12345A';
                insert mbSA;
                // Create MB SA Specs;
                List<MB_SA_Spec__c> specs = new List<MB_SA_Spec__c>();
                for (Integer i = 0; i < 5; i++) {
                    MB_SA_Spec__c spec = new MB_SA_Spec__c(Description__c = 'Spec ' + i,
                                                           Invoice_value__c = 123 + i,
                                                           PRINT__c = 'Y',
                                                           Fit_Type__c = 'S');
                    specs.add(spec);
                }
                insert specs;
                // Create document attach to MB SA
                ContentVersion documentContent = new ContentVersion();
                documentContent.Title = 'TEST_' + mbSA.Name + '_TEST';
                documentContent.PathOnClient = '/' + documentContent.Title;
                Blob bodyBlob = Blob.valueOf('Digital Sales Agreement Testing'); 
                documentContent.VersionData = bodyBlob;
                insert documentContent;
        
                // link content to sales agreement
                ContentDocumentLink contentLink = new ContentDocumentLink();
                contentLink.LinkedEntityId = mbSA.Id;
                contentLink.ContentDocumentId  = [SELECT ContentDocumentId FROM ContentVersion WHERE ID =: documentContent.id].ContentDocumentId;       
                contentLink.ShareType = 'V';
                insert contentLink;
            }
            
        }

        // create signing group for the sales agreement
        Signing_Group__c testSigningGroup = new Signing_Group__c(Name = 'Test',
                                                                 Endorse_Group_ID__c = '123456',
                                                                 Endorse_Group_Name__c = 'Test',
                                                                 Approve_Group_ID__c = '123457',
                                                                 Approve_Group_Name__c = 'Test',
                                                                 Unique_Identifier__c = 'MB_Team_A');
        insert testSigningGroup;



        /*UserRole r = [SELECT ID FROM UserRole WHERE Name = 'Sales Consultant A'];
        // create testing userVehi
        User testUser = Test_DataFactory.createUser(false, 'Test DocuSign Callout', 'Test');
        testUser.UserRoleId = r.Id;
        insert testUser;*/
        // create approver user for testing
        User testUser = Test_DataFactory.createUser(true, 'Test DocuSign Callout', 'Test');
        DocuSign_Recipient__c testSigningUser = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Approver', User__c = testUser.ID);
        insert testSigningUser;
    }

    @isTest
    static void Test_updateValidityDate() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Validity_Date__c FROM MB_Sales_Agreement__c];
        Test.startTest();
        MB_DocuSign.updateValidityDate(mbSA.ID);
        Test.stopTest();
    }

    @isTest
    static void Test_signInPlace_DSA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        String signedLink = MB_Docusign.signInPlace(mbSA.Id, 'SA');
        System.assertNotEquals(null, signedLink);
        Test.stopTest();
    }

    @isTest
    static void Test_signInPlace_UCA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name, Seller_is_Not_Buyer__c FROM MB_Sales_Agreement__c];
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        String signedLink = MB_Docusign.signInPlace(mbSA.Id, 'UCA');
        System.assertNotEquals(null, signedLink);
        Test.stopTest();
    }

    @isTest
    static void Test_signViaEmail_DSA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        MB_Docusign.signViaEmail(mbSA.Id, 'SA');
        Test.stopTest();
    }

    @isTest
    static void Test_signViaEmail_UCA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        MB_Docusign.signViaEmail(mbSA.Id, 'UCA');
        Test.stopTest();
    }

    /*@isTest
    static void Test_UCA_Signing_Seller_is_Buyer() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name, Seller_is_Not_Buyer__c FROM MB_Sales_Agreement__c];
        mbSA.Seller_is_Not_Buyer__c = false;
        update mbSA;
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        MB_Docusign.signViaEmail(mbSA.Id, 'UCA');
        Test.stopTest();
    }*/

    @isTest
    static void Test_getPreview_SA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
		Test.startTest();
        String previewURL = MB_Docusign.getPreview(mbSA.Id, 'SA');
        System.assertNotEquals(null, previewURL);
        Test.stopTest();
    }

    @isTest
    static void Test_getPreview_UCA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
		Test.startTest();
        String previewURL = MB_Docusign.getPreview(mbSA.Id, 'UCA');
        System.assertNotEquals(null, previewURL);
        Test.stopTest();
    }

    @isTest
    static void Test_signInPlace_DSA_Company() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name, Registration_Type__c, ARCA_Number__c FROM MB_Sales_Agreement__c];
        mbSA.Registration_Type__c = 'C';
        mbSA.ARCA_Number__c = 'ARCATEST123';
        update mbSA;
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        String signedLink = MB_Docusign.signInPlace(mbSA.Id, 'SA');
        System.assertNotEquals(null, signedLink);
        Test.stopTest();        
    }

    @isTest
    static void Test_signInPlace_DSA_Company_UCA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name, Registration_Type__c, ARCA_Number__c FROM MB_Sales_Agreement__c];
        mbSA.Registration_Type__c = 'C';
        mbSA.ARCA_Number__c = 'ARCATEST123';
        update mbSA;
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        String signedLink = MB_Docusign.signInPlace(mbSA.Id, 'UCA');
        System.assertNotEquals(null, signedLink);
        Test.stopTest();        
    }

    @isTest
    static void Test_UCA_Company_Asset() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Used_Car_Asset_Type__c FROM MB_Sales_Agreement__c];
        mbSA.Used_Car_Asset_Type__c = 'Company Asset';
        mbSA.Seller_Company_ARCA_Number__c = 'SELLERARCA123';
        update mbSA;
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        String signedLink = MB_Docusign.signInPlace(mbSA.Id, 'UCA');
        System.assertNotEquals(null, signedLink);
        Test.stopTest();
    }
 
    @isTest
    static void Test_Team_Identifier_B() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Sales Consultant B');
        System.assertEquals('MB_Team_B', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_Team_Identifier_C() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Sales Consultant C');
        System.assertEquals('MB_Team_C', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_Team_Identifier_D() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Sales Consultant D');
        System.assertEquals('MB_Team_D', identifier);
        Test.stopTest();
    }
 
    @isTest
    static void Test_Team_Identifier_E() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Sales Consultant E');
        System.assertEquals('MB_Team_E', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_Team_Identifier_F() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Sales Consultant F');
        System.assertEquals('MB_Team_F', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_Team_Manager_A() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Team Manager A');
        System.assertEquals('MB_Team_A', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_Team_Manager_B() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Team Manager B');
        System.assertEquals('MB_Team_B', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_Team_Manager_C() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Team Manager C');
        System.assertEquals('MB_Team_C', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_Team_Manager_D() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Team Manager D');
        System.assertEquals('MB_Team_D', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_Team_Manager_E() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Team Manager E');
        System.assertEquals('MB_Team_E', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_Team_Manager_F() {
        Test.startTest();
        String identifier = MB_Docusign.getTeamIdentifier('Team Manager F');
        System.assertEquals('MB_Team_F', identifier);
        Test.stopTest();
    }

    @isTest
    static void Test_getPreview_YF() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
		Test.startTest();
        String previewURL = MB_Docusign.getPreview(mbSA.Id, 'YF');
        System.assertNotEquals(null, previewURL);
        Test.stopTest();
    }

   	@isTest
    static void Test_signInPlace_YF() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        String signedLink = MB_Docusign.signInPlace(mbSA.Id, 'CRF');
        System.assertNotEquals(null, signedLink);
        Test.stopTest();
    }

    @isTest
    static void Test_signViaEmail_YF() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        MB_Docusign.signViaEmail(mbSA.Id, 'CRF');
        Test.stopTest();
    }

    @isTest
    static void Test_getPreview_SAUCA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
		mbSA.Seller_is_Not_Buyer__c = false;
        update mbSA;
		Test.startTest();
        String previewURL = MB_Docusign.getPreview(mbSA.Id, 'SAUCA');
        System.assertNotEquals(null, previewURL);
        Test.stopTest();
    }

    @isTest
    static void Test_signInPlace_SAUCA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        mbSA.Seller_is_Not_Buyer__c = false;
        update mbSA;
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        String signedLink = MB_Docusign.signInPlace(mbSA.Id, 'SAUCA');
        System.assertNotEquals(null, signedLink);
        Test.stopTest();
    }

    @isTest
    static void Test_signViaEmail_SAUCA() {
        MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
        mbSA.Seller_is_Not_Buyer__c = false;
        update mbSA;
        Test.setMock(HttpCalloutMock.class, new MBDocusignMockResponseGenerator());
        Test.startTest();
        MB_Docusign.signViaEmail(mbSA.Id, 'SAUCA');
        Test.stopTest();
    }
    
    @isTest
    static void Test_updateRelatedPA() {
       MB_Sales_Agreement__c mbSA = [SELECT ID, Name FROM MB_Sales_Agreement__c];
       MB_Docusign.updateRelatedPA(mbSA.Id);
    }
}
@isTest
private class EmailNotificationsInvocableTest {
    @testSetup
    static void setUp() {
        // create a sales agreement record for test
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';

        // Create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', Model_Master__c = modelMaster.ID);
        insert modelYearMaster;
        
        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelMaster.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        
        // Create stock reservation from master data
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        insert stockReservation;

        // Create sales agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.ID, customerName);
        
        salesAgreement.emailaddress__c = 'test@aodigy.com';
        salesAgreement.Package_Header__c = pckHeader.Id;
        insert salesAgreement;
        salesAgreement.Branch_Code__c = branchCode;
        update salesAgreement;
    }

	@isTest
    static void Test_COE_Expiry_Email() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c];
        EmailNotificationsInvocable.EmailNotificationsRequest request = new EmailNotificationsInvocable.EmailNotificationsRequest();
        request.recordId = sa.Id;
        request.templateNm = 'COE_Expiry_Email';

        List<EmailNotificationsInvocable.EmailNotificationsRequest> requests = new List<EmailNotificationsInvocable.EmailNotificationsRequest>{request};
		Test.startTest();
        EmailNotificationsInvocable.sendEmailNotifications(requests);
        //Integer invocations = Limits.getEmailInvocations();
        //system.assertEquals(1, invocations, 'Send 1 email');
        Test.stopTest();
    }

    @isTest
    static void Test_Insurance_Approval_Email() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c];
        EmailNotificationsInvocable.EmailNotificationsRequest request = new EmailNotificationsInvocable.EmailNotificationsRequest();
        request.recordId = sa.Id;
        request.templateNm = 'Insurance_Approval_Notification';

        List<EmailNotificationsInvocable.EmailNotificationsRequest> requests = new List<EmailNotificationsInvocable.EmailNotificationsRequest>{request};
        //EmailNotificationsInvocable.sendEmailNotifications(requests);

        Test.startTest();
        EmailNotificationsInvocable.sendEmailNotifications(requests);
        Test.stopTest();
        //Integer invocations = Limits.getEmailInvocations();
        //system.assertEquals(1, Limits.getFutureCalls(), 'Send 1 email');
    }
    
    @isTest
    static void Test_Registration_Email() {
        Sales_Agreement__c sa = [SELECT ID FROM Sales_Agreement__c];
        EmailNotificationsInvocable.EmailNotificationsRequest request = new EmailNotificationsInvocable.EmailNotificationsRequest();
        request.recordId = sa.Id;
        request.templateNm = 'Registration_Email_Notification';

        List<EmailNotificationsInvocable.EmailNotificationsRequest> requests = new List<EmailNotificationsInvocable.EmailNotificationsRequest>{request};
        //EmailNotificationsInvocable.sendEmailNotifications(requests);

        Test.startTest();
        EmailNotificationsInvocable.sendEmailNotifications(requests);
		//Integer invocations = Limits.getEmailInvocations();
        //system.assertEquals(1, invocations, 'Send 1 email');
        Test.stopTest();
    }
}
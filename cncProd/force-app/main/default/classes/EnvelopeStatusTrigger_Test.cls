@isTest
private with sharing class EnvelopeStatusTrigger_Test {
    @TestSetup
    private static void testSetup(){
        // create a sales agreement record for test
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';
        string customerEMail = 'test@123.com';
        string CUSTOMER_SIGN_ORDER = '1';

        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc.Id];
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = personAcc.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt.Contact_Person__c = personAcc.PersonContactId;
        insert oppt;

        //* create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', Model_Master__c = modelMaster.ID);
        insert modelYearMaster;
        
        // Create Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test', ADM_CHRGCD__c = 'R004');
        insert addnlChargeMaster;
        
        // Create Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC', Model_Master__c = modelMaster.Id, PKH_STATUS__c = 'A');
        insert pckHeader;
        
        //* create stock reservation from master data
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation.Package_Header_From_PickList__c = pckHeader.Id;
        stockReservation.Opportunity__c    = oppt.Id;
        insert stockReservation;

        //* sales agreement
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, branchCode, agreementNo, stockReservation.ID, customerName);
        
        //salesAgreement.emailaddress__c = 'test@aodigy.com';
        salesAgreement.Package_Header__c = pckHeader.Id;
        salesAgreement.DocuSign_Envelope_ID__c = 'DSA';
        salesAgreement.UCA_Docusign_Envelope_ID__c = 'UCA';
        //insert salesAgreement;
        //salesAgreement.Branch_Code__c = branchCode;
        insert salesAgreement;

        // Below is setup test data for MB SA
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
        mbSA.Latest_Docusign_Envelope__c = 'MBDSA';
        mbSA.Latest_UCA_Docusign_Envelope__c = 'MBUCA';
        mbSA.Latest_YF_Docusign_Envelope__c = 'MBYF';
        mbSA.Latest_SA_UCA_Docusign_Envelope__c = 'MBSAUCA';
        insert mbSA;
    }

    /**
     -- Test create 1 DSA envelope
     -- Expected: new envelope link to related SA & SA's approval status change to 'Not Approved'
     */
    @isTest
    private static void DSA_CreateEnvelope() {

        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'DSA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, SalesAgreement__c FROM dsfs__DocuSign_Status__c];
        Sales_Agreement__c sa = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals(sa.ID, envelope.SalesAgreement__c); // link to related SA
        system.assertEquals('Not Approved', sa.ApprovalStatus__c); // update the approval status
    }

    /**
     -- Test envelope is in signing process, status changed but still not complete
     -- Expected: the SA's status remain 'Not Approved'
     */
    @isTest
    private static void DSA_PendingEnvelope() {
        Sales_Agreement__c sa = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals(null, sa.ApprovalStatus__c); // before envelope the approval status is None (null)

        // create envelope
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'DSA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        Sales_Agreement__c sa2 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Not Approved', sa2.ApprovalStatus__c); // Approval status is 'Not Approved' when envelope created

        // update envelope status
        dsStatus.dsfs__Envelope_Status__c = 'Delivered';
        update dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, SalesAgreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c];
        Sales_Agreement__c sa3 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Delivered', envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Not Approved', sa3.ApprovalStatus__c); // the approval status dont change to 'Approved'
    }

    /**
     -- Test envelope is in signing process, status changed but still not complete
     -- Expected: the SA's status change to 'Approved'
     */
    /*@isTest
    private static void DSA_CompleteEnvelope() {
        Sales_Agreement__c sa = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals(null, sa.ApprovalStatus__c); // before envelope the approval status is None (null)

        // create envelope
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'DSA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        Sales_Agreement__c sa2 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Not Approved', sa2.ApprovalStatus__c); // Approval status is 'Not Approved' when envelope created

        // update envelope status
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, SalesAgreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c];
        Sales_Agreement__c sa3 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Completed', envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Approved', sa3.ApprovalStatus__c); // the approval status dont change to 'Approved'
    }*/

    /**
     -- Test the case where an old envelope is finished and the newest status still pending
     -- Expected: the approval status remain 'Not Approved', only the newest envelope status is valid
     -- Expected: both envelope link to related SA
     */
    @isTest
    private static void DSA_CompletePreviousEnvelope() {
        Sales_Agreement__c sa = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals(null, sa.ApprovalStatus__c); // before envelope the approval status is None (null)

        // create 1st envelope
        dsfs__DocuSign_Status__c old_dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'DSA', dsfs__Envelope_Status__c = 'Sent', dsfs__Subject__c = 'OLD');
        insert old_dsStatus;
        Sales_Agreement__c sa2 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Not Approved', sa2.ApprovalStatus__c); // Approval status is 'Not Approved' when envelope created

        // create 2nd envelope
        sa2.DocuSign_Envelope_ID__c = 'NEW DSA';
        update sa2;
        dsfs__DocuSign_Status__c new_DsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'NEW DSA', dsfs__Envelope_Status__c = 'Sent', dsfs__Subject__c = 'NEW');
        insert new_DsStatus;
        Sales_Agreement__c sa3 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Not Approved', sa3.ApprovalStatus__c); // Approval status is 'Not Approved' when new envelope created

        // finish old envelope
        old_dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update old_dsStatus;

        // assertion
        dsfs__DocuSign_Status__c old_envelope = [SELECT ID, SalesAgreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Subject__c = 'OLD'];
        dsfs__DocuSign_Status__c new_envelope = [SELECT ID, SalesAgreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Subject__c = 'NEW'];
        Sales_Agreement__c sa4 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Completed', old_envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Sent', new_envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Not Approved', sa4.ApprovalStatus__c); // the approval status dont change to 'Approved'
    }

    /**
     -- Test create a service data pool object
     */
    @isTest
    private static void testLogError() {
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'DSA', dsfs__Envelope_Status__c = 'Sent');
        CustomException mockError = new CustomException('Mock Error');
        list<dsfs__DocuSign_Status__c> mockTriggerRecords = new list<dsfs__DocuSign_Status__c> {dsStatus};
        map<string, dsfs__DocuSign_Status__c> mockExtraContext = new map<string, dsfs__DocuSign_Status__c> {'Envelope' => dsStatus};
        EnvelopeStatus.logError(mockError, 'Service', mockTriggerRecords, mockExtraContext);

        // assertion
        list<Logger_Data_Pool__c> sdp = [SELECT ID, Name, Type__c FROM Logger_Data_Pool__c WHERE Instance__c = 'EnvelopeStatus'];
        system.assertEquals(1, sdp.size());
    }

    /**
     -- Test finish 1st envelope then create and finish 2nd envelope
     -- Expected: approval status change to Approved after finishing 1st envelope and change to Not Approved when create 2nd envelope
     */
    /*@isTest
    private static void DSA_CreateAnotherEnvelope() {
        Sales_Agreement__c sa = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals(null, sa.ApprovalStatus__c); // before envelope the approval status is None (null)

        // create 1st envelope
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'DSA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        Sales_Agreement__c sa2 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Not Approved', sa2.ApprovalStatus__c);

        // finish 1st envelope
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus;
        Sales_Agreement__c sa3 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Approved', sa3.ApprovalStatus__c);

        sa3.DocuSign_Envelope_ID__c = 'NEW DSA';
        update sa3;

        // create 2nd envelope
        dsfs__DocuSign_Status__c dsStatus2 = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'NEW DSA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus2;
        Sales_Agreement__c sa4 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Not Approved', sa4.ApprovalStatus__c);

        // finish 2nd envelope
        dsStatus2.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus2;
        Sales_Agreement__c sa5 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Approved', sa5.ApprovalStatus__c);
    }*/

    /**
     -- Test create bulk envelope
     */
    /*@isTest
    private static void DSA_BulkEnvelope() {
        Sales_Agreement__c sa = [SELECT ID, DocuSign_Envelope_ID__c FROM Sales_Agreement__c];

        Test.startTest();
        for (integer i = 0; i < 10; i++) {
            sa.DocuSign_Envelope_ID__c = 'DSA' + string.valueOf(i);
            update sa;
            dsfs__DocuSign_Status__c envelope = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'DSA' + string.valueOf(i), dsfs__Envelope_Status__c = 'Sent', dsfs__Subject__c = string.valueOf(i));
            insert envelope;
        }
        Test.stopTest();

        // assertion
        list<dsfs__DocuSign_Status__c> dsStatuses_after = [SELECT ID, SalesAgreement__c FROM dsfs__DocuSign_Status__c];
        for (integer i = 0; i < 10; i++) {system.assertEquals(sa.ID, dsStatuses_after[i].SalesAgreement__c);}
    }*/

    /**
     -- Test the signing process of UCA envelope
     -- Expected: envelope link to SA but the status of envelope dont affect SA's approval status
     */
    @isTest
    private static void UCA_FinishEnvelope() {
        Sales_Agreement__c sa = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals(null, sa.ApprovalStatus__c);

        // create envelope
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'UCA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        Sales_Agreement__c sa2 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals(null, sa2.ApprovalStatus__c);

        // update envelope status
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, SalesAgreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c];
        Sales_Agreement__c sa3 = [SELECT ID, ApprovalStatus__c FROM Sales_Agreement__c];
        system.assertEquals('Completed', envelope.dsfs__Envelope_Status__c);
        system.assertEquals(null, sa3.ApprovalStatus__c);
        system.assertEquals(sa3.ID, envelope.SalesAgreement__c);
    }

    /**
     -- Test create 1 DSA envelope
     -- Expected: new envelope link to related SA & SA's approval status change to 'Not Approved'
     */
    @isTest
    private static void DSA_CreateEnvelope_MB() {

        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'MBDSA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, MB_Sales_Agreement__c FROM dsfs__DocuSign_Status__c];
        MB_Sales_Agreement__c sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals(sa.ID, envelope.MB_Sales_Agreement__c); // link to related SA
        system.assertEquals('Not Approved', sa.Approval_Status__c); // update the approval status
    }

    /**
     -- Test envelope is in signing process, status changed but still not complete
     -- Expected: the SA's status remain 'Not Approved'
     */
    @isTest
    private static void DSA_PendingEnvelope_MB() {
        MB_Sales_Agreement__c sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c); // before envelope the approval status is Not Approved

        // create envelope
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'MBDSA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        MB_Sales_Agreement__c sa2 = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa2.Approval_Status__c); // Approval status is 'Not Approved' when envelope created

        // update envelope status
        dsStatus.dsfs__Envelope_Status__c = 'Delivered';
        update dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, SalesAgreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c];
        MB_Sales_Agreement__c sa3 = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Delivered', envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Not Approved', sa3.Approval_Status__c); // the approval status dont change to 'Approved'
    }

    /**
     -- Test the case where an old envelope is finished and the newest status still pending
     -- Expected: the approval status remain 'Not Approved', only the newest envelope status is valid
     -- Expected: both envelope link to related SA
     */
    @isTest
    private static void DSA_CompletePreviousEnvelope_MB() {
        MB_Sales_Agreement__c sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c); // before envelope the approval status is Not Approved

        // create 1st envelope
        dsfs__DocuSign_Status__c old_dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'MBDSA', dsfs__Envelope_Status__c = 'Sent', dsfs__Subject__c = 'OLD');
        insert old_dsStatus;
        sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c); // Approval status is 'Not Approved' when envelope created

        sa.Latest_Docusign_Envelope__c = 'NEW MBDSA';
        update sa;

		// create 2nd envelope
        dsfs__DocuSign_Status__c new_DsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'NEW MBDSA', dsfs__Envelope_Status__c = 'Sent', dsfs__Subject__c = 'NEW');
        insert new_DsStatus;

        sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c); // Approval status is 'Not Approved' when new envelope created

        // finish old envelope
        old_dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update old_dsStatus;

        // assertion
        dsfs__DocuSign_Status__c old_envelope = [SELECT ID, MB_Sales_Agreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE dsfs__DocuSign_Envelope_ID__c = 'MBDSA'];
        dsfs__DocuSign_Status__c new_envelope = [SELECT ID, MB_Sales_Agreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE dsfs__DocuSign_Envelope_ID__c = 'NEW MBDSA'];
        sa = [SELECT ID, Approval_Status__c, Latest_Docusign_Envelope__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Completed', old_envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Sent', new_envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Not Approved', sa.Approval_Status__c); // the approval status dont change to 'Approved'
    }

    /**
     -- Test the signing process of UCA envelope
     -- Expected: envelope link to SA but the status of envelope dont affect SA's approval status
     */
    @isTest
    private static void UCA_FinishEnvelope_MB() {
        MB_Sales_Agreement__c sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c);

        // create envelope
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'MBUCA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        MB_Sales_Agreement__c sa2 = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa2.Approval_Status__c);

        // update envelope status
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, MB_Sales_Agreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c];
        MB_Sales_Agreement__c sa3 = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Completed', envelope.dsfs__Envelope_Status__c);
        system.assertEquals('Not Approved', sa3.Approval_Status__c);
        system.assertEquals(sa3.ID, envelope.MB_Sales_Agreement__c);
    }

    /**
     -- Test the signing process of YF envelope
     -- Expected: envelope link to SA but the status of envelope dont affect SA's approval status
     */
    @isTest
    private static void YF_FinishEnvelope_MB() {
        MB_Sales_Agreement__c sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c);

        // create envelope
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'MBYF', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        MB_Sales_Agreement__c sa2 = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa2.Approval_Status__c);

        // update envelope status
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, MB_Sales_Agreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c];
        MB_Sales_Agreement__c sa3 = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Completed', envelope.dsfs__Envelope_Status__c);
        system.assertEquals('Not Approved', sa3.Approval_Status__c);
        system.assertEquals(sa3.ID, envelope.MB_Sales_Agreement__c);
    }

    /**
     -- Test create 1 Sales & UCPA envelope
     -- Expected: new envelope link to related SA & SA's approval status change to 'Not Approved'
     */
    @isTest
    private static void SAUCA_CreateEnvelope_MB() {

        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'MBSAUCA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, MB_Sales_Agreement__c FROM dsfs__DocuSign_Status__c];
        MB_Sales_Agreement__c sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals(sa.ID, envelope.MB_Sales_Agreement__c); // link to related SA
        system.assertEquals('Not Approved', sa.Approval_Status__c); // update the approval status
    }

    /**
     -- Test envelope is in signing process, status changed but still not complete
     -- Expected: the SA's status remain 'Not Approved'
     */
    @isTest
    private static void SAUCA_PendingEnvelope_MB() {
        MB_Sales_Agreement__c sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c); // before envelope the approval status is Not Approved

        // create envelope
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'MBSAUCA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        MB_Sales_Agreement__c sa2 = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa2.Approval_Status__c); // Approval status is 'Not Approved' when envelope created

        // update envelope status
        dsStatus.dsfs__Envelope_Status__c = 'Delivered';
        update dsStatus;

        // assertion
        dsfs__DocuSign_Status__c envelope = [SELECT ID, SalesAgreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c];
        MB_Sales_Agreement__c sa3 = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Delivered', envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Not Approved', sa3.Approval_Status__c); // the approval status dont change to 'Approved'
    }

    /**
     -- Test the case where an old envelope is finished and the newest status still pending
     -- Expected: the approval status remain 'Not Approved', only the newest envelope status is valid
     -- Expected: both envelope link to related SA
     */
    @isTest
    private static void SAUCA_CompletePreviousEnvelope_MB() {
        MB_Sales_Agreement__c sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c); // before envelope the approval status is Not Approved

        // create 1st envelope
        dsfs__DocuSign_Status__c old_dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'MBSAUCA', dsfs__Envelope_Status__c = 'Sent', dsfs__Subject__c = 'OLD');
        insert old_dsStatus;
        sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c); // Approval status is 'Not Approved' when envelope created

        sa.Latest_SA_UCA_Docusign_Envelope__c = 'NEW MBSAUCA';
        update sa;

        // create 2nd envelope
        dsfs__DocuSign_Status__c new_DsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'NEW MBSAUCA', dsfs__Envelope_Status__c = 'Sent', dsfs__Subject__c = 'NEW');
        insert new_DsStatus;
        sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.assertEquals('Not Approved', sa.Approval_Status__c); // Approval status is 'Not Approved' when new envelope created

        // finish old envelope
        old_dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update old_dsStatus;

        // assertion
        dsfs__DocuSign_Status__c old_envelope = [SELECT ID, MB_Sales_Agreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE dsfs__DocuSign_Envelope_ID__c = 'MBSAUCA'];
        dsfs__DocuSign_Status__c new_envelope = [SELECT ID, MB_Sales_Agreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE dsfs__DocuSign_Envelope_ID__c = 'NEW MBSAUCA'];
        sa = [SELECT ID, Approval_Status__c FROM MB_Sales_Agreement__c];
        system.debug('Approval_Status__c:: ' + sa.Approval_Status__c);
        system.assertEquals('Completed', old_envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Sent', new_envelope.dsfs__Envelope_Status__c); // check if envelope's status successfully updated
        system.assertEquals('Not Approved', sa.Approval_Status__c); // the approval status dont change to 'Approved'
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('dsfs__DocuSign_Status__c', true);
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c = 'DSA', dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        TriggerExclusion.excludeTrigger('dsfs__DocuSign_Status__c', false);
    }

    private class CustomException extends Exception{}
}
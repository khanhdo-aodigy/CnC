/** ******
 * Description : Test class for InvoicePromoLineItemService class
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                    Description
 * 20220427             thanh.ly@aodigy         Created Initial Version. 
 * 
** ******/
@isTest
private class InvoicePromoLineItemServiceTest{
    @TestSetup
    static void setUp(){
        Account acc = Test_DataFactory.createAccount(true, 'Ly Van Thanh');
        Contact con = Test_DataFactory.createContact(true, 'Thanh', 'Ly', acc.Id);
        Campaign cam = Test_DataFactory.createCamp(true, 'KIA Event', 'Promotions', 'CCK');

        Promo_Line_Item__c item1 = Test_DataFactory.createPromoLineItem(true, 'USB', 100, 80, 'Blue', 10);
        Promo_Line_Item__c item2 = Test_DataFactory.createPromoLineItem(true, 'USB', 100, 80, 'White', 10);

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

        /** == MASTER TEST DATA - BEGIN == */

        // Model Master
        Model_Master__c modelCode = Test_DataFactory.createModelCode(false, 'Test Model Code');
        modelCode.Engine_Capacity__c = 1600;    // To test COE Category
        modelCode.BHP__c = 130;                 // To test COE Category
        modelCode.Franchise_Code__c = 'KIAPC';
        insert modelCode;
        // Model Year Master
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(false, modelCode.Id);
        modelYearCode.VSMS_Compound_Primary_Key__c = '1';
        insert modelYearCode;
        // Color Master
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        // Trim Master
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        // Stock Vehicle Master
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID);
        insert vMaster;
        // Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        // Stock Reservation
        Stock_Reservation__c sr = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        sr.Package_Header_From_PickList__c = pckHeader.Id;
        sr.Vehicle_Master__c = vMaster.ID;
        sr.Opportunity__c    = oppt.Id;
        sr.Customer_Mobile_Number__c = '6587546859';
        insert sr;

        /** == MASTER TEST DATA - END ==*/


        // Accessories Master
        List<Accessories_Master__c> accMasters = new List<Accessories_Master__c>();
        Accessories_Master__c accMaster = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                    ACM_ACCSDESC__c = 'ACC',
                                                                    ACM_ACCSCD__c = 'TESTACCMASTER',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'C');
        accMasters.add(accMaster);
        
        Accessories_Master__c accMaster2 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Service Credit',
                                                                     ACM_ACCSCD__c = 'SVC1000',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        accMasters.add(accMaster2);
 
        insert accMasters;
        
        // Create Accs Rate Master
        Accs_Rate_Master__c accRateMaster = new Accs_Rate_Master__c(Accessories__c = accMasters[0].Id,
                                                                    ARM_ACM_FRNCD__c = 'KIAPC');
        insert accRateMaster;

        // Create Package Accessories
        List<Package_Accs__c> pckAccList = new List<Package_Accs__c>();
        Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                     Accessories_Master__c = accMasters[0].Id,
                                                     PKA_PKH_FRNCD__c = 'KIAPC',
                                                     PKA_VALUE__c = null);
        pckAccList.add(pckAcc);

        Package_Accs__c pckAcc2 = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                      Accessories_Master__c = accMasters[1].Id,
                                                      PKA_PKH_FRNCD__c = 'KIAPC');
        pckAccList.add(pckAcc2);
		insert pckAccList;

		// Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004',
                                                                                          VSMS_Compound_Primary_Key__c = '1');
        insert addnlChargeMaster;

        // Package Addtional Charges
        List<Package_Additional_Charges__c> pckAddnlChargeList = new List<Package_Additional_Charges__c>();
        Package_Additional_Charges__c pckAddnlCharge1 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                          Package_Header__c = pckHeader.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R004',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge1);
        Package_Additional_Charges__c pckAddnlCharge2 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                          Package_Header__c = pckHeader.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R002',
                                                                                          PKC_INCPRICE__c = 'INC',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge2);
        insert pckAddnlChargeList;

        Sales_Agreement__c sAgree = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', sr.Id, 'Test'); 
        sAgree.Package_Header__c = pckHeader.Id;
        insert sAgree;

        TriggerExclusion.excludeTrigger('Invoice__c', true);
        Invoice__c invoice = new Invoice__c();
        invoice.NRIC__C = '198400907Z';
        invoice.Transaction_Status__c = 'settled';
        invoice.Vehicle_Registration_Number__c = 'SGU4225Z';
        invoice.Transaction_ID__c = '3ex4b0ym';
        invoice.Campaign_ID__c = cam.Id;
        invoice.Contact__r = con;
        invoice.Department__c = 'CCK';
        invoice.Sales_Agreement__c = sAgree.Id;
        insert invoice;

        Invoice_Promo_Line_Item__c invoiceItem1 = Test_DataFactory.createInvoicePromoLineItem(true, invoice.Id, item1.Id);
        Invoice_Promo_Line_Item__c invoiceItem2 = Test_DataFactory.createInvoicePromoLineItem(true, invoice.Id, item2.Id);
    }
    
    @isTest
    static void Test_getRelatedPromoLineItems(){
        Sales_Agreement__c saleAgreement = [SELECT Id FROM Sales_Agreement__c LIMIT 1];

        List<Invoice_Promo_Line_Item__c> invoiceItems = InvoicePromoLineItemService.getRelatedPromoLineItems(saleAgreement.Id);
        
        System.assertEquals(2, invoiceItems.size());
    }
}
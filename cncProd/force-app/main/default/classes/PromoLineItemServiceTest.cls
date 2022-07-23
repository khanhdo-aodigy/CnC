/** ******
 * Description : Test class for PromoLineItemService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                    Description
 * 20220419             thanh.ly@aodigy         Created Initial Version. 
 * 
** ******/
@isTest
private class PromoLineItemServiceTest{
    @TestSetup
    private static void setUp(){
        Account acc = Test_DataFactory.createAccount(true, 'Ly Van Thanh');
        Contact con = Test_DataFactory.createContact(true, 'Thanh', 'Ly', acc.Id);
        Campaign cam = Test_DataFactory.createCamp(true, 'KIA Event', 'Promotions', 'CCK');
        User user = Test_DataFactory.createUser(false, 'Thanh', 'ABC');
        user.FirstName = 'Ly';
        insert user;

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

        Sales_Agreement__c sAgree1 = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', sr.Id, 'Test1'); 
        sAgree1.Package_Header__c = pckHeader.Id;
        sAgree1.Stage__c = 'Cancelled';
        sAgree1.OwnerId = user.Id;
        insert sAgree1;



        // Create other Sales Agreement 
        Account personAcc2 = Test_DataFactory.createPerson(false, 'Test2', 'Prospect');
        personAcc2.PersonEmail = 'patest2@mail.com';
        insert personAcc2;
        personAcc2 = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc2.Id];
        Opportunity oppt2 = Test_DataFactory.createOpportunity(false,'testRun2', personAcc2.Id);
        oppt2.Branch_Code__c = 'CCF';
        oppt2.Opportunity_Score__c = 40;
        oppt2.Account__c = personAcc2.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt2.Contact_Person__c = personAcc2.PersonContactId;
        insert oppt2;

        Model_Master__c modelCode2 = Test_DataFactory.createModelCode(false, 'Test Model Code 2');
        modelCode2.Engine_Capacity__c = 1600;    // To test COE Category
        modelCode2.BHP__c = 130;                 // To test COE Category
        modelCode2.Franchise_Code__c = 'CITPC';
        insert modelCode2;
        // Model Year Master
        Model_Year_Master__c modelYearCode2 = Test_DataFactory.createModelYearCode(false, modelCode2.Id);
        modelYearCode2.VSMS_Compound_Primary_Key__c = '2';
        insert modelYearCode2;
        // Color Master
        Color_Master__c colorCode2 = Test_DataFactory.createColorCode(true, 'Test Color Code 2', 'Test 2', 'CCF', 'CITPC');
        // Trim Master
        Trim_Master__c trimCode2 = Test_DataFactory.createTrimCode(true, 'Test Trim Code 2');
        Date productionMonth2 = Date.newInstance(2019, 08, 02);  
        // Stock Vehicle Master
        Vehicle_Master2__c vMaster2 = new Vehicle_Master2__c(Original_Commcase__c = 'CITPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode2.ID,
                                                            System_Commcase__c = 'CITPC0120190086', 
                                                            Engine_No__c = 'ENGINE279832',
                                                            Chassis__c = 'CHAS279832', 
                                                            Model_Code__c = modelCode2.ID, 
                                                            ProductionMonth__c = productionMonth2,
                                                            Color_Code__c = colorCode2.ID, 
                                                            Trim_Code__c = trimCode2.ID);
        insert vMaster2;

        Package_Header__c pckHeader2 = new Package_Header__c(PKH_FRN_FRNCD__c = 'CITPC',
                                                            Model_Master__c = modelCode2.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader2;

        Stock_Reservation__c sr2 = Test_DataFactory.StockReservation(false, modelCode2.ID, colorCode2.ID, trimCode2.ID, modelYearCode2.ID);
        sr2.Package_Header_From_PickList__c = pckHeader2.Id;
        sr2.Vehicle_Master__c = vMaster2.ID;
        sr2.Opportunity__c    = oppt2.Id;
        sr2.Customer_Mobile_Number__c = '6587546859';
        insert sr2;

        /** == MASTER TEST DATA - END ==*/


        // Accessories Master
        List<Accessories_Master__c> accMasters2 = new List<Accessories_Master__c>();
        Accessories_Master__c accMaster3 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'CITPC',
                                                                    ACM_ACCSDESC__c = 'ACC',
                                                                    ACM_ACCSCD__c = 'TESTACCMASTER',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'C');
        accMasters2.add(accMaster3);
        
        Accessories_Master__c accMaster4 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'CITPC',
                                                                     ACM_ACCSDESC__c = 'Service Credit',
                                                                     ACM_ACCSCD__c = 'SVC1001',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        accMasters2.add(accMaster4);
 
        insert accMasters2;
        
        // Create Accs Rate Master
        Accs_Rate_Master__c accRateMaster2 = new Accs_Rate_Master__c(Accessories__c = accMasters2[1].Id,
                                                                    ARM_ACM_FRNCD__c = 'CITPC');
        insert accRateMaster2;

        // Create Package Accessories
        List<Package_Accs__c> pckAccList2 = new List<Package_Accs__c>();
        Package_Accs__c pckAcc3 = new Package_Accs__c(Package_Header__c = pckHeader2.Id,
                                                     Accessories_Master__c = accMasters2[0].Id,
                                                     PKA_PKH_FRNCD__c = 'CITPC',
                                                     PKA_VALUE__c = null);
        pckAccList2.add(pckAcc3);

        Package_Accs__c pckAcc4 = new Package_Accs__c(Package_Header__c = pckHeader2.Id,
                                                      Accessories_Master__c = accMasters2[1].Id,
                                                      PKA_PKH_FRNCD__c = 'CITPC');
        pckAccList2.add(pckAcc4);
		insert pckAccList2;

		// Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster2 = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test 2',
                                                                                          ADM_CHRGCD__c = 'R005',
                                                                                          VSMS_Compound_Primary_Key__c = '2');
        insert addnlChargeMaster2;

        // Package Addtional Charges
        List<Package_Additional_Charges__c> pckAddnlChargeList2 = new List<Package_Additional_Charges__c>();
        Package_Additional_Charges__c pckAddnlCharge3 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'CITPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster2.Id,
                                                                                          Package_Header__c = pckHeader2.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R005',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList2.add(pckAddnlCharge3);
        Package_Additional_Charges__c pckAddnlCharge4 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'CITPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster2.Id,
                                                                                          Package_Header__c = pckHeader2.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R002',
                                                                                          PKC_INCPRICE__c = 'INC',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList2.add(pckAddnlCharge4);
        insert pckAddnlChargeList2;

        Sales_Agreement__c sAgree2 = Test_DataFactory.createSalesAgreement(false, 'CCF', 'NO9998', sr2.Id, 'Test2'); 
        sAgree2.Package_Header__c = pckHeader.Id;
        insert sAgree2;

        TriggerExclusion.excludeTrigger('Invoice__c', true);
        Invoice__c invoice = new Invoice__c();
        invoice.NRIC__C = '198400907Z';
        invoice.Transaction_Status__c = 'settled';
        invoice.Vehicle_Registration_Number__c = 'SGU4225Z';
        invoice.Transaction_ID__c = '3ex4b0ym';
        invoice.Campaign_ID__c = cam.Id;
        invoice.Contact__r = con;
        invoice.Department__c = 'CCK';
        invoice.Sales_Agreement__c = sAgree1.Id;
        insert invoice;
        
        Promo_Line_Item__c item1 = Test_DataFactory.createPromoLineItem(true, 'USB', 100, 80, 'Blue', 10);
        Promo_Line_Item__c item2 = Test_DataFactory.createPromoLineItem(true, 'USB', 100, 80, 'White', 10);

        Invoice_Promo_Line_Item__c invoiceItem1 = Test_DataFactory.createInvoicePromoLineItem(false, invoice.Id, item1.Id);
        invoiceItem1.Quantity__c = 1;
        insert invoiceItem1;
        Invoice_Promo_Line_Item__c invoiceItem2 = Test_DataFactory.createInvoicePromoLineItem(false, invoice.Id, item2.Id);
        invoiceItem2.Quantity__c = 2;
        insert invoiceItem2;
    }
    
    @isTest
    private static void Test_getPromoLineItemsByIds(){
        Promo_Line_Item__c Item = [SELECT Id FROM Promo_Line_Item__c LIMIT 1];
        List<Promo_Line_Item__c> Items = PromoLineItemService.getPromoLineItemsByIds(new Set<String> {Item.Id});
        
        System.assertEquals(1, Items.size());
    }

    @isTest
    private static void Test_updatePromoLineItemQuantity(){
        Sales_Agreement__c saleAgree = [SELECT Id, Stage__c, Owner.Id, Name, Stock_Reservation__c, Owner.FirstName FROM Sales_Agreement__c LIMIT 1];

        List<Invoice_Promo_Line_Item__c> invoiceItems = [SELECT Id, Promo_Line_Item__c, Promo_Line_Item__r.No_of_Stock__c, Quantity__c FROM Invoice_Promo_Line_Item__c];
        
        PromoLineItemService.updatePromoLineItemQuantity(invoiceItems, saleAgree.Id);
    }

    
    @isTest
    private static void Test_cancelSA(){
        Sales_Agreement__c saleAgree = [SELECT Id, Stage__c, Owner.Id, Name, Stock_Reservation__c, Owner.FirstName FROM Sales_Agreement__c LIMIT 1];
        
        PromoLineItemService.cancelSA(saleAgree.Id);
    }

    @isTest
    private static void Test_transferUpsellAccs_DifferentModel(){
        Sales_Agreement__c saleAgree1 = [SELECT Id, Stage__c, Owner.Id, Name, Stock_Reservation__c, Owner.FirstName, Stock_Reservation__r.Vehicle_Master__r.Model__c 
                                        FROM Sales_Agreement__c
                                        WHERE SOH_SONO__c = 'NO9999'];

        Sales_Agreement__c saleAgree2 = [SELECT Id, Name, Stock_Reservation__r.Vehicle_Master__r.Model__c 
                                        FROM Sales_Agreement__c
                                        WHERE SOH_SONO__c = 'NO9998'];

        List<Invoice_Promo_Line_Item__c> invoiceItems = [SELECT Id, Promo_Line_Item__c, Promo_Line_Item__r.No_of_Stock__c, Quantity__c FROM Invoice_Promo_Line_Item__c];
        
        PromoLineItemService.transferUpsellAccs(invoiceItems, saleAgree1.Id, saleAgree2.Name);
    }

    @isTest
    private static void Test_updateInvoices(){
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];
        Sales_Agreement__c saleAgree1 = [SELECT Id, Stage__c, Owner.Id, Name, Stock_Reservation__c, Owner.FirstName, Stock_Reservation__r.Vehicle_Master__r.Model__c,
                                                Stock_Reservation__r.Model_Code__c
                                        FROM Sales_Agreement__c
                                        WHERE SOH_SONO__c = 'NO9999'];

        PromoLineItemService.updateInvoices(new List<Invoice__c>{invoice}, (String)saleAgree1.Id);
    }

    @isTest 
    private static void Test_sendEmailForRefund(){
        Sales_Agreement__c saleAgree = [SELECT Id, Stage__c, Owner.Id, Name, Stock_Reservation__c, Owner.FirstName 
                                        FROM Sales_Agreement__c 
                                        WHERE SOH_SONO__c = 'NO9999'
                                        LIMIT 1];
        PromoLineItemService.sendEmailForRefund(saleAgree.Owner.Id, 'Notification_to_Refund_for_Upsell_Accs', saleAgree.Owner.FirstName, saleAgree.Name);
    }
}
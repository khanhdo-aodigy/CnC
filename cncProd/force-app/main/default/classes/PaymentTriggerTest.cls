@isTest
private class PaymentTriggerTest {

    @testSetup
    static void setUp() {
        Account acc = Test_DataFactory.createAccount(true, 'Test');
        Contact con = Test_DataFactory.createContact(true, 'Thanh', 'Ly', acc.Id);

        Test_DataFactory.createCamp(true, 'test', 'Promotions', 'CCI');
        Id campRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('C&C Campaign RT (Sales Targeted Promo)').getRecordTypeId();
        Campaign camp = Test_DataFactory.createCamp(false, 'test', 'Promotions', 'CCK');
        camp.Sales_Targeted_Promo_Type__c = 'Multiple';
        camp.RecordTypeId = campRT;
        camp.Type = 'Sales Targeted Promo';
        insert camp;

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
        insert sAgree1;

        Campaign_Member_Vehicle__c camMemVehicle = new Campaign_Member_Vehicle__c();
        camMemVehicle.Name = 'Test';
        camMemVehicle.Campaign__c = camp.Id;
        camMemVehicle.Contact__c = con.Id;
        camMemVehicle.Account__c = acc.Id;
        camMemVehicle.Sales_Agreement__c = sAgree1.Id;
        insert camMemVehicle;
    }
    
    @isTest
    static void Test_beforeInsert_SetCampaignLookup() {
        Id campaignId = [Select Id From Campaign Where Branch_Code__c = 'CCI'].Id;
		Invoice__c inv = insertInvoice('CCI');
        
        System.assertEquals(campaignId, inv.Campaign_ID__c);
    }    
    
    @isTest
    static void Test_beforeInsert_SetInvNoCCI() {
        List<Invoice__c> invoices = new List<Invoice__c>();
        Campaign cciCampaign = [Select Id, CampaignId__c From Campaign Where Branch_Code__c = 'CCI'];
    
        for(Integer i = 1; i <= 3; i++) {
            Invoice__c inv = Test_DataFactory.createInvoice(false, null, null);
            inv.Campaign_ID__c = cciCampaign.Id;
            inv.Department__c = 'CCI';
            inv.SequenceIdentifier__c = 'Paid Event';
            inv.SeqNum__c = i;
            inv.Amount_With_GST__c = 100;
            invoices.add(inv);
        }
        
        insert invoices;
        
		invoices = [Select Inv_No__c From Invoice__c Order By Inv_No__c ASC];
        String cleanCampaignId = cciCampaign.CampaignId__c.replaceAll('CID', '');
        for(Integer i = 0; i <= 2; i++) {
            System.assertEquals('SG-CCI-EVT-OTP' + cleanCampaignId + '-' + (i + 1), invoices[i].Inv_No__c);
		}
    }   
    
    @isTest
    static void Test_beforeInsert_SetInvNoNonCCI() {
        List<Invoice__c> invoices = new List<Invoice__c>();
        Id campaignId = [Select Id From Campaign Where Branch_Code__c = 'CCK'].Id;
    
        for(Integer i = 1; i <= 3; i++) {
            Invoice__c inv = Test_DataFactory.createInvoice(false, null, null);
            inv.Campaign_ID__c = campaignId;
            inv.Department__c = 'CCK';
            inv.SeqNum__c = i;
            inv.Amount_With_GST__c = 100;
            invoices.add(inv);
        }
        
        insert invoices;
        
		invoices = [Select Inv_No__c From Invoice__c Order By Invoice_Number__c ASC];

        Integer month = System.today().month();
        String monthStr = String.valueOf(month).leftPad(2, '0');
        Integer year = System.today().year();
        String yearStr = String.valueOf(year).right(2);
        
        for(Integer i = 0; i <= 2; i++) {
            System.assertEquals('SG-CCK-' + monthStr + yearStr + '-0000000' + (i + 1), invoices[i].Inv_No__c);
		}
    }
    
    @isTest
    static void Test_insert_duplicateInvNo() {
        List<Invoice__c> invoices = new List<Invoice__c>();
        Campaign cciCampaign = [Select Id, CampaignId__c From Campaign Where Branch_Code__c = 'CCI'];
        
        for(Integer i = 1; i <= 4; i++) {
            Invoice__c inv = Test_DataFactory.createInvoice(false, null, null);
            inv.Campaign_ID__c = cciCampaign.Id;
            inv.Department__c = 'CCI';
            inv.SequenceIdentifier__c = 'Paid Event';
            inv.Amount_With_GST__c = 100;
          
            switch on i {
                when 1 {
                    inv.SeqNum__c = 1;
                    insert inv;                    
                }
                when 2 {
                    inv.SeqNum__c = 1;
                    invoices.add(inv);
				}
                when 3 {
                    inv.SeqNum__c = 2;
                    invoices.add(inv);
                }
                when 4 {
                    inv.SeqNum__c = 2;
                    invoices.add(inv);
                }
            }
        }
        
        Integer emailbefore = Limits.getEmailInvocations();
        insert invoices;        

        System.assert(Limits.getEmailInvocations() > emailbefore);
		System.assertEquals(3, [Select COUNT() From Invoice__c Where Duplicate__c = true]);
    }
    
    @isTest
    static void Test_afterUpdate_InvoiceAttachedCCI() {
		Invoice__c inv = insertInvoice('CCI');
        
        Test.startTest();
        inv.Department__c = 'CCI';
        inv.TC_Val__c = 'test';
        update inv;
        Test.stopTest();
        
        System.assertEquals(1, [Select Id From ContentDocumentLink Where LinkedEntityId = :inv.Id].size());
    }
    
    @isTest
    static void Test_afterUpdate_InvoiceAttachedNonCCI() {
        Invoice__c inv = insertInvoice('CCK');

        Promo_Line_Item__c item1 = Test_DataFactory.createPromoLineItem(true, 'USB Device', 30, 20, 'Blue', 10);
        Promo_Line_Item__c item2 = Test_DataFactory.createPromoLineItem(true, 'Firefly Bluetooth Receiver', 40, 30, null, 10);

        Invoice_Promo_Line_Item__c invItem1 = Test_DataFactory.createInvoicePromoLineItem(false, inv.Id, item1.Id);
        invItem1.Quantity__c = 2;
        invItem1.Total_Commission_Value__c = 1;
        insert invItem1;

        Invoice_Promo_Line_Item__c invItem2 = Test_DataFactory.createInvoicePromoLineItem(false, inv.Id, item2.Id);
        invItem2.Quantity__c = 1;
        invItem2.Total_Commission_Value__c = 0.5;
        insert invItem2;

        inv.Department__c = 'CCK';
        inv.Transaction_Status__c = 'authorized';
        update inv;
    }    
    
    private static Invoice__c insertInvoice(String branchCode) {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Sales_Agreement__c sA = [SELECT Id FROM Sales_Agreement__c LIMIT 1];
        Id campaignId = [Select Id From Campaign Where Branch_Code__c = :branchCode].Id;
        Invoice__c inv = Test_DataFactory.createInvoice(false, null, null);
        inv.Amount_With_GST__c = 100;
        inv.Campaign_ID__c = campaignId;
        inv.Contact__c = con.Id;
        inv.Sales_Agreement__c = sA.Id;
        inv.Campaign__c = campaignId;
        insert inv;
        
        inv = [Select Id, Campaign_ID__C, Amount_With_GST__c, Department__c, Transaction_Status__c, Contact__c, Sales_Agreement__c, Campaign__c From Invoice__c];
		return inv;        
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Invoice__c', true);
        Invoice__c inv = insertInvoice('CCI');
        TriggerExclusion.excludeTrigger('Invoice__c', false);
    }
}
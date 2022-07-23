@isTest
private class DigitalSalesAgreementApplicationTest {

   	/*
   	 * Thou shalt prepare for the test of time.
   	 */
    @testSetUp
    static void prepareTestData(){
        // create a sales agreement record for test
        string branchCode = 'CCK';
        string agreementNo = 'ALOHA_TEST';
        string customerName = 'Imaginary Customer';
        string customerEMail = 'test@123.com';
        string CUSTOMER_SIGN_ORDER = '1';    
        
        // create Account and Opportunity
        // Account personAcc = Test_DataFactory.createPerson(true, 'Imaginary Customer', 'Customer');
        Account personAcc = Test_DataFactory.createPA(true, 'Test Last', 'pa@gmail.com', 'Customer');
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'Imaginary Customer-Opp', personAcc.Id);
        oppt.Branch_Code__c = 'CCK';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = personAcc.Id;
        insert oppt;
        
        Opportunity oppt1 = Test_DataFactory.createOpportunity(false,'Imaginary Customer-Opp1', personAcc.Id);
        oppt1.Branch_Code__c = 'CCK';
        oppt1.Opportunity_Score__c = 40;
        insert oppt1;
        
        // create master data
        Model_Master__c modelMaster = new Model_Master__c(Name = 'Test Model Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert modelMaster;
        Color_Master__c colorMaster = new Color_Master__c(Name = 'Test Color Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', ColorCode__c = 'Z3P0');
        insert colorMaster;
        Trim_Master__c trimMaster = new Trim_Master__c(Name = 'Test Trim Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC');
        insert trimMaster;
        Model_Year_Master__c modelYearMaster = new Model_Year_Master__c(Name = 'Test Model Year Code', Branch_Code__c = branchCode, Franchise_Code__c = 'KIAPC', Model_Master__c = modelMaster.ID);
        insert modelYearMaster;
        
        // Package Header
        Package_Header__c pkh = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC', PKH_STATUS__c='A', Model_Master__c = modelMaster.Id, PKH_PKGPRICE__c=1000000);
        insert pkh;
        
        Package_Header__c pkh1 = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC', PKH_STATUS__c='A', Model_Master__c = modelMaster.Id, PKH_PKGPRICE__c=2000000);
        insert pkh1;
        
        // create stock reservation from master data
        //Stock_Reservation__c stockReservation_1 = Test_DataFactory.StockReservation(true, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        Stock_Reservation__c stockReservation_1 = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        stockReservation_1.Package_Header_From_PickList__c = pkh.Id;
        stockReservation_1.Opportunity__c                  = oppt.Id;
        insert stockReservation_1;
        Stock_Reservation__c stockReservation_2 = Test_DataFactory.StockReservation(false, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
		stockReservation_2.Package_Header_From_PickList__c = pkh1.Id;
        stockReservation_2.Opportunity__c                  = oppt1.Id;
        insert stockReservation_2;
         Stock_Reservation__c stockReservation_3 = Test_DataFactory.StockReservation(true, modelMaster.ID, colorMaster.ID, trimMaster.ID, modelYearMaster.ID);
        // Package Header, Package Accs & Package Addtnl Charges
        //Package_Header__c pkh = new Package_Header__c();
        //Package_Header__c pkh = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC', PKH_STATUS__c='A', Model_Master__c = modelMaster.Id, PKH_PKGPRICE__c=1000000);
        //insert pkh;
        
        // accessory master for Off Peak
        Accessories_Master__c offPeakMaster = new Accessories_Master__c(ACM_ACCSCD__c = 'OFF PEAK', ACM_FRN_FRNCD__c = 'KIAPC');
        insert offPeakMaster;
        Accessories_Master__c accMaster = new Accessories_Master__c(ACM_MNM_MAJGROUPCD__c = 'AIR_CON', ACM_FRN_FRNCD__c = 'KIAPC', ACM_ACCSCD__c = 'IU');
        insert accMaster;
        Accessories_Master__c accMaster2 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Service Credit',
                                                                     ACM_ACCSCD__c = 'SVC1000',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster2;       
        Accessories_Master__c accMaster3 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Accessories Credit',
                                                                     ACM_ACCSCD__c = 'ACC1000',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        insert accMaster3;
        
        // create package accessories for package header
        list<Package_Accs__c> pkgAccs = new list<Package_Accs__c>{};
		for (integer i = 0; i < 9; i++) pkgAccs.add(new Package_Accs__c(Package_Header__c = pkh.id, Accessories_Master__c = accMaster.id));
        pkgAccs.add(new Package_Accs__c(Package_Header__c = pkh.id, Accessories_Master__c = offPeakMaster.id));
        Package_Accs__c pckAcc2 = new Package_Accs__c(Package_Header__c = pkh.Id,
                                                      Accessories_Master__c = accMaster2.Id,
                                                      PKA_PKH_FRNCD__c = 'KIAPC');
        pkgAccs.add(pckAcc2);
        Package_Accs__c pckAcc3 = new Package_Accs__c(Package_Header__c = pkh.Id,
                                                      Accessories_Master__c = accMaster3.Id,
                                                      PKA_PKH_FRNCD__c = 'KIAPC');
        pkgAccs.add(pckAcc3); 
        insert pkgAccs;
        
        // create package additional charge for package header
        list<Package_Additional_Charges__c> pkgAddtnlCharges = new list<Package_Additional_Charges__c>{};
        Additional_Charges_Master__c addtnlChargeMaster = new Additional_Charges_Master__c();
        insert addtnlChargeMaster;
        Additional_Charges_Master__c addtnlChargeMasterSurcharge = new Additional_Charges_Master__c(ADM_CHRGCD__c = 'R001');
        insert addtnlChargeMasterSurcharge;
        Additional_Charges_Master__c addtnlChargeMasterRoadTax = new Additional_Charges_Master__c(ADM_CHRGCD__c = 'R004');
        insert addtnlChargeMasterRoadTax;
        Additional_Charges_Master__c addtnlChargeMasterRetentionNumber = new Additional_Charges_Master__c(ADM_CHRGCD__c = 'R015');
        insert addtnlChargeMasterRetentionNumber;
        for (integer i = 0; i < 7; i++) pkgAddtnlCharges.add(new Package_Additional_Charges__c(Package_Header__c = pkh.id, Additional_Charges_Master__c = addtnlChargeMaster.id));
        pkgAddtnlCharges.add(new Package_Additional_Charges__c(Package_Header__c = pkh.id, Additional_Charges_Master__c = addtnlChargeMasterSurcharge.id));
        pkgAddtnlCharges.add(new Package_Additional_Charges__c(Package_Header__c = pkh.id, Additional_Charges_Master__c = addtnlChargeMaster.id, PKC_ADM_CHRGCD__c = 'R001'));
        pkgAddtnlCharges.add(new Package_Additional_Charges__c(Package_Header__c = pkh.id, Additional_Charges_Master__c = addtnlChargeMasterRetentionNumber.id));
        insert pkgAddtnlCharges;
                
        // sales agreement
        Sales_Agreement__c salesAgreement = /*Test_DataFactory.*/createSalesAgreement(true, branchCode, agreementNo, stockReservation_1.ID, customerName);
        
        // link package header to SA
        //salesAgreement.Package_Header__c = pkh.id;
        //update salesAgreement;
        
        // business associate master
        Business_Associate_Master__c bam = new Business_Associate_Master__c(Name = 'Test BAM', BAM_TYPE__c = 'FIN');
        insert bam;
    }
	
    /*
     * Thou shalt be able to access sales agreement through stock reservation.
     */
    @isTest 
    private static void initializeSalesAgreementStockReservation_StockReservation(){
        Sales_Agreement__c SA = [SELECT id, SOH_SONO__c, Stock_Reservation__c FROM Sales_Agreement__c WHERE SOH_SONO__c = 'ALOHA_TEST'];
        Stock_Reservation__c stockReserve = [SELECT id FROM Stock_Reservation__c WHERE id = :SA.Stock_Reservation__c];
        Sales_Agreement__c testSA = (Sales_Agreement__c) DigitalSalesAgreementApplication.initializeSalesAgreement(stockReserve.id);
        system.assertEquals('ALOHA_TEST', testSA.SOH_SONO__c);
    }
	
    /*
     * Thou shalt recall sales agreement thyself.
     */
    @isTest 
    private static void initializeSalesAgreementSalesAgreement_SalesAgreement(){
        Sales_Agreement__c createdSA = [SELECT id FROM Sales_Agreement__c];
        Sales_Agreement__c testSA = (Sales_Agreement__c) DigitalSalesAgreementApplication.initializeSalesAgreement(createdSA.id);
        system.assertEquals('ALOHA_TEST', testSA.SOH_SONO__c);
    }
    
    /*
     * Thou shalt be able to create if Maker not yet create it.
     */
    @isTest 
    private static void initializeSalesAgreementSalesAgreement_NewSalesAgreement(){
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        Stock_Reservation__c stockReserve = [SELECT id FROM Stock_Reservation__c WHERE id != :SA.Stock_Reservation__c AND Package_Header_From_PickList__c = null LIMIT 1];
        Stock_Reservation__c testSR = (Stock_Reservation__c) DigitalSalesAgreementApplication.initializeSalesAgreement(stockReserve.id);
        system.debug(testSR);
        system.assert(testSR.id != null);
        Stock_Reservation__c stockReserve1 = [SELECT id FROM Stock_Reservation__c WHERE id != :SA.Stock_Reservation__c AND Package_Header_From_PickList__c != null LIMIT 1];
        DigitalSalesAgreementApplication.createInitialSalesAgreement(stockReserve1.Id);
    }
    
    /*
     * Thou shalt redeem for mistake.
     */
    @isTest
    private static void updateSalesAgreement() {
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        SA.COE_Deposit__c = 100;
        DigitalSalesAgreementApplication.updateSalesAgreement(SA);
        Sales_Agreement__c testSA = [SELECT id, Stock_Reservation__c, SOH_SONO__c, COE_Deposit__c FROM Sales_Agreement__c];
        system.assertEquals(100, testSA.COE_Deposit__c);
    }
    
    /*
     * May the accessories be with you.
     */
    @isTest
    private static void getSAAcessories() {
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        list<SA_Accessory__c> accessories = DigitalSalesAgreementApplication.getSAAcessories(SA.id);
        system.assertEquals(12, accessories.size());
    }
    
    @isTest
    private static void getAccessoriesMaster() {
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        list<Accessories_Master__c> accMasters = DigitalSalesAgreementApplication.getAccessoriesMaster(SA.id);
        system.assertEquals(0, accMasters.size());
    }
    
    @isTest
    private static void deleteOffpeakRecord() {
        SA_Accessory__c offPeakAcc = [SELECT id FROM SA_Accessory__c LIMIT 1];
        DigitalSalesAgreementApplication.deleteOffpeakRecord(offPeakAcc);
        // test delete opearation
        try {
            delete offPeakAcc;
        } catch (Exception e) {
            system.assert(!string.isBlank(e.getMessage()));
        }
    }
    
    @isTest
    private static void upsertOffPeakRecord_Existing() {
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        SA_Accessory__c saOffPeakRecord = DigitalSalesAgreementApplication.upsertOffPeakRecord(SA.id, 'CCK');
        system.assertEquals('OFF PEAK', saOffPeakRecord.SAC_ACM_ACCSCD__c);
    }
    
    @isTest
    private static void getSAAdditionalCharges() {
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        list<SA_Additional_Charge__c> adtnlCharges = DigitalSalesAgreementApplication.getSAAdditionalCharges(SA.id);
        system.assertEquals(2, adtnlCharges.size());
    }
    
    @isTest
    private static void getAdditionalCharges() {
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        list<Package_Additional_Charges__c> adtnlCharges = DigitalSalesAgreementApplication.getAdditionalCharges(SA.id);
        system.assertEquals(1, adtnlCharges.size());
    }
    
    @isTest
    private static void processSAAccessories() {
        list<SA_Accessory__c> accsList = [SELECT id FROM SA_Accessory__c];
        list<SA_Accessory__c> accsToDelete = new list<SA_Accessory__c> {accsList[5].clone()};
        insert accsToDelete;
        list<SA_Accessory__c> result = DigitalSalesAgreementApplication.processSAAccessories(accsList, accsToDelete);
        try {
            delete accsToDelete;
        } catch (Exception e) {
            system.assert(!string.isBlank(e.getMessage()));
        }
    }
    
    @isTest
    private static void getAddonSAAcessories() {
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        list<SA_Accessory__c> results = DigitalSalesAgreementApplication.getAddonSAAcessories(SA.id);
        system.assertEquals(0, results.size());
    }
    
    @isTest
    private static void deleteAddonSAAcessories() {
        SA_Accessory__c addOnAcc = [SELECT id FROM SA_Accessory__c LIMIT 1];
        DigitalSalesAgreementApplication.deleteAddonSAAcessories(new list<SA_Accessory__c> {addOnAcc});
        // test delete opearation
        try {
            delete addOnAcc;
        } catch (Exception e) {
            system.assert(!string.isBlank(e.getMessage()));
        }
    }
    
    @isTest
    private static void getBusinessAssociateMaster() {
        list<Business_Associate_Master__c> bam = DigitalSalesAgreementApplication.getBusinessAssociateMaster(new list<string>{'FIN'});
        system.assertEquals(1, bam.size());
    }
    
    @isTest
    private static void getNumberRetentionAdditionalChargesMaster() {
        list<SA_Additional_Charge__c> numberRetentionCharges = DigitalSalesAgreementApplication.getNumberRetentionAdditionalChargesMaster();
        system.assertEquals(1, numberRetentionCharges.size());
    }
    
    @isTest
    private static void deleteNumberRetention() {
        SA_Additional_Charge__c numberRetentionRec = [SELECT id FROM SA_Additional_Charge__c WHERE SAD_ADM_CHRGCD__c = 'R015'];
        DigitalSalesAgreementApplication.deleteNumberRetention(numberRetentionRec);
        try {
            delete numberRetentionRec;
        } catch (Exception e) {
            system.assert(!string.isBlank(e.getMessage()));
        }
    }
    
    @isTest
    private static void upsertNumberRetention() {
        // check the number of additional charges before upsert
        Sales_Agreement__c SA = [SELECT id, (SELECT id FROM SA_Additional_Charges__r) FROM Sales_Agreement__c];
        system.assertEquals(10, SA.SA_Additional_Charges__r.size());
        
        // create and add new additional charge to sales agreement
        Package_Header__c pkh = [SELECT id FROM Package_Header__c LIMIT 1];
        SA_Additional_Charge__c addtnlCharge = new SA_Additional_Charge__c();
        addtnlCharge = DigitalSalesAgreementApplication.upsertNumberRetention(SA.id, addtnlCharge);
        
        // asert
        Sales_Agreement__c SA2 = [SELECT id, (SELECT id FROM SA_Additional_Charges__r) FROM Sales_Agreement__c];
        system.assertEquals(11, SA2.SA_Additional_Charges__r.size());
        
    }
    
    @isTest
    private static void updateStockReservation() {
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        Stock_Reservation__c stockReserve = [SELECT id FROM Stock_Reservation__c WHERE id != :SA.Stock_Reservation__c AND Package_Header_From_PickList__c = null LIMIT 1];
        stockReserve.Registration_Type__c = 'C';
        DigitalSalesAgreementApplication.updateStockReservation(stockReserve);
    }
    
    @isTest
    private static void getPackage() {
        Sales_Agreement__c SA = [SELECT id, Stock_Reservation__c FROM Sales_Agreement__c];
        Stock_Reservation__c stockReserve = [SELECT id, Model_Code__c FROM Stock_Reservation__c WHERE id != :SA.Stock_Reservation__c AND Package_Header_From_PickList__c = null LIMIT 1];
        DigitalSalesAgreementApplication.getPackage(stockReserve.Model_Code__c);
    }
    
    /*@isTest
    private static void cancelSalesAgreement() {
        Sales_Agreement__c SA = [SELECT id, Stage__c, Stock_Reservation__c FROM Sales_Agreement__c];
        SA.Stage__c = 'Cancelled';
        DigitalSalesAgreementApplication.cancelSalesAgreement(SA);
    }*/
    
    @isTest
    private static void updateRelatedPA() {
        Sales_Agreement__c SA = [SELECT id FROM Sales_Agreement__c];
        DigitalSalesAgreementApplication.updateRelatedPA(SA.Id);
    }

    /**
    * Create sales agreement [Thu added 30/08/2021] - Temporarily fix due to the validation
    **/
    private static Sales_Agreement__c createSalesAgreement(Boolean doInsert, string branchCode, string agreementNo, ID stockReservationId, string customerName) {
        
        // create sales agreement
        Sales_Agreement__c SA = new Sales_Agreement__c();
        SA.Branch_Code__c = branchCode;
        SA.SOH_SONO__c = agreementNo;
        SA.Stock_Reservation__c = stockReservationId;
        //SA.Customer_Full_Name__c = customerName;
        SA.NCD__c = 20;
        SA.Promo_Discount__c = 200;
        SA.Accessories_Discount__c = 500;
        SA.Expected_Delivery_From__c = Date.today();
        SA.Expected_Delivery_To__c = Date.today();
        SA.Payment__c = 'Car Loan';
        SA.ARCA_Number__c = 'UEN123456';
        SA.Company_Name__c = 'ABC TEST';
        if (doInsert) {insert SA;}
        return SA;
    }
}
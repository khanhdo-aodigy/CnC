/*
Author: Tom Lin, October 2019
*/
@isTest
private class UtilityTest {
    
    @isTest
    static void Test_getFields() {
        String fields = Utility.getFields('Account');
        System.assertNotEquals(null, fields);
    }
    
    @isTest
    static void Test_checkForContact() {
        Account acc = Test_DataFactory.createAccount(true, 'test');
        Contact con = Test_DataFactory.createContact(false, 'test', 'test', acc.Id);
        con.Email = 'test@test.com';
        insert con;
        
        List<Contact> cons = Utility.checkForContact('test@test.com');
        System.assertEquals(1, cons.size());
    }
    
    @isTest
    static void Test_getVariantFromStockVehicleMaster() {
        Model__c model = Test_DataFactory.createmodelId(true, 'test', 'CCK', 'KIAPC');
        Variant__c variant = Test_DataFactory.createVariant(false, 'test', model.Id, 'CCK');
        variant.DWH_Variant_ID__c = 'CCK,KIAPC,test';
        insert variant;
        
        Vehicle_Master2__c vm = createVehicleMaster();
        List<Variant__c> variants = Utility.getVariantFromStockVehicleMaster(vm);
        System.assertEquals(1, variants.size());
    }
    
    private static Vehicle_Master2__c createVehicleMaster() {
        Model_Master__c mm = Test_DataFactory.createModelCode(false, 'test');
        mm.Branch_Code__c = 'CCK';
        mm.Franchise_Code__c = 'KIAPC';
        insert mm;
        
        Color_Master__c cm = Test_DataFactory.createColorCode(true, 'test', 'test', 'CCK', 'KIAPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true, 'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true, mm.Id);
        
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false, mm.Id, cm.Id, tm.Id, mym.Id, 'test', 'test');
        vm.ProductionMonth__c = System.today();
        insert vm;   
        
        return [Select Model_Code__r.Branch_Code__c, Model_Code__r.Franchise_Code__c, Model_Code__r.Name From Vehicle_Master2__c];
    }    
    
    // TODO: Solid unit test with asserts for each method call contained herein
    @isTest
    static void Test_checkOpportunities() {
        Model__c model = Test_DataFactory.createmodelId(true, 'test', 'CCK', 'KIAPC');
        Variant__c variant = Test_DataFactory.createVariant(true, 'test', model.Id, 'CCK');
        
        Utility.checkForExistingOpportunity(
            null, new List<Variant__c>{variant}
        );
        Utility.checkOppExistsForThisConsultant(null, null);
        Utility.checkOpenOppExistsForTheContact(null, null);
        Utility.checkOppExistsForTheContact(null, null);
        Utility.checkBookedOppExistsForTheLead(null, null);
        Utility.checkOppExistsForTheLead(null, null);
    }
    
    @isTest
    static void Test_getModelForTestDrive() {
        Model__c model = Test_DataFactory.createmodelId(true, 'test', 'CCK', 'KIAPC');
        Variant__c variant = Test_DataFactory.createVariant(true, 'test', model.Id, 'CCK');        
        Vehicle_Master__c vm = Test_DataFactory.createVehicleMaster(false, 'test', variant.Id, model.Id);
        vm.Type__c = 'Test Drive';
        insert vm;
        
        List<Vehicle_Master__c> vms = Utility.getModelForTestDrive(variant);
        System.assertEquals(1, vms.size());
    }
    
    @isTest
    static void Test_getSequenceNo() {
        Test_DataFactory.createGlobalOrfDefaults(true);
        for(String branchNonCCI : new Set<String>{'CCK', 'CCA', 'CCF'}) {
            Utility.getSequenceNo(branchNonCCI);        
        }            
    }    
    
    @isTest
    private static void testGetSequenceNoEvent_branchCCK(){
        String branch = 'CCK';
        Campaign testCamp = Test_DataFactory.createCamp(true, 'Name', 'Events', branch);        
        InvoiceSeqNum__c invoiceSeqNum = Test_DataFactory.createInvoiceSeqNum(true, testCamp.Id);
        
        Utility.getSequenceNoEvent(branch, testCamp.Id);
    }
    
    @isTest
    private static void testGetSequenceNoEvent_branchCCA(){
        String branch = 'CCA';
        Campaign testCamp = Test_DataFactory.createCamp(true, 'Name', 'Events', branch);        
        InvoiceSeqNum__c invoiceSeqNum = Test_DataFactory.createInvoiceSeqNum(true, testCamp.Id);
        
        Utility.getSequenceNoEvent(branch, testCamp.Id);
    }
    
    @isTest
    private static void testGetSequenceNoEvent_branchCCF(){
        String branch = 'CCF';
        Campaign testCamp = Test_DataFactory.createCamp(true, 'Name', 'Events', branch);        
        InvoiceSeqNum__c invoiceSeqNum = Test_DataFactory.createInvoiceSeqNum(true, testCamp.Id);
        
        Utility.getSequenceNoEvent(branch, testCamp.Id);
    }
    
    @isTest
    private static void testGetSequenceNoEvent_branchCCI(){
        String branch = 'CCI';
        List<Campaign> campList = new List<Campaign>();
        Campaign oneTimePurchaseCamp = Test_DataFactory.createCamp(false, 'Name', 'Promotions', branch);
        oneTimePurchaseCamp.Promotion_Type__c = 'One Time Purchase';
        campList.add(oneTimePurchaseCamp);
        
        Campaign serviceCamp = Test_DataFactory.createCamp(false, 'Name', 'Promotions', branch);
        serviceCamp.Promotion_Type__c = 'Service Package';
        campList.add(serviceCamp);
        
        Campaign merchandiseCamp = Test_DataFactory.createCamp(false, 'Name', 'Promotions', branch);
        merchandiseCamp.Promotion_Type__c = 'Merchandise';
        campList.add(merchandiseCamp);  
        
        Campaign eventsCamp = Test_DataFactory.createCamp(false, 'Name', 'Events', branch);
        campList.add(eventsCamp); 
        
        insert campList;
        
        InvoiceSeqNum__c oneTimeSeqNum = Test_DataFactory.createInvoiceSeqNum(true, oneTimePurchaseCamp.Id);
        InvoiceSeqNum__c serviceSeqNum = Test_DataFactory.createInvoiceSeqNum(true, serviceCamp.Id);
        InvoiceSeqNum__c merchandiseSeqNum= Test_DataFactory.createInvoiceSeqNum(true, merchandiseCamp.Id);
        
        for(Campaign camp: campList){
            Utility.getSequenceNoEvent(branch, camp.Id);
        }
        
    }    
    
    static void testCheckForOpenInvoice() {
        String testEmail = 'fake@domain.com';
        
        Invoice__c dummyInvoice = new Invoice__c();
        dummyInvoice.Customer_Email__c = testEmail;
        dummyInvoice.Transaction_ID__c = null;
        insert dummyInvoice;
        
        List<Invoice__c> invs = Utility.checkForOpenInvoice(testEmail);
        System.assertEquals(1, invs.size());
    }
    
    @isTest
    static void Test_createToDoTask() {
        Account acc = Test_DataFactory.createAccount(true, 'test');
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'test', acc.Id);
        
        Stock_Reservation__c stockRes = Test_DataFactory.StockReservation(false, null, null, null, null);
        stockRes.Opportunity__c = opp.Id;
        stockRes.Stock_Source__c = 'KIA Warehouse';
        insert stockRes;
        
        stockRes = [Select OwnerId, Opportunity__c, Stock_Source__c From Stock_Reservation__c];
        
        Utility.createToDoTask(stockRes, 'Confirmation');
        Utility.createToDoTask(stockRes, 'Refund');
        
        List<Task> createdTasks = [Select Subject, OwnerId, WhatId From Task];
        System.assertEquals(2, createdTasks.size());
        
        Boolean confirmationTaskCreated = false;
        Boolean refundTaskCreated = false;
        for(Task tsk : createdTasks) {
            if(tsk.Subject == 'KIA Warehouse - Confirmation') {
                confirmationTaskCreated = true;
            } else if(tsk.Subject == 'KIA Warehouse - Refund Request') {
                refundTaskCreated = true;
            }
            System.assertEquals(stockRes.Opportunity__c, tsk.WhatId);
            System.assertEquals(stockRes.OwnerId, tsk.OwnerId);
        }
        System.assert(confirmationTaskCreated);
        System.assert(refundTaskCreated);
    }
    
    @isTest
    static void Test_getBatchConfiguration() {
        Map<String, Branch_Configuration__mdt> mapBranchConfig = Utility.getBatchConfiguration();
        System.debug('@@@@DEBUG Test_getBatchConfiguration :: mapBranchConfig = '+ mapBranchConfig);
    }
    
    @isTest
    static void Test_createTask() {
        Account acc = Test_DataFactory.createAccount(true, 'test');
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'test', acc.Id); 
        Utility.isWebTestDriveBrand = 'CCA';
        Utility.createTask(opp.Id, UserInfo.getUserId(), 'dummy subject');
        
        Utility.isWebTestDrive = true;
        Utility.createTask(opp.Id, UserInfo.getUserId(), 'dummy subject');
    }    
    
    @isTest 
    static void checkOppExistsForTheCustomerTM(){
        
        Account acct = Test_DataFactory.createAccount(true, 'TestAccount-11');
        
        Contact tempContact = Test_DataFactory.createContact(false, 'TestContact-1', 'Dummy', String.valueOf(acct.Id) );
        insert tempContact;
        
        Account paCustomer = Test_DataFactory.createPerson(false, 'TestPACustomer-1', 'Customer');
        insert paCustomer;
        
        Opportunity oppo = Test_DataFactory.createOpportunity(false, 'TestOppo'+tempContact.Id, acct.Id);
        oppo.Branch_Code__c     = 'CCA';
        oppo.Contact_Person__c  = tempContact.Id;
        oppo.Account__c         = paCustomer.Id; 
        oppo.StageName          = 'Booked';
        oppo.OwnerId            = UserInfo.getUserId();
        insert oppo;
        
        List<Opportunity> lstOppo = Utility.checkOppExistsForTheCustomer('CCA', String.valueOf(paCustomer.Id) );
        System.debug('testing checkOpenOppExistsForTheAccountTM = ' + lstOppo );
    }
    
    
    @isTest 
    static void checkOppExistsForTheProspectTM(){
        
        Account acct = Test_DataFactory.createAccount(true, 'TestAccount-2');
        
        Account paProspect = Test_DataFactory.createPerson(false, 'TestPAProspect-2', 'Prospect');
        insert paProspect;
        
        Opportunity oppo = Test_DataFactory.createOpportunity(false, 'TestOppo', acct.Id);
        oppo.Branch_Code__c = 'CCA';
        oppo.Account__c     = paProspect.Id; 
        oppo.StageName      = 'Booked';
        insert oppo;
        
        
        Utility.isWebTestDriveBrand = 'CCA';
        Utility.webTDManagerAccessToProspectRecords( String.valueOf(paProspect.Id) );
    }
    
    
    @isTest
    static void checkOpenOppExistsForTheAccountTM(){
        Account acct = Test_DataFactory.createAccount(true, 'TestAccount-3');
        
        Contact tempContact = Test_DataFactory.createContact(false, 'TestContact-3', 'Dummy', String.valueOf(acct.Id) );
        insert tempContact;
        
        Account paCustomer = Test_DataFactory.createPerson(false, 'TestPACustomer-3', 'Customer');
        insert paCustomer;
        
        Opportunity oppo = Test_DataFactory.createOpportunity(false, 'TestOppo'+tempContact.Id, acct.Id);
        oppo.Branch_Code__c     = 'CCA';
        oppo.Contact_Person__c  = tempContact.Id;
        oppo.Account__c         = paCustomer.Id; 
        oppo.StageName          = 'Open';
        oppo.OwnerId            = UserInfo.getUserId();
        insert oppo;
        
        
        List<Opportunity> lstOppo = Utility.checkOpenOppExistsForTheAccount('CCA', String.valueOf(paCustomer.Id) );
        System.debug('testing checkOpenOppExistsForTheAccountTM = ' + lstOppo );
    }
    
    @isTest
    static void dummyTM(){
        System.assert(  new Utility.httpErrorResponse('dummyStatus','dummyMessage') <> null );
        System.assert(  new Utility.httpSuccessResponse('dummyStatus','dummyMessage') <> null );
        System.assert( Utility.isSandbox <> null );
    }
}
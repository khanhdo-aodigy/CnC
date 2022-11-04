/** *****
 * Description : Test Class for PaymentReceiptController
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20220926            khanh.do@aodigy.com           Created Initial Version. 
 * 
** *****/
@isTest
private with sharing class PaymentReceiptControllerTest {
    
    @testSetup
    private static void setup() {
        TriggerExclusion.excludeTrigger('Account', true);
        Account customer = Test_DataFactory.createPA(true, 'Do Phu Khanh', 'khanh.do@aodigy.test', 'Customer');
        TriggerExclusion.excludeTrigger('Account', false);
        
        // Create master data
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(true, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
   
        // Create Sales Agreement
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        Sales_Agreement__c salesAgreement = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', stockReservation.ID, 'Thieu Dang Vu');
        salesAgreement.Account__c = customer.Id;
        salesAgreement.Stage__c   = 'Pending Registration';
        salesAgreement.SOH_REGNO__c = 'AVH001NAU';
        salesAgreement.Registration_Date__c = Date.today();  
        insert salesAgreement;        
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);   
        
        //Create Sales Invoice
        Sales_Invoice__c salesInvoice = new Sales_Invoice__c();
        salesInvoice.Sales_Agreement__c = salesAgreement.Id;
        salesInvoice.Bill_To__c = customer.Id;
        salesInvoice.Branch_Code__c = 'CCK';
        insert salesInvoice;
        
    }
    
    @istest
    private static void getReceiptHeader_success() {
        Sales_Agreement__c sa = [  SELECT Id
                                   FROM Sales_Agreement__c
                                   LIMIT 1
                                 ];
        PaymentReceiptController.ReceiptHeader actualResult = PaymentReceiptController.getReceiptHeader(sa.Id);
        System.assertEquals('Sales_Agreement__c', actualResult.sObjName);
        System.assertEquals(sa.Id, actualResult.record.Id);
    }
    
    @istest
    private static void getReceiptHeader_invalidRecordId() {
        Sales_Invoice__c si = [  SELECT Id
                                   FROM Sales_Invoice__c
                                   LIMIT 1
                                 ];
        try {
            PaymentReceiptController.getReceiptHeader(si.Id);
        } catch(Exception e) { }        
    }

    @istest
    private static void getCommissionMap() {        
        Test.startTest();
        PaymentReceiptController.getCommissionMap();
        Test.stopTest();
    }

    @istest
    private static void getGstRate() {
        Date today = Date.today();
        Test.startTest();
        PaymentReceiptController.getGstRate(today);
        Test.stopTest();
    }

    @istest
    private static void createPaymentReceipt() {
        Sales_Agreement__c sa = [  SELECT Id, Account__c
                                   FROM Sales_Agreement__c
                                   LIMIT 1
                                 ];
        
        Sales_Invoice__c si = [  SELECT Id
                                   FROM Sales_Invoice__c
                                   LIMIT 1
                                 ];
        
        Payment_Receipt__c receipt  = new Payment_Receipt__c
        (
            Franchise_Code__c = 'KIAPC',
            Payment_Mode__c = 'Cash',
            Receipt_Amount__c = 10000,
            Registered_Party__c = sa.Account__c,
            Receipt_Date__c = Date.today(),
            Type__c = 'Balance Payment',
            Status__c = 'Posted',
            Bill_To__c = sa.Account__c,
            Sales_Agreement__c = sa.Id
        );
        List<PaymentReceiptController.ReceiptDetail> receiptDetails = new List<PaymentReceiptController.ReceiptDetail>();
        
        
        PaymentReceiptController.ReceiptDetail detailRow = new PaymentReceiptController.ReceiptDetail();
        detailRow.salesAgreementId   = sa.Id;
        detailRow.salesInvoiceId     = si.Id;
        detailRow.documentAmount     = 5000;
        detailRow.paymentAmount      = 5000;
       	receiptDetails.add(detailRow);
        
        Test.startTest();
        PaymentReceiptController.createPaymentReceipt(receipt, receiptDetails, true);
        Test.stopTest();
    }
    
    
    @istest
    private static void getAccountInfo() {
        TriggerExclusion.excludeTrigger('Account', true);
        Account customer = Test_DataFactory.createPA(true, 'Fap Fap', 'phap.mai@aodigy.test', 'Customer');
        TriggerExclusion.excludeTrigger('Account', false);
        Account result = PaymentReceiptController.getAccountInfo(customer.Id);
        System.assertNotEquals(null, result);
    }
    
    @istest
    private static void getReceiptDetails() {
        String franchiseCode = 'KIAPC';
		Account customer = [ SELECT Id
                             FROM Account
                             LIMIT 1
                           ];
        
        Sales_Agreement__c sa = [  SELECT Id
                                   FROM Sales_Agreement__c
                                   LIMIT 1
                                 ];
        List<Debtor_Transaction__c> debtorTransList = new List<Debtor_Transaction__c>();
        for(Integer i = 0; i < 3; i++) {
            Debtor_Transaction__c debtorTran  = new Debtor_Transaction__c();
                debtorTran.Franchise_Code__c      = franchiseCode;
                debtorTran.Billing_Account__c     = customer.Id;
                debtorTran.Transaction_Type__c    = 'Journal Transfer';
                debtorTran.Date__c                = Date.today();
                debtorTran.Credit_Debit__c        = 'Debit';
                debtorTran.Document_Amount__c     = 10000;
                debtorTran.Amount__c              = 10000;
                debtorTran.Sales_Agreement__c     = sa.Id;
       		debtorTransList.add(debtorTran);
        }
        insert debtorTransList;
        PaymentReceiptController.getReceiptDetails(customer.Id, franchiseCode);
    }
        
}
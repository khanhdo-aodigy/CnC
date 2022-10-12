/*==========================================================================================================================================================================
 * Test class for PaymentReceiptService
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           23 Sep 2022                       quy.tan@aodigy.com                    				                                          Init
 *           
 * ========================================================================================================================================================================== 
 */
@isTest
public with sharing class PaymentReceiptServiceTest {
    @TestSetup
    private static void makeData(){
        Account register = Test_DataFactory.createAccount(true, 'Supplier Account');
        Payment_Receipt__c paymentReceipt  = new Payment_Receipt__c
        (
            Franchise_Code__c = 'KIAPC',
            Payment_Mode__c = 'Cash',
            Receipt_Amount__c = 10000,
            Registered_Party__c = register.id,
            Receipt_Date__c = Date.today(),
            Type__c = 'Balance Payment',
            Status__c = 'Voided',
            Bill_To__c = register.id
        );
        insert paymentReceipt;
    }

    @istest
    private static void getPaymentReceiptsByIds_success() {
        List<Payment_Receipt__c> pr = [SELECT id FROM Payment_Receipt__c ];
        Set<Id> prId = new Set<Id>();
        for ( Payment_Receipt__c prs : pr) {
            prId.add(prs.id);
        }
        
        test.startTest();
        List<Payment_Receipt__c> prnew = PaymentReceiptService.getPaymentReceiptsByIds(prId);
        System.assert(prnew.size()>0);
        test.stopTest();
        
    }
    @istest
    private static void getPaymentReceiptsById_success() {
        Payment_Receipt__c pr = [SELECT id FROM Payment_Receipt__c LIMIT 1 ];
        Id prId = pr.id;
        test.startTest();
        System.assertNotEquals(null, PaymentReceiptService.getPaymentReceiptsById(prId));
        test.stopTest();
        
    }

    @istest
    private static void getPaymentReceiptByIdWithLineItems_success() {
        Payment_Receipt__c pr = [SELECT id FROM Payment_Receipt__c LIMIT 1 ];
        Id prId = pr.id;
        
        test.startTest();
        Payment_Receipt__c prnew = PaymentReceiptService.getPaymentReceiptByIdWithLineItems(prId, true);
        test.stopTest();
        
    }
}
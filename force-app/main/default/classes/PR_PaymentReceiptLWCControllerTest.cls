/*==========================================================================================================================================================================
 * Test class for PR_PaymentReceiptLWCController
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           23 Sep 2022                       quy.tan@aodigy.com                    				                                          Init
 *           
 * ========================================================================================================================================================================== 
 */

@isTest
public with sharing class PR_PaymentReceiptLWCControllerTest 
{
    @TestSetup
    private static void makeData(){
        Account register = Test_DataFactory.createAccount(true, 'Supplier Account');
        //Create Payment Receipt
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
    private static void voidPaymentReceiptLineItems_success() {
        Payment_Receipt__c pr = [SELECT id FROM Payment_Receipt__c LIMIT 1 ];
        Id prId = pr.id;
        Test.startTest();
        Boolean result = PR_PaymentReceiptLWCController.voidPaymentReceipt(prId,pr);
        
        Test.stopTest();
    }

    @istest
    private static void getPaymentReceiptLineItems_success() {
        Payment_Receipt__c pr = [SELECT id FROM Payment_Receipt__c LIMIT 1 ];
        Id prId = pr.id;
        Test.startTest();
        List<Payment_Receipt_Line_Item__c> result = PR_PaymentReceiptLWCController.getPaymentReceiptLineItems(prId);
        
        Test.stopTest();
    }

}
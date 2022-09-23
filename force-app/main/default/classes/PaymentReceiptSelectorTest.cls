/*==========================================================================================================================================================================
 * Test selector class for Payment Receipt Entity
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            21 Sep 2022                       nam@aodigy.com                   
 * ========================================================================================================================================================================== 
 */
@isTest 
public with sharing class PaymentReceiptSelectorTest 
{
    @TestSetup
    static void makeData()
    {       
         // create account supplier
         Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

        //Create Payment Receipt
        Payment_Receipt__c paymentReceipt  = new Payment_Receipt__c
        (
            Franchise_Code__c = 'MAXUSCV',
            Payment_Mode__c = 'Credit Card',
            Receipt_Amount__c = 10000,
            Registered_Party__c = supplier.id,
            Receipt_Date__c = Date.today(),
            Type__c = 'Vehicle Deposit',
            Status__c = 'Voided'
        );
        insert paymentReceipt;     
    }

     /**
     * Get Payment Receipt together with Payment Receipt Line Item via correct PR Id
     * Expected: correct Payment Receipt retrieved together with related PRLI
     */
    @IsTest
    private static void getPaymentReceiptByIdWithLineItems_success()
    {
        Payment_Receipt__c paymentReceipt = [SELECT Id FROM Payment_Receipt__c LIMIT 1];
        PaymentReceiptSelector sel = new PaymentReceiptSelector();
        Test.startTest();
            Payment_Receipt__c result = sel.getPaymentReceiptByIdWithLineItems(paymentReceipt.Id,true);
        Test.stopTest();   
    }
}
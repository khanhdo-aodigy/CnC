/*==========================================================================================================================================================================
 * Controller class for LWC in Payment Receipt module
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           19 Sep 2022                       dong.nguye@aodigy.com                    US-PR-000022                                          Init
 *           19 Sep 2022                       phan.thu@aodigy.com                    	US-PR-000022                                     Added getPaymentReceiptLineItems, voidPaymentReceiptLineItems methods
 * ========================================================================================================================================================================== 
 */

public inherited sharing class PR_PaymentReceiptLWCController 
{
    @AuraEnabled
    public static Boolean voidPaymentReceipt(Id paymentReceiptId, Payment_Receipt__c updatedPaymentReceipt)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Credit_Note__c.SObjectType,
                                                                                            Voided_Payment_Receipt__c.SObjectType,    
                                                                                            Payment_Receipt__c.SObjectType});

        try 
        {
            Payment_Receipt__c paymentReceipt = PaymentReceiptService.getPaymentReceiptsByIds(new Set<Id>{paymentReceiptId})?.get(0);

            Credit_Note__c newCreditNote = new Credit_Note__c(Account__c                = paymentReceipt?.Bill_To__c,
                                                            Credit_Debit__c             = 'Credit',
                                                            Sales_Agreement__c          = paymentReceipt?.Sales_Agreement__c,
                                                            Voided_Payment_Receipt__c   = paymentReceipt?.Id,
                                                            Debit_Credit_Note_Amount__c = paymentReceipt?.Total_Receipt_Amount__c,
                                                            Credit_Debit_Note_Type__c   = getCreditDebitNoteType(paymentReceipt?.Type__c),
                                                            GST__c                      = paymentReceipt?.GST_Percentage__c <> null ? Decimal.valueOf(paymentReceipt?.GST_Percentage__c) : null);

            uow.registerNew(newCreditNote);

            Voided_Payment_Receipt__c newVoidedPR = new Voided_Payment_Receipt__c(Payment_Receipt__c = paymentReceiptId,
                                                                                Sales_Agreement__c   = paymentReceipt?.Sales_Agreement__c,
                                                                                Void_Date__c         = Date.today(),
                                                                                Void_Payment_Mode__c = paymentReceipt?.Payment_Mode__c,
                                                                                Void_Payment_Type__c = paymentReceipt?.Type__c,
                                                                                Payment_Amount__c    = paymentReceipt?.Receipt_Amount__c);

            uow.registerNew(newVoidedPR);  
            uow.registerRelationship(newVoidedPR, Voided_Payment_Receipt__c.Credit_Debit_Note__c, newCreditNote);

            uow.registerDirty(updatedPaymentReceipt);
           
            uow.commitWork();
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage() + ' -- ' + e.getLineNumber());
        }

        return true;
    }

    @AuraEnabled(cacheable = true)
    public static List<Payment_Receipt_Line_Item__c> getPaymentReceiptLineItems(Id paymentReceiptId)
    {
        try 
        {
            Payment_Receipt__c paymentReceipt = PaymentReceiptService.getPaymentReceiptByIdWithLineItems(paymentReceiptId, true);

            return paymentReceipt?.Payment_Receipt_Line_Items_del__r;
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getCreditDebitNoteType(String paymentReceiptType)
    {
        String creditDebitNote = '';

        switch on paymentReceiptType {
            when 'Balance Payment' 
            {
                creditDebitNote = 'VOID BALANCE PAYMENT';
            }
            when 'COE Deposit'
            {
                creditDebitNote = 'VOID COE DEPOSIT';
            }
            when 'Vehicle Deposit'
            {
                creditDebitNote = 'VOID VEHICLE DEPOSIT';
            }
        }

        return creditDebitNote;
    }
}
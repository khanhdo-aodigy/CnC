/*==========================================================================================================================================================================
 * Service class for Payment Receipt Entity
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            14 Sep 2022                       phan.thu@aodigy.com                    US-PR-000022                                            Init
 * ========================================================================================================================================================================== 
 */

public inherited sharing class PaymentReceiptService 
{
    private static PaymentReceiptSelector sel = new PaymentReceiptSelector();

    public static Payment_Receipt__c getPaymentReceiptsById(Id recordId)
    {
        List<Payment_Receipt__c> paymentReceiptList = getPaymentReceiptsByIds(new Set<Id>{recordId});
        return  paymentReceiptList.size() > 0 ? paymentReceiptList[0] : null;
    }

    public static List<Payment_Receipt__c> getPaymentReceiptsByIds(Set<Id> recordIds)
    {
        return sel.selectSObjectsById(recordIds);
    }

    public static Payment_Receipt__c getPaymentReceiptByIdWithLineItems(Id recordId, Boolean withLineItems)
    {
        return sel.getPaymentReceiptByIdWithLineItems(recordId, withLineItems);
    }
}
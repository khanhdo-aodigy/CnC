/*******
 * Description : Service class for  Invoice Promo Line Item object
 * 
 * Change History :
 * Date(YYYYMMDD)      Name                    Description
 * 20220424         thu.phan@aodigy.com     Created Initial Version 
*******/

public class InvoicePromoLineItemService 
{
    @AuraEnabled(cacheable = true)
    public static List<Invoice_Promo_Line_Item__c> getRelatedPromoLineItems(String recordId)
    {
        List<Invoice_Promo_Line_Item__c> invoiceItems = new List<Invoice_Promo_Line_Item__c>();

        try 
        {               
            List<Invoice__c> invoices = [SELECT Id, (SELECT Id, Promo_Line_Item__c, Promo_Line_Item__r.No_of_Stock__c, Quantity__c FROM Invoice_Promo_Line_Items__r) FROM Invoice__c WHERE Sales_Agreement__c =: recordId];

            if (invoices <> null && !invoices.isEmpty())
            {
                for (Invoice__c invoice : invoices)
                {
                    if (invoice.Invoice_Promo_Line_Items__r <> null && !invoice.Invoice_Promo_Line_Items__r.isEmpty())
                    {
                        invoiceItems.addAll(invoice.Invoice_Promo_Line_Items__r);
                    }
                }
            }

            return invoiceItems;
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
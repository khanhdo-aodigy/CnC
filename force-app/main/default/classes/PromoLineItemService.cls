/*******
 * Description : Service class for Promo Line Item object
 * 
 * Change History :
 * Date(YYYYMMDD)      Name                    Description
 * 20220324         thu.phan@aodigy.com     Created Initial Version 
*******/

public class PromoLineItemService 
{
    private static PromoLineItemSelector sel = new PromoLineItemSelector();

    public static List<Promo_Line_Item__c> getPromoLineItemsByIds (Set<String> recordIds)
    {
        return sel.getPromoLineItemsByIds(recordIds);
    }

    @AuraEnabled
    public static Boolean updatePromoLineItemQuantity(List<Invoice_Promo_Line_Item__c> records, String sAId)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Promo_Line_Item__c.SObjectType,
                                                                                            Sales_Agreement__c.SObjectType,
                                                                                            Stock_Reservation__c.SObjectType});       
        try 
        {              
            Sales_Agreement__c sA = [SELECT Stock_Reservation__c, Owner.Id, Owner.FirstName, Name FROM Sales_Agreement__c WHERE ID =: sAId LIMIT 1];
            uow.registerDirty(updateSalesAgreement(sAId));
            uow.registerDirty(updateSR(sA.Stock_Reservation__c));
            uow.registerDirty(updatePromoLineItem(records));

            uow.commitWork();

            sendEmailForRefund(sA.Owner.Id, 'Notification_to_Refund_for_Upsell_Accs', sA.Owner.FirstName, sA.Name);
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }
    
    @AuraEnabled
    public static Boolean cancelSA(String sAId)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Sales_Agreement__c.SObjectType, 
                                                                                            Stock_Reservation__c.SObjectType});       
        try 
        {
            Sales_Agreement__c sA = [SELECT Stock_Reservation__c FROM Sales_Agreement__c WHERE ID =: sAId LIMIT 1];
            uow.registerDirty(updateSalesAgreement(sAId));
            uow.registerDirty(updateSR(sA.Stock_Reservation__c));

            uow.commitWork();
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }

    @AuraEnabled
    public static Boolean transferUpsellAccs(List<Invoice_Promo_Line_Item__c> records, String oldSAId, String newSANo)
    {
        ADGLIB_SObjectUnitOfWork uow    = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Promo_Line_Item__c.SObjectType,
                                                                                                Sales_Agreement__c.SObjectType,
                                                                                                Stock_Reservation__c.SObjectType,
                                                                                                Invoice__c.SObjectType});       
        List<Sales_Agreement__c> oldSAs = new List<Sales_Agreement__c>();
        List<Sales_Agreement__c> newSAs = new List<Sales_Agreement__c>();
        Boolean isPaymentTransferred    = false;

        try 
        {
            oldSAs = [SELECT Id, Stock_Reservation__r.Model_Code__c , Stock_Reservation__c, Stage__c, Owner.Id, Owner.FirstName, Name, (SELECT Sales_Agreement__c FROM Payments__r) FROM Sales_Agreement__c WHERE Id =: oldSAId LIMIT 1];
            newSAs = [SELECT Id, Stock_Reservation__r.Model_Code__c FROM Sales_Agreement__c WHERE Name =: newSANo LIMIT 1];

            uow.registerDirty(updateSalesAgreement(oldSAId));
            uow.registerDirty(updateSR(oldSAs.get(0).Stock_Reservation__c));
            
            if (newSAs <> null && !newSAs.isEmpty())
            {
                if (oldSAs.get(0).Stock_Reservation__r.Model_Code__c <> newSAs.get(0).Stock_Reservation__r.Model_Code__c)
                {
                    uow.registerDirty(updatePromoLineItem(records));
                    sendEmailForRefund(oldSAs.get(0).Owner.Id, 'Notification_to_Refund_for_Upsell_Accs', oldSAs.get(0).Owner.FirstName, oldSAs.get(0).Name);
                }
                else 
                {
                    uow.registerDirty(updateInvoices(oldSAs.get(0).Payments__r, newSAs.get(0).Id));
                    isPaymentTransferred = true;
                }
            }

            uow.commitWork();
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
        }

        return isPaymentTransferred;
    }

    public static void sendEmailForRefund(String userId, String template, String firstName, String sANo)
    {
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =: template];
        OrgWideEmailAddress add     = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg'];
    
        String htmlBody = emailTemplate.HtmlValue;          
        htmlBody = htmlBody.replace('{!Receiving_User.CustomerName__c}', firstName);
        htmlBody = htmlBody.replace('{!Sales_Agreement__c.Name}', sANo);
        
        Messaging.SingleEmailmessage email = new Messaging.SingleEmailmessage();
        email.setOrgWideEmailAddressId(add.Id);
        email.setTargetObjectId(userId);
        email.setSaveAsActivity(false);
        email.setSubject(emailTemplate.Subject);
        email.setHtmlBody(htmlBody);

        Messaging.sendEmail(new List<Messaging.SingleEmailmessage> {email});        
    }

    public static List<Promo_Line_Item__c> updatePromoLineItem(List<Invoice_Promo_Line_Item__c> records)
    {
        Map<Id, Promo_Line_Item__c> updatedPromoItems = new Map<Id, Promo_Line_Item__c>();
        Set<Id> invoiceItemIds                        = new Set<Id>();
        Promo_Line_Item__c updatedPromoItem           = new Promo_Line_Item__c();

        for (Invoice_Promo_Line_Item__c invoiceItem : records)
        {
            invoiceItemIds.add(invoiceItem.Id);
        }

        Map<Id, Invoice_Promo_Line_Item__c> invoiceItems = new Map<Id, Invoice_Promo_Line_Item__c> ([SELECT Id, Payment__c, Payment__r.Transaction_Status__c FROM Invoice_Promo_Line_Item__c WHERE ID IN: invoiceItemIds]);
        
        for (Invoice_Promo_Line_Item__c invoiceItem : records)
        {
            if (invoiceItems.get(invoiceItem.Id).Payment__r.Transaction_Status__c <> null && invoiceItems.get(invoiceItem.Id).Payment__r.Transaction_Status__c <> 'processor_declined')
            {
                if (updatedPromoItems.containsKey(invoiceItem.Promo_Line_Item__c))
                {
                    updatedPromoItem = updatedPromoItems.get(invoiceItem.Promo_Line_Item__c);
                    updatedPromoItem.No_of_Stock__c += invoiceItem.Quantity__c;
                    updatedPromoItems.put(invoiceItem.Promo_Line_Item__c, updatedPromoItem);
                }
                else 
                {
                    updatedPromoItems.put(invoiceItem.Promo_Line_Item__c, new Promo_Line_Item__c(Id = invoiceItem.Promo_Line_Item__c, 
                                                                                                No_of_Stock__c = invoiceItem.Promo_Line_Item__r.No_of_Stock__c + invoiceItem.Quantity__c));
                }
            }
        }
        
        return updatedPromoItems.values();
    }

    public static List<Invoice__c> updateInvoices (List<Invoice__c> records, String sAId)
    {
        if (records <> null && records.size() > 0)
        {
            for (Invoice__c inv : records)
            {
                inv.Sales_Agreement__c = sAId;
            }
        }

        return records;
    }

    public static Sales_Agreement__c updateSalesAgreement(String sAId)
    {
        return new Sales_Agreement__c (Id = sAId, Stage__c = 'Cancelled');
    }

    public static Stock_Reservation__c updateSR(String stockResId)
    {
        return new Stock_Reservation__c(Id = stockResId, Reservation_Status__c = 'Cancel', Cancellation_Reason__c = 'Sales Agreement has been cancelled.');
    }
}
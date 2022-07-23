/** ******
 * Description: This trigger will consolidate all Opportunity-related logic.
 *              Please call any Business Logic class/methods in the TriggerHandler.
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		    Description
 * 20190807             Cycle & Carriage        Created Initial Version. 
 * 20190716             CGaylan                 This trigger does not follow best practices. Before Trigger was added for Insert.
 * 20200221			    HS					    Added isBypassTriggerExecution to perform additional check based on mdt data setup to bypass Trigger execution
 * 20220406             TPhan@aodigy.com        Added condition to afterUpdate trigger for Sales Targeted Promo Invoice PDF to be created.
 * 20220422             TPhan@aodigy.com        Added Amount w/o GST and GST calculation to Before Insert trigger.
** ******/
trigger PaymentTrigger on Invoice__c (before insert,after insert,after update) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    //Trigger exclusion check
    if( TriggerExclusion.isTriggerExclude('Payment')
         || TriggerExclusion.isTriggerExclude('Invoice__c') 
            || TriggerExclusion.isBypassTriggerExecution('Invoice__c') 
                || automationSetting.Bypass_Triggers__c
    )
    {
        return;
    }

    
    if (Trigger.isAfter && Trigger.isUpdate)
    {
        System.debug('Start!');
        for(Invoice__c inv : Trigger.new)
        {
            System.debug('Invoice: ' + inv);
            if  (inv.Campaign__c != null  
                    && (inv.Campaign_Type__c == 'Promotions' || inv.Campaign_Type__c == 'Evergreen Promotion' || inv.Campaign_Type__c == 'Sales Targeted Promo') 
                        && Trigger.oldmap.get(inv.id).TC_Val__c == null && inv.TC_Val__c != null && inv.Payment_Type__c != 'Receipt')
            {  
                try 
                {          
                    if(inv.Department__c == 'CCI') 
                    {
                        System.enqueueJob(new Invoice_Save_Copy_CCI(inv.id,inv.Invoice_Number__c));   
                    } 
                    else 
                    {
                        System.enqueueJob(new Invoice_Save_Copy_PDF_Future(inv.id,inv.Invoice_Number__c));    
                    }                             
                }
                catch(exception e)
                {
                    loggerDataPool.buildLogDataPool('Trigger_InvoiceSave_PDF', e);
                }
            }
        }  
        
        try 
        {
            List<Invoice__c> invoices = [SELECT Campaign__r.Sales_Targeted_Promo_Type__c,
                                                Campaign__r.RecordType.DeveloperName, Campaign__r.Type,
                                                Id, Transaction_Status__c, Campaign__c, Sales_Agreement__c, Contact__c
                                        FROM Invoice__c 
                                        WHERE ID IN: Trigger.new];
            Set<Id> successInvoiceIds = new Set<Id>();
            List<Id> contactIds       = new List<Id>();
            List<Id> sAIds            = new List<Id>();
            List<Id> campIds          = new List<Id>(); 
            
            for (Invoice__c inv : invoices)
            {
                if (inv.Campaign__r.RecordType.DeveloperName == 'C_C_Campaign_RT_Sales_Targeted_Promo' 
                    && inv.Campaign__r.Type == 'Sales Targeted Promo'
                            && (Trigger.oldmap.get(inv.Id).Transaction_Status__c <> inv.Transaction_Status__c
                                && (inv.Transaction_Status__c <> null && inv.Transaction_Status__c <> 'processor_declined')
                                    && Trigger.oldmap.get(inv.Id).Transaction_Status__c == null))
                {
                    if (inv.Campaign__r.Sales_Targeted_Promo_Type__c == 'Multiple')
                    {
                        successInvoiceIds.add(inv.Id);
                    }

                    contactIds.add(inv.Contact__c);
                    sAIds.add(inv.Sales_Agreement__c);
                    campIds.add(inv.Campaign__c);
                  
                }
            }  
            
            if (successInvoiceIds.size() > 0)
            {
                Set<Id> promoItemIds                          = new Set<Id>();
                Map<Id, Promo_Line_Item__c> updatedPromoItems = new Map<Id, Promo_Line_Item__c>();
                Map<Id, Sales_Agreement__c> updatedSAs        = new Map<Id, Sales_Agreement__c>();
                Promo_Line_Item__c updatedPromoItem           = new Promo_Line_Item__c();
                Sales_Agreement__c tempSA                     = new Sales_Agreement__c();
                List<Invoice_Promo_Line_Item__c> invoiceItems = [SELECT Id, Quantity__c, Promo_Line_Item__c, Total_Commission_Value__c,
                                                                        Payment__r.Sales_Agreement__c, Payment__r.Sales_Agreement__r.Targeted_Promo_Commission__c 
                                                                FROM Invoice_Promo_Line_Item__c
                                                                WHERE Payment__c IN: successInvoiceIds];
               
                if (invoiceItems <> null && invoiceItems.size() > 0)
                {
                    for (Invoice_Promo_Line_Item__c item : invoiceItems)
                    {
                        promoItemIds.add(item.Promo_Line_Item__c);
                    }

                    Map<Id, Promo_Line_Item__c> promoItems = new Map<Id, Promo_Line_Item__c>([SELECT Id, No_of_Stock__c FROM Promo_Line_Item__c WHERE ID IN: promoItemIds]);
                    System.debug('promoItems: ' + promoItems);

                    for (Invoice_Promo_Line_Item__c item : invoiceItems)
                    {
                        if (!updatedPromoItems.containsKey(item.Promo_Line_Item__c))
                        {
                            updatedPromoItems.put(item.Promo_Line_Item__c, 
                                                  new Promo_Line_Item__c(Id = item.Promo_Line_Item__c, 
                                                                        No_of_Stock__c = promoItems.get(item.Promo_Line_Item__c).No_of_Stock__c - item.Quantity__c));
                        }
                        else 
                        {
                            updatedPromoItem = updatedPromoItems.get(item.Promo_Line_Item__c);
                            updatedPromoItem.No_of_Stock__c -= item.Quantity__c;
                            updatedPromoItems.put(item.Promo_Line_Item__c, updatedPromoItem);
                        }

                        if (updatedSAs.containsKey(item.Payment__r.Sales_Agreement__c))
                        {
                            tempSA = updatedSAs.get(item.Payment__r.Sales_Agreement__c);
                            tempSA.Targeted_Promo_Commission__c += item.Total_Commission_Value__c;
                            updatedSAs.put(item.Payment__r.Sales_Agreement__c, tempSA);
                        }
                        else
                        {
                            Decimal com = (item.Payment__r.Sales_Agreement__r.Targeted_Promo_Commission__c > 0) && (item.Payment__r.Sales_Agreement__r.Targeted_Promo_Commission__c <> null)
                                            ? (item.Payment__r.Sales_Agreement__r.Targeted_Promo_Commission__c + (item.Total_Commission_Value__c))
                                            : (item.Total_Commission_Value__c);
    
                            updatedSAs.put(item.Payment__r.Sales_Agreement__c, new Sales_Agreement__c(Id = item.Payment__r.Sales_Agreement__c,
                                                                                                      Targeted_Promo_Commission__c = com));
                        }
                    }

                    update updatedPromoItems.values();
                    update updatedSAs.values();
                }
            }
            System.debug('***********' + contactIds + '**********' + sAIds + '************' + campIds);
            if (contactIds.size() > 0 && sAIds.size() > 0 && campIds.size() > 0)
            {
                List<Campaign_Member_Vehicle__c> campaignMems = new List<Campaign_Member_Vehicle__c>();
                
                campaignMems = [SELECT Id, Purchased__c, Purchased_Date__c
                                FROM Campaign_Member_Vehicle__c 
                                WHERE Contact__c IN: contactIds
                                    AND Campaign__c IN: campIds 
                                    AND Sales_Agreement__c IN: sAIds];

                if (!campaignMems.isEmpty())
                {
                    for (Campaign_Member_Vehicle__c member : campaignMems)
                    {
                        member.Purchased__c      = true;
                        member.Purchased_Date__c = Date.today();  
                    }
                    
                    update campaignMems;
                }
            }
        }
        catch (Exception e)
        {
            System.debug('PaymentTrigger - updateUpsellAccStock :: Error: ' + e.getMessage() + e.getLineNumber());
            loggerDataPool.buildLogDataPool('PaymentTrigger - updateUpsellAccStock', e);
        }       
    }
    
    if(Trigger.isBefore && Trigger.isInsert) 
    {
        List<Invoice__c> invoices = new List<Invoice__c>();

        for(Invoice__c inv : Trigger.new) 
        {
            if( String.isNotBlank(inv.Campaign_ID__c) && inv.Campaign_ID__c != 'N/A' ) 
            {
                inv.Campaign__c = inv.Campaign_ID__c;
            }

            invoices.add(inv);
        }

        InvoiceNumberService.setInvNo(invoices);
        InvoiceNumberService.markAnyDuplicates(invoices);
    }
    
    if(Trigger.isAfter && Trigger.isInsert) 
    {
        List<Invoice__c> invoices = new List<Invoice__c>();
        Decimal GST               = Decimal.valueOf(Label.GST);
        System.debug('BeforeInsert: ' + GST);

        Map<Id, Invoice__c> invoiceLst = new Map<Id, Invoice__c>([SELECT Campaign__c, Campaign__r.Type FROM Invoice__c WHERE ID IN: Trigger.new]);

        for (Invoice__c inv : Trigger.new)
        {
            Invoice__c updatedInvoice = new Invoice__c();

            if (inv.Payment_Type__c == 'Invoice' 
                || ( invoiceLst.get(inv.Id).Campaign__c <> null 
                    && (invoiceLst.get(inv.Id).Campaign__r.Type == 'Paid Event' 
                        || invoiceLst.get(inv.Id).Campaign__r.Type == 'Promotions' 
                            || invoiceLst.get(inv.Id).Campaign__r.Type == 'Evergreen Promotion' 
                                || invoiceLst.get(inv.Id).Campaign__r.Type == 'Sales Targeted Promo'))
                                    || inv.Event__c == 'E-Shop')
            {
                System.debug('***************' + inv.Amount_With_GST__c + '******************' + GST);
                if (inv.Amount_With_GST__c <> null)
                {
                    updatedInvoice.Amount_wo_GST__c = (inv.Amount_With_GST__c / (1 + GST)).setScale(2);
                    updatedInvoice.GST_Value__c     = (inv.Amount_With_GST__c * (GST / (1 + GST))).setScale(2);
                }
            }
            else 
            {
                updatedInvoice.Amount_wo_GST__c = inv.Amount_With_GST__c;
                updatedInvoice.GST_Value__c     = 0;
            }

            updatedInvoice.Id = inv.Id;

            invoices.add(updatedInvoice);
        }

        TriggerExclusion.excludeTrigger('Invoice__c', true);
        update invoices;
        TriggerExclusion.excludeTrigger('Invoice__c', false);

		InvoiceNumberService.emailNotifyOfDuplicates(Trigger.new);
    }
}
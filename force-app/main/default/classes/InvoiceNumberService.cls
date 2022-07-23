public inherited sharing class InvoiceNumberService {

    public static void setInvNo(List<Invoice__c> invoices) {
        Map<String, List<Invoice__c>> invoicesByCampaignId = new Map<String, List<Invoice__c>>();
        for(Invoice__c inv : invoices) {
            if(invoicesByCampaignId.containsKey(inv.Campaign__c)) {
                invoicesByCampaignId.get(inv.Campaign__c).add(inv);
            } else {
                invoicesByCampaignId.put(inv.Campaign__c, new List<Invoice__c>{inv});
            }
        }
        
        setInvNo(invoicesByCampaignId);
    }
    
    private static void setInvNo(Map<String, List<Invoice__c>> invoicesByCampaignId) {
        String template = 'SG-{0}-{1}-{2}';
		Map<Id, Campaign> campaignById = new Map<Id, Campaign>([
        	Select CampaignId__c, Promotion_Type__c From Campaign Where Id In :invoicesByCampaignId.keySet()
        ]);

        for(String campaignId : invoicesByCampaignId.keySet()) 
        {
            String campaignExternalId = '';
            String cciPromoCode = '';
            if(campaignById.containsKey(campaignId)) 
            {
                Campaign camp = campaignById.get(campaignId);
                campaignExternalId = camp.CampaignId__c != null ? camp.CampaignId__c : '';
                campaignExternalId = campaignExternalId.replaceAll('CID', '');
                
                switch on camp.Promotion_Type__c {
                    when 'Service Package' {
                        cciPromoCode = '-SVCP';
                    }
                    when 'Merchandise' {
                        cciPromoCode = '-MER';
                    }
                    when 'One Time Purchase' {
                        cciPromoCode = '-OTP';
                    }                            
                }
            }
            
            for(Invoice__c inv : invoicesByCampaignId.get(campaignId)) 
            {
                String department = inv.Department__c != null ? inv.Department__c : '';
                String seqNo = inv.SeqNum__c != null ? String.valueOf(inv.SeqNum__c) : '';
                if(department != 'CCI') 
                {
                    seqNo = seqNo.leftPad(8, '0');
				}
                
                if(inv.SequenceIdentifier__c == 'AfterSales' || inv.SequenceIdentifier__c == 'Paid Event' || inv.SequenceIdentifier__c == 'Sales Targeted Promo') 
                {
                    String identifier = inv.SequenceIdentifier__c == 'AfterSales' ? 'AFT' : (inv.SequenceIdentifier__c == 'Sales Targeted Promo' ? 'STP' : 'EVT');
                    
                    if(department == 'CCI') 
                    {
						identifier += cciPromoCode;
                    }

                    // Example outputs: SG-CCI-AFT-OTP-223-54, SG-CCF-AFT-203-00000020
                    inv.Inv_No__c = String.format(template, new List<String>{department, identifier + campaignExternalId, seqNo});
                } 
                else 
                {
                    Integer month = System.today().month();
                    String monthStr = String.valueOf(month).leftPad(2, '0');
                    Integer year = System.today().year();
                    String yearStr = String.valueOf(year).right(2);

                    // Example outputs: SG-CCI-0420-212, SG-CCF-0420-00000212
                    inv.Inv_No__c = String.format(template, new List<String>{department, monthStr + yearStr, seqNo});
                }
            }
        }
    }
    
    public static void markAnyDuplicates(List<Invoice__c> newInvoices) {
        Map<String, List<Invoice__c>> newInvoicesByInvNo = new Map<String, List<Invoice__c>>();
        
        for(Invoice__c inv : newInvoices) {
            // Some invoices without Sequence Number legitimately have duplicates
            if(inv.SeqNum__c == null) {
                continue;
			}
            
            if(newInvoicesByInvNo.containsKey(inv.Inv_No__c)) {
                newInvoicesByInvNo.get(inv.Inv_No__c).add(inv);
            } else {
                newInvoicesByInvNo.put(inv.Inv_No__c, new List<Invoice__c>{inv});
            }
        }
        
        // Mark any duplicates found within the array of new Invoices with reference to each other
        // Otherwise, in-memory duplicate Invoices which are not yet persisted to DB might go undetected
        for(String invNo : newInvoicesByInvNo.keySet()) {
            List<Invoice__c> newInvs = newInvoicesByInvNo.get(invNo);
            if(newInvs.size() > 1) {
                for(Invoice__c inv : newInvs) {
                    inv.Duplicate__c = true;
                }
                
                // Safely remove them from collection, since Invoices already marked as duplicate, to optimize SOQL row count below
                newInvoicesByInvNo.remove(invNo);
            }
        }

        // Mark any new Invoices as duplicates if existing Invoice found in DB
        for(Invoice__c existingInv : [Select Inv_No__c, Invoice_Number__c From Invoice__c
                                      Where Inv_No__c In :newInvoicesByInvNo.keySet()
                                      Or Invoice_Number__c In :newInvoicesByInvNo.keySet()])
        {
            if(newInvoicesByInvNo.containsKey(existingInv.Inv_No__c)) {
                List<Invoice__c> newInvs = newInvoicesByInvNo.get(existingInv.Inv_No__c);
                newInvs[0].Duplicate__c = true;
            }
            if(newInvoicesByInvNo.containsKey(existingInv.Invoice_Number__c)) {
                List<Invoice__c> newInvs = newInvoicesByInvNo.get(existingInv.Invoice_Number__c);
                newInvs[0].Duplicate__c = true;
            }
        }
    }
    
    public static void emailNotifyOfDuplicates(List<Invoice__c> invoices) {
        List<EmailTemplate> templates = [Select Id From EmailTemplate Where Name = 'Duplicate Invoice Notification'];
        List<Email_Recipients__mdt> recipients = [Select BCC_Addresses__c, CC_Addresses__c, Recipient_Addresses__c From Email_Recipients__mdt
                                                  Where DeveloperName = 'ITD'];
        if(templates.isEmpty() || recipients.isEmpty()) {
            return;
        }
        
        List<Invoice__c> duplicateInvoices = new List<Invoice__c>();
        for(Invoice__c inv : invoices) {
            if(inv.Duplicate__c) {
                duplicateInvoices.add(inv);
            }
        }
        
        if(!duplicateInvoices.isEmpty()) {
            List<String> toAddresses = getEmailAddresses(recipients[0], 'Recipient_Addresses__c');
            List<String> ccAddresses = getEmailAddresses(recipients[0], 'CC_Addresses__c');    
            List<String> bccAddresses = getEmailAddresses(recipients[0], 'BCC_Addresses__c');      

            Id templateId = templates[0].Id;
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
            try {            
                for(Invoice__c inv : duplicateInvoices) {
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, null, inv.Id);
                    email.setSenderDisplayName('Salesforce Automated Email');
                    email.setToAddresses(toAddresses);
                    email.setCcAddresses(ccAddresses);
                    email.setBccAddresses(bccAddresses);
                    email.setSaveAsActivity(false);
                    emailsToSend.add(email);
                }       
                
                Messaging.sendEmail(emailsToSend);                
            } catch(Exception e) {
                System.debug(e);
            }
        }
    }
    
    private static List<String> getEmailAddresses(Email_Recipients__mdt recipients, String fldName) {
        List<String> addresses = new List<String>();
        String addressesFldValue = (String)recipients.get(fldName);
        
        if(String.isBlank(addressesFldValue)) {
            return addresses;
        } else {
            return addressesFldValue.split(';');
        }
    }

}
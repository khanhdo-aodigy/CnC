/** ******
 * Description: Trigger handler for the Promo_Line_Item__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20220415           TPhan@aodigy.com    Created Initial Version. 
** ******/

public class PromoLineItems extends ADGLIB_SObjectDomain
{
    public PromoLineItems(List<Promo_Line_Item__c> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new PromoLineItems(sObjectList);
		}
	}

    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
        sendEmailWhenThresholdAmountIsReached(existingRecords);
    }

    private void sendEmailWhenThresholdAmountIsReached(Map<Id,SObject> existingRecords)
    {
        Set<Id> promoItemIds = new Set<Id>();
        Contact dummyContact;

        try 
        {
            for (Promo_Line_Item__c item: (List<Promo_Line_Item__c>) Records)
            {
                Promo_Line_Item__c oldItem =  (Promo_Line_Item__c) existingRecords.get(item.Id);
                if ((item.No_of_Stock__c <> null && oldItem.No_of_Stock__c <> item.No_of_Stock__c) && (item.No_of_Stock__c <= item.Threshold_Amount__c))
                {
                    promoItemIds.add(item.Id);
                }
            }
    
            if (promoItemIds.size() > 0)
            {
                List<Messaging.SingleEmailmessage> emails   = new List<Messaging.SingleEmailmessage>();
                EmailTemplate emailTemplate                 = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Sales_Targeted_Items_In_Low_Stock'];
                OrgWideEmailAddress add                     = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg'];
                List<Promo_Line_Item__c> lowStockPromoItems = [SELECT Id, (SELECT Id, Campaign__c, Campaign__r.Owner.Email FROM Campaign_Promo_Line_Items__r) FROM Promo_Line_Item__c WHERE Id IN: promoItemIds];
                
                dummyContact = new Contact (LastName = 'Sales Targeted Dummy Contact');
                insert dummyContact; 
    
                for (Promo_Line_Item__c item : lowStockPromoItems)
                {
                    if (item.Campaign_Promo_Line_Items__r <> null && item.Campaign_Promo_Line_Items__r.size() > 0)
                    {
                        for (Campaign_Promo_Line_Item__c campaignItem : item.Campaign_Promo_Line_Items__r)
                        {
                            emails = addEmail(emails, emailTemplate.Id, add.Id, campaignItem.Campaign__c, dummyContact.Id, campaignItem.Campaign__r.Owner.Email);
                        }
                    }
                }
                
                if (emails.size() > 0)
                {
                    Messaging.sendEmail(emails); 
                }     
            }
        } 
        catch (Exception ex)
        {
            loggerDataPool.buildLogDataPool('PromoLineItems sendEmailWhenThresholdAmountIsReached', ex);
            System.debug ('@@@@DEBUG PromoLineItems :: sendEmailWhenThresholdAmountIsReached Exception :: err.msg = ' + ex.getMessage() + ' || err.cause = ' + ex.getCause() + ' || err.line : ' + ex.getLineNumber() );
        }       
        finally
        {
            if (dummyContact <> null) delete dummyContact;
        }
    }

    private static List<Messaging.SingleEmailMessage> addEmail(List<Messaging.SingleEmailMessage> mailList, String emTemplateId, String orgWideEmailAddressId, String recordId, String contactId, String suppliedEmail) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emTemplateId);
        mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        mail.setSaveAsActivity(true);
        mail.setTargetObjectId(contactId);
        mail.setToAddresses(new List<String>{suppliedEmail});
        mail.setWhatId(recordId);
        mail.setTreatTargetObjectAsRecipient(false);
        
        mailList.add(mail);
        
        return mailList;
    }
}
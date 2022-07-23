/** ******
 * Description: Trigger handler for the Campaign_Member_Vehicle__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20220415           TPhan@aodigy.com    Created Initial Version. 
** ******/

public class CampaignMemberAndVehicles extends ADGLIB_SObjectDomain
{
    public CampaignMemberAndVehicles(List<Campaign_Member_Vehicle__c> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new CampaignMemberAndVehicles(sObjectList);
		}
	}

    public override void onAfterInsert()
    {
        createCustomerAlerts();
    }

    private void createCustomerAlerts()
    {
        List<String> campaignsNoTC        = new List<String>();
        List<CustomerAlerts__c> newAlerts = new List<CustomerAlerts__c>();
        
        Map<String,Schema.RecordTypeInfo> recType     = BroadcastController.getCustomerAlertRtByDeveloperName();
        List<Campaign_Member_Vehicle__c> campaignMems = [SELECT Campaign__c, Campaign__r.TC_Val__c, Campaign__r.Sales_Targeted_Promo_Type__c, Campaign__r.Deep_Linking_URL__c,
                                                                Campaign__r.RecordType.DeveloperName, Campaign__r.Type, Campaign__r.Promo_Inbox_Text__c,
                                                                Contact__c, Contact__r.AccountId
                                                        FROM Campaign_Member_Vehicle__c 
                                                        WHERE ID IN: Trigger.new];

        for (Campaign_Member_Vehicle__c member: campaignMems)
        {
            if (member.Campaign__r.RecordType.DeveloperName == 'C_C_Campaign_RT_Sales_Targeted_Promo' && member.Campaign__r.Type == 'Sales Targeted Promo')
            {
                newAlerts.add(new CustomerAlerts__c(Name = 'Notification',
                                                    Date__c = System.today(),
                                                    DateTime__c = System.now(),
                                                    Status__c = 'unread',
                                                    isAlert__c = true,
                                                    isEmail__c = false,
                                                    isPush__c = false,
                                                    isSMS__c = false,
                                                    Type__c = 'Broadcast',
                                                    Account__c = member.Contact__r.AccountId,
                                                    Contact__c = member.Contact__c,
                                                    Alert_Description__c = member.Campaign__r.Promo_Inbox_Text__c,
                                                    Description__c = member.Campaign__r.Promo_Inbox_Text__c,
                                                    Deep_Linking_URL__c = member.Campaign__r.Deep_Linking_URL__c,
                                                    Campaign__c = member.Campaign__c,
                                                    SubType__c = 'Sales Targeted Promo',
                                                    RecordTypeId = recType.containsKey('Broadcast') ? recType.get('Broadcast').getRecordTypeId() : ''));
                
                if (member.Campaign__r.Sales_Targeted_Promo_Type__c == 'Single' && member.Campaign__r.TC_Val__c == null && !campaignsNoTC.contains(member.Campaign__c))
                {
                    campaignsNoTC.add(member.Campaign__c);
                }
            }
        }

        if (!campaignsNoTC.isEmpty())
        {
            if (System.isBatch() == false && System.isFuture() == false)
            {
                if (!newAlerts.isEmpty())
                {          
                    insert newAlerts;
                }

                InvoiceEmail_ProcessBuilder_RestTC.apexcallout(campaignsNoTC);                     
            }

            if (System.isBatch() == true || System.isFuture() == true || System.Test.isRunningTest())
            {
                Set<Id> alertIds = new Set<Id>();

                if (!newAlerts.isEmpty() && !System.Test.isRunningTest())
                { 
                    TriggerExclusion.excludeTrigger('CustomerAlerts__c', true);         
                    insert newAlerts;
                    TriggerExclusion.excludeTrigger('CustomerAlerts__c', false);

                    for (CustomerAlerts__c alert : newAlerts)
                    {
                        alertIds.add(alert.Id);
                    }
                }

                System.enqueueJob(new InvoiceEmail_RestTCQueueable(campaignsNoTC, alertIds));
            }
        }
        else 
        {                     
            if (!newAlerts.isEmpty())
            {          
                insert newAlerts;
            }
        }
    }
}
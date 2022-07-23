/** ******
 * Description: Trigger handler for the Campaign_Promo_Line_Item__c custom object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20220415           TPhan@aodigy.com    Created Initial Version. 
** ******/

public class CampaignPromoLineItems extends ADGLIB_SObjectDomain
{
    public CampaignPromoLineItems(List<Campaign_Promo_Line_Item__c> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new CampaignPromoLineItems(sObjectList);
		}
	}

    public override void onBeforeInsert()
    {
        checkModelsOnCampaignAndUpsellAccs(null);
    }

    private void checkModelsOnCampaignAndUpsellAccs(Map<Id,SObject> existingRecords)
    {
        Set<Id> promoLineItemIds     = new Set<Id>();
        Set<Id> campaignIds          = new Set<Id>();
        List<String> models          = new List<String>();
        List<String> branchCodes     = new List<String>();
        Promo_Line_Item__c promoItem;

        for (Campaign_Promo_Line_Item__c campaignItem : (List<Campaign_Promo_Line_Item__c>) Records)
        {
            promoLineItemIds.add(campaignItem.Promo_Line_Item__c);
            campaignIds.add(campaignItem.Campaign__c);
        }

        Map<Id, Promo_Line_Item__c> promoLineItems =  new Map<Id, Promo_Line_Item__c> ([SELECT Id, Model__c, Branch_Code__c FROM Promo_Line_Item__c WHERE Id IN: promoLineItemIds]);
        Map<Id, Campaign> campaigns                =  new Map<Id, Campaign> ([SELECT Id, Model_Master__c, Model_Master__r.Model_Description__c, Model_Master__r.Branch_Code__c FROM Campaign WHERE Id IN: campaignIds]);

        for (Campaign_Promo_Line_Item__c campaignItem : (List<Campaign_Promo_Line_Item__c>) Records)
        {
            promoItem   = promoLineItems.get(campaignItem.Promo_Line_Item__c);

            if (String.isNotBlank(promoItem.Model__c) && String.isNotBlank(promoItem.Branch_Code__c))
            {
                models      = promoItem.Model__c.split(';');
                branchCodes = promoItem.Branch_Code__c.split(';');
    
                if ((((models.contains('All KIA') || models.contains('All MIT') || models.contains('All CIT')) || models.contains('All DS') && !models.contains('All Brands'))
                    && (((campaigns.get(campaignItem.Campaign__c).Model_Master__c <> null) && !branchCodes.contains(campaigns.get(campaignItem.Campaign__c).Model_Master__r.Branch_Code__c))))
                    || ((!models.contains('All KIA') && !models.contains('All MIT') && !models.contains('All CIT') && !models.contains('All DS') && !models.contains('All Brands'))
                        && ((campaigns.get(campaignItem.Campaign__c).Model_Master__c <> null) && (!models.contains(campaigns.get(campaignItem.Campaign__c).Model_Master__r.Model_Description__c)))))
                {
                    campaignItem.addError('Model on Upsell Acc and Campaign must be the same!');
                }    
            }
        }
    }
}
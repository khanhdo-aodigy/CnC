/*******
 * Description : Service class for Campaign Promo Line Item object
 * 
 * Change History :
 * Date(YYYYMMDD)      Name                    Description
 * 20220324         thu.phan@aodigy.com     Created Initial Version 
*******/

public class CampaignPromoLineItemService 
{
    private static CampaignPromoLineItemSelector sel = new CampaignPromoLineItemSelector();

    public static List<Campaign_Promo_Line_Item__c> getCampaignPromoLineItemsByIds (Set<String> recordIds)
    {
        return sel.getCampaignPromoLineItemsByIds(recordIds);
    }
}
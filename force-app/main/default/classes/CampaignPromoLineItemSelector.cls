/*******
 * Description : Selector class for Campaign Promo Line Item object
 * 
 * Change History :
 * Date(YYYYMMDD)      Name                    Description
 * 20220324         thu.phan@aodigy.com     Created Initial Version 
*******/

public class CampaignPromoLineItemSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType() 
    {
        return Campaign_Promo_Line_Item__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() 
    {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Campaign_Promo_Line_Item__c');
    }

    public List<Campaign_Promo_Line_Item__c> getCampaignPromoLineItemsByIds(Set<String> recordIds) 
    {
        adglib_QueryFactory query = newQueryFactory();    
        query.selectFields(new Set<String>{'Promo_Line_Item__r.No_of_Stock__c', 'Campaign__r.Owner.Email', 'Campaign__r.OwnerId', 'Promo_Line_Item__r.Threshold_Amount__c'});
        String str_filter = ' Id IN: recordIds '; 
        query.setCondition( str_filter );

        return Database.query(query.toSOQL());
    }
}
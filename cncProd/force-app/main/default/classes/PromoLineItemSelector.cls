/*******
 * Description : Selector class for Promo Line Item object
 * 
 * Change History :
 * Date(YYYYMMDD)      Name                    Description
 * 20220324         thu.phan@aodigy.com     Created Initial Version 
*******/

public class PromoLineItemSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType() 
    {
        return Promo_Line_Item__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() 
    {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Promo_Line_Item__c');
    }

    public List<Promo_Line_Item__c> getPromoLineItemsByIds(Set<String> recordIds) 
    {
        adglib_QueryFactory query = newQueryFactory();    
        String str_filter = ' Id IN: recordIds '; 
        query.setCondition( str_filter );

        return Database.query(query.toSOQL());
    }
}
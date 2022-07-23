/** *****
 * Description :Selector class for Promo_Code_Master__c object
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer                  Details
 * 20210417             khanh.do@aodigy            Created initial version
 ** *****/
public class PromoCodeMasterSelector extends ADGLIB_SObjectSelector  {

    public Schema.SObjectType getSObjectType() {
        return Promo_Code_Master__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Promo_Code_Master__c');
    }

    public List<Promo_Code_Master__c> getPromoCodeListByNameAndCampaignIds(Set<String> promoCodes, Set<String> campaignIds) {
        List<Promo_Code_Master__c> campaignList = new List<Promo_Code_Master__c>();
        adglib_QueryFactory query = newQueryFactory();  
        String str_filter = ''; 

        if( !promoCodes.isEmpty() ) { 
            str_filter += ' Promo_Code__c IN :promoCodes ';
        }

        if( !campaignIds.isEmpty() ) {            
            str_filter += ' AND Campaign__c IN :campaignIds ';
        }
         
        query.setCondition( str_filter );
        campaignList = Database.query( query.toSOQL() );
        return campaignList;
    }
    
}
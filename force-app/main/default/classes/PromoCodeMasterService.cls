/** *****
 * Description : Service class for Campain object
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer                  Details
 * 20210417             khanh.do@aodigy            Created initial version
 ** *****/
public with sharing class PromoCodeMasterService {
    private static PromoCodeMasterSelector selector = new PromoCodeMasterSelector();
    
    public static Promo_Code_Master__c getPromoByNameAndCampaignId(String promoCodeName, String campaignId) 
    {
        List<Promo_Code_Master__c> promoList = getPromoCodeListByNameAndCampaignIds( new Set<String>{promoCodeName}, new Set<String>{campaignId});
        return !promoList.isEmpty() ? promoList.get(0) : null;
    }

    public static List<Promo_Code_Master__c> getPromoCodeListByNameAndCampaignIds(Set<String> promoCodeNames, Set<String> campaignIds) 
    {
        return selector.getPromoCodeListByNameAndCampaignIds( promoCodeNames, campaignIds );
    }

    public static Boolean isPromoCodeExpired(Promo_Code_Master__c promoCode) {
        if(promoCode != null && promoCode.Expiry_Date__c != null) {
            if( promoCode.Expiry_Date__c < Date.today() ) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }
}
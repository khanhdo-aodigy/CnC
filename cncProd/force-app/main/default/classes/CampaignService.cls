/** *****
 * Description : Service class for Campain object
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer                  Details
 * 20210417             khanh.do@aodigy            Created initial version
 ** *****/
public with sharing class CampaignService {
    private static CampaignSelector selector = new CampaignSelector();
    
    public static Campaign getCampaignById(String campaignId) 
    {
        List<Campaign> campaignList = getCampaignListByIds(new Set<String>{campaignId});
        return !campaignList.isEmpty() ? campaignList.get(0) : null;
    }

    public static List<Campaign> getCampaignListByIds( Set<String> campaignIds) 
    {
        return selector.getCampaignListByIds( campaignIds );
    }

    public static List<Campaign> getCampaignListByBrandAndBranchCode (String brand, String branchCode)
    {
        return selector.getCampaignListByBrandAndBranchCode (brand,branchCode);
    }



}
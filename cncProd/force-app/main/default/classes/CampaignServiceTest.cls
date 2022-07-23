/** *****
 * Description : Test Class for CampaignService class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210409             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class CampaignServiceTest {
    
    @testSetup
    private static void setup() {
        Campaign camp1 = Test_DataFactory.createCamp(true, 'KIA Party', 'Events', 'CCK');
        Campaign camp2 = Test_DataFactory.createCamp(true, 'CIT Jam Arteastiq 4 Aug', 'Paid Event', 'CCF');
        Campaign camp3 = Test_DataFactory.createCamp(true, 'Cleaning promo', 'Campaign - Brand', 'CCA');
    }
    
    @isTest
    private static void testGetCampaignById() {
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        Campaign result = CampaignService.getCampaignById(camp.Id);
        System.assertNotEquals(null, result);
    }
    
    @isTest
    private static void testGetCampaignListByIds() {
        Map<String, Campaign> mapCamps = new Map<String, Campaign>([SELECT Id, Name FROM Campaign]);
        Set<String> campIds = mapCamps.keySet();
        List<Campaign> result = CampaignService.getCampaignListByIds(campIds);
        System.assertEquals(3, result.size());
    }
    
    @isTest
    private static void testCampaignListByBrandAndBranchCode() {
        Campaign camp = Test_DataFactory.createCamp(false, 'Cleaning promo', 'Campaign - Brand', 'CCA');
        camp.Brand__c = 'MIT';
        camp.Status   = 'Planned';
        camp.Target_Audience__c = 'Public And Targeted';
        camp.IsActive = true;
        camp.EndDate = Date.today() + 5;
        camp.Budgeted_Cost_in_Campaign__c = 200;
        insert camp;
        
        List<Campaign> result = CampaignService.getCampaignListByBrandAndBranchCode('MIT', 'CCA');
        System.assertEquals(1, result.size());
    }
    

}
/** ******
 * Description : Test class for CampaignPromoLineItemService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                    Description
 * 20220419             thanh.ly@aodigy         Created Initial Version. 
 * 
** ******/
@isTest
private class CampaignPromoLineItemServiceTest{
    @TestSetup
    private static void setUp(){
        User user = Test_DataFactory.createUser(true, 'Thanh', 'Ly');

        Campaign cam = Test_DataFactory.createCamp(false, 'Targeted Promo Kia', 'Promotions', 'CCK');
        cam.OwnerId = user.Id;
        insert cam;

        Promo_Line_Item__c item = Test_DataFactory.createPromoLineItem(false, 'USB', 100, 80, 'Blue', 10);
        item.Threshold_Amount__c = 100;
        insert item;
        
        Campaign_Promo_Line_Item__c camItem = Test_DataFactory.createCampaignPromoLineItem(true, cam.Id, item.Id);
    }
    
    @isTest
    private static void Test_getCampaignPromoLineItemsByIds(){
        Campaign_Promo_Line_Item__c camItem = [SELECT Id FROM Campaign_Promo_Line_Item__c];

        List<Campaign_Promo_Line_Item__c> camItems = CampaignPromoLineItemService.getCampaignPromoLineItemsByIds(new Set<String> {camItem.Id});
        
        System.assertEquals(1, camItems.size());
    }
}
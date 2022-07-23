/** *****
 * Description : Test Class for PromoCodeMasterSelector class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210416             tphung@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class PromoCodeMasterSelectorTest {
    @TestSetup
    private static void setup() {
        Campaign cam1 = Test_DataFactory.createCamp(true, 'Test 1', 'Promotions', 'CCI');
        Campaign cam2 = Test_DataFactory.createCamp(true, 'Test 2', 'Promotions', 'CCA');
        Campaign cam3 = Test_DataFactory.createCamp(true, 'Test 3', 'Promotions', 'CCA');
        String id1 = cam1.Id;
        String id2 = cam2.Id;
        String id3 = cam3.Id;
        Promo_Code_Master__c promo1 = Test_DataFactory.createPromoCode(true, id1, 'Test 1', 'Number',20,Date.Today() + 1);
        Promo_Code_Master__c promo2 = Test_DataFactory.createPromoCode(true, id2, 'Test 2', 'Number',30,null);
        Promo_Code_Master__c promo3 = Test_DataFactory.createPromoCode(true, id3, 'Test 3', 'Number',40,Date.Today() - 3);
    }

    @isTest
    private static void testGetPromoCodeListByNameAndCampaignIds() {    
        Set<String> ids = new set<string>();
        list<Campaign> listCamp = [SELECT id from Campaign];
        for(campaign cam : listCamp){
            ids.add(cam.id);
        }
        Set<String> promoNames = new Set<String>{'Test 1','Test 2','Test 3'};
        PromoCodeMasterSelector newSelector = new PromoCodeMasterSelector();
        List<Promo_Code_Master__c> result = newSelector.getPromoCodeListByNameAndCampaignIds(promoNames, ids);
        System.assertEquals(3, result.size());

    }
}
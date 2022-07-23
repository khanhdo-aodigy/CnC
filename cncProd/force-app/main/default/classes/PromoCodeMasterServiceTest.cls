/** *****
 * Description : Test Class for PromoCodeMasterService class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210416             tphung@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class PromoCodeMasterServiceTest {
    @TestSetup
    private static void setup() {
        Campaign cam1 = Test_DataFactory.createCamp(true, 'Test Camp1', 'Promotions', 'CCI');
        Campaign cam2 = Test_DataFactory.createCamp(true, 'Test Camp2', 'Promotions', 'CCA');
        Campaign cam3 = Test_DataFactory.createCamp(true, 'Test Camp3', 'Promotions', 'CCA');
        String id1 = cam1.Id;
        String id2 = cam2.Id;
        String id3 = cam3.Id;
        Promo_Code_Master__c promo1 = Test_DataFactory.createPromoCode(true, id1, 'Test 1', 'Number',20,Date.Today() + 1);
        Promo_Code_Master__c promo2 = Test_DataFactory.createPromoCode(true, id2, 'Test 2', 'Number',30,null);
        Promo_Code_Master__c promo3 = Test_DataFactory.createPromoCode(true, id3, 'Test 3', 'Number',40,Date.Today() - 3);
    }
     @isTest   
    private static void testGetPromoByNameAndCampaignId() {
        Promo_Code_Master__c promo  =  [SELECT Id,Promo_Code__c,Campaign__r.Id from Promo_Code_Master__c limit 1];
        System.debug(promo.Promo_Code__c);
        System.debug(promo.Campaign__c);
        Promo_Code_Master__c result = PromoCodeMasterService.getPromoByNameAndCampaignId(promo.Promo_Code__c, promo.Campaign__c);
        system.debug(result);
        System.assertNotEquals(null, result);

    }
    @isTest
    private static void testGetPromoCodeListByNameAndCampaignIds() {   
        Set<String> ids = new set<string>();
        list<Campaign> listCamp = [SELECT id from Campaign];
        for(campaign cam : listCamp){
            ids.add(cam.id);
        }
        Set<String> promoNames = new Set<String>{'Test 1','Test 2','Test 3'};
        List<Promo_Code_Master__c> result = PromoCodeMasterService.getPromoCodeListByNameAndCampaignIds(promoNames, ids);
        System.assertEquals(3, result.size());

    }
    @isTest
    private static void testIsPromoCodeExpiredisFalse(){
        Promo_Code_Master__c promo = [Select Id,Expiry_Date__c From Promo_Code_Master__c Where Expiry_Date__c > TODAY Limit 1];
        Boolean testBo = PromoCodeMasterService.isPromoCodeExpired(promo);
        System.assertEquals(False,testBo);

    }
    @isTest
    private static void testIsPromoCodeExpiredisTrue(){
        Promo_Code_Master__c promo = [Select Id,Expiry_Date__c From Promo_Code_Master__c Where Expiry_Date__c < TODAY Limit 1];
        Boolean testBo = PromoCodeMasterService.isPromoCodeExpired(promo);
        System.assertEquals(True,testBo);

    }
    @isTest
    private static void testIsPromoCodeExpiredisNull(){
        Promo_Code_Master__c promo = [Select Id,Expiry_Date__c From Promo_Code_Master__c Where Expiry_Date__c = null Limit 1];
        Boolean testBo = PromoCodeMasterService.isPromoCodeExpired(promo);
        System.assertEquals(True,testBo);

    }
}
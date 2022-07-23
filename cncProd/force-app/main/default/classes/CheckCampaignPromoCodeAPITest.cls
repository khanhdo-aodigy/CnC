/** *****
 * Description : Test Class for CheckCampaignPromoCodeAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210409             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class CheckCampaignPromoCodeAPITest {
    
    @isTest
    private static void testCheckPromoCode_ValidCode() {
        String promoName = 'HAPPYSales';
        Campaign camp = Test_DataFactory.createCamp(true, 'KIA Party', 'Events', 'CCK');
        Promo_Code_Master__c promoCode = Test_DataFactory.createPromoCode(true, camp.Id, promoName, 'Percent', 50, Date.today().addDays(30));
        String reqBody ='{'+
                        '  "CampaignID": "'+ camp.Id+'",'+
                        '  "PromoCode": "'+ promoName +'"'+
                        '}';
        Test.startTest();
        String reqURI = '/promotion/checkPromoCode/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CheckCampaignPromoCodeAPI.checkCampaignPromoCode();
        Test.stopTest();
    }
    
    @isTest
    private static void testCheckPromoCode_MissingRequiredFields() {
        String reqBody ='{'+
                        '  "CampaignID": "",'+
                        '  "PromoCode": "PROMO001"'+
                        '}';
        Test.startTest();
        String reqURI = '/promotion/checkPromoCode/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CheckCampaignPromoCodeAPI.checkCampaignPromoCode();
        Test.stopTest();
    }
    
    @isTest
    private static void testCheckPromoCode_NonexistCampaign() {
        String reqBody ='{'+
                        '  "CampaignID": "701O0000001NSDFAKE",'+
                        '  "PromoCode": "PROMO001"'+
                        '}';
        Test.startTest();
        String reqURI = '/promotion/checkPromoCode/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CheckCampaignPromoCodeAPI.checkCampaignPromoCode();
        Test.stopTest();
    }
    
    @isTest
    private static void testCheckPromoCode_PromoCodeExpired() {
        String promoName = 'HAPPYSales';
        Campaign camp = Test_DataFactory.createCamp(true, 'KIA Party', 'Events', 'CCK');
        Promo_Code_Master__c promoCode = Test_DataFactory.createPromoCode(true, camp.Id, promoName, 'Percent', 50, Date.today().addDays(-2));
        String reqBody ='{'+
                        '  "CampaignID": "'+ camp.Id+'",'+
                        '  "PromoCode": "'+ promoName +'"'+
                        '}';
        Test.startTest();
        String reqURI = '/promotion/checkPromoCode/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CheckCampaignPromoCodeAPI.checkCampaignPromoCode();
        Test.stopTest();
    }
    
    @isTest
    private static void testCheckPromoCode_InvalidPayloadFormat_ExceptionThrown() {
        String reqBody ='{'+
                        '  "CampaignID": '+
                        '  "PromoCode": "HAPPYHOURS"'+
                        '}';
        Test.startTest();
        String reqURI = '/promotion/checkPromoCode/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CheckCampaignPromoCodeAPI.checkCampaignPromoCode();
        Test.stopTest();
    }
}
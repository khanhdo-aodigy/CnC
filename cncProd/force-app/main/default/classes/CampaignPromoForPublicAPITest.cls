/** *****
 * Description : Test Class for CheckCampaignPromoCodeAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210412             tphung@aodigy           Created Initial Version. 
 * 
** *****/
@isTest
private class CampaignPromoForPublicAPITest {
    @isTest
    private static void testPromoCamp_ValidBrandAndBranchCode(){

        Campaign camp = Test_DataFactory.createCamp(true, 'KIA Party', 'Events', 'CCK');
        camp.Brand__c = 'MIT';
        camp.EndDate = Date.today().addDays(30);
        camp.Description = 'Wiper';
        camp.Status ='Planned';
        camp.IsActive = True;
        camp.Target_Audience__c = 'Public And Targeted';
        camp.Budgeted_Cost_in_Campaign__c = 200;
        update camp;
        System.debug(camp);
        String reqBody ='{'+
        '  "BranchCode": "CCK",'+
        '  "Brand": "MIT"'+
        '}';                       
        Test.startTest();
        String reqURI = '/promotion/getCampaigns/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CampaignPromoForPublicAPI.doPost();
        Test.stopTest();
    }
    @isTest
    private static void testPromoCamp_MissingRequired(){
        String reqBody ='{'+
        '  "BranchCode": "",'+
        '  "Brand": "MIT"'+
        '}';
        Test.startTest();
        String reqURI = '/promotion/getCampaigns/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CampaignPromoForPublicAPI.doPost();
        Test.stopTest();

    }
    @isTest
    private static void testPromoCamp_NonExistBrand(){
        String reqBody ='{'+
        '  "BranchCode": "CCK",'+
        '  "Brand": "MIAA"'+
        '}';
        Test.startTest();
        String reqURI = '/promotion/getCampaigns/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CampaignPromoForPublicAPI.doPost();
        Test.stopTest();

        
    }
    @isTest
    private static void testPromoCamp_InvalidPayloadFormat_ExceptionThrown() {
        String reqBody ='{'+
                        '  "BranchCode": '+
                        '  "Brand": "MAA"'+
                        '}';
        Test.startTest();
        String reqURI = '/promotion/checkPromoCode/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CampaignPromoForPublicAPI.doPost();
        Test.stopTest();
    }
}
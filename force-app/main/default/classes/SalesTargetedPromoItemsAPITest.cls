/** *****
 * Description : Test Class for CheckSalesTargetedPromoLineItemsAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                      Description
 * 20220408             thanh.ly@aodigy           Created Initial Version. 
 * 
** *****/
@isTest
private class SalesTargetedPromoItemsAPITest {
    @TestSetup
    private static void testRecord(){
        Campaign cam = Test_DataFactory.createCamp(false, 'Targeted Promo Kia', 'Test', 'CCK');
        cam.Status = 'Planned';
        cam.StartDate = Date.today();
        cam.EndDate = Date.today() + 1;
        cam.Description = 'Targeted Promo Kia';
        cam.Brand__c = 'KIA';
        cam.IsActive = true;
        insert cam;

        Promo_Line_Item__c item1 = Test_DataFactory.createPromoLineItem(false, 'USB Device', 100, 80, 'Blue', 1);
        item1.Group_Display_Name__c = 'USB Device';
        item1.Item_Group_Code__c = '001';
        insert item1;

        Promo_Line_Item__c item2 = Test_DataFactory.createPromoLineItem(false, 'USB Device', 100, 80, 'White', 1);
        item2.Group_Display_Name__c = 'USB Device';
        item2.Item_Group_Code__c = '001';
        insert item2;

        Campaign_Promo_Line_Item__c camItem1 = Test_DataFactory.createCampaignPromoLineItem(true, cam.Id, item1.Id);
        Campaign_Promo_Line_Item__c camItem2 = Test_DataFactory.createCampaignPromoLineItem(true, cam.Id, item2.Id);
    }
    
    @isTest
    private static void testPromoItem_GetResponse(){
        Campaign cam = [SELECT Id, Type, Status, StartDate, Name, EndDate, Description, Brand__c, Branch_Code__c
                        FROM Campaign
                        LIMIT 1];

        String reqBody ='{'+
        '  "CampaignId": "' + cam.Id + '"'+
        '}';
        Test.startTest();
        String reqURI = '/promotion/getSalesTargetedCampaign/*';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        SalesTargetedPromoItemsAPI.doPost();
        Test.stopTest();
    }

    @isTest
    private static void testPromoItem_MissingRequired(){
        String reqBody ='{'+
        '  "CampaignId": ""'+
        '}';
        Test.startTest();
        String reqURI = '/promotion/getSalesTargetedCampaign/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        SalesTargetedPromoItemsAPI.doPost();
        Test.stopTest();
    }
}
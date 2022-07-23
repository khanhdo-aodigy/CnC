/** *****
 * Description : Test Class for PromoLineItems Trigger Handler class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                      Description
 * 20220518             thanh.ly@aodigy           Created Initial Version. 
 * 
** *****/
@isTest
private class PromoLineItemsTest {
    @TestSetup
    private static void setup(){
        User user = Test_DataFactory.createUser(true, 'Thanh', '123');
        
        Campaign cam = Test_DataFactory.createCamp(false, 'Targeted Promo Kia', 'Test', 'CCK');
        cam.Status = 'Planned';
        cam.StartDate = Date.today();
        cam.EndDate = Date.today() + 1;
        cam.Description = 'Targeted Promo Kia';
        cam.Brand__c = 'KIA';
        cam.IsActive = true;
        cam.OwnerId = user.Id;
        insert cam;

        Promo_Line_Item__c item1 = Test_DataFactory.createPromoLineItem(false, 'USB Device', 30, 20, 'Blue', 10);
        item1.Item_Group_Code__c = '001';
        item1.Threshold_Amount__c = 100;
        insert item1;

        Promo_Line_Item__c item2 = Test_DataFactory.createPromoLineItem(false, 'Firefly Bluetooth Receiver', 40, 30, null, 10);
        item2.Threshold_Amount__c = 80;
        insert item2;

        Campaign_Promo_Line_Item__c camItem1 = Test_DataFactory.createCampaignPromoLineItem(true, cam.Id, item1.Id);
        Campaign_Promo_Line_Item__c camItem2 = Test_DataFactory.createCampaignPromoLineItem(true, cam.Id, item2.Id);
        
        Account acc = Test_DataFactory.createAccount(true, 'Test');
        Contact con = Test_DataFactory.createContact(true, null, 'Sales Targeted Dummy Contact', acc.Id);
    }
    
    @isTest
    private static void testOnAfterUpdate(){
        List<Promo_Line_Item__c> promoItems = new List<Promo_Line_Item__c>();
        promoItems = [SELECT Id, No_of_Stock__c, Threshold_Amount__c
                        FROM Promo_Line_Item__c];
        promoItems[0].No_of_Stock__c = 9;
        update promoItems;
    }
}
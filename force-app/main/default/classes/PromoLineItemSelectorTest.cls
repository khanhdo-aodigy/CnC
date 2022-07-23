/** ******
 * Description : Test class for PromoLineItemSelector.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                    Description
 * 20220419             thanh.ly@aodigy         Created Initial Version. 
 * 
** ******/
@isTest
private class PromoLineItemSelectorTest{
    @TestSetup
    static void setUp(){
        Promo_Line_Item__c item = Test_DataFactory.createPromoLineItem(true, 'USB', 100, 80, 'Blue', 10);
    }
    
    @isTest
    static void Test_getPromoLineItemsByIds(){
        Promo_Line_Item__c Item = [SELECT Id FROM Promo_Line_Item__c];

        PromoLineItemSelector itemSel = new PromoLineItemSelector();
        List<Promo_Line_Item__c> Items = itemSel.getPromoLineItemsByIds(new Set<String> {Item.Id});
        
        System.assertEquals(1, Items.size());
    }
}
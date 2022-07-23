/** *****
 * Description : Test Class for CampaignPromoLineItems
 * 
 * Change History
 * Date(YYYYMMDD)       Name                      Description
 * 20220420             thanh.ly@aodigy           Created Initial Version.
 * 
** *****/
@IsTest
private class CampaignPromoLineItemsTest {
    @TestSetup
    static void setup(){
        Model_Group__c modelGroup = new Model_Group__c();
        modelGroup.Name = 'DE NIRO';
        modelGroup.Branch_Code__c = 'KIA';
        modelGroup.Branch_Code__c = 'CCK';
        modelGroup.Franchise_Code__c = 'KIAPC';
        modelGroup.VSMS_Compound_Primary_Key__c = 'KIAPCDE EV NIRO';
        insert modelGroup;

        Model_Master__c modelMaster = new Model_Master__c();
        modelMaster.Branch_Code__c = 'CCK';
        modelMaster.Model_Description__c = '09 CARENS 2.0 A';
        modelMaster.Franchise_Code__c = 'KIAPC';
        modelMaster.VSMS_Compound_Primary_Key__c = 'KIAPCDE NIRONIROEVG605';
        modelMaster.Model_Group__c = modelGroup.Id;
        insert modelMaster;

        Campaign cam = Test_DataFactory.createCamp(false, 'TARGETED PROMO KIA NIRO EV', 'Promotions', 'CCK');
        cam.Model_Master__c = modelMaster.Id;
        insert cam;
        
        Promo_Line_Item__c item = Test_DataFactory.createPromoLineItem(false, 'USB', 100, 80, null, 10);
        item.Branch_Code__c = 'CCK';
        item.Model__c = '09 CARENS 2.0 A';
        item.Brand__c = 'KIA';
        insert item;
    }
    @isTest
    private static void test_OnBeforeInsert(){                    
        Campaign cam = [SELECT Id, Model_Master__c, Model_Master__r.Model_Description__c, Model_Master__r.Branch_Code__c
                        FROM Campaign
                        LIMIT 1];

        Promo_Line_Item__c item = [SELECT Id, Model__c, Branch_Code__c
                                    FROM Promo_Line_Item__c
                                    LIMIT 1];

        Campaign_Promo_Line_Item__c camItem = Test_DataFactory.createCampaignPromoLineItem(true, cam.Id, item.Id);
	}
}
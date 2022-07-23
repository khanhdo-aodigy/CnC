/** ******
 * Description: Test Class for CampaignMemberAndVehicles Trigger handler
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                    Description
 * 20220520             thanh.ly@aodigy.com     Created Initial Version. 
** ******/
@isTest
private class CampaignMemberAndVehicleTest {
    @TestSetup
    private static void setup(){
        Account acc = Test_DataFactory.createAccount(true, 'Bob');
        Contact con = Test_DataFactory.createContact(true, 'Bob', 'Lee', acc.Id);
        
        Campaign camp = Test_DataFactory.createCamp(false, 'Paid Event', 'type', 'CCK');
        Id campRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('C&C Campaign RT (Sales Targeted Promo)').getRecordTypeId();
        camp.RecordTypeId = campRT;
        camp.Type = 'Sales Targeted Promo';
        camp.Sales_Targeted_Promo_Type__c = 'Single';
        insert camp;

        Campaign camp1 = Test_DataFactory.createCamp(false, 'Test', 'Promotions', 'CCK');
        camp1.RecordTypeId = campRT;
        camp1.TC_Val__c = 'Hello';
        camp1.Sales_Targeted_Promo_Type__c = 'Single';
        insert camp1;
    }
    @isTest
    private static void testOnAfterInsert_TCNull() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Campaign cam = [SELECT Id FROM Campaign WHERE Name = 'Paid Event'];
        Campaign_Member_Vehicle__c camMemVehicle = new Campaign_Member_Vehicle__c();
        camMemVehicle.Name = 'Test';
        camMemVehicle.Campaign__c = cam.Id;
        camMemVehicle.Contact__c = con.Id;
        camMemVehicle.Account__c = acc.Id;
        insert camMemVehicle;
    }

    @isTest
    private static void testOnAfterInsert_TC() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Campaign cam1 = [SELECT Id FROM Campaign WHERE Name = 'Test'];
        Campaign_Member_Vehicle__c camMemVehicle1 = new Campaign_Member_Vehicle__c();
        camMemVehicle1.Name = 'Test 123';
        camMemVehicle1.Campaign__c = cam1.Id;
        camMemVehicle1.Contact__c = con.Id;
        camMemVehicle1.Account__c = acc.Id;
        insert camMemVehicle1;
    }
}
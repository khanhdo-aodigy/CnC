/** ******
 * Description: Test Class For OffboardCustFromSalesTargetedPromo class
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		         Description
 * 20220511             thanh.ly@aodigy              Created Initial Version. 
** ******/
@isTest
private class OffboardCustFromSalesTargetedPromoTest {
    @TestSetup
    private static void setup(){
        Account acc = Test_DataFactory.createAccount(true, 'Bob');
        Contact con = Test_DataFactory.createContact(true, 'Bob', 'Lee', acc.Id);

        Id camRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('C&C Campaign RT (Sales Targeted Promo)').getRecordTypeId();
        Campaign cam = Test_DataFactory.createCamp(false, 'Test', 'New', 'CCK');
        cam.IsActive = true;
        cam.Type = 'Sales Targeted Promo';
        cam.RecordTypeId = camRT;
        cam.EndDate = Date.today() - 1;
        insert cam;

        Campaign_Member_Vehicle__c camMemVehicle = new Campaign_Member_Vehicle__c();
        camMemVehicle.Name = 'Test';
        camMemVehicle.Campaign__c = cam.Id;
        camMemVehicle.Contact__c = con.Id;
        camMemVehicle.Account__c = acc.Id;
        insert camMemVehicle;

        camMemVehicle = [SELECT Contact__c, Campaign__c FROM Campaign_Member_Vehicle__c LIMIT 1];
        CampaignMember camMember = new CampaignMember();
        camMember.CampaignId = camMemVehicle.Campaign__c;
        camMember.ContactId = camMemVehicle.Contact__c;
        insert camMember;
    }

    @isTest
    private static void test_OffboardCustomerFromSalesTargetedPromoBatch() {
        Test.startTest();
        OffboardCustFromSalesTargetedPromo.OffboardCustomerFromSalesTargetedPromoBatch();
        OffboardCustFromSalesTargetedPromo offboard = new OffboardCustFromSalesTargetedPromo();
        Database.executeBatch(offboard);
        Test.stopTest();
    }
}
/** *****
 * Description : Test Class for UsedCarQuoteService.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                     Description
 * 20220525            tan.nguyen@aodigy.com    Created Initial Version 
 * 
** *****/
@isTest
private class UsedCarQuoteServiceTest {

    @TestSetup
    static void setUp(){
        Used_Car_Quote__c quote1 = new Used_Car_Quote__c();
        quote1.Chassis_No__c = '12321';
        quote1.Vehicle_No__c = 'AB423nv';
        quote1.Intended_Deregistration_Date__c = Date.today();
        quote1.Customer_ID_Type__c = Used_Car_Quote__c.Customer_ID_Type__c.getDescribe().getPicklistValues()[1].getValue();
        quote1.Status__c = 'Open';
        quote1.Customer_NRIC__c = 'HIHI';
        quote1.recordTypeId = UsedCarQuoteService.getMFRecordTypeId();
        insert quote1;

        Used_Car_Quote__c quote2 = new Used_Car_Quote__c();
        quote2.Chassis_No__c = '112233';
        quote2.Vehicle_No__c = 'DASD12';
        quote2.Intended_Deregistration_Date__c = Date.today();
        quote2.Customer_ID_Type__c = Used_Car_Quote__c.Customer_ID_Type__c.getDescribe().getPicklistValues()[2].getValue();
        quote2.Status__c = 'Open';
        quote2.Customer_NRIC__c = 'HOHO';
        quote2.recordTypeId = UsedCarQuoteService.getMBRecordTypeId();
        insert quote2;
    }

    @isTest

    static void getUsedCarQuoteById_Test() {
        Used_Car_Quote__c Quote = [SELECT Id FROM Used_Car_Quote__c LIMIT 1];
        String quoteId = Quote.Id;
        Used_Car_Quote__c quoteList = new Used_Car_Quote__c();
        Test.startTest();
        quoteList = UsedCarQuoteService.getUsedCarQuoteById(quoteId);
        Test.stopTest();
    }

    @isTest
    static void getQuotesBySetIds_Test() {
        Used_Car_Quote__c Quote = [SELECT Id FROM Used_Car_Quote__c LIMIT 1];
        List<Used_Car_Quote__c> quoteList = new List<Used_Car_Quote__c>();
        Test.startTest();
        quoteList = UsedCarQuoteService.getQuotesBySetIds(new Set<Id> {Quote.Id});
        Test.stopTest();

    }

    @isTest
    static void getOpenQuotesByChassisNoAndVehicleNo_Test() {
        Used_Car_Quote__c Quote = [SELECT Id, Chassis_No__c, Vehicle_No__c FROM Used_Car_Quote__c LIMIT 1];
        String chassisNo = Quote.Chassis_No__c;
        String vehicleNo = Quote.Vehicle_No__c;
        List<Used_Car_Quote__c> quoteList = new List<Used_Car_Quote__c>();
        Test.startTest();
        quoteList = UsedCarQuoteService.getOpenQuotesByChassisNoAndVehicleNo(chassisNo, vehicleNo, '');
        Test.stopTest();

    }

    @isTest
    static void getMFRecordTypeId_Test() {
        Used_Car_Quote__c Quote = [SELECT ID, recordTypeId FROM Used_Car_Quote__c WHERE Vehicle_No__c =:'AB423nv'];
        System.assertEquals(Quote.recordTypeId, UsedCarQuoteService.getMFRecordTypeId());
    }

    @isTest
    static void getMBRecordTypeId_Test() {
        Used_Car_Quote__c Quote = [SELECT ID, recordTypeId FROM Used_Car_Quote__c WHERE Vehicle_No__c =:'DASD12'];
        System.assertEquals(Quote.recordTypeId, UsedCarQuoteService.getMBRecordTypeId());
    }

    @isTest
    static void getRecordTypeId_success_Test() {
        Used_Car_Quote__c Quote = [SELECT Id, recordTypeId FROM Used_Car_Quote__c LIMIT 1];
        String quoteId = Quote.Id;
        String Id = UsedCarQuoteService.getRecordTypeId(quoteId);
        System.assertEquals(Quote.recordTypeId, Id);
    }

    @isTest
    static void getQuoteRecTypeIdByUserProfile_MF_Test() {
        System.assertEquals(UsedCarQuoteService.getMFRecordTypeId(), UsedCarQuoteService.getQuoteRecTypeIdByUserProfile('MF Purchaser'));
    }

    @isTest
    static void getQuoteRecTypeIdByUserProfile_MB_Test() {
        System.assertEquals(UsedCarQuoteService.getMBRecordTypeId(), UsedCarQuoteService.getQuoteRecTypeIdByUserProfile('MB Purchaser'));
    }

    @isTest
    static void getQuoteRecTypeIdByUserProfile_null_Test() {
        System.assertEquals(null, UsedCarQuoteService.getQuoteRecTypeIdByUserProfile('Purchaser'));
    }
}
/** *****
 * Description : Test Class for UsedCarQuoteSelector.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                     Description
 * 20220525            tan.nguyen@aodigy.com    Created Initial Version 
 * 
** *****/
@isTest
private class UsedCarQuoteSelectorTest {

    @TestSetup
    static void setUp(){
        Used_Car_Quote__c quote = new Used_Car_Quote__c();
        quote.Chassis_No__c = '12321';
        quote.Vehicle_No__c = 'AB423nv';
        quote.Intended_Deregistration_Date__c = Date.today();
        quote.Customer_ID_Type__c = Used_Car_Quote__c.Customer_ID_Type__c.getDescribe().getPicklistValues()[1].getValue();
        quote.Customer_NRIC__c = 'HIHI';
        quote.Status__c = 'Open';
        quote.recordTypeId = UsedCarQuoteService.getMFRecordTypeId();

        insert quote;
    }

    @isTest
    static void getQuotesBySetIds_Test() {
        Used_Car_Quote__c quote = [SELECT Id FROM Used_Car_Quote__c];
        UsedCarQuoteSelector ucqSelector = new UsedCarQuoteSelector();
        List<Used_Car_Quote__c> quotes = ucqSelector.getQuotesBySetIds(new Set<Id> {Quote.Id});

        System.assertEquals(1, quotes.size());
    }

    @isTest
    static void getOpenQuotesByChassisNoAndVehicleNo_Test1() {
        Used_Car_Quote__c quote = [SELECT Id, Chassis_No__c, Vehicle_No__c FROM Used_Car_Quote__c];
        String chassisNo = quote.Chassis_No__c;
        String vehicleNo = quote.Vehicle_No__c;
        UsedCarQuoteSelector ucqSelector = new UsedCarQuoteSelector();
        List<Used_Car_Quote__c> quotes = ucqSelector.getOpenQuotesByChassisNoAndVehicleNo(chassisNo, vehicleNo, '');

        System.assertEquals(1, quotes.size());

    }

    @isTest
    static void getOpenQuotesByChassisNoAndVehicleNo_Test2() {
        Used_Car_Quote__c quote = [SELECT Id, Chassis_No__c, Vehicle_No__c, recordTypeId FROM Used_Car_Quote__c];
        String chassisNo = quote.Chassis_No__c;
        String vehicleNo = quote.Vehicle_No__c;
        String recordTypeId = quote.recordTypeId;
        UsedCarQuoteSelector ucqSelector = new UsedCarQuoteSelector();
        List<Used_Car_Quote__c> quotes = ucqSelector.getOpenQuotesByChassisNoAndVehicleNo(chassisNo, vehicleNo, ' AND RecordTypeId = \'' + recordTypeId + '\'');

        System.assertEquals(1, quotes.size());

    }
}
/** *****
 * Description : Test Class for RAP_SendVehicleDetailsAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                        Description
 * 20220524             tan.nguyen@aodigy.com       Created Initial Version. 
 * 
** *****/

@isTest
private class RAP_SendVehicleDetailsAPITest {
    @TestSetup
    private static void setUp() {
        Used_Car_Quote__c testQuote = new Used_Car_Quote__c();
        testQuote.Customer_ID_Type__c = Used_Car_Quote__c.Customer_ID_Type__c.getDescribe().getPicklistValues()[1].getValue();
        testQuote.Customer_NRIC__c = 'T098';
        testQuote.Vehicle_No__c = 'VN098';
        testQuote.Vehicle_to_be_Exported__c = true;
        testQuote.Intended_Deregistration_Date__c = Date.today().addMonths(1);
        testQuote.Vehicle_Make__c = 'VM098';
        testQuote.Vehicle_Model__c = 'MER';
        testQuote.Primary_Color__c = 'Black';
        testQuote.Manufacturing_Year__c = '2022';
        testQuote.Engine_No__c = 'EN098';
        testQuote.Chassis_No__c = 'CN098';
        testQuote.Maximum_Power_Output__c = '500HP';
        testQuote.Open_Market_Value__c = 55000;
        testQuote.Original_Registration_Date__c = Date.today();
        testQuote.First_Registration_Date__c = Date.today();
        testQuote.Transfer_Count__c = 1;
        testQuote.Actual_ARF_Paid__c = 1000;
        testQuote.PARF_Eligibility__c = 'Yes';
        testQuote.PARF_Eligibility_Expiry_Date__c = Date.today().addMonths(2);
        testQuote.PARF_Rebate_Amount__c = 3000;
        testQuote.COE_Expiry_Date__c = Date.today().addYears(3);
        testQuote.COE_Category__c = 'COE Category 1';
        testQuote.COE_Period_Years__c = 10;
        testQuote.QP_Paid__c = 500;
        testQuote.COE_Rebate_Amount__c = 1200;
        testQuote.Total_Rebate_Amount__c = 2200;
        testQuote.recordTypeId = UsedCarQuoteService.getMFRecordTypeId();
        insert testQuote;
        
        global_var__c test = new global_var__c();
        test.APIGateway_url__c = 'https://www.test.com';
        test.SageMakerAPIKey__c = '123456789';
        upsert test;
    }



    @isTest
    private static void testSendVehicleDetails_Success() {
        Used_Car_Quote__c ucq = [ SELECT Id FROM Used_Car_Quote__c];
        String testQuoteId = ucq.Id;
        Test.setMock(HttpCalloutMock.class, new ADGLIB_CalloutMock());
        Test.startTest();
        RAP_SendVehicleDetailsAPI.sendVehicleDetails(testQuoteId);
        Test.stopTest();
    }

    @isTest
    private static void testSendVehicleDetails_Fail() {
        Used_Car_Quote__c ucq = [ SELECT Id FROM Used_Car_Quote__c];
        String testQuoteId = ucq.Id;
        Test.startTest();
        RAP_SendVehicleDetailsAPI.sendVehicleDetails(testQuoteId);
        Test.stopTest();
    }

    @isTest
    private static void testSendVehicleDetails_null() {
        Test.startTest();
        RAP_SendVehicleDetailsAPI.sendVehicleDetails('a2nO000000B8Yk4IAJ');
        Test.stopTest();
    }
}
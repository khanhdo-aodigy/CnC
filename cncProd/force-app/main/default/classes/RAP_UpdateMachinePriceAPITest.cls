/** *****
 * Description : Test Class for RAP_UpdateMachinePriceAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                        Description
 * 20220425             tan.nguyen@aodigy.com       Created Initial Version. 
 * 
** *****/

@isTest
private class RAP_UpdateMachinePriceAPITest {
    @TestSetup
    private static void setUp(){
        Used_Car_Quote__c ucq = new Used_Car_Quote__c();
        ucq.recordTypeId = UsedCarQuoteService.getMFRecordTypeId();
        ucq.Chassis_No__c = '12321';
        ucq.Vehicle_No__c = 'AB423nv';
        ucq.Intended_Deregistration_Date__c = Date.today();
        ucq.Customer_ID_Type__c = Used_Car_Quote__c.Customer_ID_Type__c.getDescribe().getPicklistValues()[1].getValue();
        ucq.Customer_NRIC__c = 'HIHI';
        ucq.Status__c = 'Open';
        insert ucq;
    }

    @isTest 
    private static void testUpdateMachinePrice_Success() {
        Used_Car_Quote__c testQuote = [SELECT Id FROM Used_Car_Quote__c];
        String reqBody = '{"QuoteID": "'+ testQuote.Id +'", "MachineQuote": 70000, "Depreciation": 5000}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateMachinePrice/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAP_UpdateMachinePriceAPI.doPost();
        Test.stopTest();
    }

    @isTest
    private static void testUpdateMachinePrice_missingField() {
        Used_Car_Quote__c testQuote = [SELECT Id FROM Used_Car_Quote__c];
        String reqBody = '{"QuoteID": "", "MachineQuote": 70000, "Depreciation": 5000}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateMachinePrice/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAP_UpdateMachinePriceAPI.doPost();
        Test.stopTest();
    }

    @isTest 
    private static void testUpdateMachinePrice_invalidQuoteId() {
        Used_Car_Quote__c testQuote = [SELECT Id FROM Used_Car_Quote__c];
        String reqBody = '{"QuoteID": "a2nO000000B8Yk4IAJ", "MachineQuote": 70000, "Depreciation": 5000}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateMachinePrice/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAP_UpdateMachinePriceAPI.doPost();
        Test.stopTest();
    }
    
    @isTest 
    private static void testUpdateMachine_exception() {
        Used_Car_Quote__c testQuote = [SELECT Id FROM Used_Car_Quote__c];
        String reqBody = '"QuoteID": "'+ testQuote.Id +'", "MachineQuote": 70000, "Depreciation": 5000';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateMachinePrice/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAP_UpdateMachinePriceAPI.doPost();
        Test.stopTest();
    }
}
/** *****
 * Description : Test Class for getCustomerAlerts 
 * 
 * Change History
 * Date(YYYYMMDD)       Name                      Description
 * 20220420             thanh.ly@aodigy           Created Initial Version. 
 * 
** *****/
@isTest
private class getCustomerAlertsTest{
    @TestSetup
    static void setup(){
        Account acc = Test_DataFactory.createAccount(true, 'Test');
        Contact con = Test_DataFactory.createContact(true, 'Test', '123', acc.Id);
        CustomerAlerts__c cusAlert = Test_DataFactory.createCusAlert(false, 'Test', (String)con.Id);
        cusAlert.isAlert__c = true;
        cusAlert.Account__c = acc.Id;
        insert cusAlert;
    }

    @isTest
    private static void test_GetAlerts(){
        Contact con = [SELECT Id FROM Contact];

        String reqURI = '/GetCustomerAlerts/v1/' + con.Id;
        Test.startTest();
        Test_DataFactory.createReqSF(reqURI, 'GET', null, null, 200);
        getCustomerAlerts.getAlerts();
        Test.stopTest();
    }

    @isTest
    private static void test_MissingNRIC(){
        String reqURI = '/GetCustomerAlerts/v1/';
        Test.startTest();
        Test_DataFactory.createReqSF(reqURI, 'GET', null, null, 400);
        getCustomerAlerts.getAlerts();
        Test.stopTest();
    }
}
/** ******
 * Description : Test Class for InvoiceEmail_RestTCQueueable class
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                        Description
 * 20220519            thanh.ly@aodigy.com         Created Initial Version
 * 
** ******/
@isTest
private class InvoiceEmail_RestTCQueueableTest {
    @TestSetup
    private static void setup(){
        Campaign camp = Test_DataFactory.createCamp(true, 'Paid Event', 'type', 'CCK');

        Account acc = Test_DataFactory.createAccount(false, 'Thanh');
        insert acc;
        Contact con = Test_DataFactory.createContact(true, 'Thanh', 'Ly', acc.Id);

        Id alertRT = Schema.SObjectType.CustomerAlerts__c.getRecordTypeInfosByName().get('Broadcast').getRecordTypeId();
        CustomerAlerts__c alert = Test_DataFactory.createCusAlert(false, 'Notification', con.Id);
        alert.isAlert__c = true;
        alert.Account__c = acc.Id;
        alert.Description__c = 'Test';
        alert.Deep_Linking_URL__c = 'https:/123/';
        alert.Campaign__c = camp.Id;
        alert.RecordTypeId = alertRT;
        insert alert;
    }

    @isTest
    private static void testExecute() {
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        CustomerAlerts__c alert = [SELECT Id FROM CustomerAlerts__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new InvoiceEmail_ProcessBuilder_RestTCMock());
        Test.startTest();
        InvoiceEmail_RestTCQueueable restTC = new InvoiceEmail_RestTCQueueable(new List<String> {(String)camp.Id}, new Set<Id> {alert.Id});
        System.enqueueJob(restTC);
        Test.stopTest();
    }
}
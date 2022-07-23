/*****************************************
 * Class Name: WarehousePaymentWithoutInfoTest
 * Description: Test Class for WarehousePaymentWithoutInfo
 * 
 *****************************************/
@isTest
private class WarehousePaymentWithoutInfoTest {
	//Test Scheduler
    static testMethod void testData(){
        Test.startTest();
        Invoice__c inv = Test_DataFactory.createInvoice(true, null, null);
        System.schedule('Test Send Email', '0 0 0 ? * * *', new WarehousePaymentWithoutInfo());
        Test.stopTest();
       
    }
}
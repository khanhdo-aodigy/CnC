/** *****
* Description : Test class for InvoiceEmail_ProcessBuilder_RestTC.cls
* 
* Change History
* Date(YYYYMMDD)       Name                            Description
* 20210427           tphan@aodigy.com             	Created Initial Version. 
* 
** *****/

@isTest
private class Test_InvoiceEmail_ProcessBuilder_RestTC 
{
    @isTest
    static void test_apexcallout()
    {
        Campaign c = Test_DataFactory.createCamp(true, 'Test Campaign', 'Events', 'CCA');
        
        Test.setMock(HttpCalloutMock.class, new InvoiceEmail_ProcessBuilder_RestTCMock());
        Test.startTest();
        InvoiceEmail_ProcessBuilder_RestTC.apexcallout(new List<String> {c.Id});
        Test.stopTest();
    }
}
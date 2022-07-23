/** ******
 * Description : Test Class for CBSUpdateLastSyncDateQueueable.cls
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20210205          TP@aodigy.com                   Created Initial Version.
***** **/

@isTest
private class CBSUpdateLastSyncDateQueueableTest 
{
    @isTest
    static void test_CBSUpdateLastSyncDateQueueableTest() 
    {
        CustomMetadataUtils.customMetadata = (List<CLBLReportParm__mdt>) JSON.deserialize( '[{"Last_Sync_Date__c ": "2021-02-05 04:51:26"}]', List<CLBLReportParm__mdt>.class );

        CBSUpdateLastSyncDateQueueable queue = new CBSUpdateLastSyncDateQueueable(Datetime.now().addDays(1));
        Test.startTest();
        System.enqueueJob(queue);
        Test.stopTest();
    }
}
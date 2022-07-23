/*******************************************************
 * Class Name: PaymentReportSchedulerTest
 * Description: Test class for PaymentReportScheduler
 *******************************************************/ 
@isTest
private class PaymentReportSchedulerTest {
    
    //verify queue of Payments Scheduler 
    static testMethod void testSched(){
        Test.startTest();
        PaymentReportScheduler sc = new PaymentReportScheduler();
        Id sysJobId = System.schedule('TEST Sched ' + UserInfo.getUserId(), '1 2 3 4 5 ?', sc);
        Test.stopTest();
        
        //Verify job is submitted
        System.assert( sysJobId != null );
    }
}
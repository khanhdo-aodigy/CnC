/********************************************************************
 * Description:     Schedule Batch Job to send report to SCs when today equals From Date on Bid Period 
 * Date(YYMMDD)                Name                 Description
 * 20220728                    Thanh Ly             Create Initial Version
 */
global class ScheduleBatchEmailCOEBiddingReport implements Schedulable{
    // public static final String CRON_EXPR = '0 0 8 * * ?';

    // global static String scheduleBatch() {
    //     ScheduleBatchEmailCOEBiddingReport job = new ScheduleBatchEmailCOEBiddingReport();
    //     return System.schedule('Send COE Report ', CRON_EXPR, job);
    // }

    global void execute(SchedulableContext ctx) {
        BatchEmailCOEBiddingReport b = new BatchEmailCOEBiddingReport();
        Database.executeBatch(b);
   	}
}
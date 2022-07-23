global class ScheduleBatchEmailNotificationsCOE implements Schedulable{
    public static final String CRON_EXPR = '0 0 0 * * ?';

    global static String scheduleBatch() {
        ScheduleBatchEmailNotificationsCOE job = new ScheduleBatchEmailNotificationsCOE();
        return System.schedule('Send COE Expiry Emails', CRON_EXPR, job);
    }

    global void execute(SchedulableContext ctx) {
        BatchEmailNotificationsCOE b = new BatchEmailNotificationsCOE();
        Database.executeBatch(b, 150);
   	}
}
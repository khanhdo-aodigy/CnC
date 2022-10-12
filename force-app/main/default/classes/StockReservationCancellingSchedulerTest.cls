@IsTest
private with sharing class StockReservationCancellingSchedulerTest
{
    @IsTest
    private static void scheduling()
    {
        StockReservationCancellingScheduler scheduler = new StockReservationCancellingScheduler();
        String cronExp = '0 0 23 * * ?';
        System.schedule('StockReservationCancellingBatchJob', cronExp, scheduler);
    }
}

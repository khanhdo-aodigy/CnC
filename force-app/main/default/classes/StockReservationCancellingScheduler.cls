/**
 * 
 */
public with sharing class StockReservationCancellingScheduler implements Schedulable
{
    public void execute(SchedulableContext cx)
    {
        Database.executeBatch(new StockReservationCancellingBatchJob());
    }
}

/** ******
 * Description : Invoked to perform API Callout when the Customer Alerts are inserted via Batch context (i.e. BroadcastCreationBatch.cls )
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200305            HS         Created Initial Version
 * 
** ******/
public with sharing class BroadcastPushAlertQueueable implements Queueable {
    
    public Set<Id> setCustAlertBroacastId = new Set<Id>();

    public BroadcastPushAlertQueueable( Set<Id> setCustomerAlertIds ) 
    {
        setCustAlertBroacastId = setCustomerAlertIds;
    }

    public void execute(QueueableContext con)
    {
        System.debug('@@@@DEBUG BroadcastPushAlertQueueable :: setCustAlertBroacastId = ' + setCustAlertBroacastId.size() + ' --- ' + setCustAlertBroacastId );

        if( setCustAlertBroacastId<>null && !setCustAlertBroacastId.isEmpty() )
        {   
            BroadcastController.pushCustomerBroadcast( setCustAlertBroacastId );
        }
    }

}
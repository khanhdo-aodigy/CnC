/** ******
 * Description : Queueable class to trigger updating Last Sync Date on CLBLReportParm__mdt.
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20210203          TP@aodigy.com                   Created Initial Version.
***** **/

public class CBSUpdateLastSyncDateQueueable implements Queueable
{
    private Datetime LastSyncDate;
    
    public CBSUpdateLastSyncDateQueueable(Datetime record)
    {
        this.LastSyncDate = record;
    }

    public void execute(QueueableContext context) 
    { 
        Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
        metadataFieldValueMap.put('Last_Sync_Date__c', LastSyncDate);
        CustomMetadataUtils.updateCustomMetadata('CLBLReportParm__mdt','Booking_list', 'Booking list',metadataFieldValueMap);       
    } 
}
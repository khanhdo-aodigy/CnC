/** *****
* Description : Controller class of custom action Resync.
*
* Change History
* Date(YYYYMMDD)      Name       		Description
* 20200915            huynh.hung       Created Initial Version.
*
** *****/
public class DWH_AftersalesAPIResyncController {
    @AuraEnabled
    public static void getSyncAPIAgain(Date fromDate, Date toDate)
    {
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();
		lastRunDateVar.Post_Service_Sync_From__c = fromDate;
        lastRunDateVar.Post_Service_Sync_To__c = toDate;
		update lastRunDateVar;
        //System.debug('lastRunDateVar before batch:' + lastRunDateVar.Post_Service_Sync_From__c + ',' + lastRunDateVar.Post_Service_Sync_To__c);
        BatchAftersalesServiceHeader batchable = new BatchAftersalesServiceHeader(); 
        Database.executebatch(batchable, 1);
    }
}
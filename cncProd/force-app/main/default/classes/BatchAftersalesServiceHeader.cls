/** *****
* Description : Batch class to call DWH aftersales API.
*
* Change History
* Date(YYYYMMDD)      Name       		Description
* 20200915            huynh.hung       Created Initial Version.
*
** *****/
public class BatchAftersalesServiceHeader implements Schedulable, Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful{
    public BatchAftersalesServiceHeader() {}
    
    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new BatchAftersalesServiceHeader(),1);
    }
    
	public Integer currentPage = 1;

    public Iterable<sObject> start(Database.Batchablecontext BC){
        DWH_AftersalesServiceHeader.getPostServiceHeaderDataFromDWHCount(null, null);
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Post_Service_NumberOfPages__c);
        System.debug('@@@@DEBUG BatchAftersalesServiceHeader: START :: totalPages = '+totalPages);
        return [SELECT Id FROM Contact LIMIT :totalPages];    
    }

    public void Execute(Database.BatchableContext BC, List<sObject> scope){  
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Post_Service_NumberOfPages__c);
        System.debug('@@@@DEBUG BatchAftersalesServiceHeader: EXECUTE :: currentPage = ' + this.currentPage + ' / ' + totalPages + ' --- scope.size() ' + scope.size());

        if( currentPage <= totalPages)
        {
            DWH_AftersalesServiceHeader.getPostServiceHeaderDataFromDWH(currentPage, null, null);
            this.currentPage = this.currentPage + 1;
        }
    }

    public void finish(Database.BatchableContext info){
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();
        if(lastRunDateVar.Post_Service_Sync_From__c <> null && lastRunDateVar.Post_Service_Sync_To__c <> null){
            lastRunDateVar.Post_Service_Sync_From__c = null;
            lastRunDateVar.Post_Service_Sync_To__c = null;
            update lastRunDateVar;
        }

    }
}
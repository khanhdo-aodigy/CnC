/** *****
 * Description : Scheduler class that used to sync the Vehicle Credit data from DWH
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200622            HS@aodigy            Created Initial Version 
 * 
** *****/
global class DWH_GetCreditTransaction_Sch implements Schedulable, Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful {

    public Integer currentPage = 1;

    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new DWH_GetCreditTransaction_Sch(),1);
    }

    public Iterable<sObject> start(Database.Batchablecontext BC)
    {
        DWH_CreditTransactionService.getVSMSCreditTransactionDataCount(null, null);
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Credit_Transaction_NumberOfPages__c);
        System.debug('@@@@DEBUG DWH_GetCreditTransaction_Sch:: START :: totalPages = '+totalPages);
        return [SELECT Id FROM Registered_Vehicle__c LIMIT :totalPages];    
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {  

        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Credit_Transaction_NumberOfPages__c);
        System.debug('@@@@DEBUG DWH_GetCreditTransaction_Sch:: EXECUTE :: currentPage = ' + this.currentPage + ' / ' + totalPages + ' --- scope.size() ' + scope.size());

        if( currentPage <= totalPages)
        {
            DWH_CreditTransactionService.syncVehicleCreditDataFromDWH( DWH_CreditTransactionService.getVehicleCreditDataFromDWH( currentPage, null, null ) ); 
            // DWH_CreditTransactionService.getVehicleCreditDataFromDWH( currentPage, null, null );
            this.currentPage = this.currentPage + 1;
        }
    }

    public void finish(Database.BatchableContext info)
    {
        DWH_CreditTransactionService.updateDWHcustomSetting( true );
    }

}
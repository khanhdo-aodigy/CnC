/*******
 * Description : Scheduler class that used to sync the Vehicle Credit data from DWH
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                Description
 * 20200217             HS@aodigy           Created Initial Version 
 * 20200720             HS@aodigy           Added invokeVehicleCreditDateSync method invocation
 * 20200827             HS@aodigy           Added Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful
 * 
*******/
global class DWH_GetVehicleCreditData_Sch implements Schedulable, Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful {


    public Integer currentPage = 1;
    public static Boolean success = true;

    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new DWH_GetVehicleCreditData_Sch(),1);
    }

    public Iterable<sObject> start(Database.Batchablecontext BC)
    {
        VehicleCreditService.getGetCreditAccountDWHCount(null,null);
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Vehicle_Credit_NumberOfPages__c);
        System.debug('@@@@DEBUG DWH_GetVehicleCreditData_Sch:: START :: totalPages = '+totalPages);
        return [SELECT Id FROM Vehicle_Credit__c LIMIT :totalPages];    
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){  

        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Vehicle_Credit_NumberOfPages__c);
        System.debug('@@@@DEBUG DWH_GetVehicleCreditData_Sch:: EXECUTE :: currentPage = ' + this.currentPage + ' / ' + totalPages + ' --- scope.size() ' + scope.size());

        if( currentPage <= totalPages)
        {
            VehicleCreditService.getVehicleCreditDataFromDWH(currentPage, null, null);
            this.currentPage = this.currentPage + 1;
        }
    }

    public void finish(Database.BatchableContext info)
    {
        VehicleCreditService.updateDWHcustomSetting( success );
    }

}
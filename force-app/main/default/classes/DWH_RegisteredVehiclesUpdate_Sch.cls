/**
 * @File Name          : DWH_RegisteredVehiclesUpdate_Sch.cls
 * @Description        : 
 * @Author             : jmt@aodigy.com
 * @Group              : 
 * @Last Modified By   : jmt@aodigy.com
 * @Last Modified On   : 2/20/2020, 9:52:25 AM
 * @Modification Log   : 
 * Ver       Date               Author      		    Modification
 * 1.0       02/20/2020         jmt@aodigy.com          Initial Version
 * 2.0       09/08/2020         hs@aodigy.com           Changed the class to be batchable , and allow API Callout 
**/
global class DWH_RegisteredVehiclesUpdate_Sch implements Schedulable, Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful {
    
    /*
    global void execute(SchedulableContext ctx){
        updateRegVehicleWithServiceData();
    }

    @future (callout=true)
    public static void updateRegVehicleWithServiceData(){
        RegisteredVehicleService.updateDataFromDWH(RegisteredVehicleService.getDataFromDWH(Date.today()-1)); 
    }
    */
    
    public Integer currentPage = 1;

    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new DWH_RegisteredVehiclesUpdate_Sch(),1);
    }

    public Iterable<sObject> start(Database.Batchablecontext BC){
        DWH_GetRegisteredVehicals_Data.getRegVehicleDWHCount();
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.RegVehicle_NumberOfPage__c);
        System.debug('@@@@DEBUG DWH_RegisteredVehiclesUpdate_Sch:: START :: totalPages = '+totalPages);
        return [SELECT Id FROM Registered_Vehicle__c LIMIT :totalPages];    
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){  

        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.RegVehicle_NumberOfPage__c);
        System.debug('@@@@DEBUG DWH_RegisteredVehiclesUpdate_Sch:: EXECUTE :: currentPage = ' + this.currentPage + ' / ' + totalPages + ' --- scope.size() ' + scope.size());

        if( currentPage <= totalPages)
        {
            RegisteredVehicleService.updateDataFromDWH( RegisteredVehicleService.getDataFromDWH( this.currentPage, Date.today()-1) ); 
            this.currentPage = this.currentPage + 1;
        }
    }

    public void finish(Database.BatchableContext info){}
}
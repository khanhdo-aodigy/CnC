/** *****
 * Description : Scheduler class to call api from UCS to sync vehicle record
 *
 * Change History
 * Date(YYYYMMDD)       Name       		        Description
 * 20210114             huynh.hung              Created Initial Version.
 * 20210310             HS@aodigy               Added new constructor method with "FreeTextFilter" option
 * 
** *****/
global class RASyncVehicleSch implements Schedulable, Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful
{       
    private RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();
    private Integer xDay = RA_GlobalVar.UCS_Last_Update_Date__c <> null ? RA_GlobalVar.UCS_Last_Update_Date__c.intValue() : -1;

    String LASTUPDATEDATE = String.valueOf( Date.today().addDays( xDay ) );
    String REGDATE;
    String SOLDDATE;
    String PRICEUPDATEDATE;
    String FreeTextFilter;

    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new RASyncVehicleSch(),1);
    }
    
    global RASyncVehicleSch(){}
    
    /**
     * USE WITH CARE : Test in Postman before execute the job achocly because the USC API filter format is super-sensitive (ex. spacing, lower/upsert case, etc.)  !!!
     * @param FreeTextFilter  :  Free Text String for filter (example : LASTUPDATEDATE=eq 2021-03-02)
     **/
    global RASyncVehicleSch(String FreeTextFilter ) 
    {   
        this.LASTUPDATEDATE     = null;
        this.REGDATE            = null;
        this.SOLDDATE           = null;
        this.PRICEUPDATEDATE    = null;
        this.FreeTextFilter     = FreeTextFilter;
    }

    global RASyncVehicleSch(String LASTUPDATEDATE, String REGDATE, String SOLDDATE, String PRICEUPDATEDATE) 
    {
        this.LASTUPDATEDATE     = LASTUPDATEDATE;
        this.REGDATE            = REGDATE;
        this.SOLDDATE           = SOLDDATE;
        this.PRICEUPDATEDATE    = PRICEUPDATEDATE;
        this.FreeTextFilter     = null;
    }

    global Iterable<sObject> start(Database.Batchablecontext BC)
    {
        return Database.getQueryLocator( 'Select Id From Account Limit 1');
    }

    global void Execute(Database.BatchableContext BC, list<sObject> scope)
    {
        RASyncVehicleService.syncVehicleFromUCS( RASyncVehicleService.getVehicleFromUCS( LASTUPDATEDATE, REGDATE, SOLDDATE, PRICEUPDATEDATE, FreeTextFilter ), null );
    }

    global void finish(Database.BatchableContext info){ }
}
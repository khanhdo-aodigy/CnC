/** *******
 * Class Name: DWH_BatchDeLinkVehicles
 * Description: Batch class to remove link to a the previous owner of a Registered Vehicle that is currently not owned by anyone.
 * 
 * Date                 Developer Name				Description
 * 10-May-2019          CGaylan						Created.
 * 06-Oct-2020          HS@aodigy                   Assign the Registered Vehicle to No-One (i.e. NULL)
 * 
******* **/ 
public class DWH_BatchDeLinkVehicles implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
	
    public Set<String> dwhMagicList = new Set<String>();
	public Map<String, String> magicMap = new Map<String, String>();
    
    public DWH_BatchDeLinkVehicles(){
        System.enqueuejob( new DWH_QueueDeLinkVehicles() );  
    }
    
    public DWH_BatchDeLinkVehicles(Set<String> dwhMagicAPI){
        dwhMagicList = dwhMagicAPI;
    }
    
    public DWH_BatchDeLinkVehicles(Map<String, String> dwhMagicAPI ){
        magicMap = dwhMagicAPI;
    }
    
    //execute Schedule
    public void execute (SchedulableContext ctx){   
      System.enqueuejob( new DWH_QueueDeLinkVehicles() );  
    }     
    
    //Query all Registered Vehicles currently without Owner as provided by the DWH API.
    public Database.QueryLocator start(Database.BatchableContext db){
        return Database.getQueryLocator([SELECT Id, Contact__c, Account__c, Registration_Number__c, DWH_Vehicle_ID__c 
                                         FROM Registered_Vehicle__c 
                                         WHERE DWH_Vehicle_ID__c IN: magicMap.keySet()]);
    }
    
    public void execute(Database.BatchableContext db, List<Registered_Vehicle__c> scope){
		        
        if(scope != null && !scope.isEmpty())
        {
            try
            {
                global_var__c dwhVal = global_var__c.getOrgDefaults();
                //Dummy Default Owner for Registered Vehicles without Owner Info in DWH.
                String defaultOwner = dwhVal.DWHDelinkedVehicleOwner__c; 
                List<Registered_Vehicle__c> rvList = new List<Registered_Vehicle__c>();
                
                for(Registered_Vehicle__c regVeh : scope)
                {
                    if(regVeh.Contact__c != defaultOwner)
                    {

                        //regVeh.Contact__c = defaultOwner;

                        //19-Aug-2019, delinked Vehicles will have their Registration Number updated to UNKNOWN
                        regVeh.Registration_Number__c = Constants.DELINK_REGNUM;
                        
                        regVeh.Contact__c = null;
                        regVeh.Account__c = null;

                        //Commented-out for Future Purposes; as of the moment all Reg Num will be 'UNKNOWN'
                        /*
                        if( magicMap.containsKey( regVeh.DWH_Vehicle_ID__c ) ){
                            regVeh.Registration_Number__c = magicMap.get( regVeh.DWH_Vehicle_ID__c );
                        }
                        */
                        rvList.add(regVeh);
                    }
                }

                if( rvList <> null && !rvList.isEmpty() ){
                    update rvList;
                }
            }
            catch(Exception e){
                loggerDataPool.buildLogDataPool('DWH_BatchDeLinkVehicles', e);
            }

        }     
    }
    
    public void finish(Database.BatchableContext db){
        batchDataPool.buildBatchDataPool('DWH_BatchDeLinkVehicles', db.getJobId());
    }
}
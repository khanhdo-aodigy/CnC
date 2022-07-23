/****************************************************
* Class Name: DWH_QueueDeLinkVehicles
* Description: Queueable class to get vehicles without 
*				owner from DWH and process via the delink batch.
*
* Developer Name		Date			Description
* CGaylan				10-May-2019		Created.
****************************************************/ 
public class DWH_QueueDeLinkVehicles implements Queueable, Database.AllowsCallouts{
    
    //Sync method
    //Values: 1 for full sync and 0 for partial sync
    public String syncMethod = '1';
    
    public void DWH_QueueDeLinkVehicles(Boolean isFullSync){
        this.syncMethod = isFullSync  ?  '1' : '0';
    }
    
    public void execute(QueueableContext con){
        try{
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();    
            
            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
            String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
            String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
            
            //This is for sandbox development only. Keeping this commented out for future references.
            //Set properties of the  http request
            /*req.setEndpoint('https://api.stg.cyclecarriage.com/DWHAPI/GetVehicleDelink_DWH?syncDate=02/13/2018&noOfRecords=5000&pageNo=1');
            req.setMethod('GET');
            req.setHeader('apikey', 'see dwh'); 
            */
            
            
            //this should be stored in a Remote Site Setting
            //keeping this inside the class for quick updates
            String endpt = '/DWHAPI/GetVehicleDelink_DWH?syncDate=02/13/2018&noOfRecords=' + syncMethod + '&pageNo=1';
            
            req.setEndpoint( APIGateway_url + endpt);
            req.setMethod('GET');
            req.setHeader('apikey', APIGateway_key); 
            req.setHeader('Content-Type', 'application/json'); 
            req.setTimeout(120000);
            
            resp = http.send(req);
            Map<String, String> magicMap = new Map<String, String>();
            
            JSONParser parser = JSON.createParser(resp.getBody());
            while (parser.nextToken() != null) {             
                //Consolidate all magic Id of registered vehicles.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            DeLinkWrapper regVeh = (DeLinkWrapper) parser.readValueAs(DeLinkWrapper.class);
                            if(String.isNotBlank(regVeh.MAGIC)){
                                magicMap.put( regVeh.MAGIC , regVeh.REGNO );
                            }
                        }
                    }
                }
            } 

            if(!magicMap.isEmpty()){
                //call the batch to process the update.
                Database.executeBatch( new DWH_BatchDeLinkVehicles( magicMap ) );
            }
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('DWH_QueueDeLinkVehicles', e);
        }
    }
    
    //Registered Vehicle Wrapper
    public class DeLinkWrapper{
		public String FRANCHISECODE;
		public String FRANCHISE;
		public String REGNO;
		public String COMM;
		public String ENGINE;
		public String CHASSIS;
		public String MAGIC;
		public String EDITED;
        
        public DeLinkWrapper(String fraCode, String franc, String reg, String comm, 
                             String engNum, String chassis, String magic, String edited){
            FRANCHISECODE = fraCode;
            FRANCHISE = franc;
            REGNO = reg;
            COMM = comm;
            ENGINE = engNum;
            CHASSIS = chassis;
            MAGIC = magic;
            EDITED = edited;
        }
    }
}
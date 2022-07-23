//Class for DWH service Packages 
global class DWH_GetServicePackage_Data implements Schedulable
{
Public static Integer count=0;
Public static Service_Packages__c tempServicePackages;
Public Static Boolean isSuccess  = True;
Public Static List<String> DebugLogsListSuccess = New List<String>();
Public Static List<String> DebugLogsListError = New List<String>();
   
global void execute(SchedulableContext ctx)
{getServicePakageData();}


public static void getServicePakageData()            
{
    try 
    {   
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer TotalPages = Integer.valueOf(LastRunDateVar.ServicePackage_TotalPage__c);      

        for(Integer i = 1; i <= TotalPages; i++) 
        {
            UpdateData(i);
        }        
    }
    catch(exception ex1)
    {
        system.debug(ex1.getMessage());
    }
}


//Create future call out method for http call    
@future (callout=true)    
public static void UpdateData(Integer PageNum)            
{
     //create http request, response objects here
    HttpRequest req = new HttpRequest();
    HttpResponse resInput = new HttpResponse();
    Http http = new Http();
    
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
    String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;

    DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
    Integer noOfRecords                 = Integer.valueOf(LastRunDateVar.No_of_Records__c);
    
    //Set properties of the  http request
    req.setEndpoint(APIGateway_url+'/DWHAPI/GetMyPackageDistinct_DWH?noOfRecords=' + String.valueOf(noOfRecords) + '&pageNo=' + String.ValueOf(PageNum));
    req.setMethod('GET');
    req.setHeader('apikey', APIGateway_key); 
    req.setHeader('Accept', 'application/json');
    req.setHeader('Content-Type','application/json;charset=UTF-8');
    
    Integer timeOut = Integer.valueOf(LastRunDateVar.Time_Out__c);
    req.setHeader('Content-Type', 'application/json'); 
    req.setTimeout(timeOut);
    //Send http request, capture response and pass the response to mothod which 
    //will then process the same and update the SFSC object
    try
    {
        resInput = http.send(req);
        UpdateDataParser(resInput);
        
        DebugLogs.getDebugLogs('DWH_GetServicePackage_Data'+PageNum,DebugLogsListSuccess,DebugLogsListError);
        serviceDataPool.buildServiceDataPoolHttp('getServicePakageData', 'DWH_GetServicePackage_Data', '', req, resInput);           
    }
    catch(exception ex1)
    {
        loggerDataPool.buildLogDataPool('DWH_GetServicePackage_Data', ex1);
        system.debug(ex1.getMessage());
    }
}
    public static void UpdateDataParser(HttpResponse res)    
    { 
    //List of objects with updated response
    list<Service_Packages__c> LstServicePackage = new list<Service_Packages__c>();
    Map<String, Service_Packages__c> LstServicePackageMAP = new Map<String, Service_Packages__c>();
    
    try 
    {        
        // Parse entire JSON response.        
        JSONParser parser = JSON.createParser(res.getBody());

        System.debug('Response::: ' + res.getBody() + ' ' + parser);
        
        while (parser.nextToken() != null) {
            // Start at the array of ServicePackages.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next ServicePackage object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                    {
                        // Read entire ServicePackage object, including its array of line items.
                        ServicePackage sVar = (ServicePackage)parser.readValueAs(ServicePackage.class);
                        
                        tempServicePackages = New Service_Packages__c ();  
                        tempServicePackages.Name = sVar.PACKAGE_NAME ;
                        tempServicePackages.DWH_PACKAGE_ID__c = sVar.PACKAGE_NAME+','+sVar.MAGIC;
                        tempServicePackages.Source__c = 'DWH';
                        //tempServicePackages.ITEM_ID__c = sVar.RTSCODE;
                        //tempServicePackages.ITEM_BALANCE__c = sVar.REMAIN_QTY;
                        //tempServicePackages.ITEM_DESCRIPTION__c = sVar.DESCRIPTION ;                        
                        String dateRegEx = '((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])';
                        Pattern myPattern = Pattern.compile(dateRegEx); 
                        If(sVar.EXPIRED_DATE!=null)
                        {
                            Matcher myMatcher = myPattern.matcher(String.valueOf(sVar.EXPIRED_DATE.date())); 
                            if(myMatcher.matches())
                            {
                                tempServicePackages.ITEM_EXPIRY_DATE__c =  sVar.EXPIRED_DATE.date();
                            }         
                        }
                        tempServicePackages.PACKAGE_DESCRIPTION__c = sVar.PACKAGE_DESCRIPTION ;
                        Registered_Vehicle__c tempVeh = new Registered_Vehicle__c();                            
                        tempVeh.DWH_Vehicle_ID__c  =  sVar.MAGIC ;
                        tempServicePackages.Registered_Vehicle__r = tempVeh;
                        
                        //Add ServicePackages to list from API response.
                        LstServicePackageMAP.put(tempServicePackages.DWH_PACKAGE_ID__c, tempServicePackages);
                    }
                }
            }
        }
        
        LstServicePackage = LstServicePackageMAP.values();
        //Upsert the list of updated ServicePackages into SFSC.
        Database.UpsertResult[] results = Database.upsert(LstServicePackage, Service_Packages__c.Fields.DWH_PACKAGE_ID__c, False);       
        
        //Verify and Log the records which were created, updated and threw an error.
        for(Integer index = 0, size = results.size(); index < size; index++) 
        {
            if(results[index].isSuccess()) 
            {
                if(results[index].isCreated()) 
                {
                    System.debug(LstServicePackage[index].DWH_PACKAGE_ID__c+' was created');
                    DebugLogsListSuccess.add(LstServicePackage[index].DWH_PACKAGE_ID__c+' was created');
                } 
                else 
                {
                    System.debug(LstServicePackage[index].DWH_PACKAGE_ID__c+' was updated');
                    DebugLogsListSuccess.add(LstServicePackage[index].DWH_PACKAGE_ID__c+' was updated');
                }
            }
            else
            {
                //isSuccess = False;
                system.debug(LstServicePackage[index].DWH_PACKAGE_ID__c +' had error '+results[index].getErrors());
                DebugLogsListError.add(LstServicePackage[index].DWH_PACKAGE_ID__c +' had error '+results[index].getErrors());                
            }
        }        
    } 
    catch(System.Exception e) 
    {
        isSuccess = False;
        System.debug('System_error: '+ e);
        DebugLogsListError.add('System_error: '+e.getMessage());
    }
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
        LastRunDateVar.isSuccess__c = isSuccess;
        upsert LastRunDateVar;
}
//Define ServicePackage parser class here to parse JSON values to variant fields.
public class ServicePackage {
  
    public String PACKAGE_NAME;
    public String PACKAGE_DESCRIPTION;
    public String RTSCODE;
    public String DESCRIPTION;
    public DateTime  EXPIRED_DATE;
    public Decimal REMAIN_QTY;
    public String MAGIC;
    public String DATECOST;
    
    
    
    public ServicePackage(String PACKAGE_NAMEstr, String PACKAGE_DESCRIPTIONstr, String RTSCODEstr, String DESCRIPTIONstr, 
                          DateTime  EXPIRED_DATEstr , Decimal REMAIN_QTYstr,String MAGICstr, 
                          String DATECOSTstr) 
    {
        PACKAGE_NAME = PACKAGE_NAMEstr;
        PACKAGE_DESCRIPTION = PACKAGE_DESCRIPTIONstr;
        RTSCODE = RTSCODEstr;
        DESCRIPTION = DESCRIPTIONstr;
        EXPIRED_DATE = EXPIRED_DATEstr;
        REMAIN_QTY = REMAIN_QTYstr;
        MAGIC = MAGICstr;
        DATECOST = DATECOSTstr;
        
        
    }
} 

}
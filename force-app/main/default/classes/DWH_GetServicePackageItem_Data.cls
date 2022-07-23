//Class for DWH service Package Items
global class DWH_GetServicePackageItem_Data implements Schedulable
{
    public static Integer count=0;
    public static Service_Package_Item__c tempServicePackagesItem;
    public static Boolean isSuccess  = True;
    public static List<String> DebugLogsListSuccess = New List<String>();
    public static List<String> DebugLogsListError = New List<String>();    
    
    
    global void execute(SchedulableContext ctx)
    {
        getServicePakageItemData();
    }

    public static void getServicePakageItemData()            
    {
        try 
        {   
            DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
            Integer TotalPages = Integer.valueOf(LastRunDateVar.ServicePackageItem_TotalPages__c);        
            for(Integer i = 1; i <= TotalPages; i++) 
            {
                UpdateData(i);
            }         
        }
        catch(exception ex1)
        {
            System.debug(ex1.getMessage());
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
        String APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
    
        //Set properties of the http request
        req.setEndpoint(APIGateway_url+'/DWHAPI/GetMyPackage_DWH?noOfRecords=5000&pageNo='+String.ValueOf(PageNum));
        req.setMethod('GET');
        req.setHeader('apikey', APIGateway_key); 
    
        req.setHeader('Content-Type', 'application/json'); 
        req.setTimeout(110000);
        //Send http request, capture response and pass the response to mothod which 
        //will then process the same and update the SFSC object
        try
        {
            resInput = http.send(req);
            UpdateDataParser(resInput);
            DebugLogs.getDebugLogs('DWH_GetServicePackageItem_Data'+PageNum,DebugLogsListSuccess,DebugLogsListError);
        }
        catch(exception ex1)
        {
            System.debug(ex1.getMessage());
        }
    }

    public static void UpdateDataParser(HttpResponse res)    
    {
        //List of objects with updated response
        List<Service_Package_Item__c> LstServicePackageItem = new List<Service_Package_Item__c>();
        Map<String, Service_Package_Item__c> LstServicePackageMAP = new Map<String, Service_Package_Item__c>();
        try 
        {        
            // Parse entire JSON response.        
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) 
            {
                // Start at the array of ServicePackages.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
                {
                    while (parser.nextToken() != null) 
                    {
                        // Advance to the start object marker to
                        //  find next ServicePackage object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            // Read entire ServicePackage object, including its array of line items.
                            ServicePackage sVar = (ServicePackage)parser.readValueAs(ServicePackage.class);
                            
                            tempServicePackagesItem = New Service_Package_Item__c();  
                            tempServicePackagesItem.Name                = sVar.DESCRIPTION ;
                            tempServicePackagesItem.DWH_Item_Id__c      = sVar.PACKAGE_NAME+','+sVar.MAGIC+','+sVar.RTSCODE; 
                            tempServicePackagesItem.Item_Description__c = sVar.DESCRIPTION ; 
                            tempServicePackagesItem.Source__c           = 'DWH';
                            
                            if(sVar.REMAIN_QTY!=null)
                            {
                                tempServicePackagesItem.Item_Balance__c = String.valueOf(sVar.REMAIN_QTY);
                            }                     
                            
                            String dateRegEx = '((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])';
                            Pattern myPattern = Pattern.compile(dateRegEx); 
                            if(sVar.EXPIRED_DATE!=null)
                            {
                                Matcher myMatcher = myPattern.matcher(String.valueOf(sVar.EXPIRED_DATE.date())); 
                                if(myMatcher.matches())
                                {
                                    tempServicePackagesItem.Item_Expiry_Date__c =  sVar.EXPIRED_DATE.date();
                                }         
                            }
                        
                            Service_Packages__c tempSP = new Service_Packages__c();                            
                            tempSP.DWH_PACKAGE_ID__c   =  sVar.PACKAGE_NAME+','+sVar.MAGIC;
                            tempServicePackagesItem.Service_Package__r = tempSP;
                            
                            Registered_Vehicle__c tempVeh = new Registered_Vehicle__c();                            
                            tempVeh.DWH_Vehicle_ID__c     =  sVar.MAGIC ;
                            tempServicePackagesItem.Registered_Vehicle__r = tempVeh;
                            
                            //Add ServicePackages to list from API response.
                            LstServicePackageMAP.put(tempServicePackagesItem.DWH_Item_Id__c, tempServicePackagesItem);
                        }
                    }
                }
            }
    
            LstServicePackageItem = LstServicePackageMAP.values();
            //Upsert the list of updated ServicePackages into SFSC.
            Database.UpsertResult[] results = Database.upsert(LstServicePackageItem, Service_Package_Item__c.Fields.DWH_Item_Id__c, False);       
    
            //Verify and Log the records which were created, updated and threw an error.
            for(Integer index = 0, size = results.size(); index < size; index++) 
            {
                if(results[index].isSuccess()) 
                {
                    if(results[index].isCreated()) 
                    {
                        System.debug(LstServicePackageItem[index].DWH_Item_Id__c+' was created');
                        DebugLogsListSuccess.add(LstServicePackageItem[index].DWH_Item_Id__c+' was created');
                    } 
                    else 
                    {
                        System.debug(LstServicePackageItem[index].DWH_Item_Id__c+' was updated');
                        DebugLogsListSuccess.add(LstServicePackageItem[index].DWH_Item_Id__c+' was updated');
                    }
                }
                else
                {
                    //isSuccess = False;
                    System.debug(LstServicePackageItem[index].DWH_Item_Id__c +' had error '+results[index].getErrors());
                    DebugLogsListError.add(LstServicePackageItem[index].DWH_Item_Id__c +' had error '+results[index].getErrors());               
                }
            }
            
            DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
            LastRunDateVar.isSuccess__c = isSuccess;
            if(isSuccess=true)
            {
                LastRunDateVar.DWH_import_date__c = Date.today();
            }
            
            upsert LastRunDateVar;
        } 
        catch(System.Exception e) 
        {
            isSuccess = False;
            System.debug('System_error: '+ e);
            DebugLogsListError.add('System_error: '+e.getMessage());
        }
    }

    //Define ServicePackage parser class here to parse JSON values to variant fields.
    public class ServicePackage 
    {
        public String PACKAGE_NAME;
        public String PACKAGE_DESCRIPTION;
        public String RTSCODE;
        public String DESCRIPTION;
        public DateTime EXPIRED_DATE;
        public Decimal REMAIN_QTY;
        public String MAGIC;
        public String DATECOST;

        public ServicePackage(String PACKAGE_NAMEstr, String PACKAGE_DESCRIPTIONstr, String RTSCODEstr, String DESCRIPTIONstr, 
                                DateTime EXPIRED_DATEstr , Decimal REMAIN_QTYstr, String MAGICstr, String DATECOSTstr) 
        {
            PACKAGE_NAME        = PACKAGE_NAMEstr;
            PACKAGE_DESCRIPTION = PACKAGE_DESCRIPTIONstr;
            RTSCODE             = RTSCODEstr;
            DESCRIPTION         = DESCRIPTIONstr;
            EXPIRED_DATE        = EXPIRED_DATEstr;
            REMAIN_QTY          = REMAIN_QTYstr;
            MAGIC               = MAGICstr;
            DATECOST            = DATECOSTstr;
        }
    } 

}
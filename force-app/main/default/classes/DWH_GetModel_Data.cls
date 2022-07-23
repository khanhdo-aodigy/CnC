global class DWH_GetModel_Data implements Schedulable{

Public Static Integer count=0;
Public Static Model__c tempModel;
Public Static Boolean isSuccess  = True;  
Public Static List<String> DebugLogsListSuccess = New List<String>();
Public Static List<String> DebugLogsListError = New List<String>();
    
global void execute(SchedulableContext ctx)
{GetData();}

@future (callout=true)
public static void GetData()            
{
    HttpRequest req = new HttpRequest();
    HttpResponse resInput = new HttpResponse();
    Http http = new Http();
	
    DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
    Datetime LastRunDatetime = (datetime)LastRunDateVar.DWH_import_date__c;
    isSuccess = LastRunDateVar.isSuccess__c;
    String LastRunDate = LastRunDatetime.format('MM/dd/yyyy');  
    
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
    String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
    
    req.setEndpoint(APIGateway_url+'/DWHAPI/GetModelMaster?syncDate='+LastRunDate);
    req.setMethod('GET');
    req.setHeader('apikey', APIGateway_key);
    req.setHeader('Content-Type', 'application/json'); 
    req.setTimeout(120000);
   
 try 
    {       
        resInput = http.send(req);
        UpdateData(resInput);
        DebugLogs.getDebugLogs('DWH_GetModel_Data',DebugLogsListSuccess,DebugLogsListError);
    }
    catch(exception ex1)
    {
        system.debug(ex1.getMessage());
    }
}
public static void UpdateData(HttpResponse res)            
{   
    list<Model__c> LstModel = new list<Model__c>();   
    try 
    {            
        // Parse entire JSON response.
        JSONParser parser = JSON.createParser(res.getBody());
        //System.debug('result json'+res.getBody());
        
        while (parser.nextToken() != null) {
            // Start at the array of Models.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next Model statement object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire Model object, including its array of line items.
                        Model Mod = (Model)parser.readValueAs(Model.class);                       
                        
                        If(Mod.MJM_GRPCD.trim()!='')
                        {
                            tempModel = New Model__c();                        
                            tempModel.Branch_Code__c=Mod.BRM_LCM_COMPCD;                            
                            tempModel.DWH_Model_ID__c=Mod.BRM_LCM_COMPCD+ ',' + Mod.MJM_FRN_FRNCD + ',' + Mod.MJM_GRPCD;                          
                            tempModel.Franchise_Code__c=Mod.MJM_FRN_FRNCD;                            
                            tempModel.Name=Mod.MJM_GRPDESC;
                            tempModel.Model_Description__c=Mod.MJM_GRPDESC;     
                            tempModel.Country__c='Singapore';
                            tempModel.Source__c='DWH';
                            tempModel.Active__c=true;
                            LstModel.add(tempModel);
                        }
                        
                    }
                }
            }
        }
        
        Database.UpsertResult[] results = Database.upsert(LstModel, Model__c.Fields.DWH_Model_ID__c, False);
        for(Integer index = 0, size = results.size(); index < size; index++) 
        {
            if(results[index].isSuccess()) 
            {
                if(results[index].isCreated()) 
                {
                    System.debug(LstModel[index].DWH_Model_ID__c +' was created');
                    DebugLogsListSuccess.add(LstModel[index].DWH_Model_ID__c +' was created');
                } 
                else 
                {
                    System.debug(LstModel[index].DWH_Model_ID__c +' was updated');
                    DebugLogsListSuccess.add(LstModel[index].DWH_Model_ID__c +' was updated');
                }
            }
            else
            {
                isSuccess = False;
                system.debug(LstModel[index].DWH_Model_ID__c +' had error: '+results[index].getErrors());
                DebugLogsListError.add(LstModel[index].DWH_Model_ID__c +' had error: '+results[index].getErrors());
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
    //Parser class to parse response from HTTP response.
    public class Model {
        public String BRM_LCM_COMPCD;
        public String MJM_FRN_FRNCD;
        public String MJM_GRPCD;
        public String MJM_GRPDESC;
        public DateTime MJM_LASTUPDDT;
        public DateTime MJM_CREATEDDT;        
        
        public Model(String BRM_BRCDstr, String MJM_FRN_FRNCDstr,String MJM_GRPCDstr
                       ,String MJM_GRPDESCstr,DateTime MJM_LASTUPDDTdt,DateTime MJM_CREATEDDTdt) 
        {
            BRM_LCM_COMPCD = BRM_BRCDstr;
            MJM_FRN_FRNCD = MJM_FRN_FRNCDstr;
            MJM_GRPCD = MJM_GRPCDstr;
            MJM_GRPDESC = MJM_GRPDESCstr;
            MJM_LASTUPDDT = MJM_LASTUPDDTdt;
            MJM_CREATEDDT = MJM_CREATEDDTdt;          
           
        }
} 

}
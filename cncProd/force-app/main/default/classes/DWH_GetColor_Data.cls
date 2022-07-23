global class DWH_GetColor_Data implements Schedulable{

Public Static Integer count=0;
Public Static Color_Master__c tempColor;
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
    
    req.setEndpoint(APIGateway_url+'/DWHAPI/GetColorMaster?syncDate='+LastRunDate);
    req.setMethod('GET');
    req.setHeader('apikey', APIGateway_key);
    req.setHeader('Content-Type', 'application/json'); 
    req.setTimeout(120000);
	
    try 
    {       
        resInput = http.send(req);
        UpdateData(resInput);
        DebugLogs.getDebugLogs('DWH_GetColor_Data',DebugLogsListSuccess,DebugLogsListError);
    }
    catch(exception ex1)
    {
        system.debug(ex1.getMessage());
    }
}
public static void UpdateData(HttpResponse res)            
{
    try {
       
        list<Color_Master__c> LstColor = new list<Color_Master__c>();
        //res = http.send(req);
         // Parse entire JSON response.      
    	JSONParser parser = JSON.createParser(res.getBody());   
        //System.debug('result json'+res.getBody());
        
        while (parser.nextToken() != null) {
            // Start at the array of colors.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next color statement object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire color object, including its array of line items.
                        Color Col = (Color)parser.readValueAs(Color.class);                       
                        
                        If(Col.CLR_COLORCD!=null)
                        {
                            If(Col.CLR_COLORCD.trim()!='')
                            {
                                tempColor = New Color_Master__c();
                                tempColor.Branch_Code__c=Col.BRM_LCM_COMPCD;
                                tempColor.DWH_Color_ID__c=Col.BRM_LCM_COMPCD + ',' + Col.CLR_FRN_FRNCD + ',' + Col.CLR_COLORCD;
                                tempColor.Franchise_Code__c=Col.CLR_FRN_FRNCD;
                                tempColor.Name=Col.CLR_COLORCD;
                                tempColor.Color_Description__c=Col.CLR_COLORDESC;
                                tempColor.Source__c='DWH';
                                tempColor.Country__c='Singapore';
                                If (Col.CLR_STATUS=='I')
                                {
                                    tempColor.Active__c=false;   
                                }
                                else
                                {
                                    tempColor.Active__c=true;
                                }
                                tempColor.ColorCode__c=Col.CLR_COLORCD;
                                
                                LstColor.add(tempColor);
                                
                            }  }              
                    }
                }
            }
        }
       //upsert LstColor Color_Master__c.Fields.Id;
      	Database.UpsertResult[] results = Database.upsert(LstColor, Color_Master__c.Fields.DWH_Color_ID__c, False);

        for(Integer index = 0, size = results.size(); index < size; index++) 
        {
            if(results[index].isSuccess()) 
            {
                if(results[index].isCreated()) 
                {
                    System.debug(LstColor[index].DWH_Color_ID__c +' was created');
                    DebugLogsListSuccess.add(LstColor[index].DWH_Color_ID__c +' was created');
                } 
                else 
                {
                    System.debug(LstColor[index].DWH_Color_ID__c +' was updated');
                    DebugLogsListSuccess.add(LstColor[index].DWH_Color_ID__c +' was updated');
                }
            }
            else
            {
                isSuccess = False;
                system.debug(LstColor[index].DWH_Color_ID__c +' had error'+results[index].getErrors());
                DebugLogsListError.add(LstColor[index].DWH_Color_ID__c +' had error'+results[index].getErrors());
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
    public class Color {
        public String BRM_LCM_COMPCD;
        public String CLR_FRN_FRNCD;
        public String CLR_COLORCD;
        public String CLR_COLORDESC;
        public DateTime CLR_CREATEDDT; 
        Public String CLR_STATUS;
        
        public Color(String BRM_BRCDstr, String CLR_FRN_FRNCDstr,String CLR_COLORCDstr
                       ,String CLR_COLORDESCstr,String CLR_STATUSBool) 
        {
            BRM_LCM_COMPCD = BRM_BRCDstr;
            CLR_FRN_FRNCD = CLR_FRN_FRNCDstr;
            CLR_COLORCD = CLR_COLORCDstr;
            CLR_COLORDESC = CLR_COLORDESCstr;
            CLR_STATUS = CLR_STATUSBool;
           
        }
} 

}
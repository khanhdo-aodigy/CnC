global class DWH_GetVariant_Data  implements Schedulable{
Public static Integer count=0;
Public static Variant__c tempVariant;
Public Static Boolean isSuccess  = True;
Public Static List<String> DebugLogsListSuccess = New List<String>();
Public Static List<String> DebugLogsListError = New List<String>();
    
Public static Registered_Vehicle__c tempRegistered_Vehicle;
    
global void execute(SchedulableContext ctx)
{getVariantData();}

//Create future call out method for http call    
@future (callout=true)
public static void getVariantData()            
{
    //create http request, response objects here
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
    
    //Set properties of the  http request
    req.setEndpoint(APIGateway_url+'/DWHAPI/GetVariantMaster?syncDate='+LastRunDate);
    req.setMethod('GET');
    req.setHeader('apikey', APIGateway_key); 

    req.setHeader('Content-Type', 'application/json'); 
    req.setTimeout(120000);
	
  	try 
    {   
        //Send http request, capture response and pass the response to mothod which 
        //will then process the same and update the SFSC object
        resInput = http.send(req);
        UpdateData(resInput);
        DebugLogs.getDebugLogs('DWH_GetVariant_Data',DebugLogsListSuccess,DebugLogsListError);
    }
    catch(exception ex1)
    {
        system.debug(ex1.getMessage());
    }
}
public static void UpdateData(HttpResponse res)            
{
    //List of objects with updated response
    list<Variant__c> LstVariant = new list<Variant__c>();
    //list<Variant_Color__c> LstVariantColor = new list<Variant_Color__c>();
    Map<String,String> TempLstVariantColor = new Map<String,String>();
    
        Integer count=0;
    try 
    {        
        // Parse entire JSON response.        
        JSONParser parser = JSON.createParser(res.getBody());
        
        while (parser.nextToken() != null) {
            // Start at the array of Variants.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next varient object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                    {
                        // Read entire variant object, including its array of line items.
                        Variant Var = (Variant)parser.readValueAs(Variant.class);
                        //Below count code TBD                        
                        //count=count+1;
                        //if(count<=50){
                        if(Var.MDM_MODELCD.trim()!='')
                        {
                            tempVariant = New Variant__c();                            
                            tempVariant.Branch__c= Var.BRM_LCM_COMPCD;                            
                            tempVariant.DWH_Variant_ID__c = Var.BRM_LCM_COMPCD+','+Var.MDM_FRN_FRNCD+','+Var.MDM_MODELCD;                            
                            tempVariant.Franchise__c= Var.MDM_FRN_FRNCD;
                            tempVariant.Name = Var.MDM_MODELDESC;
                            tempVariant.Description__c = Var.MDM_MODELDESC;
                            tempVariant.Engine_Capacity__c = Var.MDM_ENGINECAPACITY;
                            tempVariant.Fuel_Type__c = Var.MDM_FUELTYPE;
                            tempVariant.Number_of_Doors__c = Var.MDM_NOOFDOORS;
                            tempVariant.BHP__c = Var.MDM_BHP; 
                            tempVariant.Transmission__c = Var.MDM_TRANSMISSION;
                            tempVariant.Source__c = 'DWH';
                            tempVariant.Country__c = 'Singapore';
                            IF(Var.MDM_STATUS == 'I')
                            {
                                tempVariant.Active__c=false;
                            }
                            else
                            {
                                tempVariant.Active__c=true;
                            }
                            
                            Model__c tempMod=new Model__c();                            
                            tempMod.DWH_Model_ID__c=Var.BRM_LCM_COMPCD +','+ Var.MDM_FRN_FRNCD +','+ Var.MDM_MNM_MAJGRPCD;
                            tempVariant.Model_ID__r = tempMod;	
                            
                            //Add variants to list from API response.
                            LstVariant.add(tempVariant);
                        }
                        //}
                    }
                }
            }
        }
        
        //System.debug('Total DML Statements: ' +  Limits.getDmlStatements()+' Limit DML Statements: '+Limits.getLimitDmlStatements());
        //Upsert the list of updated variants into SFSC.
        Database.UpsertResult[] results = Database.upsert(LstVariant, Variant__c.Fields.DWH_Variant_ID__c, False); 
        
        
        //Verify and Log the records which Variant were created, updated and threw an error.
        for(Integer index = 0, size = results.size(); index < size; index++) 
        {
            if(results[index].isSuccess()) 
            {
                if(results[index].isCreated()) {
                    System.debug(LstVariant[index].DWH_Variant_ID__c +' was created');
                    DebugLogsListSuccess.add(LstVariant[index].DWH_Variant_ID__c +' was created');
                } 
                else 
                {                   
                    System.debug(LstVariant[index].DWH_Variant_ID__c +' was updated');
                    DebugLogsListSuccess.add(LstVariant[index].DWH_Variant_ID__c +' was updated');
                }
            }
            else
            {
                isSuccess = False;
                system.debug(LstVariant[index].DWH_Variant_ID__c +' had error'+results[index].getErrors());
                DebugLogsListError.add(LstVariant[index].DWH_Variant_ID__c +' had error'+results[index].getErrors());
            }
        }
        
        //Create Variant Color junction Object here.
        /*for (String Variant_DWH_Id : TempLstVariantColor.keySet())       
{  
for(String keyVariant_Color :TempLstVariantColor.get(Variant_DWH_Id).split(','))
{                   
Variant_Color__c tempVariant_Color = new Variant_Color__c();

Color_Master__c tempColor = new Color_Master__c();
tempColor.DWH_Color_ID__c = Variant_DWH_Id.substringBefore(',')+','+Variant_DWH_Id.substringBeforeLast(',').substringAfter(',')+','+keyVariant_Color;
tempVariant_Color.Color__r =  tempColor;

Variant__c tempVariant = new Variant__c();
tempVariant.DWH_Variant_ID__c =Variant_DWH_Id;
tempVariant_Color.Variant__r = tempVariant;

tempVariant_Color.Name = tempVariant_Color.Id;
tempVariant_Color.Source__c = 'DWH';                                
tempVariant_Color.DWH_External_ID__c = tempVariant.DWH_Variant_ID__c+','+tempColor.DWH_Color_ID__c;

LstVariantColor.add(tempVariant_Color);
} 
}

//Upsert the list of updated variant-color junction object into SFSC.
Database.UpsertResult[] resultsVC = Database.upsert(LstVariantColor, Variant_Color__c.Fields.DWH_External_ID__c, False);
//Verify and Log the records which were created for Variant Color, updated and threw an error.
for(Integer index = 0, size = resultsVC.size(); index < size; index++) 
{
if(resultsVC[index].isSuccess()) 
{
if(resultsVC[index].isCreated()) {
System.debug('Varianat Color: '+LstVariantColor[index].DWH_External_ID__c +' was created');
} 
else 
{                   
System.debug('Varianat Color: '+LstVariantColor[index].DWH_External_ID__c +' was updated');
}
}
else
{
isSuccess = False;
system.debug('Varianat Color: '+LstVariantColor[index].DWH_External_ID__c +' had error'+resultsVC[index].getErrors());
}
}*/      
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
//Define Variant parser class here to parse JSON values to variant fields.
public class Variant {
	
        public String BRM_LCM_COMPCD;
        public String MDM_FRN_FRNCD;
        public String MDM_MODELCD;
        public String MDM_MODELDESC;
		public String MDM_MNM_MAJGRPCD;
		public String MDM_ENGINECAPACITY;
		public String MDM_FUELTYPE;
		public String MDM_NOOFDOORS;
		public String MDM_BHP;
		public String MDM_TRANSMISSION;
		public String MDM_STATUS; 
    	public String colorArray;
        
        public Variant(String BM_BRCDstr, String MDM_FRN_FRNCDstr, String MDM_MODELCDstr, String MDM_MODELDESCstr, 
                       String MDM_MNM_MAJGRPCDstr, String MDM_ENGINECAPACITYstr, String MDM_FUELTYPEstr,String MDM_NOOFDOORSstr, 
                       String MDM_BHPstr, String MDM_TRANSMISSIONstr, String MDM_STATUSbool, String colorArraystr) 
        {
            BRM_LCM_COMPCD = BM_BRCDstr;
            MDM_FRN_FRNCD = MDM_FRN_FRNCDstr;
            MDM_MODELCD = MDM_MODELCDstr;
            MDM_MODELDESC = MDM_MODELDESCstr;
			MDM_MNM_MAJGRPCD = MDM_MNM_MAJGRPCDstr;
			MDM_ENGINECAPACITY = MDM_ENGINECAPACITYstr;
			MDM_FUELTYPE = MDM_FUELTYPEstr;
			MDM_NOOFDOORS = MDM_NOOFDOORSstr;
			MDM_BHP = MDM_BHPstr;
			MDM_TRANSMISSION = MDM_TRANSMISSIONstr;
			MDM_STATUS = MDM_STATUSbool; 
           	colorArray = colorArraystr; 
        }
} 

}
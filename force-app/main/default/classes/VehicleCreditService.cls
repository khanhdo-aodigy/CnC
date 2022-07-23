/*******
 * Description : Service Class for Vehicle Credit object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200217            HS         Created Initial Version 
 * 
*******/
public with sharing class VehicleCreditService {
    
    private static RegisteredVehicleSelector registeredVehSelector = new RegisteredVehicleSelector();

    public static void getGetCreditAccountDWHCount(Datetime fromDate, Datetime toDate) 
    {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();    
        
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
        DateTime requestFromDate = fromDate <> null ? fromDate : ( lastRunDateVar.Vehicle_Credit_Sync_From__c <> null ? (Datetime)lastRunDateVar.Vehicle_Credit_Sync_From__c : Datetime.now().addDays( -1 ) );
        DateTime requestToDate = toDate <> null ? toDate : ( lastRunDateVar.Vehicle_Credit_Sync_To__c <> null ? (Datetime)lastRunDateVar.Vehicle_Credit_Sync_To__c : Datetime.now().addDays( -1 ) );
        String formattedFromDate = requestFromDate.format('MM/dd/yyyy');   
        String formattedToDate   = requestToDate.format('MM/dd/yyyy');
        
        request.setEndpoint(APIGateway_url+'/DWHAPI/GetCreditAccount_DWH_Count?fromDate=' + formattedFromDate + '&toDate=' + formattedToDate);
        request.setMethod('GET');
        request.setHeader('apikey', APIGateway_key); 
        request.setHeader('Content-Type', 'application/json'); 
        request.setTimeout(120000);

        try 
        {   
            response = http.send(request);
            Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Integer noOfRecords = (Integer)responseMap.get('totalNumberOfRecords');

            System.debug('@@@@DEBUG getGetCreditAccountDWHCount :: noOfRecords = ' + noOfRecords );
            lastRunDateVar.Vehicle_Credit_NumberOfPages__c = ( noOfRecords > 0 && noOfRecords > lastRunDateVar.Vehicle_Credit_NumRecords__c ) ?  (noOfRecords/lastRunDateVar.Vehicle_Credit_NumRecords__c).round(System.RoundingMode.CEILING) : 1;
            System.debug('Vehicle_Credit_NumberOfPages__c = ' + lastRunDateVar.Vehicle_Credit_NumberOfPages__c);
            System.debug('Vehicle_Credit_NumRecords__c = ' + lastRunDateVar.Vehicle_Credit_NumRecords__c);
            update lastRunDateVar;
            
            serviceDataPool.buildServiceDataPoolHttp('getGetCreditAccountDWHCount', 'VehicleCreditService', '', request, response);
        }
        catch(Exception e) 
        {
            System.debug('@@@@DEBUG getGetCreditAccountDWHCount :: Error = ' + e );
            loggerDataPool.buildLogDataPool('VehicleCreditService.getGetCreditAccountDWHCount', e);
        }
    }


    // @future (callout=true)
    public static void getVehicleCreditDataFromDWH(Integer pageNum, Datetime p_fromDate, Datetime p_toDate ) {

        HttpRequest req  = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http        = new Http();
    
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
        DateTime sFromDate = p_fromDate <> null ? p_fromDate : ( lastRunDateVar.Vehicle_Credit_Sync_From__c <> null ? (Datetime)lastRunDateVar.Vehicle_Credit_Sync_From__c : Datetime.now().addDays( -1 ) );
        DateTime sToDate   = p_toDate <> null ? p_toDate : ( lastRunDateVar.Vehicle_Credit_Sync_To__c <> null ? (Datetime)lastRunDateVar.Vehicle_Credit_Sync_To__c : Datetime.now().addDays( -1 ) );
        String strFromDate = sFromDate.format('MM/dd/yyyy');   
        String strToDate   = sToDate.format('MM/dd/yyyy');
        
        String numRecs = LastRunDateVar.Vehicle_Credit_NumRecords__c <> null ? String.valueOf(LastRunDateVar.Vehicle_Credit_NumRecords__c.intValue()): '2000';

        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
        
        // String strEndPoint = APIGateway_url+'/DWHAPI/GetCreditAccount_DWH?fromDate='+strFromDate+'&toDate='+strToDate+'&noOfRecords=0&pageNo=' + pageNum; 
        String strEndPoint = APIGateway_url+'/DWHAPI/GetCreditAccount_DWH?fromDate='+strFromDate+'&toDate='+strToDate+'&noOfRecords='+numRecs+'&pageNo=' + pageNum; 
        System.debug('@@@@DEBUG getVehicleCreditDataFromDWH :: strEndPoint = ' + strEndPoint ); 
        req.setEndpoint( strEndPoint );
        req.setMethod('GET');
        req.setHeader('apikey', APIGateway_key);
        req.setHeader('Content-Type', 'application/json'); 
        req.setTimeout(120000);
        
        try {       
            res = http.send(req);
            syncVehicleCreditDataFromDWH(res);
            serviceDataPool.buildServiceDataPoolHttp('getVehicleCreditDataFromDWH', 'VehicleCreditService', '', req, res);
        }
        catch(exception ex ) {
            System.debug( '@@@@DEBUG getVehicleCreditDataFromDWH ERROR :: ' + ex.getMessage() );
            loggerDataPool.buildLogDataPool('VehicleCreditService', ex);
        }
        //return res;
    }


    public static void syncVehicleCreditDataFromDWH( HttpResponse res ) {

        List<Vehicle_Credit__c> lstVehicleCreditToUpsert = new list<Vehicle_Credit__c>();
        Boolean isSuccess = true;
        try
        {
            
            JSONParser parser = JSON.createParser(res.getBody());
            System.debug('@@@@DEBUG syncVehicleCreditDataFromDWH :: res.getBody() = ' + res.getBody() );

            while (parser.nextToken() != null) {             
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {

                            Vehicle_Credit var = (Vehicle_Credit)parser.readValueAs(Vehicle_Credit.class);
                            Vehicle_Credit__c newVC = new Vehicle_Credit__c();
                            newVC.DWH_Vehicle_ID__c = var.MAGIC_VEHICLE;    
                            newVC.Magic_Customer__c = var.MAGIC;
                            newVC.Account_Number__c = var.ACCNO;
                            newVC.Chassis_Number__c = var.CHASSIS;
                            newVC.Company_ID__c     = var.COMPANY_ID;
                            newVC.Credit_Balance__c = var.CREDIT_BALANCE <> null ? Decimal.valueof( var.CREDIT_BALANCE ) : null;
                            newVC.Data_Source__c    = var.DATASOURCE;       
                            newVC.DWH_Vehicle_ID__c = var.MAGIC_VEHICLE;
                            newVC.Module_ID__c      = var.MODULE_ID;
                            newVC.Status__c         = var.STATUS;
                            newVC.Stop_Flag__c      = var.STOPFLAG.containsIgnoreCase('False') ? false : true;
                            newVC.Type__c           = var.ACCOUNT_TYPE;           
                            newVC.Unique_Key__c     = newVC.Chassis_Number__c +  '_' + newVC.Account_Number__c + '_' + newVC.Type__c;// + '_' + newVC.Status__c;   
                            newVC.Expiry_Date__c    = VehicleCreditService.isValidDate( var.EXPIRYDATE ) ? var.EXPIRYDATE.date() : null ;
                            newVC.Edited_Date__c    = VehicleCreditService.isValidDate( var.EDITED ) ? var.EDITED.date() : null;
                            newVC.DSS_Update_Time__c = var.dss_update_time <> null ? var.dss_update_time : null;
 
                            lstVehicleCreditToUpsert.add( newVC );
                        }
                    }
                }
            }
            
            if( !lstVehicleCreditToUpsert.isEmpty() ) {
                
                lstVehicleCreditToUpsert = VehicleCreditService.linkVehicleCreditToRegisteredVehicle( lstVehicleCreditToUpsert );
                VehicleCreditService.linkVehicleCreditRecordType( lstVehicleCreditToUpsert );
                
                Database.UpsertResult[] results = Database.upsert( lstVehicleCreditToUpsert, Vehicle_Credit__c.Fields.Unique_Key__c, false);       
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if( !results[index].isSuccess() ) {
                        isSuccess = false;
                        break;
                    }
                }
            }

        }
        catch( Exception ex )
        {
            isSuccess = false;
            System.debug('@@@@DEBUG VehicleCreditService :: err cause = '+ ex.getCause() + ' --- err msg = ' + ex.getMessage() + ' --- err line# : ' + ex.getLineNumber()  );
            loggerDataPool.buildLogDataPool('VehicleCreditService', ex);
        }


        if( DWH_GetVehicleCreditData_Sch.success && !isSuccess ){
            DWH_GetVehicleCreditData_Sch.success = isSuccess;
        }
    }


    private static Boolean isValidDate( DateTime dtValueRef ){
        //For Null Dates
        String nullDate = '0001';
        String dateRegEx = '((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])';
        Pattern myPattern = Pattern.compile(dateRegEx);
        Boolean isValid = false;

        if( dtValueRef != null ) {
            if(String.valueOf( dtValueRef ).startsWith(nullDate)) {
                isValid = false;                                          
            }
            else if(myPattern.matcher(String.valueOf(dtValueRef.date())).matches()) {
                isValid = true;
            }
        }
        return isValid;
    }


    private static void linkVehicleCreditRecordType( List<Vehicle_Credit__c> lstVehicleCredits ) {
        Schema.DescribeSObjectResult rvSObj = Schema.SObjectType.Vehicle_Credit__c; 
        Map<String,Schema.RecordTypeInfo> mapVehicleCreditRecordType = rvSObj.getRecordTypeInfosByDeveloperName();
        for( Vehicle_Credit__c vc : lstVehicleCredits ){
            String strKey = vc.Type__c+'_Credit';
            if( mapVehicleCreditRecordType.containsKey( strKey ) ){
                vc.RecordTypeId = mapVehicleCreditRecordType.get( strKey ).getRecordTypeId();
            }
        }
    }


    private static List<Vehicle_Credit__c> linkVehicleCreditToRegisteredVehicle( List<Vehicle_Credit__c> lstVehicleCredits ) {
        Set<String> setChassisNumber = new Set<String>();
        for( Vehicle_Credit__c vc : lstVehicleCredits ){
            setChassisNumber.add( vc.Chassis_Number__c );
        }
        setChassisNumber.remove( null );

        Map<String,Registered_Vehicle__c>  mapRegisteredVehicle = VehicleCreditService.getRegisteredVehicleByChassisID( setChassisNumber );
        List<Vehicle_Credit__c> lstVehicleCreditsFiltered = new List<Vehicle_Credit__c>();
        if( mapRegisteredVehicle <> null && !mapRegisteredVehicle.isEmpty() ){
            for( Vehicle_Credit__c vc : lstVehicleCredits ){
                if( mapRegisteredVehicle.containsKey( vc.Chassis_Number__c ) ){
                    vc.Registered_Vehicle__c = mapRegisteredVehicle.get( vc.Chassis_Number__c ).Id;
                    lstVehicleCreditsFiltered.add( vc );
                }
            }
        }

        System.debug('@@@@DEBUG linkVehicleCreditToRegisteredVehicle :: setChassisNumber = ' + setChassisNumber.size() );
        System.debug('@@@@DEBUG linkVehicleCreditToRegisteredVehicle :: lstVehicleCredits = ' + lstVehicleCredits.size() );
        System.debug('@@@@DEBUG linkVehicleCreditToRegisteredVehicle :: lstVehicleCreditsFiltered = ' + lstVehicleCreditsFiltered.size() );
        return lstVehicleCreditsFiltered;
    }


    private static Map<String,Registered_Vehicle__c> getRegisteredVehicleByChassisID( Set<String> setChassicNumber ) {
        Map<String,Registered_Vehicle__c> mapRegisteredVehicle = new Map<String,Registered_Vehicle__c>();

        if( setChassicNumber <> null & !setChassicNumber.isEmpty() ) {
            for( Registered_Vehicle__c rv : registeredVehSelector.selectByChassisNumber( setChassicNumber ) ){
                mapRegisteredVehicle.put( rv.Chasis_Number__c , rv );
            }
        }
        return mapRegisteredVehicle;
    }


    public static void updateDWHcustomSetting( Boolean isSuccess ){
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
        lastRunDateVar.Vehicle_Credit_Sync_Success__c = isSuccess;
        if( isSuccess ) {
            lastRunDateVar.Vehicle_Credit_Sync_From__c = Date.Today();
            lastRunDateVar.Vehicle_Credit_Sync_To__c   = Date.Today();
        }
        upsert lastRunDateVar;
    }


    public class Vehicle_Credit {
       public String ACCNO;
       public String MAGIC;
       public String MAGIC_VEHICLE;
       public String DATASOURCE;
       public String MODULE_ID;
       public String COMPANY_ID;
       public String ACCOUNT_TYPE;
       public String CREDIT_BALANCE;
       public String STOPFLAG;
       public String CHASSIS;
       public String STATUS;
       public Datetime EXPIRYDATE;
       public Datetime EDITED;
       public Datetime dss_update_time;
    }
}
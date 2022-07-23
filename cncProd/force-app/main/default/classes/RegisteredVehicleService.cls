/**
 * @File Name          : RegisteredVehicleService.cls
 * @Description        : JIRA29
 * @Author             : jmt@aodigy.com
 * @Group              : 
 * @Last Modified By   : jmt@aodigy.com
 * @Last Modified On   : 2/24/2020, 10:27:05 AM
 * @Modification Log   : 
 * Ver      Date             Author      		     Modification
 * 1.0      02/12/2020       jmt@aodigy.com          Initial Version
 * 2.0      09/08/2020       hs@aodigy.com           Added pageNum to allow the API Callout being invoked incrementally 
**/
public inherited Sharing class RegisteredVehicleService {

    //@future(callout=true)
    public static HttpResponse getDataFromDWH(Integer pageNum, Datetime rundate) {
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();    
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();  
    
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
        String numRecs = LastRunDateVar.RegVehicle_NumRecords__c <> null ? String.valueOf(LastRunDateVar.RegVehicle_NumRecords__c.intValue()): '2000';
        
        // req.setEndpoint((String)JCC_GlobalVar.APIGateway_url__c+'/DWHAPI/GetRegVehicle_DWH?syncDate='+rundate.format('MM/dd/yyyy')+'&noOfRecords=0&pageNo=0');
        req.setEndpoint((String)JCC_GlobalVar.APIGateway_url__c+'/DWHAPI/GetRegVehicle_DWH?syncDate='+rundate.format('MM/dd/yyyy')+'&noOfRecords='+numRecs+'&pageNo='+String.ValueOf(pageNum));
        system.debug('Endpoint ====>: '+req.getEndpoint());
        req.setMethod('GET');
        req.setHeader('apikey', (String)JCC_GlobalVar.APIGateway_key__c); 
        req.setHeader('Content-Type', 'application/json'); 
        req.setTimeout(120000);
        try{
            resp = http.send(req);
            //RegisteredVehicleService.processResponse(resp);
            serviceDataPool.buildServiceDataPoolHttp('RegisteredVehicleCallout', 'RegisteredVehicleService', '', req, resp);
            
        }catch(Exception error){
            loggerDataPool.buildLogDataPool('RegisteredVehicleService', error);
        }

        return resp;
    }

    public static void updateDataFromDWH(HttpResponse resp){
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Registered_Vehicle__c.SObjectType});
        RegisteredVehicleUOWHelper updateUOW = new RegisteredVehicleUOWHelper();
        uow.registerWork(updateUOW);

        RegisteredVehicleSelector registeredVehSelector = new RegisteredVehicleSelector();
        MAP<String, Registered_Vehicle__c> magicVehicleMap = new  MAP<String, Registered_Vehicle__c>();
        Set <String> magicVehicleSet = new Set<String>();

        JSONParser parser = JSON.createParser(resp.getBody());
    
        while (parser.nextToken() != null) {   
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT){
                        RegisteredVehicleDWH respRow = (RegisteredVehicleDWH)parser.readValueAs(RegisteredVehicleDWH.class);
                        system.debug('Return ResponseRow:==> ' + respRow);

        
                        Registered_Vehicle__c rec = new Registered_Vehicle__c();
                        rec.DWH_Vehicle_ID__c = respRow.MAGIC_VEHICLE;
                        rec.source__c = 'DWH';  
                        rec.Service_Credits__c = respRow.SVCCRDBAL;
                        rec.Self_Import_Vehicle__c = respRow.IMMOBIL;
                        rec.Next_Service_Booking_KM__c = respRow.NEXTSMIL;
                        rec.Next_Recommended_Servi__c = respRow.NXTRECOMNDSVC;
                        rec.Last_Service_Booking_KM__c = respRow.LASTSMILE;
                        rec.IU__c = respRow.SECURENO;
                        rec.Engine_Number__c = respRow.ENGINE;
                        rec.Comm_No__c = respRow.COMM;
                        rec.vehicleDatasource__c = respRow.VEHICLE_DATASOURCE;
                        rec.registration_number__c = respRow.REGNO;
                        
                        rec.Mileage__c = decimal.valueOf(respRow.IMILEAGEU);
                        rec.SCR__c = Integer.valueof(respRow.SCRBAL);
                        rec.extended_warranty_end_date__c = isValidDate(respRow.WAREXTDT) == false ? null : respRow.WAREXTDT.date();
                        rec.last_battery_change__c = stringToDate(respRow.LASTBATTERYCHANGEdate);
                        rec.Service_Credits_Expiry_Date__c = isValidDate(respRow.SVCCRDEXPDT) == false ? null : respRow.SVCCRDEXPDT.date();
                        rec.Registered_Date__c = isValidDate(respRow.REGDATE) == false ? null : respRow.REGDATE.date();
                        rec.Next_Service_Booking_Date__c = isValidDate(respRow.NEXTSERV) == false ? null : respRow.NEXTSERV.date();
                        rec.Manufacture_Warranty_End_Date__c = isValidDate(respRow.WAREXPDT) == false ? null : respRow.WAREXPDT.date();
                        rec.Last_Service_Booking_Date__c = isValidDate(respRow.LASTSERV) == false ? null : respRow.LASTSERV.date();
                        rec.Car_Collection_Date__c = isValidDate(respRow.COLLECTIONDATE) == false ? null : respRow.COLLECTIONDATE.date();
                        magicVehicleMap.put(rec.DWH_Vehicle_ID__c, rec);
                        magicVehicleSet.add(rec.DWH_Vehicle_ID__c);
   
                    }
                }
            }
            
            if(!(magicVehicleSet.isEmpty())){
                for(Registered_Vehicle__c result : registeredVehSelector.selectByMagicVehicle(magicVehicleSet)){
                    Registered_Vehicle__c rec = magicVehicleMap.get(result.DWH_Vehicle_ID__c);
                    rec.Id = result.Id;
                    updateUOW.registerRegVehicle(rec);
                    //uow.registerDirty(rec);
                }
                uow.commitWork();
                updateUOW.logServiceDataPool();
                
            }
            
        }

        //uow.commitWork();
    }

    private static Date stringToDate(String textDate){
        Date returnDate = null;
        if(String.isNotBlank(textDate)){
            List<String> strList = textDate.split('/');
            if(strList!=null && !strList.isEmpty()){
                returnDate = Date.newInstance(Integer.valueOf(strList.get(2)), 
                    Integer.valueOf(strList.get(1)),
                    Integer.valueOf(strList.get(0)));
            }
        }
        return returnDate;
    }
    private static Boolean isValidDate(Datetime checkDate){
        Boolean returnStatus = false;
        String nullDate = '0001';
        Pattern myPattern = dateFormatMatcher();

        if(checkDate == null || String.valueOf(checkDate).startsWith(nullDate)){
            returnStatus = false;
        }else if(myPattern.matcher(String.valueOf(checkDate.date())).matches()){
            returnStatus = true;
        }

        return returnStatus;
    }
    private static Pattern dateFormatMatcher(){
        return Pattern.compile('((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])');
    }
    public class RegisteredVehicleDWH{

       public String FRANCHISE;
       public String FRANCHISECODE;
       public String REGNO;
       public String COMM;
       public String ENGINE;
       public String CHASSIS;
       public String NEXTSMIL;
       public String SECURENO;
       public String MAGIC;
       public String IMMOBIL;
       public Datetime REGDATE;
       public Datetime COLLECTIONDATE;
       public Datetime LASTSERV;
       public String LASTBATTERYCHANGEdate;
       public Datetime NEXTSERV;
       public Datetime WAREXPDT;
       public Datetime WAREXTDT;
       public Datetime SVCCRDEXPDT;
       public String SVCCRDBAL;
       public String SCRBAL;
       public String MODELYR;
       public String IMILEAGEU;
       public String EXTContactID;
       public String COLCODE;
       public String VARIANT;
       public String LASTSMILE;
       public String NXTRECOMNDSVC;
       public String MAGIC_VEHICLE;
       public String VEHICLE_DATASOURCE;
       public String MAGIC_MBPC;
       public String MAGIC_MBCV;
       public String MAGIC_MF;
       public String MAGIC_FUL;
       public String MAGIC_CUSTOMER;
    }
    
}
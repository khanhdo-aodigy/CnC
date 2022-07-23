global class DWH_GetAllRegisteredVehicals_Data implements Schedulable
{
    Public static Integer count=0;
    Public static Registered_Vehicle__c tempRegistered_Vehicle;
    Public Static Boolean isSuccess  = True;
    Public Static List<String> DebugLogsListSuccess = New List<String>();
    Public Static List<String> DebugLogsListError = New List<String>();
    Public static Boolean isNextAvailable = true;
    
    global void execute(SchedulableContext ctx){
        getAllRegistered_VehicleData();
    }
    
    
    
    public static void getAllRegistered_VehicleData()
    {
        try 
        {   
            DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
            Integer TotalPages = Integer.valueOf(LastRunDateVar.RegVehicle_NumberOfPage__c);
            Integer StartPage = Integer.valueOf(LastRunDateVar.RegVehicle_StartPage__c);
            //Boolean isNextAvailable = true;
            for(Integer i = StartPage; i <= TotalPages; i++) 
            {
                getRegistered_VehicleData(i);
            }    
            

        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('DWH_GetAllRegisteredVehicals_Data', e);
        }
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
        LastRunDateVar.RegVehicle_StartPage__c = LastRunDateVar.RegVehicle_NumberOfPage__c;
        LastRunDateVar.RegVehicle_NumberOfPage__c = LastRunDateVar.RegVehicle_StartPage__c + 10;
        update LastRunDateVar;
    }
    
    
    
    //Create future call out method for http call    
    @future (callout=true)
    public static void getRegistered_VehicleData(Integer PageNum)            
    {
        //create http request, response objects here
        HttpRequest req = new HttpRequest();
        HttpResponse resInput = new HttpResponse();
        Http http = new Http();    

        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
        String numRecs = '5000';
        
        DWH_last_run_date__c lastVals = DWH_last_run_date__c.getOrgDefaults(); 
        if(String.isNotBlank( lastVals.NumRecords__c )){
            numRecs = lastVals.NumRecords__c;
        }
        /*************************************************
         * CGaylan: Implement Named Credentials instead of hard coding URLs
         * 			as well as not to store keys in a custom setting
         ************************************************/
        
        //Set properties of the  http request
        req.setEndpoint(APIGateway_url+'/DWHAPI/GetRegVehicle_DWH?syncDate=01/01/1900&noOfRecords='+numRecs+'&pageNo='+String.ValueOf(PageNum));
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
            DebugLogs.getDebugLogs('DWH_GetAllRegisteredVehicals_Data' + String.ValueOf(PageNum),DebugLogsListSuccess,DebugLogsListError);
            
            serviceDataPool.buildServiceDataPoolHttp('RegVehFullSync', 'DWH_GetAllRegisteredVehicals_Data', '', req, resInput);
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('DWH_GetAllRegisteredVehicals_Data', e);
        }
    }
    
    public static void UpdateData(HttpResponse res)            
    {
        String Col_DWHID_var;
        //List of objects with updated response
        List<Registered_Vehicle__c> LstRegistered_Vehicle = new List<Registered_Vehicle__c>();
        Set<String> setMagicKeys = new Set<String>();
        
        List<Variant__c> TempVariantList = [Select DWH_Variant_ID__c from  Variant__c where DWH_Variant_ID__c!=null and DWH_Variant_ID__c!=''
                                            AND source__c='DWH'];
        List<String> strVariantList = new List<String>();
        for(Variant__c TempVar : TempVariantList)
        {         
            strVariantList.add(TempVar.DWH_Variant_ID__c);
        }
        
        List<Color_Master__c> TempColorList = [Select DWH_Color_ID__c from Color_Master__c where ColorCode__c!=null and ColorCode__c!=''
                                               AND source__c='DWH'];
        List<String> strColorList = new List<String>();
        for(Color_Master__c TempCol : TempColorList)
        {         
            strColorList.add(TempCol.DWH_Color_ID__c);
        }
        
        List<Branch_Code_Name_Mapping__c> TempBranchList = [Select Branch_Code__c,CV_Code__c,PC_Code__c from Branch_Code_Name_Mapping__c];
        Map<String,String> strBranchList = new Map<String,String>();
        for(Branch_Code_Name_Mapping__c TempBranch : TempBranchList)
        {         
            strBranchList.put(TempBranch.CV_Code__c,TempBranch.Branch_Code__c);
            strBranchList.put(TempBranch.PC_Code__c,TempBranch.Branch_Code__c);
        }
        
        try 
        {        
            // Parse entire JSON response.             
            JSONParser parser = JSON.createParser(res.getBody());
            String dateRegEx = '((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])';
            Pattern myPattern = Pattern.compile(dateRegEx);

            //For Null Dates
            String nullDate = '0001';            
            
            while (parser.nextToken() != null) {             
                // Start at the array of Registered_Vehicles.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {           
                    while (parser.nextToken() != null) {
                        
                        // Advance to the start object marker to
                        //  find next Registered_Vehicle object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            // Read entire Registered_Vehicle object, including its array of line items.
                            Registered_Vehicle Var = (Registered_Vehicle)parser.readValueAs(Registered_Vehicle.class);
                            IF(Var.MAGIC!=null)
                            {
                                IF(Var.MAGIC.trim()!='')
                                {
                                    tempRegistered_Vehicle = New Registered_Vehicle__c();  
                                    tempRegistered_Vehicle.Name = Var.REGNO;
                                    tempRegistered_Vehicle.Franchise__c= Var.FRANCHISE; 
                                    tempRegistered_Vehicle.Branch__c= strBranchList.get(Var.FRANCHISE);        
                                    
                                    //Updated 2019-Aug: Autoline Split
                                    tempRegistered_Vehicle.DWH_Vehicle_ID__c = Var.MAGIC_VEHICLE;   

                                    tempRegistered_Vehicle.Registration_Number__c= Var.REGNO;
                                    tempRegistered_Vehicle.Comm_No__c = Var.COMM;
                                    tempRegistered_Vehicle.Engine_Number__c = Var.ENGINE;
                                    tempRegistered_Vehicle.Chasis_Number__c = Var.CHASSIS;
                                    tempRegistered_Vehicle.Model_Year__c = Var.MODELYR;	     
                                    tempRegistered_Vehicle.Autoline_Franchise_Code__c = Var.FRANCHISECODE;
                                    tempRegistered_Vehicle.Next_Service_Booking_KM__c = Var.NEXTSMIL;
                                    tempRegistered_Vehicle.IU__c = Var.SECURENO;
                                    tempRegistered_Vehicle.Service_Credits__c = Var.SVCCRDBAL;
                                    tempRegistered_Vehicle.Self_Import_Vehicle__c = Var.IMMOBIL;
                                    tempRegistered_Vehicle.Last_Service_Booking_KM__c = Var.LASTSMILE; 
                                    tempRegistered_Vehicle.source__c = 'DWH';                            
                                    if(Var.IMILEAGEU!=null)
                                    {
                                        tempRegistered_Vehicle.Mileage__c = decimal.valueOf(Var.IMILEAGEU);
                                    }
                                    
                                    
                                    if(Var.REGDATE!=null)
                                    {
                                        if(String.valueOf(Var.REGDATE).startsWith(nullDate)){
                                            tempRegistered_Vehicle.Registered_Date__c = null;                                            
                                        }else if(myPattern.matcher(String.valueOf(Var.REGDATE.date())).matches()){
                                            tempRegistered_Vehicle.Registered_Date__c = Var.REGDATE.date();
                                        }
                                    }
                                    
                                    if(Var.COLLECTIONDATE!=null)
                                    {
                                        if(String.valueOf(Var.COLLECTIONDATE).startsWith(nullDate)){
                                            tempRegistered_Vehicle.Car_Collection_Date__c = null;                                            
                                        }else if(myPattern.matcher(String.valueOf(Var.COLLECTIONDATE.date())).matches()){
                                            tempRegistered_Vehicle.Car_Collection_Date__c = Var.COLLECTIONDATE.date();
                                        }
                                      
                                    }
                                    
                                    if(Var.LASTSERV!=null)
                                    {
                                        if(String.valueOf(Var.LASTSERV).startsWith(nullDate)){
                                            tempRegistered_Vehicle.Last_Service_Booking_Date__c = null;                                            
                                        }else if(myPattern.matcher(String.valueOf(Var.LASTSERV.date())).matches()){
                                            tempRegistered_Vehicle.Last_Service_Booking_Date__c = Var.LASTSERV.date();
                                        }
                                    } 
                                    
                                    //lastbatteryChange - 17/6/2019
                                    if(String.isNotBlank(Var.LASTBATTERYCHANGEdate))
                                    {
                                        List<String> strList = Var.LASTBATTERYCHANGEdate.split('/');
                                        if(strList!=null && !strList.isEmpty()){
                                            //year - month - day
                                            tempRegistered_Vehicle.Last_Battery_Change__c = Date.newInstance(Integer.valueOf(strList.get(2)), 
                                                                                                             Integer.valueOf(strList.get(1)),
                                                                                                             Integer.valueOf(strList.get(0)) );
                                        }
                                    } 
                                    
                                    if(Var.NEXTSERV!=null)
                                    {
                                        if(String.valueOf(Var.NEXTSERV).startsWith(nullDate)){
                                            tempRegistered_Vehicle.Next_Service_Booking_Date__c = null;                                            
                                        }else if(myPattern.matcher(String.valueOf(Var.NEXTSERV.date())).matches()){
                                            tempRegistered_Vehicle.Next_Service_Booking_Date__c = Var.NEXTSERV.date();
                                        }
                                    }
                                    
                                    if(Var.WAREXPDT!=null)
                                    {
                                        if(String.valueOf(Var.WAREXPDT).startsWith(nullDate)){
                                            tempRegistered_Vehicle.Manufacture_Warranty_End_Date__c = null;                                            
                                        }else if(myPattern.matcher(String.valueOf(Var.WAREXPDT.date())).matches()){
                                            tempRegistered_Vehicle.Manufacture_Warranty_End_Date__c = Var.WAREXPDT.date();
                                        }
                                    }
                                    
                                    if(Var.WAREXTDT!=null)
                                    {
                                        if(String.valueOf(Var.WAREXTDT).startsWith(nullDate)){
                                            tempRegistered_Vehicle.Extended_Warranty_End_Date__c = null;                                            
                                        }else if(myPattern.matcher(String.valueOf(Var.WAREXTDT.date())).matches()){
                                            tempRegistered_Vehicle.Extended_Warranty_End_Date__c = Var.WAREXTDT.date();
                                        }
                                    }
                                    
                                    if(Var.SVCCRDEXPDT!=null)
                                    {
                                        if(String.valueOf(Var.SVCCRDEXPDT).startsWith(nullDate)){
                                            tempRegistered_Vehicle.Service_Credits_Expiry_Date__c = null;                                            
                                        }else if(myPattern.matcher(String.valueOf(Var.SVCCRDEXPDT.date())).matches()){
                                            tempRegistered_Vehicle.Service_Credits_Expiry_Date__c = Var.SVCCRDEXPDT.date();
                                        }
                                    }

                                    //Start: Autoline Split: 2019- Aug
                                    
                                    //Autoline Split 2019-Aug
                                    tempRegistered_Vehicle.EXTContactID__c = Var.EXTContactID;
                                    
                                    //Linking Registered Vehicle to Business Contact
                                    Contact tempCon = new Contact();                            
                                    tempCon.DWH_Contact_ID__c = Var.MAGIC_CUSTOMER;                            
                                    // tempRegistered_Vehicle.Contact__r = tempCon;
                                    
                                    /** PA Migration : Newly Added */
                                    //Account tempAccount = new Account( RecordTypeId = AccountUtil.getCustomerRecordTypeId() ); 
                                    //tempAccount.DWH_Contact_ID__pc = Var.MAGIC_CUSTOMER;                            
                                    //tempRegistered_Vehicle.Account__r = tempAccount;
                                    
                                    tempRegistered_Vehicle.MagicCustomer__c = Var.MAGIC_CUSTOMER;
                                    tempRegistered_Vehicle.VehicleDataSource__c = Var.VEHICLE_DATASOURCE;
                                    tempRegistered_Vehicle.MAGIC_MBPC__c = Var.MAGIC_MBPC;
                                    tempRegistered_Vehicle.MAGIC_MBCV__c = Var.MAGIC_MBCV;
                                    tempRegistered_Vehicle.MAGIC_MF__c = Var.MAGIC_MF;
                                    tempRegistered_Vehicle.MAGIC_FUL__c = Var.MAGIC_FUL;
                                    
                                    //End: Autoline Split: 2019- Aug
                                    
                                    If(strVariantList.contains(Var.VARIANT))
                                    {
                                        Variant__c tempVariant = new Variant__c();
                                        tempVariant.DWH_Variant_ID__c = Var.VARIANT;                            
                                        tempRegistered_Vehicle.Variant__r = tempVariant;                            
                                    }
                                    
                                    Col_DWHID_var = strBranchList.get(Var.FRANCHISE) + ',' + Var.FRANCHISE + ',' + Var.COLCODE;
                                    If(strColorList.contains(Col_DWHID_var))
                                    {
                                        Color_Master__c tempColor = new Color_Master__c();
                                        tempColor.DWH_Color_ID__c = Col_DWHID_var;
                                        tempRegistered_Vehicle.Color__r = tempColor;   
                                    }
                                    
                                    //Add Registered_Vehicles to list from API response.
                                    LstRegistered_Vehicle.add(tempRegistered_Vehicle);
                                    setMagicKeys.add( var.MAGIC_CUSTOMER );
                                    System.debug(tempRegistered_Vehicle);
                                }
                            }
                        }
                    }
                }
            }       

            System.debug('@@@@DEBUG UpdateData :: lstRegistered_Vehicle = ' + lstRegistered_Vehicle.size() + ' --- ' + lstRegistered_Vehicle );
            System.debug('@@@@DEBUG UpdateData :: lstRegistered_Vehicle = ' + setMagicKeys.size() + ' --- ' + setMagicKeys );

            /** PA MIGRATION : Newly Added Start ; DWH Contact ID: more than one record found for external id field -> One for Business Contact, Another one will be created for Person Account Contact  */
            setMagicKeys.remove( null );
            Map<String,Account> mapMagicOfAccount = new Map<String,Account>();
            Map<String,Contact> mapMagicOfContact = new Map<String,Contact>();
            if( !setMagicKeys.isEmpty() ) 
            {
                // Person Account - Customer
                for( Account acct : [SELECT Id, Name, DWH_Contact_ID__c, RecordTypeId FROM Account WHERE DWH_Contact_ID__c IN:setMagicKeys AND RecordType.Name = 'Customer' ]){
                    mapMagicOfAccount.put( acct.DWH_Contact_ID__c, acct );
                }

                //To Remove
                for( Contact cnt : [SELECT Id, Name, DWH_Contact_ID__c, Account.RecordTypeId FROM Contact WHERE DWH_Contact_ID__c IN:setMagicKeys AND IsPersonAccount = false ]){
                    mapMagicOfContact.put( cnt.DWH_Contact_ID__c , cnt );
                }
            }
            for( Registered_Vehicle__c rv : lstRegistered_Vehicle ) {
                rv.Contact__c = mapMagicOfContact.containsKey( rv.MagicCustomer__c ) ? mapMagicOfContact.get( rv.MagicCustomer__c ).Id : rv.Contact__c;
                rv.Account__c = mapMagicOfAccount.containsKey( rv.MagicCustomer__c ) ? mapMagicOfAccount.get( rv.MagicCustomer__c ).Id : rv.Account__c;
            }
            /** PA MIGRATION end Newly Added End*/

            //Upsert the list of updated Registered_Vehicles into SFSC.
            Database.UpsertResult[] results = Database.upsert(LstRegistered_Vehicle, Registered_Vehicle__c.Fields.Chasis_Number__c, False);       
            
            //Verify and Log the records which were created, updated and threw an error.
            for(Integer index = 0, size = results.size(); index < size; index++) 
            {
                if(results[index].isSuccess()) 
                {
                    if(results[index].isCreated()) 
                    {
                        DebugLogsListSuccess.add(LstRegistered_Vehicle[index].Chasis_Number__c +' was created');
                    } 
                    else 
                    {
                        DebugLogsListSuccess.add(LstRegistered_Vehicle[index].Chasis_Number__c +' was updated');
                    }
                }
                else
                {
                    isSuccess = False;
                    DebugLogsListError.add(LstRegistered_Vehicle[index].Chasis_Number__c +' had error '+results[index].getErrors());
                }
            }
            
        } 
        catch(System.Exception e) 
        {
            isSuccess = False;
            DebugLogsListError.add('System_error: '+e.getMessage());
        }
        
    }
    //Define Registered_Vehicle parser class here to parse JSON values to Registered_Vehicle fields.
    public class Registered_Vehicle {
        
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
        public String LASTBATTERYCHANGEdate;//lastbatteryChange
        public Datetime NEXTSERV;
        public Datetime WAREXPDT;
        public Datetime WAREXTDT;
        public Datetime SVCCRDEXPDT;
        public String SVCCRDBAL;
        public String MODELYR;
        public String IMILEAGEU;
        public String EXTContactID;
        public String COLCODE;
        public String VARIANT;
        public String LASTSMILE;
        
        // Start: AutoLine Split (2019-Aug)
        public String MAGIC_VEHICLE;
        public String VEHICLE_DATASOURCE;
        public String MAGIC_MBPC;
        public String MAGIC_MBCV;
        public String MAGIC_MF;
        public String MAGIC_FUL;
        public String MAGIC_CUSTOMER;
        // End: AutoLine Split (2019-Aug)
        
        public Registered_Vehicle(String FRANCHstr, String FRANCHISECODEstr, String REGNOstr, String COMMstr, String ENGINEstr, 
                                  String CHASSISstr, String NEXTSMILstr, String SECURENOstr,String MAGICstr, 
                                  String IMMOBILstr, Datetime REGDATEstr, Datetime LASTSERVstr,String LASTBATTERYCHANGEdatestr,Datetime NEXTSERVstr , 
                                  Datetime WAREXPDTstr, Datetime WAREXTDTstr, Datetime SVCCRDEXPDTstr, String SVCCRDBALstr, String MODELYRstr, 
                                  String IMILEAGEUstr, String EXTContactIDstr, String COLCODEstr, String VARIANTstr, Datetime COLLECTIONDATEstr, String LASTSMILEstr,
                                  //AutoLine Split (2019-Aug)
                                  String MAGIC_VEHICLEstr, String VEHICLE_DATASOURCEstr, 
                                  String MAGIC_MBPCstr, String MAGIC_MBCVstr, String MAGIC_MFstr, String MAGIC_FULstr,
                                  String MAGIC_CUSTOMERstr) 
        {
            FRANCHISE = FRANCHstr;
            FRANCHISECODE = FRANCHISECODEstr;
            REGNO = REGNOstr;
            COMM = COMMstr;
            ENGINE = ENGINEstr;
            CHASSIS = CHASSISstr;
            NEXTSMIL = NEXTSMILstr;
            SECURENO = SECURENOstr;
            MAGIC = MAGICstr;
            IMMOBIL = IMMOBILstr;
            REGDATE = REGDATEstr;
            LASTSERV = LASTSERVstr;
            LASTBATTERYCHANGEdate = LASTBATTERYCHANGEdatestr; //lastbatteryChange
            NEXTSERV = NEXTSERVstr;
            WAREXPDT = WAREXPDTstr;
            WAREXTDT = WAREXTDTstr;
            SVCCRDEXPDT = SVCCRDEXPDTstr;
            SVCCRDBAL = SVCCRDBALstr;
            MODELYR = MODELYRstr;
            IMILEAGEU = IMILEAGEUstr;
            EXTContactID = EXTContactIDstr;
            COLCODE = COLCODEstr;
            VARIANT = VARIANTstr;
            COLLECTIONDATE = COLLECTIONDATEstr;
            LASTSMILE = LASTSMILEstr;

            // Start: AutoLine Split (2019-Aug)
            MAGIC_VEHICLE = MAGIC_VEHICLEstr;
            VEHICLE_DATASOURCE = VEHICLE_DATASOURCEstr;
            MAGIC_MBPC = MAGIC_MBPCstr;
            MAGIC_MBCV = MAGIC_MBCVstr;
            MAGIC_MF = MAGIC_MFstr;
            MAGIC_FUL = MAGIC_FULstr;
            MAGIC_CUSTOMER = MAGIC_CUSTOMERstr;
            // End: AutoLine Split (2019-Aug)
        }
    } 
}
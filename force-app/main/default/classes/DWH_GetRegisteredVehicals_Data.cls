/** *****
 * Description : DWH_GetRegisteredVehicals_Data: Sync vehicles from DWH and links Vehicle to PA Customer (using Email)
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * YYYYMMDD             Cycle & Carriage                 Created Initial Version
 * 20210728             khanh.do@aodigy.com              Linked Vehicle to Customer (using email).
 * 20220708             thieudang.vu@aodigy.com          Modify logic of linking vehicle to customer (using email + NRIC).
 * 
** *****/
public class DWH_GetRegisteredVehicals_Data implements Schedulable, Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful
{
    public static Integer count = 0;
    public static Boolean isSuccess = true;
    public static List<String> DebugLogsListSuccess = New List<String>();
    public static List<String> DebugLogsListError = New List<String>();
    public static String InputCSVMagic = '';
    public Integer currentPage = 1;
    
    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new DWH_GetRegisteredVehicals_Data(),1);
    }


    public Iterable<sObject> start(Database.Batchablecontext BC)
    {
        getRegVehicleDWHCount();
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.RegVehicle_NumberOfPage__c);
        System.debug('@@@@DEBUG DWH_GetRegisteredVehicals_Data:: START :: totalPages = '+totalPages);
        System.debug('Records List' + [SELECT Id FROM Registered_Vehicle__c LIMIT :totalPages]);
        return [SELECT Id FROM Registered_Vehicle__c LIMIT :totalPages];    
    }


    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {  

        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.RegVehicle_NumberOfPage__c);
        System.debug('@@@@DEBUG DWH_GetRegisteredVehicals_Data:: EXECUTE :: currentPage = ' + this.currentPage + ' / ' + totalPages + ' --- scope.size() ' + scope.size());
        if( currentPage <= totalPages)
        {
            getRegistered_VehicleData(currentPage);   
            this.currentPage = this.currentPage + 1;
        }
    }


    public void finish(Database.BatchableContext info){ }


    public static void getRegVehicleDWHCount()
    {   
        try 
        {
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();    
            
            DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
            Datetime lastRunDateTime = (Datetime)LastRunDateVar.DWH_import_date__c;
            String lastRunDate = lastRunDateTime.format('MM/dd/yyyy');  
            
            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
            String APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
            String APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
            
            req.setEndpoint(APIGateway_url+'/DWHAPI/GetRegVehicle_DWH_Count?syncDate='+lastRunDate);
            req.setMethod('GET');
            req.setHeader('apikey', APIGateway_key); 
            req.setHeader('Content-Type', 'application/json'); 
            req.setTimeout(120000);
           
            res = http.send(req);
            Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Integer noOfRecords    = (Integer)responseMap.get('totalNumberOfRecords');
            Decimal recordsPerPage = LastRunDateVar.RegVehicle_NumRecords__c <> null ? LastRunDateVar.RegVehicle_NumRecords__c : 1000;

            LastRunDateVar.RegVehicle_NumberOfPage__c = ( noOfRecords > 0 && noOfRecords > recordsPerPage ) ? (noOfRecords/recordsPerPage).round(System.RoundingMode.CEILING) : 1;
            update LastRunDateVar;
            
            serviceDataPool.buildServiceDataPoolHttp('getRegVehicleDWHCount', 'DWH_GetRegisteredVehicals_Data', '', req, res);
        }
        catch(Exception e) 
        {
            System.debug('@@@@DEBUG getRegVehicleDWHCount :: Error = ' + e );
            loggerDataPool.buildLogDataPool('DWH_GetRegisteredVehicals_Data.getRegVehicleDWHCount', e);
        }
    }


    //Create future call out method for http call    
    //@future (callout=true)
    public static void getRegistered_VehicleData(Integer pageNum)            
    {   
        try 
        { 
            HttpRequest req = new HttpRequest();
            HttpResponse resInput = new HttpResponse();
            Http http = new Http();    
            
            DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
            Datetime lastRunDateTime = (datetime)LastRunDateVar.DWH_import_date__c;
            String lastRunDate = lastRunDateTime.format('MM/dd/yyyy');  
            isSuccess = LastRunDateVar.isSuccess__c;
            String numRecs = LastRunDateVar.RegVehicle_NumRecords__c <> null ? String.valueOf(LastRunDateVar.RegVehicle_NumRecords__c.intValue()): '2000';

            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
            String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
            String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;

            System.debug('Get RV EndPoint = ' + APIGateway_url+'/DWHAPI/GetRegVehicle_DWH?syncDate='+lastRunDate+'&noOfRecords='+ numRecs +'&pageNo='+String.ValueOf(pageNum));
            req.setEndpoint(APIGateway_url+'/DWHAPI/GetRegVehicle_DWH?syncDate='+lastRunDate+'&noOfRecords='+ numRecs +'&pageNo='+String.ValueOf(pageNum));
            req.setMethod('GET');
            req.setHeader('apikey', APIGateway_key); 
            req.setHeader('Content-Type', 'application/json'); 
            req.setTimeout(120000);
        
            resInput = http.send(req);
            UpdateData(resInput);
            if(InputCSVMagic!='')
            {
                if(InputCSVMagic.endsWith(',')){
                    InputCSVMagic = InputCSVMagic.substringBeforeLast(',');
                }
            }

            DebugLogs.getDebugLogs('DWH_GetRegisteredVehicals_Data', DebugLogsListSuccess, DebugLogsListError );     
            serviceDataPool.buildServiceDataPoolHttp('DWH_GetRegisteredVehicals_Data', 'DWH_GetRegisteredVehicals_Data', '', req, resInput);
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('DWH_GetRegisteredVehicals_Data', e);
        }
    }
    

    public static void UpdateData(HttpResponse res)            
    {
        String Col_DWHID_var;
        String RV_DWHID_var;

        List<Registered_Vehicle__c> lstRegVehicles = new List<Registered_Vehicle__c>();
        Map<String, Registered_Vehicle__c> vehiclesToUpsert = new Map<String, Registered_Vehicle__c>();
        Set<String> emailList = new Set<String>();
        Set<String> nricList = new Set<String>();
        // Map<String, Registered_Vehicle__c> mapRegVehicles = new Map<String, Registered_Vehicle__c>();
        Map<String, List<Registered_Vehicle__c>> mapRegVehicles = new Map<String, List<Registered_Vehicle__c>>();
        
        List<String> strVariantList = new List<String>();
        for(Variant__c tempVar : [SELECT DWH_Variant_ID__c FROM Variant__c WHERE DWH_Variant_ID__c != null AND DWH_Variant_ID__c != '' AND source__c = 'DWH'] ) {         
            strVariantList.add( tempVar.DWH_Variant_ID__c );
        }
        
        List<String> strColorList = new List<String>();
        for(Color_Master__c tempColor : [SELECT DWH_Color_ID__c FROM Color_Master__c WHERE ColorCode__c != null AND ColorCode__c != '' AND source__c = 'DWH'] ) {         
            strColorList.add( tempColor.DWH_Color_ID__c );
        }
        
        Map<String,String> strBranchList = new Map<String,String>();
        for(Branch_Code_Name_Mapping__c tempBranch : [SELECT Branch_Code__c, CV_Code__c, PC_Code__c FROM Branch_Code_Name_Mapping__c] ) {         
            strBranchList.put(tempBranch.CV_Code__c,tempBranch.Branch_Code__c);
            strBranchList.put(tempBranch.PC_Code__c,tempBranch.Branch_Code__c);
        }
        
        try 
        {             
            JSONParser parser = JSON.createParser( res.getBody() );

            while (parser.nextToken() != null) 
            {             
                // Start at the array of Registered_Vehicles.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
                {
                    while (parser.nextToken() != null)
                    {
                        // Advance to the start object marker to find next RV_WRAPPER object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            // Read entire RV_WRAPPER object, including its array of line items.
                            RV_WRAPPER var = (RV_WRAPPER)parser.readValueAs(RV_WRAPPER.class);
                            system.debug('var ' + var);

                            Registered_Vehicle__c regVeh = New Registered_Vehicle__c();  
                            regVeh.Name                       = var.REGNO;
                            regVeh.Franchise__c               = var.FRANCHISE; 
                            regVeh.Branch__c                  = strBranchList.get(var.FRANCHISE); 
                            
                            regVeh.DWH_Vehicle_ID__c          = var.MAGIC_VEHICLE;    
                            regVeh.Registration_Number__c     = var.REGNO;
                            regVeh.Comm_No__c                 = var.COMM;
                            regVeh.Engine_Number__c           = var.ENGINE;
                            regVeh.Chasis_Number__c           = var.CHASSIS;
                            regVeh.Model_Year__c              = var.MODELYR;	     
                            regVeh.Autoline_Franchise_Code__c = var.FRANCHISECODE;
                            regVeh.Next_Service_Booking_KM__c = var.NEXTSMIL;
                            regVeh.IU__c                      = var.SECURENO;
                            regVeh.Service_Credits__c         = var.SVCCRDBAL;
                            regVeh.SCR__c                     = var.SCRBAL != null ? Integer.valueof(var.SCRBAL) : regVeh.SCR__c;
                            regVeh.Self_Import_Vehicle__c     = var.IMMOBIL;
                            regVeh.Last_Service_Booking_KM__c = var.LASTSMILE;
                            regVeh.Next_Recommended_Servi__c  = var.NXTRECOMNDSVC;
                            regVeh.source__c                  = 'DWH';                            
                            regVeh.Mileage__c                 = var.IMILEAGEU != null ? decimal.valueOf(var.IMILEAGEU) : regVeh.Mileage__c ;

                            regVeh.Registered_Date__c               = isValidDate(var.REGDATE) == false ? null : var.REGDATE.date();
                            regVeh.Car_Collection_Date__c           = isValidDate(var.COLLECTIONDATE) == false ? null : var.COLLECTIONDATE.date();
                            regVeh.Last_Service_Booking_Date__c     = isValidDate(var.LASTSERV) == false ? null : var.LASTSERV.date();
                            regVeh.Next_Service_Booking_Date__c     = isValidDate(var.NEXTSERV) == false ? null : var.NEXTSERV.date();
                            regVeh.Manufacture_Warranty_End_Date__c = isValidDate(var.WAREXPDT) == false ? null : var.WAREXPDT.date();
                            regVeh.Extended_Warranty_End_Date__c    = isValidDate(var.WAREXTDT) == false ? null : var.WAREXTDT.date();
                            regVeh.Service_Credits_Expiry_Date__c   = isValidDate(var.SVCCRDEXPDT) == false ? null : var.SVCCRDEXPDT.date();
                            regVeh.last_battery_change__c           = stringToDate(var.LASTBATTERYCHANGEdate);

                            //Start: Autoline Split: 2019-Aug
                            regVeh.EXTContactID__c      = var.EXTContactID;
                            regVeh.MagicCustomer__c     = var.MAGIC_CUSTOMER;
                            regVeh.VehicleDataSource__c = var.VEHICLE_DATASOURCE;
                            regVeh.MAGIC_MBPC__c        = var.MAGIC_MBPC;
                            regVeh.MAGIC_MBCV__c        = var.MAGIC_MBCV;
                            regVeh.MAGIC_MF__c          = var.MAGIC_MF;
                            regVeh.MAGIC_FUL__c         = var.MAGIC_FUL;
                            //End: Autoline Split: 2019- Aug
                            
                            RV_DWHID_var = strBranchList.get(var.FRANCHISE) + ',' + var.FRANCHISE + ',' + var.VARIANT;
                            system.debug('RV_DWHID_var ' + RV_DWHID_var);
                            if(strVariantList.contains(RV_DWHID_var))
                            {
                                Variant__c tempVariant = new Variant__c();
                                tempVariant.DWH_Variant_ID__c = RV_DWHID_var;                            
                                regVeh.Variant__r = tempVariant;                          
                            }
                            
                            Col_DWHID_var = strBranchList.get(var.FRANCHISE) + ',' + var.FRANCHISE + ',' + var.COLCODE;
                            system.debug('Col_DWHID_var ' + Col_DWHID_var);
                            if(strColorList.contains(Col_DWHID_var))
                            {
                                Color_Master__c tempColor = new Color_Master__c();
                                tempColor.DWH_Color_ID__c = Col_DWHID_var;
                                regVeh.Color__r = tempColor;   
                            }
                            
                            /**   
                             * Since Sep 24th, 2021: the EMAIL field in API payload is the combination of EMAIL and NRIC
                             *                       and are separeted by a special character "|"
                             * We compare only when both fields Email and NRIC are populated.
                             */
                            System.debug('var.EMAIL = ' + var.EMAIL);
                            if (String.isNotBlank(var.EMAIL) && var.EMAIL.contains('|')) {
                                regVeh.Registered_Vehicle_Email__c = var.EMAIL;

                                String conEmail = var.EMAIL.substringBefore('|').trim().toLowerCase();
                                String nric     = var.EMAIL.substringAfter('|').trim().toLowerCase();
                                System.debug('conEmail = ' + conEmail);
                                System.debug('nric = ' + nric);
 
                                if (String.isNotBlank(conEmail)) {
                                    emailList.add(conEmail);
                                }

                                if(String.isNotBlank(conEmail) && String.isNotBlank(nric)) {
                                    nricList.add(nric);
                                    // mapRegVehicles.put(conEmail + nric, regVeh);
                                    if (mapRegVehicles.containsKey(conEmail + nric)) {
                                        mapRegVehicles.get(conEmail + nric).add(regVeh);
                                    } else {
                                        mapRegVehicles.put(conEmail + nric, new List<Registered_Vehicle__c>{regVeh});
                                    }
                                }
                            }

                            System.debug('regVeh :: ' + regVeh);
                            System.debug('regVeh.Registered_Vehicle_Email__c :: ' + regVeh.Registered_Vehicle_Email__c);
                            vehiclesToUpsert.put(regVeh.Chasis_Number__c, regVeh);
                        }
                    }
                }
            }

            Map<String, Contact> mapContactByEmail = new Map<String, Contact>(); //Key = Email + NRIC_Passport_No__pc

            /*if(emailList != null && emailList.size() > 0 && nricList != null && nricList.size() > 0) {
                for(Contact con: [ SELECT Id, Email, AccountId, Account__c, Account.NRIC_Passport_No__pc
                                FROM Contact 
                                WHERE Email IN :emailList
                                AND Account.NRIC_Passport_No__pc IN :nricList
                             ]) 
                {
                    mapContactByEmail.put(con.Email.trim().toLowerCase() + con.Account.NRIC_Passport_No__pc.trim().toLowerCase(), con);
                }
            }*/

            if (emailList.size() > 0) {
                for (Contact con : [ SELECT Id, Email, AccountId, Account__c, Account.NRIC_Passport_No__pc
                                    FROM Contact 
                                    WHERE Email IN :emailList 
                                    AND IsPersonAccount = true])
                {
                    if (String.isNotBlank(con.Account.NRIC_Passport_No__pc))
                    {
                        String conNRIC = con.Account.NRIC_Passport_No__pc.trim().toLowerCase();
                        if (nricList.contains(conNRIC))
                        {
                            mapContactByEmail.put(con.Email.trim().toLowerCase() + conNRIC, con);
                        }
                    }
                }
            }

            System.debug('List Existing contacts :: ' + mapContactByEmail.size() + ' == ' + mapContactByEmail.values());
            System.debug('lstRegVehicles before link to Account :: ' + lstRegVehicles.size() + ' == ' + lstRegVehicles);
            //Link vehicle to Account/Contact
            if (mapRegVehicles != null && mapRegVehicles.size() > 0 && mapContactByEmail != null && mapContactByEmail.size() >0 ) {
                for (String key: mapRegVehicles.keySet()) {                                      
                    System.debug('[IN_THE_LOOP] key :: ' + key);
                    Contact con = mapContactByEmail.get(key); 

                    // Registered_Vehicle__c vehicle = mapRegVehicles.get(key);
                    // System.debug('[IN_THE_LOOP] vehicle - before :: ' + vehicle);

                    List<Registered_Vehicle__c> vehicles = mapRegVehicles.get(key);
 
                    System.debug('[IN_THE_LOOP] con :: ' + con);
 
                    for (Registered_Vehicle__c veh : vehicles) {
                        if (con != null) {
                            veh.Contact__c = con.Id;
                            if (String.isNotBlank(con.AccountId)) {
                                veh.Account__c = con.AccountId;
                            } else if (String.isNotBlank(con.Account__c)) {
                                veh.Account__c = con.Account__c;
                            }
                        }

                        vehiclesToUpsert.put(veh.Chasis_Number__c, veh);

                        System.debug('[IN_THE_LOOP] vehicle - after :: ' + veh);
                    }
                }
            }
            

            //Upsert the list of updated Registered_Vehicles into SFDC.
            lstRegVehicles = vehiclesToUpsert.values();
            System.debug('lstRegVehicles before upsert :: ' + lstRegVehicles);            
            Database.UpsertResult[] results = Database.upsert( lstRegVehicles, Registered_Vehicle__c.Fields.Chasis_Number__c, false );                   
            System.debug('@@@@DEBUG UpdateData :: results = ' + results.size() + ' --- ' + results );
            Set<Id> setVehicleIds = new Set<Id>();

            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    setVehicleIds.add(lstRegVehicles[index].Id);
                    if(results[index].isCreated()) {
                        DebugLogsListSuccess.add(lstRegVehicles[index].Chasis_Number__c +' was created');
                        System.debug('created vehicle :: ' + lstRegVehicles[index]);
                    } 
                    else {
                        DebugLogsListSuccess.add(lstRegVehicles[index].Chasis_Number__c +' was updated');
                        System.debug('updated vehicle :: ' + lstRegVehicles[index]);
                    }
                }
                else {
                    isSuccess = False;
                    String tempError = String.ValueOf(results[index].getErrors());
                    if(tempError.contains('getMessage=Foreign key external ID: ') && tempError.contains(' not found for field DWH_Contact_ID__c in entity Contact;')){                   
                        if(InputCSVMagic == '') {
                            InputCSVMagic = tempError.substringBetween('getMessage=Foreign key external ID: ',' not found for field DWH_Contact_ID__c in entity Contact;'); 
                        }
                        else {
                            InputCSVMagic = InputCSVMagic + ',' + tempError.substringBetween('getMessage=Foreign key external ID: ',' not found for field DWH_Contact_ID__c in entity Contact;');  
                        }          
                    }
                    else {
                        DebugLogsListError.add(lstRegVehicles[index].Chasis_Number__c +' had error '+results[index].getErrors());
                    }

                }
            }

            System.debug('Upserted vehicle Ids :: ' + setVehicleIds);
            if(setVehicleIds != null && setVehicleIds.size() > 0) {
                Map<String, Set<String>> mapAccIdsByBranch = new Map<String, Set<String>>();
                Set<Id> vehicleIds = new Set<Id>();
                List<Registered_Vehicle__c> vehicleList = [ SELECT Id, Branch__c, Account__c, Registered_Vehicle_Email__c
                                                            FROM Registered_Vehicle__c
                                                            WHERE Id IN :setVehicleIds
                                                            AND Account__c != ''
                                                            AND Account__r.IsPersonAccount = true
                                                        ];

                System.debug('upserted vehicles :: ' + vehicleList);
                for(Registered_Vehicle__c veh: vehicleList) {
                    String branch = veh.Branch__c;
                    String accId = veh.Account__c;
                    if(mapAccIdsByBranch.containsKey(branch)){
                        if(!mapAccIdsByBranch.get(branch).contains(accId)){
                            mapAccIdsByBranch.get(branch).add(accId);
                        }
                    } else {
                        mapAccIdsByBranch.put(branch, new Set<String>{accId});
                    }
                    
                }

                if(mapAccIdsByBranch.size() > 0) {
                    Set<String> mbAccIds = new Set<String>();
                    Set<String> mfAccIds = new Set<String>();
                    for(String branchCode: mapAccIdsByBranch.keySet()) {
                        if(branchCode == 'CCI') {
                            mbAccIds.addAll(mapAccIdsByBranch.get(branchCode));
                        } else if (branchCode == 'CCA' || branchCode == 'CCF' || branchCode == 'CCK') {                            
                            mfAccIds.addAll(mapAccIdsByBranch.get(branchCode));
                        }
                    }

                    if(mbAccIds != null && mbAccIds.size() > 0) {
                        List<Account> mbPAs = new List<Account>();
                        for(String accId: mbAccIds) {
                            mbPAs.add(new Account(Id = accId));
                        }
                        AccountUtil.createProfilings('MB_Person_Account_Profiling_RT', mbPAs);
                    }

                    if(mfAccIds != null && mfAccIds.size() > 0) {
                        List<Account> mfPAs = new List<Account>();
                        for(String accId: mfAccIds) {
                            mfPAs.add(new Account(Id = accId));
                        }
                        AccountUtil.createProfilings('CCS_Person_Account_Profiling_RT', mfPAs);
                    }
                }
            }
            

        
        } 
        catch(System.Exception e) 
        {
            System.debug('@@@@DEBUG updateData :: Error = ' + e );
            isSuccess = false;
            loggerDataPool.buildLogDataPool('DWH_GetRegisteredVehicals_Data', e);
            DebugLogsListError.add('System_error: '+e.getMessage());
        }

        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
        LastRunDateVar.isSuccess__c = isSuccess;
        upsert LastRunDateVar;
    }


    private static Date stringToDate(String textDate)
    {
        Date returnDate = null;
        if(String.isNotBlank(textDate)){
            List<String> strList = textDate.split('/');
            if(strList!=null && !strList.isEmpty()){
                returnDate = Date.newInstance(  Integer.valueOf(strList.get(2)), 
                                                    Integer.valueOf(strList.get(1)),
                                                        Integer.valueOf(strList.get(0)) );
            }
        }
        return returnDate;
    }


    private static Boolean isValidDate(Datetime checkDate)
    {
        Boolean returnStatus = false;
        String nullDate = '0001';
        Pattern myPattern = dateFormatMatcher();

        if(checkDate == null || String.valueOf(checkDate).startsWith(nullDate)){
            returnStatus = false;
        }
        else if(myPattern.matcher(String.valueOf(checkDate.date())).matches()){
            returnStatus = true;
        }

        return returnStatus;
    }


    private static Pattern dateFormatMatcher()
    {
        return Pattern.compile('((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])');
    }

    public class RV_WRAPPER 
    {
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
        public String EMAIL;
    }
    
 
    /** PA MIGRATION : To Remove; For Testing  */
    public static void exeTestRun( String strMockResponseResult )
    {
        String result = (String.isNotBlank( strMockResponseResult ) ) ? strMockResponseResult.replaceAll( '\\s+', '') : getMockResult();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatus('200');
        mockResponse.setBody( result );
        UpdateData( mockResponse );
    }
 




    /** PA MIGRATION : To Remove ; For Testing */
    public static String getMockResult()
    {   
        String strResult = '';
        //String strResult = '{"RV":[{"MAGIC_VEHICLE":14,"VEHICLE_DATASOURCE":"CCS","MAGIC_MBPC":321893,"MAGIC_MBCV":0,"MAGIC_MF":0,"MAGIC_FUL":0,"MAGIC_CUSTOMER":9999111,"FRANCHISECODE":"P","FRANCHISE":"MITPC","REGNO":"ABC1111Z","COMM":"0687510064","ENGINE":"27682130350663","CHASSIS":"WDC1660562A112233","REGDATE":"2016-05-04T00:00:00","COLLECTIONDATE":"2016-05-04T00:00:00","LASTSERV":"2019-11-13T00:00:00","IMILEAGEU":0,"NEXTSERV":"2020-11-15T00:00:00","NEXTSMIL":34477,"LASTSMILE":19477,"SECURENO":"1126513331","WAREXPDT":"2018-05-03T00:00:00","WAREXTDT":"2019-05-03T00:00:00","SVCCRDBAL":1195.84,"SVCCRDEXPDT":"2021-12-31T00:00:00","MAGIC":"14","IMMOBIL":"","MODELYR":2013,"COLCODE":"02890","VARIANT":"16605622-SG1","EXTContactID":250214,"DELDATE":"0001-01-01T00:00:00","CREATED":"2015-09-25T00:00:00","EDITED":"2019-11-29T00:00:00","LASTBATTERYCHANGEdate":"17/05/2018","NXTRECOMNDSVC":"","SCRBAL":11.0},{"MAGIC_VEHICLE":104,"VEHICLE_DATASOURCE":"CCS","MAGIC_MBPC":319749,"MAGIC_MBCV":0,"MAGIC_MF":0,"MAGIC_FUL":0,"MAGIC_CUSTOMER":20222,"FRANCHISECODE":"P","FRANCHISE":"MBP","REGNO":"DEF2222Y","COMM":"0587514565","ENGINE":"27091030854686","CHASSIS":"WDD1179432N223344","REGDATE":"2016-06-06T00:00:00","COLLECTIONDATE":"2016-06-06T00:00:00","LASTSERV":"2019-11-28T00:00:00","IMILEAGEU":0,"NEXTSERV":"2020-11-28T00:00:00","NEXTSMIL":47540,"LASTSMILE":32540,"SECURENO":"1126519298","WAREXPDT":"2018-06-05T00:00:00","WAREXTDT":"2019-06-05T00:00:00","SVCCRDBAL":1051.53,"SVCCRDEXPDT":"2021-07-16T00:00:00","MAGIC":"104","IMMOBIL":"","MODELYR":2015,"COLCODE":"02650","VARIANT":"11794322-SG1","EXTContactID":276516,"DELDATE":"0001-01-01T00:00:00","CREATED":"2015-07-28T00:00:00","EDITED":"2019-11-29T00:00:00","LASTBATTERYCHANGEdate":"27/06/2018","NXTRECOMNDSVC":"MBNXSVCB","SCRBAL":0.0}],"Message":"The operation is completed successfully.  1 Registered vehicles are retrieved"}';
        
        /*
        String strResult = '{"RV": [{"MAGIC_VEHICLE": 170,"VEHICLE_DATASOURCE": "CCS","MAGIC_MBPC": 3522910,"MAGIC_MBCV": 0,"MAGIC_MF": 0,"MAGIC_FUL": 0,"MAGIC_CUSTOMER": 9999111,"FRANCHISECODE": "P","FRANCHISE": "MITPC","REGNO": "SDK7237CD","COMM": "01887511467","ENGINE": "271091031579417","CHASSIS": "WDD11734322N639852","REGDATE": "2018-04-10T00:00:00","COLLECTIONDATE": "2018-04-30T00:00:00","LASTSERV": "2020-04-02T00:00:00","IMILEAGEU": 0,"NEXTSERV": "2021-04-02T00:00:00","NEXTSMIL": 40054,"LASTSMILE": 25054,"SECURENO": "1128293361","WAREXPDT": "2020-04-09T00:00:00","WAREXTDT": "2021-04-09T00:00:00","SVCCRDBAL": 6399.08,"SVCCRDEXPDT": "2023-04-09T00:00:00","MAGIC": "170","IMMOBIL": "","MODELYR": 2014,"COLCODE": "02787","VARIANT": "11734222-SG1","EXTContactID": 2720270,"DELDATE": "0001-01-01T00:00:00","CREATED": "2017-10-24T00:00:00","EDITED": "2020-04-03T00:00:00","LASTBATTERYCHANGEdate": null,"NXTRECOMNDSVC": "MBNXSVCA","SCRBAL": 12}],"Message": "The operation is completed successfully.  1696 Registered vehicles are retrieved"}';
        */

        return strResult;
     
    }
}
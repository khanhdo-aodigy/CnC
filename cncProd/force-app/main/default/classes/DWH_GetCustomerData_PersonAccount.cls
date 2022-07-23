/** *****
 * Description : Scheduled Batch Job to sync Individual Customer Information from DWH (i.e. Person Account)
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20201001            HS@aodigy            Created Initial Version 
 * 
** *****/
global class DWH_GetCustomerData_PersonAccount implements Schedulable, Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    public static List<String> DebugLogsListSuccess = New List<String>();
    public static List<String> DebugLogsListError = New List<String>();

    public static Boolean isSuccess   = true;  
    public static Boolean isSandbox   = false;
    public static boolean CallFromDWH = false;
    public Integer currentPage        = 1;

    public DWH_GetCustomerData_PersonAccount() { }

    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new DWH_GetCustomerData_PersonAccount(),1);
    }


    public Iterable<sObject> start(Database.Batchablecontext BC){
        getCustomerDWHCount();
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Customer_NumberOfPages__c);
        System.debug('@@@@DEBUG DWH_GetCustomerData_PersonAccount:: START :: totalPages = '+totalPages);
        return [SELECT Id FROM Contact LIMIT :totalPages];    
    }


    public void execute(Database.BatchableContext BC, List<sObject> scope){  

        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Customer_NumberOfPages__c);
        System.debug('@@@@DEBUG DWH_GetCustomerData_PersonAccount:: EXECUTE :: currentPage = ' + this.currentPage + ' / ' + totalPages + ' --- scope.size() ' + scope.size());
        if( currentPage <= totalPages)
        {
            getContactData(currentPage);   
            this.currentPage = this.currentPage + 1;
        }
    }

    public void finish(Database.BatchableContext info){ }


    public static void getCustomerDWHCount()
    {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();    
        
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
        Datetime lastRunDateTime = (Datetime)lastRunDateVar.DWH_import_date__c;
        String lastRunDate = lastRunDateTime.format('MM/dd/yyyy');  
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
        
        request.setEndpoint(APIGateway_url+'/DWHAPI/GetCustomer_DWH_Count?syncDate=' + lastRunDate);
        request.setMethod('GET');
        request.setHeader('apikey', APIGateway_key); 
        request.setHeader('Content-Type', 'application/json'); 
        request.setTimeout(120000);

        try 
        {   
            response = http.send(request);
            Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Integer noOfRecords = (Integer)responseMap.get('totalNumberOfRecords');
            lastRunDateVar.Customer_NumberOfPages__c = ( noOfRecords > 0 && noOfRecords > lastRunDateVar.Customer_NumRecords__c ) ? 
                                                            (noOfRecords/LastRunDateVar.Customer_NumRecords__c).round(System.RoundingMode.CEILING) : 1;
            update lastRunDateVar;
            
            serviceDataPool.buildServiceDataPoolHttp('getCustomerDWHCount', 'DWH_GetCustomerData_PersonAccount', '', request, response);
        }
        catch(Exception ex) 
        {
            System.debug('@@@@DEBUG getCustomerDWHCount :: Error = ' + ex );
            loggerDataPool.buildLogDataPool('DWH_GetCustomerData_PersonAccount.getCustomerDWHCount', ex);
        }
    }


    public static void getContactData(Integer pageNum)            
    {        
        try 
        { 
            HttpRequest req = new HttpRequest();
            HttpResponse resInput = new HttpResponse();
            Http http = new Http();
            
            DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
            Datetime lastRunDateTime = (datetime)lastRunDateVar.DWH_import_date__c;
            String LastRunDate = lastRunDateTime.format('MM/dd/yyyy');  
            isSuccess = lastRunDateVar.isSuccess__c;
            
            String numRecs = lastRunDateVar.Customer_NumRecords__c <> null ? String.valueOf(lastRunDateVar.Customer_NumRecords__c.intValue()) : '2000';
            
            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
            String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
            String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;

            req.setEndpoint(APIGateway_url+'/DWHAPI/GetCustomer_DWH?syncDate='+LastRunDate+'&noOfRecords='+ numRecs +'&pageNo='+String.ValueOf(pageNum));
            req.setMethod('GET');
            req.setHeader('apikey', APIGateway_key); 
            req.setHeader('Content-Type', 'application/json'); 
            req.setTimeout(120000);
        
            resInput = http.send(req);
            updateData(resInput);

            DebugLogs.getDebugLogs('DWH_GetCustomerData_PersonAccount',DebugLogsListSuccess,DebugLogsListError);
            
            serviceDataPool.buildServiceDataPoolHttp('ContactSync', 'DWH_GetCustomerData_PersonAccount', '', req, resInput);
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('DWH_GetCustomerData_PersonAccount', e);
        }
    }


    public static void updateData(HttpResponse res)            
    {
        Map<String,Account> mapOfCustomers = new Map<String,Account>();     //Key => DWH Contact ID (i.e. UNIQUE EXTERNAL ID)
        Map<String,Set<String>> mapCustomerIDToChassis = new Map<String,Set<String>>();
        Map<String,String> mapChassisToDWHContactId = new Map<String,String>();

        List<Contact> lstContacts = new List<Contact>();
        List<Account> lstCustomerPersonAccount = new List<Account>();
        Map<String,Registered_Vehicle__c> mapChassisToRegVeh = new Map<String,Registered_Vehicle__c>();

        try 
        { 
            isSandbox = [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
               
            JSONParser parser = JSON.createParser(res.getBody());
            
            while (parser.nextToken() != null) 
            {
                // Start at the array of Contacts.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
                {
                    while (parser.nextToken() != null) 
                    {
                        // Advance to the start object marker to find next contact statement object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            // Read entire Contact object, including its array of line items.
                            CONTACT_WRAPPER var = (CONTACT_WRAPPER)parser.readValueAs(CONTACT_WRAPPER.class);                       
                            if( String.isNotBlank( var.MAGIC ) )
                            {   
                                Account personAcct = new Account(  RecordTypeId = AccountUtil.getCustomerRecordTypeId() ); 

                                personAcct.Salutation             = var.TITLE;
                                personAcct.LastName               = String.isNotBlank(var.SURNAME) ? var.SURNAME : 'Customer';
                                personAcct.FirstName              = String.isNotBlank(var.FIRSTNAME) ? var.FIRSTNAME : null;
                                personAcct.Full_Name__pc          = String.isNotBlank(var.SALUTE) ? var.SALUTE : null;       //Autoline Salutation
                                personAcct.PersonBirthdate        = isValidDate(var.DOB) == false ? null : var.DOB.date();
                                personAcct.Gender__pc             = var.SEX;
                                personAcct.Address_Line_1__pc     = var.ADDRESS001;
                                personAcct.Address_Line_2__pc     = var.ADDRESS002;
                                personAcct.Address_Line_3__pc     = var.ADDRESS003;
                                personAcct.Address_Line_4__pc     = var.ADDRESS004;
                                personAcct.Address_Line_5__pc     = var.ADDRESS005;
                                personAcct.Country__pc            = String.isNotBlank(var.COUNTRY) ? var.COUNTRY : 'Singapore';
                                personAcct.PDPA__pc               = (String.isBlank(var.PDPA) || var.PDPA == 'False') ? '' : 'SMS; Call; Email';
                                personAcct.Preferred_Mode_of_contact__pc = var.Preferred_Mode_Of_Contact;
                                personAcct.DWH_Contact_ID__c      = var.MAGIC_CUSTOMER;
                                personAcct.DWH_Contact_ID__pc     = var.MAGIC_CUSTOMER;
                                personAcct.MAGIC_MBPC__pc         = var.MAGIC_MBPC;
                                personAcct.MAGIC_MBCV__pc         = var.MAGIC_MBCV;
                                personAcct.MAGIC_MF__pc           = var.MAGIC_MF;
                                personAcct.MAGIC_FUL__pc          = var.MAGIC_FUL;
                                personAcct.CustomerType__pc       = var.CUSTOMER_TYPE;
                                personAcct.CustomerDataSource__pc = var.CUSTOMER_DATASOURCE;
                                personAcct.Source__pc             = 'DWH';
                                personAcct.Type__pc               = 'Customer';
                                
                                //To Incorporate NRIC changes, If DWH contact has no DOB,then update Contact NRIC as DWH Contact Id
                                if( String.isNotBlank(var.SOCIALID) && var.SOCIALID.length() == 4) {
                                    personAcct.NRIC__pc             = var.MAGIC; 
                                    personAcct.NRIC_Passport_No__pc = var.MAGIC; 
                                }
                                else                               
                                {
                                    personAcct.NRIC__pc             = var.SOCIALID; 
                                    personAcct.NRIC_Passport_No__pc = var.SOCIALID; 
                                }

                                //40 is character length for standard Contact.FirstName field
                                if(String.isNotBlank(personAcct.FirstName) && personAcct.FirstName.contains('(') && personAcct.FirstName.length() > 40){
                                    //get the index of '('
                                    Integer openParenIndex = personAcct.FirstName.indexOf('(') - 1;
                                    personAcct.FirstName  = personAcct.FirstName.subString(0,openParenIndex);
                                }
                                
                                //Run only for Prod (not Sandbox)
                                if(!isSandbox){
                                    personAcct.Phone = var.PHONE002;
                                    if(var.PHONE005 != null){
                                        personAcct.PersonMobilePhone = '65'+var.PHONE005;
                                    }  
                                    personAcct.PersonEmail = var.EMAIL;
                                }                   

                                if( String.isNotBlank( var.LATEST_CHASSIS ) ){
                                    mapChassisToRegVeh.put( var.LATEST_CHASSIS, null );
                                }
                
                                if( String.isNotBlank(var.MAGIC_CUSTOMER) )
                                {
                                    mapOfCustomers.put( var.MAGIC_CUSTOMER, personAcct ); // ALL CUSTOMER, Key => DWH Contact ID

                                    if( String.isNotBlank(var.LATEST_CHASSIS) )
                                    {
                                        if( !mapCustomerIDToChassis.containsKey(var.MAGIC_CUSTOMER) ) {
                                            mapCustomerIDToChassis.put(var.MAGIC_CUSTOMER, new Set<String>{var.LATEST_CHASSIS});
                                        }
                                        else{
                                            mapCustomerIDToChassis.get(var.MAGIC_CUSTOMER).add(var.LATEST_CHASSIS);
                                        }

                                        mapChassisToDWHContactId.put(var.LATEST_CHASSIS, var.MAGIC_CUSTOMER); // Key => Chassis NUmber, Value => DWH Contact ID
                                    }
                                }

                                //To By Pass Trigger Execution
                                CallFromDWH = true;
                            }
                        }     
                    }
                }
            }
            System.debug('@@@@DEBUG UpdateData :: mapCustomerIDToChassis = ' + mapCustomerIDToChassis.size() + ' --- ' + mapCustomerIDToChassis ) ;
            System.debug('@@@@DEBUG UpdateData :: mapOfCustomers = ' + mapOfCustomers.size() + ' --- ' + mapOfCustomers);
            System.debug('@@@@DEBUG UpdateData :: mapChassisToDWHContactId = ' + mapChassisToDWHContactId.size() + ' --- ' + mapChassisToDWHContactId );


            //FIND EXISTING PA-CUSTOMER BY DWH CONTACT ID
            for( Account paCustomer : [ SELECT ID, DWH_Contact_Id__c, DWH_Contact_ID__pc 
                                        FROM Account 
                                        WHERE IsPersonAccount = true 
                                        AND DWH_Contact_ID__pc IN :mapOfCustomers.keySet() ]) {

                Account pAcct = mapOfCustomers.get( paCustomer.DWH_Contact_ID__pc );
                pAcct.Id      = paCustomer.Id;
            }

            //FIND EXISTING PA-PROSPECT BY CHASIS NUMBER 
            Map<String,Contact> mapChassisToProspectId = new Map<String,Contact>();
            Map<Id,Stock_Reservation__c> mapOppIdToStkRerv = new Map<Id,Stock_Reservation__c>();

            //MF Prospect Tagging -- [START]
            if( !mapChassisToDWHContactId.isEmpty() ) 
            {                     
                for( Stock_Reservation__c stkResv : Queries.getSR( mapChassisToDWHContactId.keySet() ) )
                {
                    if( mapChassisToDWHContactId.containsKey( stkResv.Vehicle_Chassis_Number__c ) && 
                            stkResv.Opportunity__r.Account__c <> null && 
                                String.isBlank( stkResv.Opportunity__r.Account__r.DWH_Contact_ID__pc ) )
                    {
                        Id prospectAcctId = stkResv.Opportunity__r.Account__c;
                        Id prospectContId = stkResv.Opportunity__r.Account__r.PersonContactId;
                        
                        String prospectDWHCntId = mapChassisToDWHContactId.get( stkResv.Vehicle_Chassis_Number__c );
                        
                        Account pAcct      = mapOfCustomers.get( prospectDWHCntId );
                        pAcct.Id           = prospectAcctId;

                        mapChassisToProspectId.put( stkResv.Vehicle_Chassis_Number__c, new Contact( Id = prospectContId, AccountId = prospectAcctId ) );
                        mapOppIdToStkRerv.put( stkResv.Opportunity__c, stkResv );
                    }
                }
            }
            System.debug('@@@@DEBUG UpdateData :: mapChassisToProspectId 111 = ' + mapChassisToProspectId.size() + ' --- ' + mapChassisToProspectId );
            //MF Prospect Tagging -- [END]
            

            //MB Prospect Tagging -- [START]
            Map<String,MB_Sales_Agreement__c> mapChassisToMbSA = new Map<String,MB_Sales_Agreement__c>();
            if( !mapChassisToDWHContactId.isEmpty() ) 
            {
                for( MB_Sales_Agreement__c mbSA : [ SELECT Id, Account__c, Account__r.PersonContactId, Account__r.RecordTypeId, Account__r.DWH_Contact_ID__pc,
                                                        Used_Car_Chassis_Number__c, Chassis_Number__c
                                                    FROM MB_Sales_Agreement__c 
                                                    WHERE MB_Stock_Vehicle_Master__r.Chassis__c IN: mapChassisToDWHContactId.keySet()
                                                    AND Status__c IN ('Pending Registration','Ready for Delivery','Car Collected')
                                                    AND Account__c != null ] )
                {
                    if( mapChassisToDWHContactId.containsKey( mbSA.Chassis_Number__c ) && String.isBlank( mbSA.Account__r.DWH_Contact_ID__pc ) )
                    {
                        Id prospectAcctId       = mbSA.Account__c;
                        Id prospectContId       = mbSA.Account__r.PersonContactId;
                        String prospectDWHCntId = mapChassisToDWHContactId.get( mbSA.Chassis_Number__c );
                        
                        Account pAcct      = mapOfCustomers.get( prospectDWHCntId );
                        pAcct.Id           = prospectAcctId;

                        mapChassisToProspectId.put( mbSA.Chassis_Number__c, new Contact( Id = prospectContId, AccountId = prospectAcctId ) );

                        mapChassisToMbSA.put( mbSA.Chassis_Number__c, mbSA );
                    }
                }
            }
            System.debug('@@@@DEBUG UpdateData :: mapChassisToProspectId 222 = ' + mapChassisToProspectId.size() + ' --- ' + mapChassisToProspectId );
            //MB Prospect Tagging -- [END]


            //UPSERT PERSON ACCOUNT
            if( mapOfCustomers <> null && !mapOfCustomers.isEmpty() ) 
            {
                System.debug('@@@@DEBUG UpdateData :: mapOfCustomers = ' + mapOfCustomers.size() + ' --- ' + mapOfCustomers );
                
                TriggerExclusion.excludeTrigger('Account', true);
                TriggerExclusion.excludeTrigger('Contact', true);
                Database.UpsertResult[] paUpsertResults = Database.upsert( mapOfCustomers.values(), false ); 
                System.debug('@@@@DEBUG UpdateData :: paUpsertResults = ' + paUpsertResults.size() + ' --- ' + paUpsertResults );


                // Map<Id,Account> mapModifiedAccts = new Map<Id,Account>( mapOfCustomers.values() );
                Map<Id,Account> mapModifiedAccts = new Map<Id,Account>();
                for( Account tempAcct : mapOfCustomers.values() ){
                    if( tempAcct.Id <> null ){
                        mapModifiedAccts.put( tempAcct.Id, tempAcct );
                    }
                }
                for( Account upsertedAcct : AccountUtil.getPersonAccountsRecordByIds( (Set<String>)JSON.deserialize( JSON.serialize(mapModifiedAccts.keySet() ), Set<String>.class) ) ){
                    if(mapOfCustomers.containsKey( upsertedAcct.DWH_Contact_ID__pc ) ){
                        mapOfCustomers.put( upsertedAcct.DWH_Contact_ID__pc, upsertedAcct );
                    }
                }

                for(Integer index = 0, size = paUpsertResults.size(); index < size; index++) 
                {
                    if(paUpsertResults[index].isSuccess()) {
                        if(paUpsertResults[index].isCreated()) {                   
                            DebugLogsListSuccess.add( mapOfCustomers.values()[index].DWH_Contact_ID__c +' was created' );
                        } 
                        else {
                            DebugLogsListSuccess.add( mapOfCustomers.values()[index].DWH_Contact_ID__c +' was updated' );
                        }                    
                    }
                    else {
                        isSuccess = false;
                        DebugLogsListError.add( mapOfCustomers.values()[index].DWH_Contact_ID__c +' had error'+paUpsertResults[index].getErrors() );
                    }
                }
            }


            //Filter Those Chassis Number Which Not Being Processed in MF / MB 
            Set<String> setUnprocessedChassis = new Set<String>();
            setUnprocessedChassis.addAll( mapChassisToDWHContactId.keySet() );
            setUnprocessedChassis.removeAll( mapChassisToProspectId.keySet() );
            System.debug('@@@@DEBUG UpdateData :: setUnprocessedChassis = ' + setUnprocessedChassis.size() + ' --- ' + setUnprocessedChassis );

            
            //Get All Registered Vehicles based on the Chassis Number (i.e. both MF & MB)
            Map<String,Registered_Vehicle__c> mapChassisRV  = new Map<String,Registered_Vehicle__c>();
            for(Registered_Vehicle__c rv : [ SELECT Id, Chasis_Number__c, Variant__c, Variant__r.Model_ID__c, Contact__c, Account__c, Account__r.RecordTypeId 
                                             FROM Registered_Vehicle__c
                                             WHERE (LeadBatchProcessed__c = false AND Chasis_Number__c IN : mapChassisToProspectId.keySet() )
                                             OR Chasis_Number__c IN : setUnprocessedChassis ] ){
                                             //AND Variant__c != null 
                                             //AND Variant__r.Model_ID__c != null ] ) {
                
                mapChassisRV.put( rv.Chasis_Number__c , rv );
            }
            System.debug('@@@@DEBUG UpdateData :: mapChassisRV = ' + mapChassisRV.size() + ' --- ' + mapChassisRV );
            

            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] { Registered_Vehicle__c.SObjectType,
                                                                                                   Stock_Reservation__c.SObjectType,
                                                                                                   Models_Interested__c.SObjectType,
                                                                                                   Opportunity.SObjectType });

            //MF Related Objects Processing -- [START]
            System.debug('@@@@DEBUG UpdateData :: mapOppIdToStkRerv = ' + mapOppIdToStkRerv.size() + ' --- ' + mapOppIdToStkRerv );

            processMFrelatedObjects( uow, mapOppIdToStkRerv, mapChassisRV, mapChassisToProspectId );


            processMBrelatedObjects( uow, mapChassisToMbSA, mapChassisRV, mapChassisToProspectId );


            //USED CAR Tagging -- (i.e. No Stock Reservation, No DSA ) -- [START]
            for( String strChassis : setUnprocessedChassis ){
                if( mapChassisRV.containsKey( strChassis ) && 
                        mapChassisToDWHContactId.containsKey( strChassis ) &&
                            mapOfCustomers.containsKey( mapChassisToDWHContactId.get( strChassis ) ) )
                {
                    Account tempAcct = mapOfCustomers.get( mapChassisToDWHContactId.get( strChassis ) );

                    Registered_Vehicle__c tempRv = mapChassisRV.get( strChassis );
                    tempRv.LeadBatchProcessed__c = true;
                    tempRv.Account__c = tempAcct.Id;
                    tempRv.Contact__c = tempAcct.PersonContactId;
                    uow.registerDirty( tempRv );
                }
            }
            //USED CAR Tagging -- [END]

            uow.commitWork();

        } 
        catch(Exception e) 
        {
            isSuccess = False;
            DebugLogsListError.add('System_error: '+e.getMessage());
            loggerDataPool.buildLogDataPool('DWH_GetCustomerData_PersonAccount', e);
        }
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
        lastRunDateVar.isSuccess__c = isSuccess;
        // Database.upsert ( lastRunDateVar , false );
        
    }


    private static void processMFrelatedObjects( ADGLIB_SObjectUnitOfWork uow, 
                                                    Map<Id,Stock_Reservation__c> mapOppIdToStkRerv, 
                                                        Map<String,Registered_Vehicle__c> mapChassisRV,
                                                            Map<String,Contact> mapChassisToProspectId )
    {
        //MF Related Objects Processing -- [START]
        System.debug('@@@@DEBUG UpdateData :: mapOppIdToStkRerv = ' + mapOppIdToStkRerv.size() + ' --- ' + mapOppIdToStkRerv );
        if( mapOppIdToStkRerv <> null && !mapOppIdToStkRerv.isEmpty() && mapChassisRV <> null && !mapChassisRV.isEmpty() )
        {
            List<Opportunity> lstMFOppoToupdate             = new List<Opportunity>();
            List<Models_Interested__c> lstMFModelToUpdate   = new List<Models_Interested__c>();
            List<Stock_Reservation__c> lstStockResvToUpdate = new List<Stock_Reservation__c>();
            List<Registered_Vehicle__c> lstRVsToUpdate      = new List<Registered_Vehicle__c>();

            for(Opportunity opps : Queries.getOpps( mapOppIdToStkRerv.keySet() ) )
            {
                String stkRervChassisNum = mapOppIdToStkRerv.get(opps.Id).Vehicle_Chassis_Number__c;

                if( mapOppIdToStkRerv.containsKey(opps.Id) && mapChassisRV.containsKey( stkRervChassisNum ) )
                {
                    if( mapChassisRV.get( stkRervChassisNum ).Variant__c != null && mapChassisRV.get( stkRervChassisNum ).Variant__r.Model_ID__c != null )
                    {
                        //Update the Opportunity
                        Id rvModelId = mapChassisRV.get( stkRervChassisNum ).Variant__r.Model_ID__c;
                        opps.Model_c__c = rvModelId;
                        opps.StageName  = 'Booked';
                        lstMFOppoToupdate.add( opps );
                        uow.registerDirty(opps);
                        
                        //Update the Registered Vehicle's Account & Contact (i.e. Points to Person Account's AccountID & ContactID)
                        Registered_Vehicle__c tempRv = mapChassisRV.get( stkRervChassisNum );
                        tempRv.LeadBatchProcessed__c = true;
                        tempRv.Account__c = mapChassisToProspectId.get( stkRervChassisNum ).AccountId;
                        tempRv.Contact__c = mapChassisToProspectId.get( stkRervChassisNum ).Id;
                        lstRVsToUpdate.add( tempRv );
                        uow.registerDirty( tempRv );

                        //Update the Stock-Reservation of the Opportunity
                        Stock_Reservation__c tempStkResv = mapOppIdToStkRerv.get( opps.Id );
                        tempStkResv.LeadBatchProcessed__c = true;
                        tempStkResv.Registered_Vehicle__c = mapChassisRV.get( stkRervChassisNum ).Id;
                        lstStockResvToUpdate.add( tempStkResv );
                        uow.registerDirty( tempStkResv );
                        
                        //Update Model Interested of the Opportunity
                        for( Models_Interested__c mi : opps.Models_Interested__r ){
                            if( mi.Model__c != null && String.valueOf(rvModelId).contains( mi.Model__c ) ){
                                mi.status__c ='Booked';
                                lstMFModelToUpdate.add( mi );
                                uow.registerDirty( mi );
                            }
                        }
                    }
                }
            }
        }
        //MF Related Objects Processing -- [END]
    }


    private static void processMBrelatedObjects( ADGLIB_SObjectUnitOfWork uow, 
                                                    Map<String,MB_Sales_Agreement__c> mapChassisToMbSA, 
                                                        Map<String,Registered_Vehicle__c> mapChassisRV,
                                                            Map<String,Contact> mapChassisToProspectId )
    {
        //MB Related Objects Processing -- [START]
        System.debug('@@@@DEBUG UpdateData :: mapChassisToMbSA = ' + mapChassisToMbSA.size() + ' --- ' + mapChassisToMbSA );
        if( mapChassisToMbSA <> null && !mapChassisToMbSA.isEmpty() && mapChassisRV <> null && !mapChassisRV.isEmpty() )
        {
            for( MB_Sales_Agreement__c mbSA : mapChassisToMbSA.values() )
            {
                String mbSAChassisNum = mbSA.Chassis_Number__c;
                if( String.isNotBlank( mbSAChassisNum ) && 
                        mapChassisRV.containsKey( mbSAChassisNum ) && 
                            mapChassisRV.get( mbSAChassisNum ).Variant__c != null && 
                                mapChassisRV.get( mbSAChassisNum ).Variant__r.Model_ID__c != null )
                {
                    //Update the Registered Vehicle's Account & Contact (i.e. Points to Person Account's AccountID & ContactID)
                    Registered_Vehicle__c tempRv = mapChassisRV.get( mbSAChassisNum );
                    tempRv.LeadBatchProcessed__c = true;
                    tempRv.Account__c = mapChassisToProspectId.get( mbSAChassisNum ).AccountId;
                    tempRv.Contact__c = mapChassisToProspectId.get( mbSAChassisNum ).Id;
                    uow.registerDirty( tempRv );
                }
            }   
        }
        //MB Related Objects Processing -- [END]
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


    public class CONTACT_WRAPPER 
    {   
        public String SOCIALID;
        public String TITLE;
        public String SURNAME;
        public String FIRSTNAME;
        public String LASTNAME;
        public String SEX;
        public String PHONE005;
        public String PHONE002;
        public Datetime DOB;
        public String EMAIL;
        public String ADDRESS001; 
        public String ADDRESS002;
        public String ADDRESS003; 
        public String ADDRESS004; 
        public String ADDRESS005; 
        public String CITY; 
        public String STATE; 
        public String COUNTRY; 
        public String POSTCODE; 
        public String Preferred_Mode_Of_Contact; 
        public String PDPA;
        public String MAGIC;
        public String SALUTE;
        public String LATEST_CHASSIS;
        public String BRAND;
        public String MAGIC_CUSTOMER;
        public String CUSTOMER_DATASOURCE;
        public String MAGIC_MBPC;
        public String MAGIC_MBCV;
        public String MAGIC_MF;
        public String MAGIC_FUL;
        public String CUSTOMER_TYPE;
    }


    public static void exeTestRun(  String strMockResponseResult )
    {
        String result = (String.isNotBlank( strMockResponseResult ) ) ? strMockResponseResult.replaceAll( '\\s+', '') : '';
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatus('200');
        mockResponse.setBody( result );
        UpdateData( mockResponse );
    }
}


/*
{
  "Customers": [
    {
      "MAGIC_CUSTOMER": 9999111,
      "CUSTOMER_DATASOURCE": "CCS",
      "MAGIC_MBPC": 0,
      "MAGIC_MBCV": 0,
      "MAGIC_MF": 33330001,
      "MAGIC_FUL": 44440001,
      "CUSTOMER_TYPE": null,
      "SALUTE": "TEST-PA CUSTOMER-1",
      "SOCIALID": "A12345990001",
      "MAGIC": 9999111,
      "TITLE": "Mr",
      "SURNAME": "Test",
      "FIRSTNAME": "Customer-1",
      "LASTNAME": "Test",
      "DOB": "1989-07-01T00:00:00",
      "SEX": "M",
      "PHONE005": "99900099",
      "PHONE002": null,
      "EMAIL": "testcustomer1@mailinator.com",
      "ADDRESS001": "99 Jalan Heaven",
      "ADDRESS002": "Singapore 345000",
      "ADDRESS003": null,
      "ADDRESS004": null,
      "ADDRESS005": "Singapore",
      "CITY": "Singapore",
      "STATE": null,
      "COUNTRY": "Singapore",
      "POSTCODE": 0,
      "PDPA": null,
      "Preferred_Mode_Of_Contact": null,
      "CREATED": "4/4/2020 12:00:00 AM",
      "EDITED": "1/5/2020 12:00:00 AM",
      "LATEST_CHASSIS": "KNAFZ411MF5404311999",
      "BRAND": "KIA"
    },
    {
      "MAGIC_CUSTOMER": 9999222,
      "CUSTOMER_DATASOURCE": "CCS",
      "MAGIC_MBPC": 0,
      "MAGIC_MBCV": 0,
      "MAGIC_MF": 33330002,
      "MAGIC_FUL": 44440002,
      "CUSTOMER_TYPE": null,
      "SALUTE": "TEST-PA CUSTOMER-2",
      "SOCIALID": "A12345990002",
      "MAGIC": 9999222,
      "TITLE": "Mr",
      "SURNAME": "Test",
      "FIRSTNAME": "Customer-2",
      "LASTNAME": "Test",
      "DOB": "1989-09-01T00:00:00",
      "SEX": "M",
      "PHONE005": "88800888",
      "PHONE002": null,
      "EMAIL": "testcustomer2@mailinator.com",
      "ADDRESS001": "888 CovidLane",
      "ADDRESS002": "Singapore 489699",
      "ADDRESS003": null,
      "ADDRESS004": null,
      "ADDRESS005": "Singapore",
      "CITY": "Singapore",
      "STATE": null,
      "COUNTRY": "Singapore",
      "POSTCODE": 0,
      "PDPA": true,
      "Preferred_Mode_Of_Contact": null,
      "CREATED": "1/5/2020 12:00:00 AM",
      "EDITED": "1/7/2020 12:00:00 AM",
      "LATEST_CHASSIS": "KNAFE2273952222222",
      "BRAND": "KIA"
    }
  ],
  "Message": "The operation is completed successfully. 2 customers have been retrieved . "
}
*/
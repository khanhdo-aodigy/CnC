global class DWH_GetCustomer_Data implements Schedulable, Database.AllowsCallouts, Database.Batchable<sObject>, Database.Stateful
{
    public static Integer count=0;
    public static Contact tempContact;  /** PA MIGRATION : To Remove */
    public static Account tempAccount;  /** PA MIGRATION : Newly Added */
    public static Boolean isSuccess  = True;  
    public static List<String> DebugLogsListSuccess = New List<String>();
    public static List<String> DebugLogsListError = New List<String>();

    //CGaylan: Flag to tell if org is sandbox, if Sandbox, do not sync Email and Phone Numbers
    public static Boolean isSandbox = false;
    
    //Public PDPAUpdate_Contact_SMS PDPAUpdate_Contact_SMSvar;  
    public static boolean CallFromDWH = false;

    /*
    global void execute(SchedulableContext ctx)
    {
        getCustomerDWHCount();
        DWH_GetCustomer_Data();
    }
    */

    public Integer currentPage = 1;
    
    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new DWH_GetCustomer_Data(),1);
    }

    public Iterable<sObject> start(Database.Batchablecontext BC){
        getCustomerDWHCount();
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Customer_NumberOfPages__c);
        System.debug('@@@@DEBUG DWH_GetCustomer_Data:: START :: totalPages = '+totalPages);
        return [SELECT Id FROM Contact LIMIT :totalPages];    
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){  

        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
        Integer totalPages = Integer.valueOf(LastRunDateVar.Customer_NumberOfPages__c);
        System.debug('@@@@DEBUG DWH_GetCustomer_Data:: EXECUTE :: currentPage = ' + this.currentPage + ' / ' + totalPages + ' --- scope.size() ' + scope.size());
        if( currentPage <= totalPages)
        {
            getContactData(currentPage);   
            this.currentPage = this.currentPage + 1;
        }
    }

    public void finish(Database.BatchableContext info){
        
    }
    
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

            System.debug('@@@@DEBUG getCustomerDWHCount :: noOfRecords = ' + noOfRecords );
            lastRunDateVar.Customer_NumberOfPages__c = ( noOfRecords > 0 && noOfRecords > lastRunDateVar.Customer_NumRecords__c ) ? (noOfRecords/LastRunDateVar.Customer_NumRecords__c).round(System.RoundingMode.CEILING) : 1;
            System.debug('Customer_NumberOfPages__c = ' + lastRunDateVar.Customer_NumberOfPages__c);
            System.debug('Customer_NumRecords__c = ' + lastRunDateVar.Customer_NumRecords__c);
            update lastRunDateVar;
            
            serviceDataPool.buildServiceDataPoolHttp('getCustomerDWHCount', 'DWH_GetCustomer_Data', '', request, response);
        }
        catch(Exception ex) 
        {
            System.debug('@@@@DEBUG getCustomerDWHCount :: Error = ' + ex );
            loggerDataPool.buildLogDataPool('DWH_GetCustomer_Data.getCustomerDWHCount', ex);
        }
    }

    /*
    public static void DWH_GetCustomer_Data()
    {
        try 
        {   
            DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
            Integer totalPages = Integer.valueOf(lastRunDateVar.Customer_NumberOfPages__c);
            Integer startPage = 1; //Integer.valueOf(lastRunDateVar.Customer_StartPage__c);
            for(Integer i = startPage; i <= totalPages; i++) 
            {
                getContactData(i);
            }    
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('DWH_GetCustomer_Data', e);
        }
    }
    */

    //Creat future call out method for http call    
    // @future (callout=true)
    public static void getContactData(Integer pageNum)            
    {        
        //create http request, response objects here
        HttpRequest req = new HttpRequest();
        HttpResponse resInput = new HttpResponse();
        Http http = new Http();
        
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
        Datetime LastRunDatetime = (datetime)lastRunDateVar.DWH_import_date__c;
        isSuccess = lastRunDateVar.isSuccess__c;
        String LastRunDate = LastRunDatetime.format('MM/dd/yyyy');  
        
        String numRecs = lastRunDateVar.Customer_NumRecords__c <> null ? String.valueOf(lastRunDateVar.Customer_NumRecords__c.intValue()) : '2000';

        System.debug('@@@@DEBUG getContactData :: LastRunDate = ' + LastRunDate);
        System.debug('@@@@DEBUG getContactData :: numRecs = ' + numRecs);
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;

        /*************************************************
         * CGaylan: Implement Named Credentials instead of hard coding URLs
         * 			as well as not to store keys in a custom setting
         ************************************************/
        //Set properties of the  http request
        // req.setEndpoint(APIGateway_url+'/DWHAPI/GetCustomer_DWH?syncDate='+LastRunDate+'&noOfRecords=0&pageNo=0');
        req.setEndpoint(APIGateway_url+'/DWHAPI/GetCustomer_DWH?syncDate='+LastRunDate+'&noOfRecords='+ numRecs +'&pageNo='+String.ValueOf(pageNum));
        req.setMethod('GET');
        req.setHeader('apikey', APIGateway_key); 
        req.setHeader('Content-Type', 'application/json'); 
        req.setTimeout(120000);
        
        try 
        {   
            //Send http request, capture response and pass the response to mothod which 
            //will then process the same and update the SFDC object
            resInput = http.send(req);
            updateData(resInput);
            DebugLogs.getDebugLogs('DWH_GetCustomer_Data',DebugLogsListSuccess,DebugLogsListError);
            
            serviceDataPool.buildServiceDataPoolHttp('ContactSync', 'DWH_GetCustomer_Data', '', req, resInput);
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('DWH_GetCustomer_Data', e);
        }
    }

    public static void updateData(HttpResponse res)            
    {
        //List of objects with updated response
        list<Contact> lstContacts = new list<Contact>();
        List<Account> lstCustomerPersonAccount = new List<Account>();
        System.debug('@@@@DEBUG UpdateData :: res = ' + res );
        System.debug('@@@@DEBUG UpdateData :: getBody() = ' + res.getBody() );
        
        try 
        { 
            //Check if Org is Sandbox
            isSandbox = [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
            
            // Parse entire JSON response.        
            JSONParser parser = JSON.createParser(res.getBody());
            
            while (parser.nextToken() != null) {
                // Start at the array of Contacts.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        // Advance to the start object marker to
                        //  find next contact statement object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            // Read entire Contact object, including its array of line items.
                            ContactC Con = (ContactC)parser.readValueAs(ContactC.class);                       
                            if(Con.Magic!=null)
                            {   
                                String str_unique_key = AccountUtil.createUniqueString();  /** PA MIGRATION : To Remove */
                                /** PA MIGRATION : Part-1 To Remove Start */
                                if(Con.Magic.trim()!='')
                                {
                                    tempContact = new Contact(); 
                                    tempContact.Identifier__c = str_unique_key;

                                    //To Incorporate NRIC changes, If DWH contact has no DOB,then update Contact NRIC as DWH Contact Id
                                    if( String.isNotBlank(Con.SOCIALID) && Con.SOCIALID.length() == 4) {
                                        tempContact.NRIC__c = Con.Magic; 
                                        tempContact.NRIC_Passport_No__c = Con.Magic; 
                                    }
                                    else                               
                                    {
                                        tempContact.NRIC__c = Con.SOCIALID; 
                                        tempContact.NRIC_Passport_No__c = Con.SOCIALID; 
                                    }
                                
                                	tempContact.Salutation = Con.TITLE;
                                    if( String.isNotBlank(Con.SURNAME) ){
                                        tempContact.LastName = Con.SURNAME;
                                    }
                                    else{
                                        //tempContact.FirstName = 'Dear';
                                        tempContact.LastName = 'Customer';
                                    }
                                    
                                    if( String.isNotBlank(Con.FIRSTNAME) ){
                                        tempContact.FirstName = Con.FIRSTNAME;
                                    }
                                    
                                    //Autoline Salutation
                                    if(String.isNotBlank(Con.SALUTE)){
                                        tempContact.Full_Name__c = Con.SALUTE; 
                                    }
                                    
                                    //28-May-2019: CGaylan: Added for 40 Character Limit on First Name
                                    //Contains Name ( some other name )
                                    //40 is character length for standard Contact.FirstName field
                                    if(String.isNotBlank(tempContact.FirstName) && tempContact.FirstName.contains('(') && tempContact.FirstName.length() > 40){
                                        //get the index of '('
                                        Integer openParenIndex = tempContact.FirstName.indexOf('(') - 1;
                                        tempContact.FirstName = tempContact.FirstName.subString(0,openParenIndex);
                                    }
                                    
                                    if(Con.DOB!=null)
                                    {                                        
                                        String dateRegEx = '((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])';
                                        Pattern myPattern = Pattern.compile(dateRegEx);
                                        Matcher myMatcher = myPattern.matcher(String.valueOf(Con.DOB.date())); 
                                        if(myMatcher.matches())
                                        {
                                            tempContact.Birthdate = Con.DOB.date();
                                        } 
                                    }
                                    tempContact.Gender__c = Con.SEX;
                                    
                                    //Run only for Prod (not Sandbox)
                                    if(!isSandbox){
                                        tempContact.Phone = Con.PHONE002;
                                        if(Con.PHONE005 != null){
                                            tempContact.MobilePhone = '65'+Con.PHONE005;
                                        }  
                                        tempContact.Email = Con.EMAIL;
                                    }                                    
                                    
                                    tempContact.Address_Line_1__c = Con.ADDRESS001;
                                    tempContact.Address_Line_2__c = Con.ADDRESS002;
                                    tempContact.Address_Line_3__c = Con.ADDRESS003;
                                    tempContact.Address_Line_4__c = Con.ADDRESS004;
                                    tempContact.Address_Line_5__c = Con.ADDRESS005;
                                    
                                    if(Con.COUNTRY != null)
                                    {
                                        if( Con.COUNTRY.trim()=='')
                                        {
                                            tempContact.Country__c = 'Singapore';
                                        }
                                        else
                                        {
                                            tempContact.Country__c = Con.COUNTRY;
                                        }   
                                    }
                                    else
                                    {
                                        tempContact.Country__c = 'Singapore';
                                    }

                                    if(Con.PDPA != null)
                                    {
                                        if(Con.PDPA == 'False' || String.isBlank(Con.PDPA))
                                        {
                                            UpdatePDPA.updatePDPA(tempContact, false, false, false);
                                        }
                                        else
                                        {
                                            UpdatePDPA.updatePDPA(tempContact, true, true, true);
                                        }  
                                    }

                                    tempContact.Preferred_Mode_of_contact__c = Con.Preferred_Mode_Of_Contact;
                                    
                                    //Previously DWH_Contact_ID__c pertains to Con.MAGIC
                                    //Changes made 2019-Aug during AutoLine split
                                    tempContact.DWH_Contact_ID__c     = Con.MAGIC_CUSTOMER;
                                    tempContact.MAGIC_MBPC__c         = Con.MAGIC_MBPC;
                                    tempContact.MAGIC_MBCV__c         = Con.MAGIC_MBCV;
                                    tempContact.MAGIC_MF__c           = Con.MAGIC_MF;
                                    tempContact.MAGIC_FUL__c          = Con.MAGIC_FUL;
                                    tempContact.CustomerType__c       = Con.CUSTOMER_TYPE;
                                    tempContact.CustomerDataSource__c = Con.CUSTOMER_DATASOURCE;
                                    tempContact.Source__c             = 'DWH';
                                    tempContact.Type__c               = 'Customer';
                                    
                                    CallFromDWH = true;
                                    
                                    
                                    //Add Contacts to list from API response.
                                    lstContacts.add(tempContact);//}
                                }
                                /** PA MIGRATION : Part-1 To Remove End */


                                /** PA MIGRATION : Part-1 Newly Added Start */
                                if(Con.Magic.trim()!='')
                                {
                                    tempAccount = new Account( RecordTypeId = AccountUtil.getCustomerRecordTypeId() ); 
                                    tempAccount.Identifier__c  = str_unique_key;
                                    // tempAccount.Identifier__pc = str_unique_key; 

                                    //To Incorporate NRIC changes, If DWH contact has no DOB,then update Contact NRIC as DWH Contact Id
                                    if( String.isNotBlank(Con.SOCIALID) && Con.SOCIALID.length() == 4) {
                                        tempAccount.NRIC__pc = Con.Magic; 
                                        tempAccount.NRIC_Passport_No__pc = Con.Magic; 
                                    }
                                    else                               
                                    {
                                        tempAccount.NRIC__pc = Con.SOCIALID; 
                                        tempAccount.NRIC_Passport_No__pc = Con.SOCIALID; 
                                    }
                                
                                	tempAccount.Salutation = Con.TITLE;
                                    if( String.isNotBlank(Con.SURNAME) ){
                                        tempAccount.LastName = Con.SURNAME;
                                    }
                                    else{
                                        //tempAccount.FirstName = 'Dear';
                                        tempAccount.LastName = 'Customer';
                                    }
                                    
                                    if( String.isNotBlank(Con.FIRSTNAME) ){
                                        tempAccount.FirstName = Con.FIRSTNAME;
                                    }
                                    
                                    //Autoline Salutation
                                    if(String.isNotBlank(Con.SALUTE)){
                                        tempAccount.Full_Name__pc = Con.SALUTE; 
                                    }
                                    

                                    if(String.isNotBlank(tempAccount.FirstName) && tempAccount.FirstName.contains('(') && tempAccount.FirstName.length() > 40){
                                        Integer openParenIndex = tempAccount.FirstName.indexOf('(') - 1;
                                        tempAccount.FirstName = tempAccount.FirstName.subString(0,openParenIndex);
                                    }
                                    
                                    if(Con.DOB!=null)
                                    {                                        
                                        String dateRegEx = '((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])';
                                        Pattern myPattern = Pattern.compile(dateRegEx);
                                        Matcher myMatcher = myPattern.matcher(String.valueOf(Con.DOB.date())); 
                                        if(myMatcher.matches())
                                        {
                                            tempAccount.PersonBirthdate = Con.DOB.date();
                                        } 
                                    }
                                    tempAccount.Gender__pc = Con.SEX;
                                    
                                    //Run only for Prod (not Sandbox)
                                    if(!isSandbox){
                                        tempAccount.Phone = Con.PHONE002;
                                        if(Con.PHONE005 != null){
                                            tempAccount.PersonMobilePhone = '65'+Con.PHONE005;
                                        }  
                                        tempAccount.PersonEmail = Con.EMAIL;
                                    }                                    
                                    
                                    tempAccount.Address_Line_1__pc = Con.ADDRESS001;
                                    tempAccount.Address_Line_2__pc = Con.ADDRESS002;
                                    tempAccount.Address_Line_3__pc = Con.ADDRESS003;
                                    tempAccount.Address_Line_4__pc = Con.ADDRESS004;
                                    tempAccount.Address_Line_5__pc = Con.ADDRESS005;
                                    
                                    if(Con.COUNTRY != null)
                                    {
                                        if( Con.COUNTRY.trim()=='')
                                        {
                                            tempAccount.Country__pc = 'Singapore';
                                        }
                                        else
                                        {
                                            tempAccount.Country__pc = Con.COUNTRY;
                                        }   
                                    }
                                    else
                                    {
                                        tempAccount.Country__pc = 'Singapore';
                                    }
                                    
                                    if(Con.PDPA != null)
                                    {
                                        if(Con.PDPA == 'False' || String.isBlank(Con.PDPA))
                                        {
                                            UpdatePDPA.updatePDPA(tempContact, false, false, false);
                                        }
                                        else
                                        {
                                            UpdatePDPA.updatePDPA(tempContact, true, true, true);
                                        }  
                                    }

                                    tempAccount.Preferred_Mode_of_contact__pc = Con.Preferred_Mode_Of_Contact;
                                    
                                    //Previously DWH_Contact_ID__c pertains to Con.MAGIC
                                    //Changes made 2019-Aug during AutoLine split
                                    tempAccount.DWH_Contact_ID__c      = Con.MAGIC_CUSTOMER;    // NEW EXTERNAL ID FIELD AT ACCOUNT LEVEL
                                    tempAccount.DWH_Contact_ID__pc     = Con.MAGIC_CUSTOMER;
                                    tempAccount.MAGIC_MBPC__pc         = Con.MAGIC_MBPC;
                                    tempAccount.MAGIC_MBCV__pc         = Con.MAGIC_MBCV;
                                    tempAccount.MAGIC_MF__pc           = Con.MAGIC_MF;
                                    tempAccount.MAGIC_FUL__pc          = Con.MAGIC_FUL;
                                    tempAccount.CustomerType__pc       = Con.CUSTOMER_TYPE;
                                    tempAccount.CustomerDataSource__pc = Con.CUSTOMER_DATASOURCE;
                                    tempAccount.Source__pc             = 'DWH';
                                    tempAccount.Type__pc               = 'Customer';
                                    
                                    CallFromDWH = true;
                                    
                                    lstCustomerPersonAccount.add( tempAccount );
                                }
                                 /** PA MIGRATION : Part-1 Newly Added End */

                            }
                            
                        }
                    }
                }
            }
            
            System.debug('@@@@DEBUG UpdateData :: lstContacts = ' + lstContacts.size() + ' --- ' + lstContacts);
            System.debug('@@@@DEBUG UpdateData :: lstCustomerPersonAccount = ' + lstCustomerPersonAccount.size() + ' --- ' + lstCustomerPersonAccount);
            
            
            //System.debug('Total DML Statements: ' +  Limits.getDmlStatements()+' Limit DML Statements: '+Limits.getLimitDmlStatements());
            //Upsert the list of updated Contacts into SFSC.
            
            // Database.UpsertResult[] results = Database.upsert(lstContacts, Contact.Fields.DWH_Contact_ID__c, false);      
            
            Map<String,Contact> mapContactToInsert = new Map<String,Contact>();
            for( Contact cnt : lstContacts ) {
                mapContactToInsert.put( cnt.DWH_Contact_ID__c , cnt );
            }

            List<Contact> lstContactToUpdate= new List<Contact>();
            for( Contact cnt : [SELECT Id, DWH_Contact_ID__c FROM Contact WHERE IsPersonAccount = false AND DWH_Contact_ID__c IN :mapContactToInsert.keySet() ] ) {
                Contact cRef = mapContactToInsert.get( cnt.DWH_Contact_ID__c );
                cRef.Id      = cnt.Id;
                lstContactToUpdate.add( cRef );
                mapContactToInsert.remove( cnt.DWH_Contact_ID__c );
            }
            System.debug('@@@@DEBUG UpdateData :: mapContactToInsert = ' + mapContactToInsert.size() + ' --- ' + mapContactToInsert);
            System.debug('@@@@DEBUG UpdateData :: lstContactToUpdate = ' + lstContactToUpdate.size() + ' --- ' + lstContactToUpdate);

            // Insert Contact
            // insert ( mapContactToInsert.values() );
            Database.SaveResult[] cntInsertResults = Database.insert( mapContactToInsert.values() , false);

            // Update Contact
            // update lstContactToUpdate;
            Database.SaveResult[] cntUpdateResults = Database.update(lstContactToUpdate, false);

            // Upsert Person Account
            Database.UpsertResult[] paUpsertResults = Database.upsert(lstCustomerPersonAccount, Account.Fields.DWH_Contact_ID__c, false);      
            
            /** PA MIGRATION : Newly Added Part-2 Start */
            for(Integer index = 0, size = paUpsertResults.size(); index < size; index++) 
            {
                if(paUpsertResults[index].isSuccess()) 
                {
                    if(paUpsertResults[index].isCreated()) 
                    {                   
                        System.debug(lstContacts[index].DWH_Contact_ID__c +' was created');
                        DebugLogsListSuccess.add(lstContacts[index].DWH_Contact_ID__c +' was created');
                    } 
                    else 
                    {
                        System.debug(lstContacts[index].DWH_Contact_ID__c +' was updated');
                        DebugLogsListSuccess.add(lstContacts[index].DWH_Contact_ID__c +' was updated');
                    }                    
                }
                else
                {
                    isSuccess = False;                
                    system.debug(lstContacts[index].DWH_Contact_ID__c +' had error'+paUpsertResults[index].getErrors());
                    DebugLogsListError.add(lstContacts[index].DWH_Contact_ID__c +' had error'+paUpsertResults[index].getErrors());
                }
            }
            /** PA MIGRATION : Newly Added Part-2 End */
        } 
        catch(Exception e) 
        {
            isSuccess = False;
            DebugLogsListError.add('System_error: '+e.getMessage());
            loggerDataPool.buildLogDataPool('DWH_GetCustomer_Data', e);
        }
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
        lastRunDateVar.isSuccess__c = isSuccess;
        Database.upsert ( lastRunDateVar , false );
        
    }

    //Define Contact parser class here to parse JSON values to Contact fields.
    public class ContactC 
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
         

        // Start: AutoLine Split (2019-Aug)
        public String MAGIC_CUSTOMER;
        public String CUSTOMER_DATASOURCE;
        public String MAGIC_MBPC;
        public String MAGIC_MBCV;
        public String MAGIC_MF;
        public String MAGIC_FUL;
        public String CUSTOMER_TYPE;
        // End: AutoLine Split (2019-Aug)
        
        public ContactC(String SOCIALIDstr, String TITLEstr, String SURNAMEstr, String FIRSTNAMstr, String LAST_NAMEstr, 
                        String SEXstr, String PHONE005str,String PHONE002str, Datetime DOBstr, String EMAILstr, 
                        String ADDRESS001str,String ADDRESS002str,String ADDRESS003str,String ADDRESS004str,
                        String ADDRESS005str,String CITYstr,String STATEstr,String COUNTRYstr,String POSTCODEstr,
                        String Preferred_Mode_Of_Contactstr,String PDPAstr,String MAGICstr, String SALUTEstr,
                        //Autoline Split, 7 new columns 2019-Aug
                        String MAGIC_CUSTOMERstr, String CUSTOMER_DATASOURCEstr, String MAGIC_MBPCstr, 
                        String MAGIC_MBCVstr, String MAGIC_MFstr, String MAGIC_FULstr, String CUSTOMER_TYPEstr 
                       ) 
        {
            SOCIALID = SOCIALIDstr;
            TITLE = TITLEstr;
            SURNAME = SURNAMEstr;
            FIRSTNAME = FIRSTNAMstr;
            LASTNAME = LAST_NAMEstr;
            SEX = SEXstr;
            PHONE005 = PHONE005str;
            PHONE002 = PHONE005str;
            DOB = DOBstr;
            EMAIL = EMAILstr;
            ADDRESS001 = ADDRESS001str; 
            ADDRESS002 = ADDRESS002str;
            ADDRESS003 = ADDRESS003str;
            ADDRESS004 = ADDRESS004str;
            ADDRESS005 = ADDRESS005str;
            CITY = CITYstr;
            STATE = STATEstr;
            COUNTRY = COUNTRYstr;
            POSTCODE = POSTCODEstr;
            Preferred_Mode_Of_Contact = Preferred_Mode_Of_Contactstr;
            PDPA = PDPAstr;
            MAGIC = MAGICstr;
            SALUTE = SALUTEstr;
            
            //Start: AutoLine Split - 2019-Aug
            MAGIC_CUSTOMER = MAGIC_CUSTOMERstr;
            CUSTOMER_DATASOURCE = CUSTOMER_DATASOURCEstr;
            MAGIC_MBPC = MAGIC_MBPCstr;
            MAGIC_MBCV = MAGIC_MBCVstr;
            MAGIC_MF = MAGIC_MFstr;
            MAGIC_FUL = MAGIC_FULstr;
            CUSTOMER_TYPE = CUSTOMER_TYPEstr; 
            //End: AutoLine Split - 2019-Aug
        }
    }


    /** PA MIGRATION : To Remove; For Testing  */
    public static void exeTestRun(  String strMockResponseResult )
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
		String strResult = '{"Customers": [{"MAGIC_CUSTOMER": 9999111,"CUSTOMER_DATASOURCE": "CCS","MAGIC_MBPC": 0,"MAGIC_MBCV": 0,"MAGIC_MF": 9999211,"MAGIC_FUL": 9999211,"CUSTOMER_TYPE": null,"SALUTE": "P3 Aodigy","SOCIALID": "123406091989","MAGIC": 9999111,"TITLE": "Mr","SURNAME": "P3","FIRSTNAME": "Aodigy","LASTNAME": null,"DOB": "1961-04-12T00:00:00","SEX": "M","PHONE005": "99900099","PHONE002": null,"EMAIL": "p3@aodigycnc.com","ADDRESS001": "30 Jalan Merah Saga","ADDRESS002": "Singapore 278108","ADDRESS003": null,"ADDRESS004": null,"ADDRESS005": "Singapore","CITY": "          ","STATE": null,"COUNTRY": "          ","POSTCODE": 0,"PDPA": null,"Preferred_Mode_Of_Contact": null,"CREATED": "2/6/2020 12:00:00 AM","EDITED": "4/4/2020 12:00:00 AM"}],"Message":"The operation is completed successfully. 1 customers have been retrieved . "}';
        return strResult;
    
    }

}
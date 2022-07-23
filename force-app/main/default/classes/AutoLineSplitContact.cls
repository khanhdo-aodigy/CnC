//for Autoline Split initial sync
//Please note that this class does not follow best practice as this class is meant to be run one time
global class AutoLineSplitContact implements Schedulable{
    Public static Integer count=0;
    Public static Contact tempContact;
    Public Static Boolean isSuccess  = True;  
    Public Static List<String> DebugLogsListSuccess = New List<String>();
    Public Static List<String> DebugLogsListError = New List<String>();
    
    //CGaylan: Flag to tell if org is sandbox, if Sandbox, do not sync Email and Phone Numbers
    public static Boolean isSandbox = false;
    
    //Public PDPAUpdate_Contact_SMS PDPAUpdate_Contact_SMSvar;  
    public static boolean CallFromDWH = false;
    Public static Boolean isNextAvailable = true;
    
    global void execute(SchedulableContext ctx){
        getAllContactData();
    }
    
    
    public static void getAllContactData(){
        try {   
            DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();  
            Integer TotalPages = Integer.valueOf(LastRunDateVar.Customer_NumberOfPages__c);
            Integer StartPage = Integer.valueOf(LastRunDateVar.Customer_StartPage__c);
            for(Integer i = StartPage; i <= TotalPages; i++){
                getContactData(i);
            }        
        }catch(exception e){
            loggerDataPool.buildLogDataPool('AutoLineSplitContact', e);
        }
        DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
        LastRunDateVar.Customer_StartPage__c = LastRunDateVar.Customer_NumberOfPages__c;
        LastRunDateVar.Customer_NumberOfPages__c = LastRunDateVar.Customer_NumberOfPages__c + 10;
        upsert LastRunDateVar;
    } 
    
    
    //Creat future call out method for http call    
    @future (callout=true)
    public static void getContactData(Integer PageNum)    
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
        req.setEndpoint(APIGateway_url+'/DWHAPI/GetCustomer_DWH?syncDate=01/01/1900&noOfRecords='+ numRecs +'&pageNo='+String.ValueOf(PageNum));
        req.setMethod('GET');
        req.setHeader('apikey', APIGateway_key); 
        
        req.setHeader('Content-Type', 'application/json'); 
        req.setTimeout(120000);
        
        try 
        {   
            //Send http request, capture response and pass the response to mothod which 
            //will then process the same and update the SFDC object
            resInput = http.send(req);
            UpdateData(resInput);
            DebugLogs.getDebugLogs('autoLineSplitContact',DebugLogsListSuccess,DebugLogsListError);
            
            serviceDataPool.buildServiceDataPoolHttp('Contact-AutSplit', 'autoLineSplitContact', '', req, resInput);
        }
        catch(exception e)
        {
            loggerDataPool.buildLogDataPool('autoLineSplitContact', e);
        }
    }
    public static void UpdateData(HttpResponse res)            
    {
        Boolean isRecordExist = false;
        //List of objects with updated response
        list<Contact> LstContact = new list<Contact>();
        
        //Key is MAGIC number
        Map<String, Contact> conMap = new Map<String, Contact>();
        
        try{       
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
                            isRecordExist = true;
                            // Read entire Contact object, including its array of line items.
                            ContactC Con = (ContactC)parser.readValueAs(ContactC.class);                       
                            if(Con.Magic!=null)
                            {
                                if(Con.Magic.trim()!='')
                                {
	                                tempContact = New Contact(); 
	                                //To Incorporate NRIC changes, If DWH contact has no DOB,then update Contact NRIC as DWH Contact Id
	                                if( String.isNotBlank(Con.SOCIALID) && Con.SOCIALID.length() == 4) {
	                                    tempContact.NRIC__c= Con.Magic; 
	                                    tempContact.NRIC_Passport_No__c= Con.Magic; 
	                                }else                               
	                                {
	                                    tempContact.NRIC__c= Con.SOCIALID; 
	                                    tempContact.NRIC_Passport_No__c= Con.SOCIALID; 
	                                }
	                                tempContact.Salutation= Con.TITLE;
                                    
                                    //18-07-2019: LastName is always null
                                    //Surname is always populated
                                    if( String.isNotBlank(Con.SURNAME) ){
                                        tempContact.LastName = Con.SURNAME;
                                    }else{
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
                                    
                                    If(Con.DOB!=null)
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
                                        If(Con.PHONE005!=null){
                                            tempContact.MobilePhone = '65'+Con.PHONE005;
                                        }  
                                        tempContact.Email = Con.EMAIL;
                                    }
                                    
                                    tempContact.Address_Line_1__c = Con.ADDRESS001;
                                    tempContact.Address_Line_2__c = Con.ADDRESS002;
                                    tempContact.Address_Line_3__c = Con.ADDRESS003;
                                    tempContact.Address_Line_4__c = Con.ADDRESS004;
                                    tempContact.Address_Line_5__c = Con.ADDRESS005;
                                    If(Con.COUNTRY!=null)
                                    {
                                        If( Con.COUNTRY.trim()=='')
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
                                    
                                    If(Con.PDPA!=null)
                                    {
                                        If(Con.PDPA=='False' || Con.PDPA.trim()=='')
                                        {
                                            tempContact.PDPA__c='';
                                        }
                                        else
                                        {
                                            tempContact.PDPA__c='SMS; Call; Email';
                                        }  
                                    }
                                    else
                                    {
                                        tempContact.PDPA__c='';
                                    }
                                    tempContact.Preferred_Mode_of_contact__c = Con.Preferred_Mode_Of_Contact;
                                    
                                    
                                    //Previously DWH_Contact_ID__c pertains to Con.MAGIC
                                    //Changes made 2019-Aug during AutoLine split
                                    tempContact.DWH_Contact_ID__c = Con.MAGIC_CUSTOMER;
                                    tempContact.MAGIC_MBPC__c = Con.MAGIC_MBPC;
                                    tempContact.MAGIC_MBCV__c = Con.MAGIC_MBCV;
                                    tempContact.MAGIC_MF__c = Con.MAGIC_MF;
                                    tempContact.MAGIC_FUL__c = Con.MAGIC_FUL;
                                    tempContact.CustomerType__c = Con.CUSTOMER_TYPE;
                                    tempContact.CustomerDataSource__c = Con.CUSTOMER_DATASOURCE;

                                    CallFromDWH = true;
                                    tempContact.Source__c='DWH';
                                    tempContact.Type__c='Customer';
                                    
                                    
                                    String identifier = '';
                                    /*
                                     * Order: 
                                     * 		(1) MBPC 
                                     * 		(2) MF 
                                     * 		(3) MBCV
                                     * 		(4) FUL (Fulco)
                                     */ 
                                    if( String.isNotBlank(Con.MAGIC_MBPC) && Con.MAGIC_MBPC!='0'){
                                        identifier = Con.MAGIC_MBPC;
                                    }else if( String.isNotBlank(Con.MAGIC_MF) && Con.MAGIC_MF!='0'  ){
                                        identifier = Con.MAGIC_MF;
                                    }else if( String.isNotBlank(Con.MAGIC_MBCV) && Con.MAGIC_MBCV!='0' ){
                                        identifier = Con.MAGIC_MBCV;
                                    }else if(  String.isNotBlank(Con.MAGIC_FUL) && Con.MAGIC_FUL!='0'  ){
                                        identifier = Con.MAGIC_FUL;
                                    }
                                    
                                    if(String.isNotBlank(identifier)){
                                        conMap.put( identifier , tempContact );
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            
            //Loop Here
            if(conMap.keySet() != null && !conMap.isEmpty()){
                for(Contact cn : [SELECT Id , DWH_Contact_ID__c 
                                  FROM Contact 
                                  WHERE DWH_Contact_ID__c IN :conMap.keySet()])
                {
                    if( conMap.containsKey(cn.DWH_Contact_ID__c) ){
                        Contact con = conMap.get( cn.DWH_Contact_ID__c );
                        con.Id = cn.Id;
                        LstContact.add( con );
                    }
                }
            }

			DWH_GetAllCustomer_Data.CallFromDWH = true;
            //Upsert the list of updated Contacts into SFDC.
            Database.SaveResult[] results =    Database.update( LstContact , false); // Database.upsert(LstContact, Contact.Fields.DWH_Contact_ID__c, False);       

            //Verify and Log the records which were created, updated and threw an error.
            list<Contact> LstContactNew = new list<Contact>();

            for(Integer index = 0, size = results.size(); index < size; index++){
                if(results[index].isSuccess()) {
                    DebugLogsListSuccess.add(LstContact[index].DWH_Contact_ID__c +' was updated');
                }else{
                    isSuccess = False;
                    DebugLogsListError.add(LstContact[index].DWH_Contact_ID__c +' had error'+results[index].getErrors());
                }
            }
        }catch(Exception e) {
            isSuccess = False;
            DebugLogsListError.add('System_error: '+e.getMessage());
        }

        isNextAvailable = isRecordExist;
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
}
public class DWH_GetSingleCustomer_Data implements Queueable, Database.AllowsCallouts{
Public static Integer count=0;
Public static Contact tempContact;
Public Static Boolean isSuccess  = True;  
Public Static List<String> DebugLogsListSuccess = New List<String>();
Public Static List<String> DebugLogsListError = New List<String>();
Public String InputMagic {get;set;}
    
//Public PDPAUpdate_Contact_SMS PDPAUpdate_Contact_SMSvar;  
public static boolean CallFromDWH = false;
    
public DWH_GetSingleCustomer_Data(String InputCSVMagic)
{
    this.InputMagic = InputCSVMagic;
}

//Creat future call out method for http call   
public void execute(QueueableContext context)           
{
    //create http request, response objects here
    HttpRequest req = new HttpRequest();
    HttpResponse resInput = new HttpResponse();
    Http http = new Http();
    
    /*DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
    Datetime LastRunDatetime = (datetime)LastRunDateVar.DWH_import_date__c;
    isSuccess = LastRunDateVar.isSuccess__c;
    String LastRunDate = LastRunDatetime.format('MM/dd/yyyy');  */
    
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
    String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
   
    //Set properties of the  http request
    req.setEndpoint(APIGateway_url+'/DWHAPI/GetCustomerByMagic_DWH');
    req.setMethod('POST');
    req.setHeader('apikey', APIGateway_key); 
    req.setHeader('Content-Type', 'application/json');
    req.setBody('{"csv":"'+InputMagic+'"}');

    req.setHeader('Content-Type', 'application/json'); 
    req.setTimeout(120000);
	
  	try 
    {   
        //System.debug('req=='+req.getBody());
        //Send http request, capture response and pass the response to mothod which 
        //will then process the same and update the SFSC object        
        resInput = http.send(req);
        UpdateData(resInput);
        //System.debug('resInput=='+resInput.getBody());
        DebugLogs.getDebugLogs('DWH_GetSingleCustomer_Data',DebugLogsListSuccess,DebugLogsListError);
    }
    catch(exception ex1)
    {
        system.debug(ex1.getMessage());
    }
}
public static void UpdateData(HttpResponse res)            
{
    //List of objects with updated response
    list<Contact> LstContact = new list<Contact>();
    try 
    {        
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
                        If(Con.Magic!=null)
                        {
                            If(Con.Magic.trim()!='')
                            {
                                tempContact = New Contact(); 
                                tempContact.NRIC__c= Con.SOCIALID; 
                                tempContact.NRIC_Passport_No__c= Con.SOCIALID; 
                                tempContact.Salutation= Con.TITLE;
                                tempContact.FirstName= Con.FIRSTNAME;
                                tempContact.Full_Name__c= Con.SURNAME;                                   
                                If(Con.LastName!=null && Con.LastName.trim()!='')
                                {  
                                    tempContact.LastName = Con.LASTNAME;
                                }
                                else If(Con.SURNAME!=null && Con.SURNAME.trim()!='')
                                {
                                    tempContact.LastName = Con.SURNAME;
                                    tempContact.Full_Name__c = '';
                                }
                                else If(Con.FIRSTNAME!=null && Con.FIRSTNAME.trim()!='')   
                                {
                                    tempContact.LastName = Con.FIRSTNAME;
                                    tempContact.FirstName = '';
                                }
                                else
                                {
                                    //tempContact.FirstName = 'Dear';
                                    tempContact.LastName = 'Customer';
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
                                //tempContact.Phone = Con.PHONE002;
                                //If(Con.PHONE005!=null){
                               	//tempContact.MobilePhone = '65'+Con.PHONE005;
                                //}  
                                //tempContact.Email = Con.EMAIL; 
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
                                tempContact.DWH_Contact_ID__c = Con.MAGIC; 
                                CallFromDWH = true;
                                tempContact.Source__c='DWH';
                                tempContact.Type__c='Customer';
                                
                                //Add Contacts to list from API response.
                                LstContact.add(tempContact);//}
                            }
                        }}
                }
            }
        }
		
        //System.debug('Total DML Statements: ' +  Limits.getDmlStatements()+' Limit DML Statements: '+Limits.getLimitDmlStatements());
       	//Upsert the list of updated Contacts into SFSC.
        Database.UpsertResult[] results = Database.upsert(LstContact, Contact.Fields.DWH_Contact_ID__c, False);       
        //System.debug(LstContact);
        //Verify and Log the records which were created, updated and threw an error.
        list<Contact> LstContactNew = new list<Contact>();
        for(Integer index = 0, size = results.size(); index < size; index++) 
        {
            if(results[index].isSuccess()) 
            {
                if(results[index].isCreated()) 
                {                   
                    System.debug(LstContact[index].DWH_Contact_ID__c +' was created');
                    DebugLogsListSuccess.add(LstContact[index].DWH_Contact_ID__c +' was created');
                } 
                else 
                { 
                    System.debug(LstContact[index].DWH_Contact_ID__c +' was updated');
                    DebugLogsListSuccess.add(LstContact[index].DWH_Contact_ID__c +' was updated');
                }                    
            }
            else
            {
                isSuccess = False;
                system.debug(LstContact[index].DWH_Contact_ID__c +' had error'+results[index].getErrors());
                DebugLogsListError.add(LstContact[index].DWH_Contact_ID__c +' had error'+results[index].getErrors());
            }
        }
         
        } 
        catch(System.Exception e) 
        {
            isSuccess = False;
            System.debug('System_error: '+ e);
            DebugLogsListError.add('System_error: '+e.getMessage());
        }
    //DWH_last_run_date__c LastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
    //LastRunDateVar.isSuccess__c = isSuccess;
    //upsert LastRunDateVar;
       
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
        
        public ContactC(String SOCIALIDstr, String TITLEstr, String SURNAMEstr, String FIRSTNAMstr, String LAST_NAMEstr, 
                       String SEXstr, String PHONE005str,String PHONE002str, Datetime DOBstr, String EMAILstr, 
                       String ADDRESS001str,String ADDRESS002str,String ADDRESS003str,String ADDRESS004str,
                       String ADDRESS005str,String CITYstr,String STATEstr,String COUNTRYstr,String POSTCODEstr,
                       String Preferred_Mode_Of_Contactstr,String PDPAstr,String MAGICstr) 
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
        }
}
}
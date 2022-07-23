/** *****
 * Description : BookJoinController
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20160405            NAIT Admin                    Created Initial Version. 
 * 20200908            khanh.do@aodigy.com           Added PA - Phase 2 Changes
 * 20210601            phan.thu@aodigy.com           Added Marketing Referral Sources
 * 20210622            khanh.do@aodigy.com           Added Person Account Profiling creation
 * 20211029            khanh.do@aodigy.com           Fixed bug missing Digital Signature when Opp exists
 * 
** *****/
public without sharing class BookJoinController_ipad {
    
    public Vehicle_Master__c vehicle{get;set;}
    public Model__c vehicleModel;
    public Contact customer{get;set;}
    public Account prospect{get;set;}   
    public Sobject currentObj;
    public Opportunity opp{get;set;}
    public Test_Drive__c test{get;set;}
    public String salesNRIC{get;set;} // removed the sales rep NRIC
    public String salesName{get;set;}
    
    //Code added for handling existing lead
    public String contactId{get;set;}
    public Contact tempContact{get;set;}
    public Contact foundContact {get;set;}
    public String personAccountId{get;set;}     
    public Account tempPA{get;set;}     
    public String testdrive_id{get;set;}
    
    public String custFullName{get;set;}
    public String custNric{get;set;}
    public String custPhone{get;set;}
    public String custPost{get;set;}
    public String custEmail{get;set;}
    public String custPostId;   
    public String branchCode{get;set;}
    public String franchiseCode{get;set;}
    
    public Boolean customerSearch{get;set;}
    public Boolean oppSearch{get;set;}
    public Boolean newPost{get;set;}
    public Boolean errDoubleBook{get;set;}
    public Boolean beingOutErr{get;set;}
    public Boolean errActiveTestdrive {get;set;}
    public Boolean errTradePlate {get;set;}
    public Boolean errTP2 {get;set;}  
    public Boolean errModelRegist {get;set;}
    
    public String baseUrl {get; set;}
    public Boolean isErrorWhenSave {get;set;}
    public String photoUrl1 {get;set;}
    public String photoUrl2 {get;set;}
    
    public String IndemForm {get;set;}
    public String franc {get;set;}
    public String logo1{get;set;}
    public String logo2{get;set;}
    
    public ID ownId{get;set;}
    public String personAccount_Id;    
    public String contact_Id;
    public Boolean isSMS, isCall, isEmail, isFax;
    public Test_Drive__c[] relatedTestDrive;
    public boolean isPAExists= false;
    public String MobileNumber;

    // public Boolean isExisted{get; set;}

    public SelectOption[] tradePlateLists { //this is where we're going to pull the list
        public get;
        private set;
    }
    public String tpSelected{get;set;}
    public List<test_drive__c> historyTest {get;set;}

    public String selectedTouchPoints { get; set; }
    public String allTouchPoints { get; set; }

    public class Wrapper 
    {
        public String label;
        public String value;    
    }
    
    public BookJoinController_ipad()
    {
        //get logo and recordtype opp based on franchise of user and set up for the indem form
        String id = ApexPages.currentPage().getParameters().get('id'); //Vehicle_Master__c record Id
        System.debug('@@@@DEBUG  ApexPages.currentPage().getParameters(): ' + ApexPages.currentPage().getParameters());
        
        //get Lead, contact and test drive Id from request
        testdrive_id = ApexPages.currentPage().getParameters().get('testdrive_id');
        contactId = ApexPages.currentPage().getParameters().get('contactId');

        System.debug('testdrive_id = ' + testdrive_id);
        System.debug('contactId = ' + contactId);

        vehicle = [ SELECT Id, Name, Registration_No__c, Model__c, Franchise_Code__c, Branch_Code__c
                    FROM Vehicle_Master__c
                    WHERE Id = :id];
        
        ownId = UserInfo.getUserId();
        User currentUser = [ SELECT Id, Name, Branch_Code__c, Franchise_Code__c 
                             FROM User
                             WHERE Id = :ownId ];

        branchCode    = currentUser.Branch_Code__c;
        franchiseCode = currentUser.Franchise_Code__c;
        //new add
        //salesNRIC =a.NRIC__c;
        salesName = currentUser.name;
        
        //C&C Logo
        logo1 = [SELECT FileName__c FROM Logo__c WHERE Branch_Code__c='' AND Franchise_Code__c='' LIMIT 1].FileName__c;
        
        //Brand-based Configuration 
        logo2 = [SELECT FileName__c FROM Logo__c WHERE Branch_Code__c=:branchCode LIMIT 1].FileName__c;
        
        customer = new Contact();
        test = new Test_Drive__c();
        opp = new Opportunity();
        //Added code for assigning Test Drive object to existing test drive
        if(testdrive_id!='null' && testdrive_id !='' && testdrive_id!=null)
        {   
            test = [SELECT id FROM Test_Drive__c WHERE Id =:testdrive_id];
        }
        
        Date today = date.today();
        test.Model__c = vehicle.id;
        test.Date__c = today;
        test.Branch_Code__c = branchCode;
        test.Franchise_Code__c = franchiseCode;
        //Start - CGaylan Added 26-May-2019
        //This is for bypassing Test Drive appointment email.
        test.IsWalkin__c = true;
        //End - CGaylan
        
        oppSearch = false;
        custNric  = '';
        custPhone = '';
        custPost  = '';
        newPost   = false;
        historyTest = new List<Test_drive__c>();
        errDoubleBook = false;
        beingOutErr = false;
        errActiveTestdrive = false;
        errTradePlate = false;
        errTP2 = false;
        errModelRegist = false;
        isErrorWhenSave = false;
        String hostUrl = URL.getSalesforceBaseUrl().getHost();
        baseUrl = 'https://' + hostUrl;
        
        if(branchCode != null){
            if(branchCode == 'CCK'){
                IndemForm = 'C&C';
                franc= 'Kia';
            }else if(branchCode == 'CCA'){
                IndemForm = 'C&C';
                franc= 'Automotive';
            }else{
                IndemForm = 'CCF';
                franc= 'France';
            }
        } 

        tradePlateLists = new SelectOption[]{};
        List<Trade_Plate__c> tplists = [SELECT Id, Name FROM Trade_Plate__c WHERE Active__c = true AND Branch_Code__c = :branchCode AND Franchise_Code__c = :franchiseCode];
        tradePlateLists.add(new SelectOption('','--None--'));
        for (Trade_Plate__c tp:tplists){
            tradePlateLists.add(new SelectOption( tp.Id, tp.Name));
        }
        /** ADDED BY TPhan@aodigy.com - Marketing Referral Sources */   
        List<Schema.PicklistEntry> ple = Marketing_Referral_Source__c.Touch_Point__c.getDescribe().getPicklistValues();
        List<Wrapper> wrappers = new List<Wrapper>();
        for ( Schema.PicklistEntry f : ple)
        {
            Wrapper w = new Wrapper();
            w.label = f.getLabel();
            w.value = f.getValue();
            wrappers.add(w);
        }     

        allTouchPoints = JSON.serialize(wrappers);
        /** END */
        if(contactId != 'null' && contactId != '' && contactId != null) {
            tempContact = [ SELECT Id, Name, FirstName, LastName, MobilePhone, Birthdate, Email, AccountId,
                                   Address_Line_1__c, Address_Line_2__c, Address_Line_3__c,
                                   Country__c, Postal_Code__c, Status__c, Postal_Code__r.Name, Full_Name__c, 
                                   SMS__c, Email__c, Call__c, Fax__c, PDPA__c
                            FROM Contact
                            WHERE Id =:contactId ];

            custEmail                  = tempContact.Email;
            customer.Address_Line_1__c = tempContact.Address_Line_1__c;
            customer.Address_Line_2__c = tempContact.Address_Line_2__c;
            customer.Address_Line_3__c = tempContact.Address_Line_3__c;
            customer.Country__c        = tempContact.Country__c;
            custPost                   = tempContact.Postal_Code__r.Name;
            customer.FirstName         = String.isNotBlank(tempContact.FirstName) ? tempContact.FirstName : '';
            customer.LastName          = String.isNotBlank(tempContact.LastName) ? tempContact.LastName : '';
            custFullName               = String.isNotBlank(tempContact.Full_Name__c) ? tempContact.Full_Name__c :  tempContact.Name;

            if(tempContact.Birthdate != null) {
                customer.Birthdate = tempContact.Birthdate;   
            }

            if((tempContact.MobilePhone != null) && ((tempContact.MobilePhone).length() == 10)) {
                custPhone = tempContact.MobilePhone.substring(2);
            }

            if(tempContact.SMS__c || tempContact.Call__c|| tempContact.Email__c || tempContact.Fax__c) {
                Iagree = 'Yes';
            } 
            else {    
                Iagree = 'No';
            }
            
            List<Postal_Code__c> postalCodes = [ SELECT Id, Name, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Country__c
                                                 FROM Postal_code__c
                                                 WHERE Name =: tempContact.Postal_Code__c ];
            newPost = true;
            if (postalCodes.size()>0){                
                newPost     = false;
                custPost    = postalCodes[0].Name;
                custPostId  = postalCodes[0].id;
                customer.Address_Line_1__c = postalCodes[0].Address_Line_1__c;
                customer.Address_Line_2__c = postalCodes[0].Address_Line_2__c;
                customer.Address_Line_3__c = postalCodes[0].Address_Line_3__c;
                customer.Country__c        = postalCodes[0].Country__c;
            }
        }       
    }
    
    public pageReference searchCustNric(){
        String searchTypeToUse = Apexpages.currentPage().getParameters().get('searchType');
        String typeValToUse= Apexpages.currentPage().getParameters().get('typeVal');
        System.debug('@@@@DEBUG searchCustNric :: searchTypeToUse: ' + searchTypeToUse);
        System.debug('@@@@DEBUG searchCustNric :: typeValToUse: ' + typeValToUse);
        if(searchTypeToUse == 'mobilePhone'){
            typeValToUse = '65' + typeValToUse;
        }
        //search customer by nric
        errDoubleBook = false;
        beingOutErr = false;
        errActiveTestdrive = false;
        errTradePlate = false;
        errTP2 = false;
        errModelRegist = false;
        custNric = custNric.trim();
        custPhone = custPhone.trim();
        historyTest = new List<Test_drive__c>();
        customerSearch = false;
        List<Contact> existingContact = new List<Contact>();
        List<Account> existingPA = new List<Account>();    
        
        if( String.isNotblank( typeValToUse ) && typeValToUse != 'noemail@noemail.com'){
            
            if(!searchTypeToUse.startsWith('Person')){
                searchTypeToUse = 'Person' + searchTypeToUse;
            }
             
            if(searchTypeToUse.startsWith('Person')){
                searchTypeToUse = searchTypeToUse.replace('Person', '');
            }
            
            existingContact = Database.query('SELECT Id, Name, NRIC_Passport_No__c, Lastname, FirstName, AccountId, ' +
                                                    'Mobilephone, Email, Postal_Code__c, Birthdate, Unit_No_Floor__c,' +
                                                    'Phone, Gender__c, Address_Line_1__c,Address_Line_2__c, Address_Line_3__c,' +
                                                    'Country__c, Branch_Code__c, Franchise_Code__c, OwnerID, Full_Name__c, ' +
                                                    'SMS__c, Call__c, Email__c, Fax__c, PDPA__c '+
                                            ' FROM Contact' +
                                            ' WHERE ' + String.escapeSingleQuotes(searchTypeToUse) + ' = \''+ String.escapeSingleQuotes(typeValToUse) + '\' ' +
                                            ' AND IsPersonAccount = true '+
                                            ' Order By Account.RecordType.Name ASC ');

            System.debug('@@@@DEBUG searchCustNric :: existingContact = ' + existingContact);

            foundContact = existingContact.size() > 0 ? existingContact.get(0) : foundContact;

            if (existingContact.size()>0)
            {
                if(existingContact[0].Birthdate!= null) 
                {
                    customer.Birthdate = existingContact[0].Birthdate;   
                }

                if((existingContact[0].Mobilephone!= null) && ((existingContact[0].Mobilephone).length() == 10)) 
                {
                    custPhone = existingContact[0].Mobilephone.substring(2);   
                }

                else if((existingContact[0].Mobilephone!= null) && ((existingContact[0].Mobilephone).length() == 8))
                {
                    custPhone=existingContact[0].Mobilephone;
                }

                customer.FirstName = String.isNotBlank(existingContact[0].FirstName) ? existingContact[0].FirstName : '';
                customer.LastName = String.isNotBlank(existingContact[0].LastName) ? existingContact[0].LastName : '';

                custFullName = String.isNotBlank(existingContact[0].Full_Name__c) ? existingContact[0].Full_Name__c :  existingContact[0].Name;
                custNric = existingContact[0].NRIC_Passport_No__c;
                custEmail = existingContact[0].Email;
  
                List<Postal_Code__c> temp2=[select id,Name,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Country__c from Postal_code__c where id=:existingContact[0].Postal_Code__c];
                newPost=true;
                if (temp2.size()>0){
                    newPost=false;
                    custPost=temp2[0].Name;
                    custPostId =temp2[0].id;
                    customer.Address_Line_1__c=temp2[0].Address_Line_1__c;
                    customer.Address_Line_2__c=temp2[0].Address_Line_2__c;
                    customer.Address_Line_3__c=temp2[0].Address_Line_3__c;
                    customer.Country__c=temp2[0].Country__c;
                }
                test.Prospect__c=existingContact[0].id;
                historyTest=Database.query('select Date__c, CreatedDate, Owner.Name,Sales_Rep_Mobile__c,Model__r.name,Count_Day__c,Branch_Code__c,Franchise_Code__c from test_drive__c where '+ searchTypeToUse + '__c = \''+ typeValToUse + '\'' + ' and Branch_Code__c = \''+ branchCode + '\' and Franchise_Code__c = \'' +franchiseCode + '\' order by Count_Day__c');
            }  

            //PA Phase 2: Removed tempLeadList.size() == 0 
            if(existingContact.size() == 0 && existingPA.size() == 0)
            {
                custNric = '';
                custPost='';
                customer.Birthdate = null;
                customer.NRIC_Passport_No__c  = '';
                customer.FirstName = '';
                customer.LastName = '';
                custFullName =  '';     
            }

            //PA Phase 2: Removed tempLeadList.size() == 0 
            if(searchTypeToUse == 'mobilePhone' && existingContact.size()==0 && existingPA.size() == 0)
            { 
                custEmail = '';
            }
            
        }
        else 
        {
            customer = new Contact();
            custPhone = '';
            custPost = '';
            test.Prospect__c=null;
            customer.Address_Line_1__c = '';
            customer.Address_Line_2__c = '';
            customer.Address_Line_3__c = '';
            customer.Birthdate = null;
            customer.Country__c = '';
        }

        // if(customer.Birthdate != null && custNric != null){
        //     isExisted = true;
        // }
        
        System.debug('@@@@DEBUG searchCustNric :: searchTypeToUse = ' + searchTypeToUse );
        System.debug('@@@@DEBUG searchCustNric :: typeValToUse = ' + typeValToUse );
        System.debug('@@@@DEBUG searchCustNric :: isPAExists = ' + isPAExists );

        return null;
    }
    
    public pageReference postalChange()
    {
        //change postal based on the postal code
        newPost = true;
        List<Postal_Code__c> postalCodes = [ SELECT Id, Name, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Country__c 
                                             FROM Postal_code__c 
                                             WHERE Name = :custPost
                                            ];
        customer.Postal_Code__c = null;
        if ( postalCodes.size() > 0 )
        {
            newPost = false;
            custPostId = postalCodes[0].Id;
            customer.Address_Line_1__c = postalCodes[0].Address_Line_1__c;
            customer.Address_Line_2__c = postalCodes[0].Address_Line_2__c;
            customer.Address_Line_3__c = postalCodes[0].Address_Line_3__c;
            customer.Country__c        = postalCodes[0].Country__c;
            customer.Postal_Code__c    = postalCodes[0].Id;
        }
        else
        {
            customer.Address_Line_1__c = '';
            customer.Address_Line_2__c = '';
            customer.Address_Line_3__c = '';
            customer.Country__c        = '';
        }

        return null;
    }
    
    public void oppSearch()
    {
        List<Opportunity> relatedOpportunities =new List<Opportunity>();

        System.debug('@@@@DEBUG oppSearch :: contact_Id = ' + contact_Id );
        if(contact_Id != null)
        {
			//Code was modified for Oppty standardisation --> NSJ
			relatedOpportunities = OpportunityService.activeOpportunityList(branchCode, contact_Id);
            System.debug('relatedOpportunities = ' + relatedOpportunities);
        }

        if (relatedOpportunities.size()>0)
        {
            relatedTestDrive = [ SELECT Id 
                                 FROM Test_Drive__c
                                 WHERE Opportunity__c =: relatedOpportunities[0].Id ];

            if(relatedTestDrive.isEmpty())
            {
                Decimal oppScore = relatedOpportunities[0].Opportunity_Score__c; 
                if (oppScore != null)
                {
                    oppScore= oppScore.intValue() + 40;                
                }
                else{
                    oppScore =40;
                }
                relatedOpportunities[0].Opportunity_Score__c = oppScore;
                relatedOpportunities[0].Rating__c = 'Warm';
            }
            else if(relatedOpportunities[0].Opportunity_Score__c <= 25)
            {
                relatedOpportunities[0].Rating__c = 'Cold';
            }
            
            opp = relatedOpportunities[0];
            system.debug('opp:: ' + opp);
            test.Opportunity__c = opp.id;
            system.debug('test.Opportunity__c :: ' + test.Opportunity__c);
        }
    }

    public String formatString(String theOld)
    {
        if(theOld!=null && theOld!='')
        {
            //format the address to have 1st letter is uppercase
            String temp = '';
            String[] s = theOld.split(' ');
            Integer i = 0;
            List<String> newString = new List<String>();
            for(String str:s)
            {
                i = str.length();
                String x,y,finalstring;
                x = str.substring(0,1).toUpperCase();
                y = str.substring(1,i).toLowerCase();
                finalstring = x + y;
                newString.add(finalstring);
            }
            String xyz = String.valueOf(newString);
            temp = xyz.replace(',','');
            temp = temp.replace('(','');
            temp = temp.replace(')','');
            return temp;
        }
        else
        {
            return theOld;
        }
    }
    
    public pageReference save()
    {
        try
        {            
            Date today = Date.today();
            System.debug('@@@@DEBUG save :: customer = ' + customer );
            System.debug('@@@@DEBUG save :: foundContact = ' + foundContact );
            custNric = custNric.trim();
            String newNRIC,NRIClastFourDigits,NRICFirstFourDigits;
            Date custDob = customer.Birthdate;
            String Dob = Datetime.newInstance(custDob.year(), custDob.month(),custDob.day()).format('dd/MM/YYYY');
            if(custNric.length() == 9 && custDob != null)
            {
                test.NRIC__c       = custNric;
                NRIClastFourDigits = custNric.substring(custNric.length()-4,custNric.length());
                newNRIC            = NRIClastFourDigits + Dob.replaceAll('/', ''); 
            }
            // 11/7/2022 - if NRIC's length is 12, take 4 first characters to format NRIC
            if(custNric.length() == 12 && custDob != null){
                NRICFirstFourDigits = custNric.substring(0, 4);
                newNRIC             = NRICFirstFourDigits + Dob.replaceAll('/', '');
            }
            // *** End
            //save the Test drive with contact opp and postal change insert when have new
            errDoubleBook       = false;
            beingOutErr         = false;
            errActiveTestdrive  = false;
            errTradePlate       = false;
            errTP2              = false;
            errModelRegist      = false;
            isErrorWhenSave     = false;
            
            List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
            Boolean newCust=false;
            if (customer.Address_Line_1__c != null)
            {
                customer.Address_Line_1__c = formatString(customer.Address_Line_1__c);
            }

            if (customer.Address_Line_2__c != null)
            {
                customer.Address_Line_2__c = formatString(customer.Address_Line_2__c);
            }

            if (customer.Address_Line_3__c != null)
            {
                customer.Address_Line_3__c = formatString(customer.Address_Line_3__c);
            }

            if (customer.Country__c != null)
            {
                customer.Country__c = formatString(customer.Country__c);
            }

            if (custNric==null || custNric=='' || custEmail ==null || custEmail =='')
            {
                isErrorWhenSave = true;
                photoUrl1 = null;
                photoUrl2 = null;
                return null;
            }

            if (customer.Lastname==null || customer.Lastname=='')
            {
                isErrorWhenSave = true;
                photoUrl1 = null;
                photoUrl2 = null;
                return null;
            }

            custPhone=custPhone.trim();
            if (custPhone == '' || custPhone == null)
            {
                isErrorWhenSave = true;
                photoUrl1 = null;
                photoUrl2 = null;
                return null;
            }
            
            custPhone = custPhone.trim();
            if (custPhone != '' && custPhone != null && custPhone.isNumeric()==false)
            {
                isErrorWhenSave = true;
                photoUrl1 = null;
                photoUrl2 = null;
                return null;
            }

            if (custPhone != '' && custPhone != null && custPhone.left(1)!='8' && custPhone.left(1)!='9')
            {
                isErrorWhenSave = true;
                photoUrl1 = null;
                photoUrl2 = null;
                return null;
            }

            if (custPhone != '' && custPhone != null && custPhone.length()!=8)
            {
                isErrorWhenSave = true;
                photoUrl1 = null;
                photoUrl2 = null;
                return null;
            }
            
            if(custEmail == null || custEmail == '')
            {
                isErrorWhenSave = true;
                photoUrl1 = null;
                photoUrl2 = null;
                return null;
            }

            if(customer.Birthdate != null && customer.Birthdate > today ) 
            {
                isErrorWhenSave = true;
                photoUrl1 = null;
                photoUrl2 = null;
                return null;
            }

            if(opp.Date_of_Registration__c != null && opp.Date_of_Registration__c > today ) 
            {
                photoUrl1 = null;
                photoUrl2 = null;
                isErrorWhenSave = true;
                return null;
            }
            
            testDrives = [SELECT Id, Name, Branch_Code__c, Franchise_Code__c
                          FROM Test_Drive__c 
                          WHERE CreatedDate = :today
                          AND Status__c <> 'In'
                          AND OwnerID = :ownId
                          AND Model__c = :vehicle.Id
                          AND Branch_Code__c = :branchCode
                          AND Franchise_Code__c = :franchiseCode];

            if (testDrives.size()>0)
            {
                errDoubleBook = true;
                photoUrl1 = null;
                photoUrl2 = null;
                isErrorWhenSave = true;
                return null;
            }
            
            test.Trade_Plate__c = tpSelected;
            if (vehicle.Registration_No__c == null || vehicle.Registration_No__c == '') 
            {
                if (test.Trade_Plate__c == null){
                    errTradePlate = true;
                    photoUrl1 = null;
                    photoUrl2 = null;
                    isErrorWhenSave = true;
                    return null;
                } 
                else 
                {
                    testDrives = [SELECT Id, Name, Branch_Code__c, Franchise_Code__c
                                  FROM Test_Drive__c 
                                  WHERE CreatedDate = TODAY
                                  AND Status__c <> 'In'
                                  AND Trade_Plate__c = :test.Trade_Plate__c 
                                  AND Model__c <> :vehicle.Id
                                  AND Branch_Code__c = :branchCode
                                  AND Franchise_Code__c = :franchiseCode];
                    if (testDrives.size()>0)
                    {
                        errTP2 = true; 
                        photoUrl1 = null;
                        photoUrl2 = null;
                        isErrorWhenSave = true;
                        return null;
                    }
                }
            } 
            else 
            {
                if (test.Trade_Plate__c!=null || test.Trade_Plate__c == '')
                {
                    errModelRegist = true;
                    photoUrl1 = null;
                    photoUrl2 = null;
                    isErrorWhenSave = true;
                    return null;
                }
            }
            
            if(Iagree != null)
            {
                if(Iagree == 'Yes') {
                    //PDPAVal= 'SMS;Call;Email';
                    isSMS = true;
                    isEmail = true;
                    isCall = true;
                    isFax = true;
                } 
                else 
                {
                    //PDPAVal = '';
                    isSMS = false;
                    isEmail = false;
                    isCall = false;
                    isFax = false;
                }
            }
         
            if( foundContact <> null && foundContact.Id <> null)
            {
                contact_Id       = foundContact.Id;
                personAccount_Id = foundContact.AccountId;

                Contact eCnt = new Contact( Id = foundContact.Id );
                eCnt.Email               = custEmail;
                eCnt.FirstName           = customer.FirstName;
                eCnt.NRIC_Passport_No__c = newNRIC;
                eCnt.NRIC__c             = newNRIC;
                eCnt.Birthdate           = customer.Birthdate;
                eCnt.Mobilephone         = '65'+custPhone;
                eCnt.Address_Line_1__c   = customer.Address_Line_1__c;
                eCnt.Address_Line_2__c   = customer.Address_Line_2__c;
                eCnt.Address_Line_3__c   = customer.Address_Line_3__c;
                eCnt.Unit_No_Floor__c    = customer.Unit_No_Floor__c;
                eCnt.Country__c          = customer.Country__c;
                eCnt.Postal_Code__c      = custPostId;
                
                test.Prospect__c = contact_Id;
                test.Account__c  = personAccount_Id;

                customer.Id = foundContact.Id;

                customerSearch = true;
                system.debug('customerSearch:: ' + customerSearch);
            }
            else 
            {
                //PA Phase 2: If no existing Person Account and no existing Contact found => Create new Prospect instead of Lead
                Id idPA_prospect = AccountUtil.getProspectRecordTypeId();
                prospect = new Account( FirstName = customer.FirstName,
                                        LastName = customer.Lastname,
                                        PersonMobilePhone = '65'+custPhone,
                                        Phone = '65'+custPhone,
                                        PersonEmail = custEmail,
                                        PersonBirthdate = customer.Birthdate,
                                        Status__pc = 'Open',
                                        PersonLeadSource = 'Website',
                                        //PDPA__pc = PDPAVal,
                                        SMS__pc = isSMS,
                                        Call__pc = isCall,
                                        Email__pc = isEmail,
                                        Fax__pc = isFax,
                                        // 12/07/2022 - Add value for NRIC_Passport field on PA
                                        NRIC_Passport_No__pc = newNRIC,
                                        // *** End
                                        NRIC__pc = newNRIC,
                                        Address_Line_1__pc = customer.Address_Line_1__c,
                                        Address_Line_2__pc = customer.Address_Line_2__c,
                                        Address_Line_3__pc = customer.Address_Line_3__c,
                                        PersonMailingStreet = customer.Address_Line_1__c,
                                        PersonMailingCity = customer.Address_Line_2__c,
                                        PersonMailingState = customer.Address_Line_3__c,
                                        Country__pc = customer.Country__c,
                                        Postal_Code__pc = custPostId,
                                        Full_Name__pc = custFullName,
                                        RecordTypeId = idPA_prospect
                                    );
                //Database.DMLOptions dmlOpts = new Database.DMLOptions();
                //dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                prospect = AccountUtil.createProspect( prospect );               

                // System.debug('Testing --- ' + AccountUtil.getSinglePersonAccountById( String.valueOf(prospect.Id) ) );
                if (prospect.Id <> null)
                {
                    List<Account> theProspectAcct = [SELECT Id, Name, PersonContactId FROM Account WHERE Id = :prospect.Id];
                    System.debug('@@@@DEBUG save :: theProspectAcct = ' + theProspectAcct );

                    if (theProspectAcct.size() > 0)
                    {
                        //System.debug('PersonContactId after = ' + prospect.PersonContactId);
                        test.Prospect__c = theProspectAcct[0].PersonContactId; //Look up to Prospect's Contact
                        test.Account__c  = theProspectAcct[0].Id;
                        personAccount_Id = theProspectAcct[0].Id;
                        contact_Id       = theProspectAcct[0].PersonContactId; 
                    }
                }          
            }

            
            //Added by Khanh: Create Person Account Profiling
            if(String.isNotBlank(personAccount_Id)) {
                AccountUtil.createProfiling('CCS_Person_Account_Profiling_RT', new Account(Id=personAccount_Id));
            }                
            
            if (customerSearch==true)
            {
                system.debug('go to oppSearch');
                oppSearch();
            }
            //Protion code moved end
            if (newPost==true && (custPost != null && custPost != ''))
            {
                Postal_Code__c pac=new Postal_Code__c();
                pac.Name=custPost;
                pac.Address_Line_1__c = customer.Address_Line_1__c;
                pac.Address_Line_2__c = customer.Address_Line_2__c;
                pac.Address_Line_3__c = customer.Address_Line_3__c;
                pac.Country__c = customer.Country__c;
                insert pac;
                customer.Postal_Code__c=pac.id;
            }
            
            // when pdpa is agreed in the booking form, the Contact PDPA section needs to be updated - seelct all 3 picklist values. if disagree then deselect all 3 values. 
            if(Iagree != null)
            {
                test.Agree__c = Iagree;
                if(test.Agree__c == 'Yes')
                {
                    customer.PDPA__c = 'SMS;Call;Email';
                    customer.SMS__c = true;
                    customer.Email__c = true;
                    customer.Call__c = true;
                    customer.Fax__c = true;
                }
                else
                {
                    System.debug('HERE!!!');
                    customer.PDPA__c = '';
                    customer.SMS__c = false;
                    customer.Email__c = false;
                    customer.Call__c = false;
                    customer.Fax__c = false;
                    System.debug('Customer: ' + customer);
                }
            }
            
            if (test.Prospect__c == null)
            {
                customer.NRIC_Passport_No__c = newNRIC;
                customer.Mobilephone = '65'+ custPhone;
                customer.ownerid = ownId;
                customer.Branch_Code__c = branchCode;
                customer.Franchise_Code__c = franchiseCode;
                newCust = true;
            } 
            else {
                //add for share
                if (ownId != customer.ownerID) {}
                //end add
                customer.NRIC_Passport_No__c = newNRIC;
                customer.Mobilephone = '65'+ custPhone;
                if (customer.Id <> null ) {update customer;}
            } 
            
			//Code was modified for Oppty standardisation --> NSJ
			//Opportunity Record Type 
			Id rtid = OpportunityService.getStrRecordTypeAssignment(branchCode);
            system.debug('before opp :: ' + opp);
            system.debug('before oppId :: ' + opp.Id);
			opp = OpportunityService.updateOpportunity(opp, contact_Id, personAccount_Id, rtid, branchCode, franchiseCode, 'Walk-in');
            system.debug('after opp :: ' + opp);

            opp.Test_Drive__c = true;
            Decimal oppScore = opp.Opportunity_Score__c;
            system.debug('test.Opportunity__c:: ' + test.Opportunity__c);
            if (String.isBlank(test.Opportunity__c))
			{
                System.debug('GOT UPDATE OPPORTUNITY');

                opp.StageName = 'Test Driven';
                opp.Model_c__c = vehicle.Model__c;

                if(contact_Id != null)
				{ 
                    Contact con = [SELECT Id, Name FROM Contact WHERE Id =: contact_Id];

                    //Code was modified for Oppty standardisation --> NSJ
					opp.Name = OpportunityService.getStrOpportunityName(con.name, vehicle.Franchise_Code__c);
                } 
                else 
				{
					//Code was modified for Oppty standardisation --> NSJ
					opp.Name = OpportunityService.getStrOpportunityName(customer.Lastname, vehicle.Franchise_Code__c);
                }                
                                          

                if (oppScore != null)
                {
                    oppScore = oppScore.intValue() + 40;                
                }
                else
                {
                    oppScore = 40;
                }

                IF(opp.ownerid == null)
                {
                    opp.ownerid=ownId;
                }

                opp.Opportunity_Score__c = oppScore;
                opp.Rating__c = 'Warm';
                insert opp;
                System.debug('Opportunity = ' + opp);
                list<sharingHelper.generateShare> lstToCreateShare = new list<sharingHelper.generateShare>();

                if( contact_Id !='null' && contact_Id !='' && contact_Id!=null) 
                {
                    lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', opp.Contact_Person__c, opp.OwnerId));
                }

                sharingHelper.creatShare(lstToCreateShare);
                test.Opportunity__c=opp.id;
            } 
            else 
            {
                System.debug('opp.Id = ' + opp.Id);
                opp.StageName = 'Test Driven';
                opp.LeadSource = 'Walk-in';
                update opp;
                list<sharingHelper.generateShare> lstToCreateShare = new list<sharingHelper.generateShare>();
 
                if(contact_Id != null) 
                {
                    lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', opp.Contact_Person__c, opp.OwnerId));
                }

                sharingHelper.creatShare(lstToCreateShare);
            }
            string userSign = Apexpages.currentPage().getParameters().get('userSign');
            System.debug('testDrive = ' + test);
            System.debug('userSign = ' + userSign);
            if(userSign != null || userSign != '') 
            {
                test.Digital_Signature__c = '<img src=\"'+userSign+'\" height="75" width="150">';
                test.Has_Signature_Populated__c = true;
            }
            if(RecEmail != null)
            {
                test.receive_idemnity_form__c =RecEmail;
            }
            // Modify on 14/07/2020 - Add new field Contactless Test Drive
            if (ContactLess != null) {
                test.contactless_test_drive__c = ContactLess;
            }
            List<Test_Drive__c> existingTestDrives = [ SELECT Id, Name, Branch_Code__c, Franchise_Code__c
                                                           FROM Test_Drive__c
                                                           WHERE Model__c = :vehicle.id 
                                                           AND CreatedDate = TODAY
                                                           AND Status__c = 'Out'
                                                           AND Branch_Code__c = :branchCode
                                                           AND Franchise_Code__c = :franchiseCode
                                                        ];

            if (existingTestDrives.size() > 0)
            {
                beingOutErr = true;
                return null; 
            } else {
                test.Check_Out__c = DateTime.now();
                test.Status__c = 'Out'; 
            }

            serviceDataPool.buildServiceDataPoolHttp('BookJoinController', 'BookJoinController', String.valueOf(test.Check_Out__c) +  ' ' + test.Status__c + ' ' + test.Account__c, new HttpRequest(), new HttpResponse());
        }
        catch (Exception e)
        {
            String msg = e.getMessage();
            Integer linenum = e.getLineNumber();
            String typename = e.getTypeName();
            Exception cause = e.getCause();
            loggerDataPool.buildLogDataPool('BookJoinController',e);
            System.debug('BookJoinController_ipad - save - Exception: ' + msg + '. At line: ' + lineNum +'. Cause: ' + cause);
            //serviceDataPool.buildServiceDataPoolWalkInTestDrive('Walk-In Test Drive', 'BookJoinController_ipad', '', cause,msg,typename,linenum);
        }
        return null;
    }
    
    public pageReference afterSave()
    {
        try{
            
            //Update existing Test Drive Object
            if (testdrive_id !='null' && testdrive_id !='' && testdrive_id!=null) 
            {
               
            }
            else 
            {   
				Models_Interested__c modInterested = new Models_Interested__c();
				modInterested = ModelsInterestedService.newModelInterestedObject(test.Opportunity__c, vehicle.Model__c, 'Offline', 'Test Drive (Walk-In)');
				modInterested.Status__c = 'Open';
				insert modInterested;

                /** ADDED BY TPhan@aodigy.com - Marketing Referral Sources */
                if (String.isNotBlank(selectedTouchPoints))
                {
                    List<Marketing_Referral_Source__c> mrsList = new List<Marketing_Referral_Source__c>();
                    List<String> touchPointLst = selectedTouchPoints.split(',');

                    for (String option: touchPointLst)
                    {
                        mrsList.add(new Marketing_Referral_Source__c(Source__c = 'Test Drive', Touch_Point__c = option, Opportunity__c = test.Opportunity__c));
                    }

                    System.debug('MSR: ' + mrsList);

                    insert mrsList;
                }
                /** END */              
                insert test;
                
            }

            List<Attachment> listPhoto = new List<Attachment>();
            Attachment thePhoto = new Attachment();                   
            System.debug('photoUrl1: ' + photoUrl1);
            System.debug('photoUrl2: ' + photoUrl2);
            if(test.Id != null)
            {
                test = [SELECT PDPA_Testdrive__c, Account__c, Brand__c, Send_Survey_SMS__c , SMS_Trigger_Flag__c, Survey_sent_in_an_earlier_Test_Drive__c
                        FROM Test_Drive__c
                        WHERE Id = :test.Id];
                Boolean isExisted = checkExistedTodayTestDriveByBrand(test.Account__c, test.Brand__c);
                if (isExisted) {
                    test.Survey_sent_in_an_earlier_Test_Drive__c = true;
                } else if (String.isNotBlank(test.PDPA_Testdrive__c) && test.PDPA_Testdrive__c.contains('SMS')) {
                    test.Send_Survey_SMS__c = true;
                    test.SMS_Trigger_Flag__c = true;
                }
                if(photoUrl1 != null && photoUrl1 != '')
                {
                    Long timestamp = datetime.now().getTime();
                    thePhoto.ContentType = 'image/jpeg';
                    thePhoto.Body = EncodingUtil.base64Decode(photoUrl1);
                    thePhoto.Name = customer.NRIC_Passport_No__c+' - '+timestamp;
                    thePhoto.ParentId = test.Id;
                    thePhoto.Description = test.Id;
                    
                    listPhoto.add(thePhoto);
                    thePhoto = new Attachment();
                }
                
                if(photoUrl2 != null && photoUrl2 != '')
                {
                    Long timestamp = datetime.now().getTime();
                    thePhoto.ContentType = 'image/jpeg';
                    thePhoto.Body = EncodingUtil.base64Decode(photoUrl2);
                    thePhoto.Name = customer.NRIC_Passport_No__c+' - '+timestamp;
                    thePhoto.ParentId = test.Id;
                    thePhoto.Description = test.Id;
                    
                    listPhoto.add(thePhoto);
                    thePhoto = new Attachment();
                }

                System.debug('listPhoto = ' +  listPhoto);
                if(listPhoto.size() > 0)
                {
                    insert listPhoto;

                    test.Has_NRIC_Photo_Uploaded__c = true;
                    System.debug('test.Has_NRIC_Photo_Uploaded__c = ' + test.Has_NRIC_Photo_Uploaded__c);
                    update test;
                    listPhoto = new List<Attachment>();
                }
            }

            photoUrl1 = null;
            photoUrl2 = null;
        }
        catch (Exception e)
        {
            String msg = e.getMessage();
            Integer linenum = e.getLineNumber();
            String typename = e.getTypeName();
            Exception cause = e.getCause();
            loggerDataPool.buildLogDataPool('BookJoinController',e);
        }
        return new Pagereference('/apex/TestDrive_ipad');
    }
    
    public pageReference cancel()
    {
        return new Pagereference('/apex/TestDrive_ipad');
    }
    
    String RecEmail = 'Yes';        
    public List<SelectOption> getItems() 
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }
    
    public String getRecEmail() 
    {
        return RecEmail;
    }
    
    public void setRecEmail(String RecEmail) 
    { 
        this.RecEmail = RecEmail; 
    }

    public List<SelectOption> getOps() 
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }
    
    String Iagree;
    public String getIagree() 
    {
        return Iagree;
    }
    
    public void setIagree(String Iagree) 
    { 
        this.Iagree = Iagree; 
    }

    // Modify on 14/07/2020 - Add new field Contactless Test Drive
    String ContactLess = 'Yes';
    public String getContactLess() 
    {
        return ContactLess;
    }

    public void setContactLess(String ContactLess) 
    {
        this.ContactLess = ContactLess;
    }

    /**
     * GFB CR - Deploy later
     */
    private static Boolean checkExistedTodayTestDriveByBrand(Id paId, String brand) {
        List<Test_Drive__c> tds = [SELECT ID
                                   FROM Test_Drive__c
                                   WHERE Account__c         = :paId
                                    AND  Brand__c           = :brand
                                    AND  Send_Survey_SMS__c = true
                                    AND  CreatedDate        = TODAY];
        return tds.size() > 0;
    }
}
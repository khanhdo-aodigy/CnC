/** ******
 * Change History : 
 * Date(YYYYMMDD)      Name                   Description
 * xxxxxxxx           xxxx                Created initial version
 * 20200925         TP@aodigy.com         PA Phase 2 : Changed logic for Contact/Lead Obj to PA Customer/Prospect
 * 
** ******/
@RestResource(urlMapping='/leads_accountManager/v1/*')
global with sharing class LeadsManager 
{
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;        
    private static map<String, Object> mapJSONBody = new map<String, Object>();    
    
    @HttpPost
    global static SObject getLeadByName() 
    {   
        mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        String LeadFName     = (String) mapJSONBody.get('LeadFName');
        String LeadLName     = (String) mapJSONBody.get('LeadLName');
        String LeadPhone     = (String) mapJSONBody.get('LeadPhone');
        String LeadEmail     = (String) mapJSONBody.get('LeadEmail');  
        String LeadBrand     = (String) mapJSONBody.get('LeadBrand');   
        String LeadCountry   = (String) mapJSONBody.get('LeadCountry');  
        String PDPAText      = (String) mapJSONBody.get('PDPAText');  
        String LeadSourceVal = (String) mapJSONBody.get('LeadSourceVal');  
        String FloorUnit     = '';
        String BuildingName  = '';
        String StreetName    = '';
        String PostalCode    = '';
        String AddressLine1  = '';
        String AddressLine2  = ''; 
        String AddressLine3  = '';    
        Id idPA_prospect     = AccountUtil.getProspectRecordTypeId();
        
        if(mapJSONBody.containsKey('StreetName')) {
            AddressLine2 = (String) mapJSONBody.get('StreetName');
        }
        
        if(mapJSONBody.containsKey('BuildingName')) {
            BuildingName = (String) mapJSONBody.get('BuildingName');
        }
        
        if(mapJSONBody.containsKey('FloorUnit')) {               
            FloorUnit = (String) mapJSONBody.get('FloorUnit'); 
        }
        
        if(mapJSONBody.containsKey('PostalCode')) { 
            AddressLine3 = (String) mapJSONBody.get('PostalCode');
        }
        
        if(String.isNotBlank(FloorUnit)) {
            AddressLine1 = FloorUnit;
        }
        
        if(String.isNotBlank(BuildingName)) {
            AddressLine1 = AddressLine1+' '+ BuildingName;
        }
        
        String Returnstr;
        //Lead ReturnLead;
        Contact ReturnContactIsPA; // --> PA MIGRATION
        Account ReturnPA;
        Sobject ReturnObj;
        String ErrorCode;
        String Errormsg;
        String StatusVar='Open';
        String LeadCompany='JCCL';
        String jsonS;
        String PDPAVal='';
        Boolean isSMS = false, isCall = false, isEmail = false, isFax = false;
        String branchCode = '';
        List <Model__c> thisModel = new List <Model__c> ();    
        
        if (LeadBrand != null && LeadBrand.trim() != '' && LeadBrand == 'KIA') {
            branchCode = 'CCK';
        }
        if (LeadBrand != null && LeadBrand.trim() != '' && LeadBrand == 'MIT') {
            branchCode = 'CCA';
        }
        if (LeadBrand != null && LeadBrand.trim() != '' && LeadBrand == 'MB') {
            branchCode = 'CCI';
        }
        if (LeadBrand != null && LeadBrand.trim() != '' && LeadBrand == 'CIT') {
            branchCode = 'CCF';
        }
        
        if (PDPAText=='yes') 
        {
            PDPAVal='Email;SMS;Call'; 
            isSMS = true;
            isCall = true;
            isEmail = true;
            isFax = true;
        } 
        
        if(LeadEmail !='')
        {
            try
            {   /** PA Phase 2  */
                //Get All contacts based on Email address
                // Contact[] resultContact = [SELECT Id FROM Contact WHERE IsPersonAccount = false AND Email = :LeadEmail];
                // if(resultContact.size()>0)
                // {
                //     List<Contact> cn = [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c 
                //                         FROM Contact 
                //                         WHERE IsPersonAccount = false AND Email =: LeadEmail AND Id = :resultContact.get(0).Id 
                //                         LIMIT 1];
                //     if(cn!=null)
                //     {
                //         Contact conSing = cn[0];
                //         conSing.Address_Line_1__c = AddressLine1;
                //         conSing.Address_Line_2__c = AddressLine2;
                //         conSing.Address_Line_3__c = AddressLine3;
                //         Database.update( conSing , false);
                //     }
                //     ReturnObj =  resultContact[0];
                // }             
                //PA MIGRATION --> biz live
                /*
				Contact[] resultPersonAccount_Contact = [SELECT Id FROM Contact WHERE IsPersonAccount = true AND Email = :LeadEmail];
                if(resultPersonAccount_Contact.size()>0)
                {
                    // contact conAcc = [SELECT AccountId FROM Contact WHERE Id =: resultPersonAccount_Contact.get(0).Id limit 1];
                    
                    List<Account> accList = new List<Account>();
                    // acclist = [SELECT Id, Address_Line_1__pc, Address_Line_2__pc, Address_Line_3__pc FROM Account WHERE Id =: conAcc.AccountId ];
                    
                    acclist = [SELECT Id, Address_Line_1__pc, Address_Line_2__pc, Address_Line_3__pc 
                               FROM Account 
                               WHERE PersonContactId =: resultPersonAccount_Contact.get(0).Id LIMIT 1 ];
                    
                    if(acclist != null)
                    {
                        Account acc = accList[0];
                        acc.Address_Line_1__pc = AddressLine1;
                        acc.Address_Line_2__pc = AddressLine2;
                        acc.Address_Line_3__pc = AddressLine3;
                        Database.update( acc , false);
                    }
                    ReturnObj =  resultPersonAccount_Contact[0]; //--> PA MIGRATION
                }*/				
                // End of PA MIGRATION --> biz live
                
                /** PA Phase 2: Start */
                
                //if PA Customer found, return Customer
                Id idPA_customer = AccountUtil.getCustomerRecordTypeId();
               	Contact[] resultPersonAccount_Contact = [SELECT Id FROM Contact WHERE IsPersonAccount = true AND Email = :LeadEmail AND Account.RecordTypeId =: idPA_customer];
                if(resultPersonAccount_Contact.size() > 0)
                {
                    List<Account> accList = [SELECT Id, Address_Line_1__pc, Address_Line_2__pc, Address_Line_3__pc FROM Account WHERE PersonContactId =: resultPersonAccount_Contact.get(0).Id LIMIT 1];
                    if (accList <> null)
                    {
                        Account acc = accList[0];
                        acc.Address_Line_1__pc = AddressLine1;
                        acc.Address_Line_2__pc = AddressLine2;
                        acc.Address_Line_3__pc = AddressLine3;
                        Database.update( acc , false);
                    }
                    
                    ReturnObj = resultPersonAccount_Contact[0];
                }                 
                /** END */
                else if (/*resultContact.size() == 0*/ resultPersonAccount_Contact.size() == 0) //PA MIGRATION && resultPersonAccount_Contact.size() == 0
                {                 
                    //Get All the Leads based upon Email        
                    /*Lead[] resultLead = [SELECT Id FROM Lead WHERE Email = :LeadEmail]; 
                    
                    //If Lead Already exists, return the same
                    if (resultLead.size()>0) 
                    {
                        //Check If name of the customer is "Customer" then update the same with provided one's.
                        List<Lead> UpdateleadLst = [SELECT Id, FirstName, LastName, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c 
                                                    FROM Lead 
                                                    WHERE Email = :LeadEmail];  
                        
                        if( UpdateleadLst.size() > 0 )
                        {
                            Lead Updatelead = UpdateleadLst[0];
                            if( Updatelead.LastName == 'Customer' && LeadLName!=null && LeadLName.trim()!='' )
                            {
                                Updatelead.LastName          = LeadLName;
                                Updatelead.FirstName         = LeadFName;
                                Updatelead.Address_Line_1__c = AddressLine1;
                                Updatelead.Address_Line_2__c = AddressLine2;
                                Updatelead.Address_Line_3__c = AddressLine3;
                                Database.update( Updatelead , false );
                                
                            }
                            else if( String.isBlank(Updatelead.Address_Line_1__c) )
                            {
                                Updatelead.Address_Line_1__c = AddressLine1;
                                Updatelead.Address_Line_2__c = AddressLine2;
                                Updatelead.Address_Line_3__c = AddressLine3;
                                Database.update( Updatelead , false );
                            }
                        }
                        ReturnLead = resultLead[0]; */           
                    
                        /** PA Phase 2: Start */

                        Contact[] resultProspect = [SELECT Id, FirstName, LastName, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c 
                                                    FROM Contact 
                                                    WHERE IsPersonAccount = true AND Email = :LeadEmail AND Account.RecordTypeId =: idPA_prospect];   
                    
                    	//if PA Prospect found, update Prospect and return prospect
                    	if (resultProspect.size() > 0)
                        {
                            Contact prospectCnt = resultProspect[0];
                            if( prospectCnt.LastName == 'Customer' && LeadLName!=null && LeadLName.trim()!='' )
                            {
                                prospectCnt.LastName          = LeadLName;
                                prospectCnt.FirstName         = LeadFName;
                                prospectCnt.Address_Line_1__c = AddressLine1;
                                prospectCnt.Address_Line_2__c = AddressLine2;
                                prospectCnt.Address_Line_3__c = AddressLine3;      
                                Database.update( prospectCnt , false );
                            }
                            else if( String.isBlank(prospectCnt.Address_Line_1__c))
                            {
                                System.debug('FOUND : ' + String.valueOf(prospectCnt));
                                prospectCnt.Address_Line_1__c = AddressLine1;
                                prospectCnt.Address_Line_2__c = AddressLine2;
                                prospectCnt.Address_Line_3__c = AddressLine3;
                                Database.update( prospectCnt , false );
                            }
           
                            // returnPA = resultProspect[0];   
                            ReturnContactIsPA = resultProspect[0]; 
                        }                 
                    	//if PA Prospect does not exixts, create new one        
                        else
                        {
                            /*
                            String uniqueLinkKey = AccountUtil.createUniqueString();
                            ReturnLead = new Lead();
                            Lead thisLead = new Lead(
                                                    FirstName=LeadFName,
                                                    LastName= String.isBlank(LeadLName) ? 'Customer' : LeadLName,
                                                    Phone=LeadPhone,
                                                    Status=StatusVar,
                                                    Company=LeadCompany,             
                                                    Email=LeadEmail,
                                                    PDPA__c=PDPAVal,
                                                    Branch_Code__c =  branchCode,   
                                                    LeadSource = LeadSourceVal,
                                                    Identifier__c = uniqueLinkKey, //--> PA MIGRATION, unique key linking between PA n Lead
                                                    Address_Line_1__c = AddressLine1,
                                                    Address_Line_2__c = AddressLine2,
                                                    Address_Line_3__c = AddressLine3);
     
                            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                            Database.DMLOptions dmlOpts = new Database.DMLOptions();
                            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                            //Check the Auto Assignment rule to true via setting the DMLOption on Lead instance
                            Database.update(thisLead, dmlOpts);
                            
                            insert thisLead;       
                            ReturnLead.Id = thisLead.Id;   
                            
                            //PA MIGRATION  //How to link? add RT type prospect
                            ReturnContactIsPA = new contact();
                            Account thisAccount = new Account(
                                FirstName   = LeadFName,
                                LastName    = String.isBlank(LeadLName) ? 'Customer' : LeadLName,
                                Phone       = LeadPhone,
                                Status__pc  = StatusVar,
                                PersonEmail = LeadEmail,
                                PDPA__pc    = PDPAVal,
                                RecordTypeId    = idPA_prospect,
                                Branch_Code__pc =  branchCode,   
                                AccountSource   = LeadSourceVal,
                                Identifier__pc  = uniqueLinkKey, //--> PA MIGRATION, unique key linking between PA n Lead
                                Identifier__c  = uniqueLinkKey,
                                Address_Line_1__pc = AddressLine1,
                                Address_Line_2__pc = AddressLine2,
                                Address_Line_3__pc = AddressLine3 );
                            
                            insert thisAccount;
                            thisAccount = AccountUtil.createProspect( thisAccount );
                            
                            contact objContact = [SELECT Id FROM Contact WHERE Accountid = :thisAccount.Id];
                            
                            ReturnContactIsPA.Id = objContact.Id;   
                            // End of PA MIGRATION*/
                            
                            String uniqueLinkKey = AccountUtil.createUniqueString();
                            Account thisAccount = new Account( 	FirstName   = LeadFName,
                                                                LastName    = String.isBlank(LeadLName) ? 'Customer' : LeadLName,
                                                                Phone       = LeadPhone,
                                                                Status__pc  = StatusVar,
                                                                PersonEmail = LeadEmail,
                                                                PDPA__pc    = PDPAVal,
                                                                SMS__pc     = isSMS,
                                                                Call__pc    = isCall,
                                                                Email__pc   = isEmail,
                                                                Fax__pc     = isFax,
                                                                RecordTypeId    = idPA_prospect,
                                                                Branch_Code__pc =  branchCode,   
                                                                AccountSource   = LeadSourceVal,
                                                                // Identifier__pc  = uniqueLinkKey,
                                                                // Identifier__c  = uniqueLinkKey,
                                                                Address_Line_1__pc = AddressLine1,
                                                                Address_Line_2__pc = AddressLine2,
                                                                Address_Line_3__pc = AddressLine3 );
                            
                            thisAccount = AccountUtil.createProspect( thisAccount );
                            
                            Contact objContact = [SELECT Id FROM Contact WHERE Accountid = :thisAccount.Id];
                            ReturnContactIsPA = new contact();
                            ReturnContactIsPA.Id = objContact.Id;   
                            // ReturnPA.Id = thisAccount.Id;
                        }
                        
                    ReturnObj = ReturnContactIsPA; /*--> PA MIGRATION / contact*/
                    //ReturnObj = ReturnLead;
                    // ReturnObj = ReturnPA;
                    /** END */
                }
                
            }
            catch (Exception e)
            { 
                loggerDataPool.buildLogDataPool('LeadsManager', e);
                res.responseBody = Blob.valueOf(e.getMessage());
                res.statusCode=400;       
            }  
        }
        else
        {
            //ErrorCode='E1';
            Errormsg='[{"message":"Required fields not supplied. Fields: LeadFName Or LeadLName Or LeadPhone"}]';
            
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(Errormsg);
            res.statusCode=400;
            
        }    
        
        serviceDataPool.buildServiceDataPool('Create Lead', 'LeadsManager', '', req, res);
		System.debug('return Obj to sitecore ' + ReturnObj);
        return ReturnObj;
    }
}


/*
    /services/apexrest/leads_accountManager/v1

    {
        "LeadFName": "Test",
        "LeadLName": "CNC-1",
        "LeadPhone": "11001100",
        "LeadEmail": "TestCNC-1@mailinator.com",
        "LeadBrand": "KIA",
        "LeadCountry": "Singapore",
        "LeadSourceVal": "EventRegistration",
        "PDPAText": "yes"
    }
*/
/** *****
 * Description : API Class to create Price Alert
 * 
 * Change History
 * Date(YYYYMMDD)       Name                        Description
 * 20180831             Cycle & Carriage            Created Initial Version. 
 * 20200506             Thu@aodigy                  PA Migration Phase 2 : Removed Lead reference in the code.
 *  
** *****/
@RestResource(urlMapping='/priceAlerts/v1/*')
global class priceAlerts {

    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Utility.httpErrorResponse errorResponse;
    private static Utility.httpSuccessResponse successResponse;
    private static map<String, Object> mapJSONBody = new map<String, Object>();
    public static String modelId = ''; 
    
    @HttpPost
    //global static SObject createPriceAlerts(String PersonId, String Type, String PDPAText, String Model, String Variant) 
    global static void createPriceAlerts()
    {
        mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        res.addHeader('Content-Type', 'application/json');
        String PersonId = (String)mapJSONBody.get('PersonId');
        String Type     = (String)mapJSONBody.get('Type');
        String PDPAText = (String)mapJSONBody.get('PDPAText');
        String Model    = (String)mapJSONBody.get('Model');
        String Variant  = (String)mapJSONBody.get('Variant');
        
        String Returnstr;
        price_alert__c prcAlrt;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        List<Opportunity> opp = new List<Opportunity>();
        Opportunity newOpp = new Opportunity();
        Lead [] thisLead = new List <Lead>();
        Contact [] thisContact = new List <contact>();    
        String account_Id = null;  
        Sobject ReturnObj;
        String ErrorCode;
        String Errormsg;
        String jsonS;
        String PDPAVal = ';';
        Boolean isSMS = false, isCall = false, isEmail = false, isFax = false;
        Date today = Date.today();
        ID rtid;
        Date oppCloseDate = today.addDays(30);   
        if (PDPAText=='yes')   
        {
            PDPAVal='Email;SMS;Call';
            isSMS = true;
            isCall = true;
            isEmail = true;
            isFax = true;
        } 
        List<Model__c> lstbranchCode = new List<Model__c>();
        String branchCode = '';
        String franchiseCode = '';
    
        System.debug('#### PersonId ---- ' + PersonId);
        System.debug('#### Type ---- ' + Type);
        System.debug('#### PDPAText ---- ' + PDPAText);
        System.debug('#### Model ---- ' + Model);
        System.debug('#### Variant ---- ' + Variant);
        
        if( String.isNotBlank( PersonId ) && String.isNotBlank( Type ) && String.isNotBlank( Model ) )
        {
            try
            { 
                lstbranchCode = [SELECT Id, Branch_Code__c, Franchise_Code__c FROM Model__c WHERE Id =:Model];
                
                if(lstbranchCode.size()>0)
                {
                    priceAlerts.modelId = lstbranchCode[0].Id;
                    branchCode          = lstbranchCode[0].Branch_Code__c;
                    franchiseCode       = lstbranchCode[0].Franchise_Code__c;
                }
                
                if(String.isNotBlank(branchCode))
                {
                    //Code was modified for Oppty standardisation --> NSJ
					rtid = OpportunityService.getStrRecordTypeAssignment(branchCode);
                }
                
                // 003 can be the PA Prospect/Customer
                if (PersonId.startsWith('003'))
                {
					//Code was modified for Oppty standardisation --> NSJ
					lstOpportunity = OpportunityService.activeOpportunityList(branchCode, PersonId);

                    System.debug('lstOpportunity'+lstOpportunity);
                    if(lstOpportunity != null && lstOpportunity.size() > 0)
                    {
                        //Open Opportunity Exists
                        opp = lstOpportunity;
                    }
                    
                    thisContact = [SELECT Id, Name, OwnerId, Account__c, Account__r.Id, AccountId, IsPersonAccount,
                                            SMS__c, Call__c, Email__c, Fax__c
                                   FROM Contact
                                   WHERE Id=:PersonId];
                    
                    if(!thiscontact.isEmpty())
                    {
                        if(thiscontact[0].IsPersonAccount == true )
                        {
                            account_Id = thiscontact[0].AccountId;
                        }
                        else if (thiscontact[0].Account__c != null)
                        {
                            account_Id = thiscontact[0].Account__r.Id;
                        }

                        //Update contact PDPA
                        Contact tempCon = new Contact(Id = thiscontact[0].Id); //Work around to update contact prevent error in case isPersonAccount = true
                        tempCon.SMS__c = isSMS;
                        tempCon.Call__c = isCall;
                        tempCon.Email__c = isEmail;
                        tempCon.Fax__c = isFax;
                        update tempCon;
                    }
                    
                    if(opp.size() == 0)
                    {
						//Code was modified for Oppty standardisation --> NSJ
						newopp = OpportunityService.newOpportunityObject(PersonId, account_Id, rtid,
																		branchCode, franchiseCode, 'PriceAlert');

                        
                        newopp.Name = thisContact[0].Name +' - '+Utility.getBatchConfiguration().get(branchCode).Branch_Name__c;
                        
                        lstOpportunity = Utility.checkOppExistsForTheContact(branchCode, PersonId);
                        if(lstOpportunity !=  null && lstOpportunity.size() > 0)
                        {
                            newopp.OwnerId = lstOpportunity[0].OwnerId;
                            TriggerExclusion.excludeTrigger('Opportunity', true);
                            //Last Consultant
                            insert newopp;
                            
                            Task tsk = new Task();
                            tsk = Utility.createTask(newopp.Id, newopp.OwnerId, System.Label.OppAssignment);
                            insert tsk;
                            
                            TriggerExclusion.excludeTrigger('Opportunity', false);
                            opp.add(newopp);
                        }
                        else
                        {
                            //Round Robbin
                            insert newopp;
                            opp.add(newopp);
                        }
                    }
                }
                
                if (opp.size()>0)
                {
                    prcAlrt = new price_alert__c ();
                    price_alert__c thisprcAlert = new price_alert__c(
                        Opportunity__c = opp[0].Id, 
                        PDPA__c = PDPAVal, 
                        Model__c = Model, 
                        Variant__c = Variant
                    );
                    
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                    
                    Database.update(thisprcAlert, dmlOpts);
                    insert thisprcAlert;
                    
                    prcAlrt.Id = thisprcAlert.Id;
                    
                    //Update Opportunity
                    Decimal oppScore = opp[0].Opportunity_Score__c;
                    
                    Integer oppoScore;
                    if(opp[0].PriceAlert__c != true)
                    {
                        if (oppScore != null)
                        {
                            oppoScore = oppScore.intValue() + 5;
                        }
                        else
                        {
                            oppoScore = 5;
                        }
                        opp[0].Opportunity_Score__c = oppoScore;
                    }
                    
                    opp[0].PriceAlert__c = true;
                    
                    if(opp[0].Opportunity_Score__c <= 25)
                    {
                        opp[0].Rating__c = 'Cold';
                    }
                    else if(opp[0].Opportunity_Score__c >=26 && opp[0].Opportunity_Score__c <=60)
                    {
                        opp[0].Rating__c = 'Warm';
                    }
                    else if(opp[0].Opportunity_Score__c > 60)
                    {
                        opp[0].Rating__c = 'Hot';
                    }
                    update opp;
                    processFurther(opp);
                }
                
                ReturnObj = prcAlrt;
                res.statusCode = 200;      
                RestContext.response = res;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.Serialize(ReturnObj));
            }
            catch (Exception e)
            { 
                res.statusCode=400;
                errorResponse = new Utility.httpErrorResponse('Failed', e.getmessage());   
                loggerDataPool.buildLogDataPool('priceAlerts', e);  
                if(errorResponse != null)
                {
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
                }    
            }    
        }
        else
        {
            Errormsg='Required fields not supplied. Fields: LeadFName Or LeadLName Or LeadPhone';
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 400;
            errorResponse  = new Utility.httpErrorResponse('Failed', Errormsg);
            if(errorResponse != null)
            {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
            }
        }    
        serviceDataPool.buildServiceDataPool('priceAlerts', 'priceAlerts', '', req, res);
    }
    
    public static void processFurther(List<Opportunity> listOpp)
    {
        Opportunity oppToProcess = [ SELECT Id, Name, Contact_Person__c, Lead__c, Account__c, StageName, Branch_Code__c, Franchise_Code__c, 
                                        Model_c__c, TotalOpportunityQuantity, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                                        (SELECT Id, Model__c, Touch_Points__c FROM Models_Interested__r) 
                                     FROM Opportunity 
                                     WHERE id = :listOpp[0].Id ];
        createSharing(oppToProcess);
        createModelInterest(oppToProcess);
    }
    
    public static void createSharing(Opportunity oppToShare)
    {
        List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>();

        if(oppToShare.Account__c != null)
        {
            Contact personAccountContact = [Select id from Contact where AccountId =: oppToShare.Account__c];
            lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', personAccountContact.Id, oppToShare.OwnerId));
        }
        else if(oppToShare.Contact_Person__c != null)
        {
            lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', oppToShare.Contact_Person__c, oppToShare.OwnerId));
        }
        sharingHelper.creatShare(lstToCreateShare); 
    }
    
    public static void createModelInterest(Opportunity opp)
    {
		//Code was modified for Oppty standardisation --> NSJ
		Models_Interested__c modInt = new Models_Interested__c();
		modInt = ModelsInterestedService.newModelInterestedObject(opp.id, modelId, 'Online', 'Price Alert');

		insert modInt;


    }
}


/*
    /services/apexrest/priceAlerts/v1/*

    {
        "PersonId": "0035D00001JV8EcQAL",
        "Type": "Contact",
        "PDPAText": "PriceAlert",
        "Model": "a0r5D00000323CKQAY",
        "Variant": "a0z5D000000lt2YQAQ"
    }

*/
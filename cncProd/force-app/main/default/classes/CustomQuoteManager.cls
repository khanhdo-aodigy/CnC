/** *****
 * Class Name: CustomQuoteManager
 * Description : Apex class to Insert Custom Quote
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20180914            Cycle & Carriage              Created Initial Version.
 * 20200910            Khanh Do                      Added PA Migration Changes
 * 20210715            Khanh Do                      Added Person Account Profiling creation
 * 
** *****/ 
@RestResource(urlMapping='/CustomQuote/v1/*')
global class CustomQuoteManager 
{
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Utility.httpErrorResponse errorResponse;
    private static Utility.httpSuccessResponse successResponse;
    private static map<String, Object> mapJSONBody = new map<String, Object>();

    private final static String CONST_PA_PROFILING_CCS = 'CCS_Person_Account_Profiling_RT';
    
    @HttpPost
    global static void CustomQuoteManager()
    {
        
        System.debug('_______'+req.requestBody.toString());
        mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        res.addHeader('Content-Type', 'application/json');
        String modelid = (String)mapJSONBody.get('modelid');
        String variantid = (String)mapJSONBody.get('variantid');
        String firstname = (String)mapJSONBody.get('firstname');
        String lastname = (String)mapJSONBody.get('lastname');
        String email = (String)mapJSONBody.get('email');
        String MobilePhone = (String)mapJSONBody.get('MobilePhone');
        String tradeinregnumber = (String)mapJSONBody.get('tradeinregnumber');
        String lastfournric = (String)mapJSONBody.get('lastfournric');
        Boolean istestdrive = (Boolean)mapJSONBody.get('istestdrive');
        Boolean isreceivepromotion = (Boolean)mapJSONBody.get('isreceivepromotion');
        Boolean isTradeIn = (Boolean)mapJSONBody.get('isTradeIn');
        String additionaltext = (String)mapJSONBody.get('additionaltext');
        Map<String,Object> itemlist = (Map<String,Object>)mapJSONBody.get('itemlist');
        Map<String,Object> inneritemlist = (Map<String,Object>)mapJSONBody.get('inneritemlist');
        String imageURL = (String)mapJSONBody.get('imageURL');
        /* Custom Quote Enhancement */
        String trimId = (String)mapJSONBody.get('trimid');
        String colorId = (String)mapJSONBody.get('colorid');
        String tradeInModel = (String)mapJSONBody.get('tradeinModel');
        String tradeInBrand = (String)mapJSONBody.get('tradeinBrand');
        String tradeInMileage = (String)mapJSONBody.get('tradeinMileage');
        Decimal loanAmount = (Decimal)mapJSONBody.get('loanAmount');
        Decimal loanInterest = (Decimal)mapJSONBody.get('loanInterest');
        Integer loanTerm = (Integer)mapJSONBody.get('loanTerm');
		String bankName = (String)mapJSONBody.get('bankName');
		Decimal monthlyInstallment = (Decimal)mapJSONBody.get('monthlyInstallment');
        /** END */
        system.debug('_____________'+mapJSONBody);
        Map<String, String> responseMap =   new Map<String, String>();
        Map<String, String> ErrorResponseMap =   new Map<String, String>();
        String Errormsg;
        Account [] personAcc = new list <Account>(); // PA MIGRATION
        Contact[] contact = new List <contact>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        Opportunity[] opp = new List <Opportunity>();
        Opportunity newopp; 
        Opportunity[] oppt = new List <Opportunity>();
        Variant__c variant;
        Model__c model;
        Date today = Date.today();
        Date oppCloseDate = today.addDays(30);
        Models_Interested__c[] modIntList = new List<Models_Interested__c>();
        Models_Interested__c modInt;
        Custom_Quote__c customQuote;
        String customQuoteID;
        String relatedCustomQuoteID;
        Custom_Quote__c[] relatedCustomQuote = new List<Custom_Quote__c>();
        String ContactId = null;
        String AccountId = null; 
        Integer customizedQuote = 0;
        Integer priceValue;
        Integer innerpriceValue = 0;
        String substr;
        String value;
        Integer BasePrice=0;
        String Owner;
        String PDPAVal='';
        Boolean isSMS, isCall, isEmail;
        String  BranchCode='';
        List<Related_Custom_Quotes_List__c> relatedCustomQuotes = new List<Related_Custom_Quotes_List__c>();
        List<Related_Custom_Quotes_SubList__c> relatedCustomQuoteSubItemsList = new List<Related_Custom_Quotes_SubList__c>();
        String oppName = '';
        
        if( String.isNotBlank( modelid ) && String.isNotBlank( variantid ) )
        {			
            try
            {
                model = [SELECT Branch_Code__c, Franchise_Code__c FROM Model__c WHERE Id =:modelid];
                BranchCode = model.Branch_Code__c;
                
                variant = [SELECT Listed_price__c FROM Variant__c WHERE Id =:variantid];
                BasePrice = Integer.valueOf(variant.Listed_price__c);
                
                if (isreceivepromotion == true) {
                    PDPAVal = 'Email;SMS;Call';
                    isSMS = true;
                    isCall = true;
                    isEmail = true;
                } 

                //CHECK IF THIS CONTACT EXIST CUSTOMER, BY EMAIL
                List<Contact> lstCustomerContact = ContactService.getCustomerContactsByEmail( email );
                if( lstCustomerContact <> null && !lstCustomerContact.isEmpty() )
                {
                    contact = lstCustomerContact;
                }
                else
                {
                    //CHECK IF THIS CONTACT IS PROSPECT, BY EMAIL
                    contact = ContactService.getProspectContactsByEmail( email );
                }
                System.debug('@@@@DEBUG CustomQuoteManager :: contact = ' + contact );

                //CREATE PA(PROSPECT) IF THIS CONTACT NOT FOUND AT ALL 
                if( contact.size() > 0 ) 
                {   
                    AccountId          = contact[0].AccountId;
                    ContactId          = contact[0].Id;
                    oppName            = contact[0].Name;

                    Contact tempCon = new Contact( Id = contact[0].Id);
                    UpdatePDPA.updatePDPA(tempCon, isSMS, isCall, isEmail);
                    update tempCon;
                }
                else 
                {
                    id idPA_prospect = AccountUtil.getProspectRecordTypeId();
                    Account new_prospect = new Account();
                    new_prospect.FirstName    = firstname;
                    new_prospect.LastName     = lastname;
                    new_prospect.Phone        = MobilePhone;
                    new_prospect.PersonEmail  = email;
                    new_prospect.RecordTypeId = idPA_prospect;
                    //new_prospect.PDPA__pc     = PDPAVal;
                    UpdatePDPA.updatePDPA(new_prospect, isSMS, isCall, isEmail);
                    new_prospect.PersonLeadSource = 'Custom Quote';
                    
                    new_prospect = AccountUtil.createProspect( new_prospect );

                    AccountId   = new_prospect.Id;

                    contact = ContactService.getProspectContactsByAccountId( accountId );
                    if( contact <> null && !contact.isEmpty() ){
                        ContactId = contact.get(0).Id;
                        oppName   = contact[0].Name;
                    }
                    
                    System.debug('testing ---- new Prospect ---- ' + new_prospect + ' --- ' + new_prospect.PersonContactId );
                }

                if(String.isNotBlank(accountId) ) {
                    AccountUtil.createProfiling(CONST_PA_PROFILING_CCS, new Account(Id=accountId));
                }
                

                if( String.isNotBlank( ContactId ) )
                {					   
					//Code was modified for Oppty standardisation --> NSJ
					lstOpportunity = OpportunityService.activeOpportunityList(BranchCode, ContactId );

                    if(lstOpportunity != null && lstOpportunity.size() > 0)
                    {
                        //Open Opportunity Exists
                        opp = lstOpportunity;
                    }
                    oppt = OpportunityService.activeOpportunityList(BranchCode, ContactId);
                }   

                if(opp.size() >0)
                {
                    relatedCustomQuote = [SELECT Id FROM Custom_Quote__c WHERE Opportunity__c =: opp[0].Id];
                    Owner = opp[0].OwnerID;
                    
                    if(relatedCustomQuote.isEmpty())
                    {
                        Decimal oppScore = opp[0].Opportunity_Score__c;
                        
                        if (oppScore != null)
                        {
                            oppScore = oppScore.intValue() + 5;                    
                        }
                        else
                        {
                            oppScore = 5;
                        }
                        
                        opp[0].Opportunity_Score__c = oppScore;
                        opp[0].Custom_Quote__c = true;
                        
                        if(opp[0].Opportunity_Score__c <= 25)
                        {
                            opp[0].Rating__c = 'Cold';
                        }
                        else if(opp[0].Opportunity_Score__c >=26 && opp[0].Opportunity_Score__c <=60)
                        {
                            opp[0].Rating__c = 'Warm';
                        }
                        else if(opp[0].Opportunity_Score__c > 61)
                        {
                            opp[0].Rating__c = 'Hot';
                        }
                        
                        update opp;
                    }
                }
                else
                {

					//Code was modified for Oppty standardisation --> NSJ
					// Opportunity Record Type
                    Id rtid = OpportunityService.getStrRecordTypeAssignment(model.Branch_Code__c);
					newopp = OpportunityService.newOpportunityObject(ContactId, AccountId, rtid,
																	model.Branch_Code__c, model.Franchise_Code__c,'Custom Quote');
                    
                    newopp.Name = oppName +' - ' +Utility.getBatchConfiguration().get(model.Branch_Code__c).Branch_Name__c;
                    
                    if(ContactId != null && oppt.size() > 0 && oppt[0].Owner.IsActive)
                    {
                        newopp.OwnerId = oppt[0].OwnerId;
                    }                    

                    insert newopp;
                    Task tsk = new Task();
                    tsk = Utility.createTask(newopp.Id, newopp.OwnerId, System.Label.OppAssignment);
                    insert tsk;
                    
                    newopp = [ SELECT Id, OwnerId, AccountId, Account__c, Opportunity_Score__c, Rating__c, Custom_Quote__c, Contact_Person__c
                               FROM Opportunity
                               WHERE Id =:newopp.Id
                               LIMIT 1]; 
                    List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>();
                    
                    if(ContactId != null)
                    {
                        lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', newopp.Contact_Person__c, newopp.OwnerId));
                        sharingHelper.creatShare(lstToCreateShare);
                    }

                    Owner = newopp.OwnerId;
                    opp.add(newopp);
                }
                
                if(opp.size()>0)
                {
					
					//Code was modified for Oppty standardisation --> NSJ
					modInt = ModelsInterestedService.newModelInterestedObject(opp[0].Id, modelid, 'Online', 'Custom Quote');
                    insert modInt;
                    
                    customQuote = new Custom_Quote__c(First_Name__c = firstname,
                                                      Last_Name__c = lastname,
                                                      Email__c= email,
                                                      Mobile__c = MobilePhone,
                                                      Last_4_digits_of_NRIC_FIN_Passport_n__c = lastfournric,
                                                      Vehicle_registration_number__c = tradeinregnumber,
                                                      Model__c = modelid,
                                                      Variant__c = variantid,
                                                      Is_Receive_Promotion__c = isreceivepromotion,
                                                      Base_Price__c = variant.Listed_price__c,
                                                      Is_Test_Drive__c = istestdrive,
                                                      Opportunity__c = opp[0].Id,
                                                      Contact__c = ContactId,
                                                      Account__c = AccountId,
                                                      ImageURL__c = imageURL,
                                                      additionaltext__c = additionaltext,
                                                      PDPA__c = PDPAVal,
                                                      Vehicle_Brand__c = tradeInBrand,
                                                      Vehicle_Model__c = tradeInModel,
                                                      Mileage__c = tradeInMileage,
                                                      Loan_Amount__c = loanAmount,
                                                      Loan_Interest__c = loanInterest,
                                                      Loan_Term__c = loanTerm,
													  Bank_Name__c = bankName,
													  Monthly_Installment__c = monthlyInstallment );

					if(trimId != '')
					{
                        customQuote.Trim__c = trimId;
					}
					if(colorId != '')
					{
						customQuote.Color__c = colorId;
					}

                    insert customQuote;
                    customQuoteID = customQuote.Id;
                    
                    if(opp[0].Custom_Quote__c != true)
                    {
                        Decimal oppScore = opp[0].Opportunity_Score__c;
                        if (oppScore != null)
                        {
                            oppScore = oppScore.intValue() + 5;                    
                        }
                        else
                        {
                            oppScore = 5;
                        }
                        
                        opp[0].Opportunity_Score__c = oppScore;
                        opp[0].Custom_Quote__c = true;
                        
                        if(opp[0].Opportunity_Score__c <= 25)
                        {
                            opp[0].Rating__c = 'Cold';
                        }
                        else if(opp[0].Opportunity_Score__c >=26 && opp[0].Opportunity_Score__c <=60)
                        {
                            opp[0].Rating__c = 'Warm';
                        }
                        else if(opp[0].Opportunity_Score__c > 61)
                        {
                            opp[0].Rating__c = 'Hot';
                        }
                        
                        update opp;
                    }
                    
                    if(itemlist!=null && itemlist.size()>0)
                    {
                        for(String items :itemlist.keyset())
                        {
                            value = String.valueOf(itemlist.get(items));
                            priceValue = Integer.valueOf(itemlist.get(items));
                            substr = FormatString(priceValue.format()); 
                            Related_Custom_Quotes_List__c relatedCustomQuoteDetails = new Related_Custom_Quotes_List__c();
                            relatedCustomQuoteDetails.Name = items;
                            relatedCustomQuoteDetails.Price__c = substr;
                            relatedCustomQuoteDetails.Custom_Quote__c = customQuoteID;
                            customizedQuote += priceValue;
                            insert relatedCustomQuoteDetails;
                            
                            if(inneritemlist.size()>0 || inneritemlist!=null)
                            {
                                for(String inneritems :inneritemlist.keyset())
                                {
                                    value = String.valueOf(inneritemlist.get(inneritems));
                                    if(inneritems !=null)
                                    {
                                        innerpriceValue = Integer.valueOf(inneritemlist.get(inneritems)); 
                                    }
                                    substr = FormatString(innerpriceValue.format());
                                    Related_Custom_Quotes_SubList__c relatedCustomQuoteSubDetails = new Related_Custom_Quotes_SubList__c(); 
                                    
                                    if(inneritems.containsIgnoreCase(items))
                                    {
                                        relatedCustomQuoteSubDetails.Name = inneritems.substringAfter('*');
                                        relatedCustomQuoteSubDetails.Price__c = substr;
                                        relatedCustomQuoteSubDetails.Related_Custom_Quotes_List__c = relatedCustomQuoteDetails.Id;
                                        relatedCustomQuoteSubItemsList.add(relatedCustomQuoteSubDetails);
                                        customizedQuote += innerpriceValue; 
                                    }
                                    
                                }
                            }  
                            
                            if(items.containsIgnoreCase('Finance') && items.containsIgnoreCase('Subsidy'))
                            {
                                Task financingTask = new Task();
                                if(opp[0].OwnerId != null){financingTask.OwnerId = opp[0].OwnerId;}
                                financingTask.Status = 'Open';
                                financingTask.Subject = 'Interested in financing';
                                financingTask.WhatId = customQuoteID;
                                insert financingTask;
                            }
                        }
                        insert relatedCustomQuoteSubItemsList;
                    }
                    
                    
                    if(customizedQuote !=null)
                    {
						customQuote.Customized_quote__c = customQuote.Base_Price__c;
                        if(customizedQuote > 0)
						{
							customQuote.Customized_quote__c = customizedQuote;
                        }

						if(opp[0].OwnerId != null)
                        {	
                            customQuote.OwnerId = opp[0].OwnerId;
                        }
                        update customQuote;
                    }
                    if(isTradeIn == true)
                    {
                        Task customQuoteTask = new Task();
                        if(opp[0].OwnerId != null)
                        {
                            customQuoteTask.OwnerId = opp[0].OwnerId;
                        }
                        customQuoteTask.Status  = 'Open';
                        customQuoteTask.Subject = 'Trade-in Quote';
                        customQuoteTask.WhatId  = customQuote.Id;
                        insert customQuoteTask;
                    }
                }
                
                responseMap.put('Status', 'Success');
                res.statusCode = 200;      
                RestContext.response = res;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.Serialize(responseMap));
            }
            catch (Exception e)
            {                          
                String msg = e.getMessage();
                loggerDataPool.buildLogDataPool('Custom Quote Manager', e);
                errorResponse = new Utility.httpErrorResponse('Failed', msg);
                res.statusCode=400;       
                if(errorResponse != null)
                {
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
                }
            }
            
        }
        else
        {
            
            RestRequest req = RestContext.request;
            Errormsg ='Model/Variant is not supplied.';
            res.statusCode=400;
            ErrorResponseMap.put('ErrorCode', 'Err02-SF');
            ErrorResponseMap.put('Message', Errormsg);
            RestContext.response = res;
            res.addHeader('Content-Type', 'application/json');
            errorResponse = new Utility.httpErrorResponse('Failed', Errormsg);
            if(errorResponse != null)
            {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
            }
        }   
        
        serviceDataPool.buildServiceDataPool('Custom Quote Manager', 'CustomQuoteManager', '', req, res);
    }
    
    public static String FormatString(String str)
    {
        String formatString;
        Integer pos;
        if(str.contains('-'))
        {
            pos =str.indexOf('-');
            formatString= str.substring(pos+1);
            formatString ='-$'+formatString; 
        }
        else if(str.contains('+'))
        {
            pos =str.indexOf('+');
            formatString= str.substring(pos+1);
            formatString ='+$'+formatString;
        }
        else
        {
            formatString ='$'+str; 
        }
        return formatString;
    }
}

/*
    /services/apexrest/CustomQuote/v1/*

    {
        "modelid": "a0r5D00000323BsQAI",
        "variantid": "a0z5D000000lt0ZQAQ",
        "firstname": "Quote-1",
        "lastname": "Test",
        "email": "testQuote1@mailinator.com",
        "MobilePhone": "651100990022",
        "tradeinregnumber": "",
        "lastfournric": "",
        "istestdrive": true,
        "isreceivepromotion": true,
        "itemlist": {
            "L MODEL Base Price": "82999",
            "Cerato Promo": "320",
            "Cerato Road Show": "380",
            "Trade in Subsidy": "-5000"
        },
        "inneritemlist": {
            
        },
        "additionaltext": "Cerato Include Text Goes Here , Text 2 At Model , Text 3 At Model,VES Surcharge/Rebate , $220 registration fee , 6-months' road tax (with ERP rebate) , IU installation , 7% GST,Promo Include Text , Promo Include Text 2,Registration fee ($220)",
        "isTradeIn": true,
        "imageURL": "https://qa.cyclecarriage.com/sg/-/media/jccl/sites/kia/variant-comparison/cerato/variantcom-web-ceratol-1680x760.png?modifiedDate=20180914T013644Z&h=540&w=960&as=1&iar=1&hash=24B999BB15BA77E64E10A3B83B6E5C8ED2343A51"
    }

*/
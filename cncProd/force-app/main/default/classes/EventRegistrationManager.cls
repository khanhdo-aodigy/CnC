@RestResource(urlMapping='/EventRegistration/v1/*')
global class EventRegistrationManager 
{
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Utility.httpErrorResponse errorResponse;
    private static Utility.httpSuccessResponse successResponse;
    private static map<String, Object> mapJSONBody = new map<String, Object>();
    public static String modelId = ''; 
    
    @HttpPost
    global static void EventRegistrationManager()
    {   
        try
        {
            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
            String reqStr = req.requestBody.toString();
            reqStr = reqStr.replaceAll('\n',' ');
            reqStr = reqStr.replaceAll('\r',' ');
            reqStr = reqStr.replaceAll('\r\n',' ');
            mapJSONBody = (map<String, Object>)JSON.deserializeUntyped( reqStr );
            
            res.addHeader('Content-Type', 'application/json');
            Integer NumberOfGuests      = (Integer)mapJSONBody.get('NumberOfGuests');
            String FirstName            = (String)mapJSONBody.get('FirstName');
            String LastName             = (String)mapJSONBody.get('LastName');
            String MobilePhone          = (String)mapJSONBody.get('MobilePhone');
            String Email                = (String)mapJSONBody.get('Email');
            String EventID              = (String)mapJSONBody.get('EventID');
            String ModelID              = (String)mapJSONBody.get('ModelID');
            String LeadId               = (String)mapJSONBody.get('LeadId');
            String TimeSlot             = (String)mapJSONBody.get('TimeSlot');
            String PDPA                 = (String)mapJSONBody.get('PDPA');
            String ContactId            = (String)mapJSONBody.get('ContactId');
            String EventDate            = (String)mapJSONBody.get('EventDate');
            String EventStatus          = (String)mapJSONBody.get('EventStatus');
            String Location             = (String)mapJSONBody.get('Location');
            String Dynamic_Field_Label1 = (String)mapJSONBody.get('Dynamic_Field_Label1');
            String Dynamic_Field_Label2 = (String)mapJSONBody.get('Dynamic_Field_Label2');
            String Dynamic_Field_Label3 = (String)mapJSONBody.get('Dynamic_Field_Label3');
            String Dynamic_Field_Label4 = (String)mapJSONBody.get('Dynamic_Field_Label4');
            String Dynamic_Field_Label5 = (String)mapJSONBody.get('Dynamic_Field_Label5');
            String Dynamic_Field_Label6 = (String)mapJSONBody.get('Dynamic_Field_Label6');
            String Dynamic_Field_Label7 = (String)mapJSONBody.get('Dynamic_Field_Label7');
            String Dynamic_Field_Label8 = (String)mapJSONBody.get('Dynamic_Field_Label8');
            String Dynamic_Field_Label9 = (String)mapJSONBody.get('Dynamic_Field_Label9');
            String Remarks              = (String)mapJSONBody.get('Remarks');
            String Dynamic_Field_Value1 = (String)mapJSONBody.get('Dynamic_Field_Value1');
            String Dynamic_Field_Value2 = (String)mapJSONBody.get('Dynamic_Field_Value2');
            String Dynamic_Field_Value3 = (String)mapJSONBody.get('Dynamic_Field_Value3');
            String Dynamic_Field_Value4 = (String)mapJSONBody.get('Dynamic_Field_Value4');
            String Dynamic_Field_Value5 = (String)mapJSONBody.get('Dynamic_Field_Value5');
            String Dynamic_Field_Value6 = (String)mapJSONBody.get('Dynamic_Field_Value6');
            String Dynamic_Field_Value7 = (String)mapJSONBody.get('Dynamic_Field_Value7');
            String Dynamic_Field_Value8 = (String)mapJSONBody.get('Dynamic_Field_Value8');
            String Dynamic_Field_Value9 = (String)mapJSONBody.get('Dynamic_Field_Value9');
            String Preffered_Time       = (String)mapJSONBody.get('Preffered_Time');
            String Preffered_Date       = (String)mapJSONBody.get('Preffered_Date');
            String DateRange            = (String)mapJSONBody.get('DateRange');
            String ImageURL             = (String)mapJSONBody.get('ImageURL');
            String LocationName         = (String)mapJSONBody.get('LocationName');
            String TemplateName         = (String)mapJSONBody.get('TemplateName');
            String PaymentId;

            if(mapJSONBody.ContainsKey('PaymentId'))
            {
                PaymentId= (String)mapJSONBody.get('PaymentId');
            }

            Boolean Waitlist = false;
            if(mapJSONBody.ContainsKey('WaitList'))
            {
                Waitlist = (Boolean)mapJSONBody.get('WaitList');
            }
            
            Boolean IsSuccess = false;
            Boolean IsSuccessForContact = false;
            Boolean IsSuccessForUser = false;
            Boolean isTCAccepted = false; 
            String ErrorCode;
            String Errormsg;
            String jsonS;
            Date today = Date.today();
            Date oppCloseDate = today.addDays(30);  
            Map<String, String> responseMap =   new Map<String, String>();
            Map<String, String> ErrorResponseMap =   new Map<String, String>();
            List<Opportunity> lstOpportunity = new List<Opportunity>();
            List<Opportunity> opp = new List<Opportunity>();
            Opportunity newOpp = new Opportunity();
            Contact [] thisContact = new List <Contact>();
            Campaign [] thisCampaign = new List <campaign>();
            String PDPAText;
            Boolean isSMS = false, isCall = false, isEmail = false, isFax = false;
            String Model;
            Boolean intModelEx = false;
            List<Campaign> cmpInfo = new List<Campaign>();
            List<Model__c> BranchCodeLstMd = new List<Model__c>();
            String BranchCode = '';
            String franchiseCode = '';
            ID rtid;
            Set<String> SetOppStage = new Set<String>();
            Task tsk = new Task();
            List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>(); 
            if (String.isBlank(ModelID))
            {
                Model ='';
            }
            else 
            {
                Model = ModelID;  
            }

            if(String.isNotBlank(PDPA) && PDPA.trim()=='on') 
            {
                PDPAText = 'Email;SMS;Call';
                isSMS = true;
                isCall = true;
                isEmail = true;
                isFax = true;
                isTCAccepted  = true;
            }
            
            try
            { 
                if( String.isNotBlank(EventID) && ((LeadId != null && LeadId.trim() != '') || (ContactId != null && ContactId.trim() != ''))) 
                {
                    cmpInfo = [SELECT Id, Do_Not_Create_Oppty_Contact__c, Do_Not_Create_Oppty_Lead__c, OwnerId, Branch_Code__c 
                               FROM Campaign 
                               WHERE Id =: EventID];
                    
                    if(Model.trim()!='')
                    {
                        BranchCodeLstMd = [SELECT Id, Branch_Code__c, Franchise_Code__c FROM Model__c WHERE Id =:ModelID];
                        
                        if(BranchCodeLstMd.size()>0)
                        {
                            EventRegistrationManager.modelId = BranchCodeLstMd[0].Id;
                            BranchCode  = BranchCodeLstMd[0].Branch_Code__c;
                            franchiseCode = BranchCodeLstMd[0].Franchise_Code__c;
                        }
                    }
                    else
                    {
                        if(cmpInfo.size()>0 && String.isNotBlank(cmpInfo[0].Branch_Code__c))
                        {
                            BranchCode = cmpInfo[0].Branch_Code__c;                            
                        } 
                    }

					//Code was modified for Oppty standardisation --> NSJ
					rtid = OpportunityService.getStrRecordTypeAssignment(BranchCode);
                    
                    Event_Registration__c TempEvent_Registration = new Event_Registration__c();
                    
                    if (ContactId != null && ContactId.trim() != '' &&  BranchCode.trim() != '')
                    {
                        thisContact = [SELECT Id, name, OwnerId, Account__c, Account__r.Id, AccountId, IsPersonAccount, Account.RecordTypeId,
                                              SMS__c, Call__c, Email__c, Fax__c
                                       FROM Contact 
                                       WHERE Id =:ContactId];
                        
                        String accountId = null;
                        
                        if(!thiscontact.isEmpty())
                        {
                            accountId = thisContact[0].AccountId;
                            
                            Contact tempContact = new Contact( Id = thisContact[0].Id );
                            UpdatePDPA.updatePDPA( tempContact, PDPAText );

                            update tempContact;
                        }

                        Boolean isCustomer = AccountUtil.isCustomer( thisContact.get(0).Account.RecordTypeId, null);
                        System.debug('Line 175 >>>>>>>>>>>>>> ' + isCustomer);
                        Boolean isProspect = AccountUtil.isProspect( thisContact.get(0).Account.RecordTypeId, null);
                        
                        //if(cmpInfo.size()>0 && cmpInfo[0].Do_Not_Create_Oppty_Contact__c == false )
                        if( (cmpInfo.size()>0 && cmpInfo[0].Do_Not_Create_Oppty_Contact__c == false && isCustomer) ||
                                (cmpInfo.size()>0 && cmpInfo[0].Do_Not_Create_Oppty_Lead__c == false && isProspect) )
                        {    
							//Code was modified for Oppty standardisation --> NSJ
							lstOpportunity = OpportunityService.activeOpportunityList(BranchCode, ContactId);

                            if(lstOpportunity != null && lstOpportunity.size() > 0)
                            {
                                opp = lstOpportunity;
                            }
                            if(opp.size() <= 0)
                            {                                
                                if( isCustomer )
                                {
									//Code was modified for Oppty standardisation --> NSJ
									lstOpportunity = OpportunityService.activeOpportunityList(BranchCode, ContactId);
                                    System.debug('Line 194 >>>>>>>>>>>>>>>>>>> ' + lstOpportunity + ' ' + BranchCode + ' ' + ContactId);
                                }
                                else if( isProspect )
                                {
									//Code was modified for Oppty standardisation --> NSJ
									lstOpportunity = OpportunityService.activeOpportunityList(BranchCode, ContactId);
                                }
                               
							    //Code was modified for Oppty standardisation --> NSJ
							    System.debug('Line 202 >>>>>>>>>>>>>>>>>>> ' + lstOpportunity);
								newopp = OpportunityService.newOpportunityObject(ContactId, accountId, rtid,
																				BranchCode, franchiseCode, 'Events');

								newOpp.Name = thisContact[0].Name +' - ' +Utility.getBatchConfiguration().get(BranchCode).Branch_Name__c;

                                if(lstOpportunity != null && lstOpportunity.size() > 0)
                                {
                                    newOpp.OwnerId      = lstOpportunity[0].OwnerId;
                                }

                                insert newopp;
                                opp.add(newopp); 
                            }  
                        }
                        
                        TempEvent_Registration.ContactId__c = ContactId;
                        TempEvent_Registration.Account__c   = accountId;

                        try
                        {
                            CampaignMember TempCM = new CampaignMember();
                            TempCM.CampaignId = EventID;
                            TempCM.ContactId  = ContactId; 
                            database.insert(TempCM,false);
                        }
                        catch(Exception e)
                        {
                            loggerDataPool.buildLogDataPool('Event Registration Manager - Campaign Member', e);
                            responseMap.put('Message', 'A system exception has occurred while adding Campaign member, Please contact your administrator.' +e.getMessage());
                            responseMap.put('ErrorCode', 'Err04-SF');
                            res.statusCode = 400;   
                            errorResponse = new Utility.httpErrorResponse('Failed', e.getMessage());
                            if(errorResponse != null)
                            {
                                res.statusCode = 400;
                                res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
                            }
                        }
                    }  
                   
                    TempEvent_Registration.FirstName__c = FirstName;
                    TempEvent_Registration.LastName__c = LastName;
                    TempEvent_Registration.Email__c = Email;
                    TempEvent_Registration.MobilePhone__c = MobilePhone;
                    
                    if ( String.isNotBlank( Model ) )
                    {
                        TempEvent_Registration.ModelCode__c = Model; 
                    } 
                    
                    TempEvent_Registration.PromoID__c = EventID;
                    
                    if(String.isNotBlank(EventDate))
                    {
                        TempEvent_Registration.Event_Date__c = Date.valueOf(EventDate);
                    }
                    
                    TempEvent_Registration.Event_Status__c   = EventStatus;
                    TempEvent_Registration.Location__c       = Location;
                    TempEvent_Registration.NumberOfGuests__c = NumberOfGuests;
                    TempEvent_Registration.TimeSlot__c       = TimeSlot ;
                    TempEvent_Registration.PDPA__c           = PDPAText;
                    TempEvent_Registration.DateRange__c      = DateRange;
                    TempEvent_Registration.ImageURL__c       = ImageURL;
                    TempEvent_Registration.Location_Name__c  = LocationName;
                    TempEvent_Registration.TemplateName__c   = TemplateName;
                    
                    
                    if(String.isBlank(Preffered_Date) && String.isNotBlank(EventDate))
                    {
                        TempEvent_Registration.Preffered_Date__c = Date.valueOf(EventDate);
                    }
                    else if(String.isNotBlank(Preffered_Date))
                    {
                        TempEvent_Registration.Preffered_Date__c = Date.valueOf(Preffered_Date);
                    }
                    
                    TempEvent_Registration.Dynamic_Field_Label_1__c = Dynamic_Field_Label1;
                    TempEvent_Registration.Dynamic_Field_Label_2__c = Dynamic_Field_Label2;
                    TempEvent_Registration.Dynamic_Field_Label_3__c = Dynamic_Field_Label3;
                    TempEvent_Registration.Dynamic_Field_Label_4__c = Dynamic_Field_Label4;
                    TempEvent_Registration.Dynamic_Field_Label_5__c = Dynamic_Field_Label5;
                    TempEvent_Registration.Dynamic_Field_Label_6__c = Dynamic_Field_Label6;
                    TempEvent_Registration.Dynamic_Field_Label_7__c = Dynamic_Field_Label7;
                    TempEvent_Registration.Dynamic_Field_Label_8__c = Dynamic_Field_Label8;
                    TempEvent_Registration.Dynamic_Field_Label_9__c = Dynamic_Field_Label9;
                    TempEvent_Registration.Remarks__c               = Remarks;
                    TempEvent_Registration.Dynamic_Field_Value_1__c = Dynamic_Field_Value1;
                    TempEvent_Registration.Dynamic_Field_Value_2__c = Dynamic_Field_Value2;
                    TempEvent_Registration.Dynamic_Field_Value_3__c = Dynamic_Field_Value3;
                    TempEvent_Registration.Dynamic_Field_Value_4__c = Dynamic_Field_Value4;
                    TempEvent_Registration.Dynamic_Field_Value_5__c = Dynamic_Field_Value5;
                    TempEvent_Registration.Dynamic_Field_Value_6__c = Dynamic_Field_Value6;
                    TempEvent_Registration.Dynamic_Field_Value_7__c = Dynamic_Field_Value7;
                    TempEvent_Registration.Dynamic_Field_Value_8__c = Dynamic_Field_Value8;
                    TempEvent_Registration.Dynamic_Field_Value_9__c = Dynamic_Field_Value9;
                    
                    
                    if(String.isBlank(Preffered_Time) && String.isNotBlank(TimeSlot))
                    {
                        TempEvent_Registration.Preffered_Time__c = TimeSlot;
                    }
                    else if(String.isNotBlank(Preffered_Time))
                    {
                        TempEvent_Registration.Preffered_Time__c = Preffered_Time;
                    }
                    
                    TempEvent_Registration.Payment__c = PaymentId;
                    TempEvent_Registration.Waitlist__c = Waitlist; 
                    
                    
                    if(isTCAccepted)
                    {
                        TempEvent_Registration.TCAccepted__c  = true;
                    }
                    
                    
                    if(opp.size()>0)
                    {
                        TempEvent_Registration.Opportunity__c = opp[0].Id;                         
                        
                        Decimal oppScore = opp[0].Opportunity_Score__c;
                        
                        Integer oppoScore;
                        if(opp[0].EventRegistration__c!=true)
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
                        opp[0].EventRegistration__c = true;
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
                        
                        
                        Database.DMLOptions dmlOptions = new Database.DMLOptions();
                        dmlOptions.assignmentRuleHeader.useDefaultRule = true;
                        Database.update(opp, dmlOptions);
                        update opp;  
                        opportunity oppBack = [SELECT Id, OwnerId FROM Opportunity WHERE Id=: opp[0].Id LIMIT 1];
                        TempEvent_Registration.OwnerId = oppBack.OwnerId;
                        processFurther(opp);
                        
                    }
                    else
                    {
                        TempEvent_Registration.OwnerId = (cmpInfo.size()>0) ? cmpInfo[0].OwnerId : (String)JCC_GlobalVar.Default_Owner_C_C__c ;
                    }                  
                    
                    try
                    {
                        insert TempEvent_Registration;
                    }
                    catch(Exception e)
                    {
                        loggerDataPool.buildLogDataPool('Event Registration Manager', e);
                        res.statusCode = 400; 
                        errorResponse = new Utility.httpErrorResponse('Failed', e.getMessage());
                        if(errorResponse != null)
                        {
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
                        } 
                        serviceDataPool.buildServiceDataPool('Event Registration Manager', 'EventRegistrationManager', '', req, res);
                    }                    
                    
                    try
                    {                       
                        if(String.isNotBlank(PaymentId) && String.isNotBlank(EventID)) 
                        {
                            String conVal     = String.isBlank(ContactId) ? null : ContactId;
                            String leadVal    = String.isBlank(LeadId) ? null : LeadId;
                            String nric       = '';
                            Double amtWithGST = 0;
                            String vehRegNum  = '';
                            List<Invoice__c> paymentRec = new List<Invoice__c>();
                            paymentRec = [SELECT Id, Amount_With_GST__c, Net_Amount__c 
                                          FROM Invoice__c 
                                          WHERE Id=:PaymentId LIMIT 1];
                            
                            
                            if( String.isNotBlank(Dynamic_Field_Label1) && Dynamic_Field_Label1 == 'VehicleRegistrationNumber' && String.isNotBlank(Dynamic_Field_Value1) )
                            {
                                vehRegNum = Dynamic_Field_Value1;
                            }
                            
                            if( String.isNotBlank(Dynamic_Field_Label2) && Dynamic_Field_Label2 == 'VehicleRegistrationNumber' && String.isNotBlank(Dynamic_Field_Value2) )
                            {
                                vehRegNum = Dynamic_Field_Value2;
                            }
                            
                            if( String.isNotBlank(Dynamic_Field_Label3) && Dynamic_Field_Label3 == 'VehicleRegistrationNumber' && String.isNotBlank(Dynamic_Field_Value3) )
                            {
                                vehRegNum = Dynamic_Field_Value3;
                            }
                            
                            if( String.isNotBlank(Dynamic_Field_Label4) && Dynamic_Field_Label4 == 'VehicleRegistrationNumber' && String.isNotBlank(Dynamic_Field_Value4) )
                            {
                                vehRegNum = Dynamic_Field_Value4;
                            }
                            
                            if( String.isNotBlank(Dynamic_Field_Label5) && Dynamic_Field_Label5 == 'VehicleRegistrationNumber' && String.isNotBlank(Dynamic_Field_Value5) )
                            {
                                vehRegNum = Dynamic_Field_Value5;
                            }
                            
                            if(paymentRec!=null && !paymentRec.isEmpty() && paymentRec.get(0).Net_Amount__c!=null)
                            {
                                amtWithGST = paymentRec.get(0).Net_Amount__c;
                            }
                            
                            String acctId = '';
                            if(String.isNotBlank(conVal))
                            {
                                Contact cn = [SELECT Id, NRIC__c, Account__c, Account__r.Id, AccountId, IsPersonAccount 
                                              FROM Contact 
                                              WHERE Id =: conVal
                                              LIMIT 1];
                                
                                nric = cn != null ? cn.NRIC__c : null;

                                acctId = cn.AccountId;
                            }
                            
                            Campaign cmp = [SELECT Id, Name 
                                            FROM Campaign 
                                            WHERE Id=: EventID LIMIT 1];
                            
                            Invoice__c pr  = new Invoice__c( Id = PaymentId, 
                                                             Amount_With_GST__c = amtWithGST, 
                                                             Vehicle_Registration_Number__c = vehRegNum, 
                                                             Campaign__c = EventID, 
                                                             Campaign_ID__c = EventID, 
                                                             Contact__c = conVal, 
                                                             Account__c = acctId,
                                                             NRIC__c = nric, 
                                                             Product_Item__c = cmp.Name,
                                                             Product_Item_Quantity__c = NumberOfGuests );
                            
                            TriggerExclusion.excludeTrigger('Payment', true);
                            Database.update(pr, false);
                            TriggerExclusion.excludeTrigger('Payment', false);
                        }
                    }
                    catch(Exception e)
                    {
                        loggerDataPool.buildLogDataPool('Event Registration', e);
                    }
                    res.statusCode = 200;
                    responseMap.put('Status', 'Success');
                    res.addHeader('Content-Type', 'application/json');
                    responseMap.put('RecordId', TempEvent_Registration.Id);
                    res.responseBody = Blob.valueOf(JSON.Serialize(responseMap));
                }
                else
                {
                    responseMap.put('Message', 'Mandatory field(s) are missing. Please refer API doc');
                    responseMap.put('ErrorCode', 'Err02-SF');
                    res.statusCode = 400;
                    res.addHeader('Content-Type', 'application/json');
                    errorResponse = new Utility.httpErrorResponse('Failed', 'Mandatory field(s) are missing. Please refer API doc');
                    if(errorResponse != null)
                    {
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
                    }
                }
            }
            catch (DmlException e)
            {   
                loggerDataPool.buildLogDataPool('Event Registration Manager', e);
                responseMap.put('Message', 'A system exception has occurred, Please contact your administrator.' +e.getMessage());
                responseMap.put('ErrorCode', 'Err04-SF');
                res.statusCode = 400; 
                errorResponse = new Utility.httpErrorResponse('Failed', e.getMessage());
                if(errorResponse != null)
                {
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
                }       
            }    
            res.addHeader('Content-Type', 'application/json');
            serviceDataPool.buildServiceDataPool('Event Registration Manager', 'EventRegistrationManager', '', req, res);
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('Event Registration Manager', e);
            res.statusCode = 400; 
            errorResponse = new Utility.httpErrorResponse('Failed', e.getMessage());
            if(errorResponse != null)
            {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
            } 
            serviceDataPool.buildServiceDataPool('Event Registration Manager', 'EventRegistrationManager', '', req, res);
        }
    }

    
    public static void processFurther(List<Opportunity> listOpp)
    {
        Opportunity oppToProcess = [SELECT Id, Name, Contact_Person__c, Account__c, Account__r.Id, StageName, Branch_Code__c, Franchise_Code__c, 
                                            Model_c__c, TotalOpportunityQuantity, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                                        (SELECT Id, Model__c, Touch_Points__c 
                                         FROM Models_Interested__r 
                                         ORDER BY CreatedDate DESC) 
                                    FROM Opportunity 
                                    WHERE Id = :listOpp[0].Id];
        createSharing(oppToProcess);
        createModelInterest(oppToProcess);
    }
    

    public static void createSharing(Opportunity oppToShare)
    {
        List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>();
        if(oppToShare.Contact_Person__c != null)
        {
            lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', oppToShare.Contact_Person__c, oppToShare.OwnerId));
        }
        sharingHelper.creatShare(lstToCreateShare);     
    }

    
    public static void createModelInterest(Opportunity opp)
    {
		Models_Interested__c modInt = new Models_Interested__c();
        //Code was modified for Oppty standardisation --> NSJ
		modInt = ModelsInterestedService.newModelInterestedObject(opp.id, modelId, 'Online', 'Event Registration');
        insert modInt;
    }
}


/*
    /services/apexrest/EventRegistration/v1/*

    {
        "NumberOfGuests": 0,
        "FirstName": "EvtGuest-1",
        "LastName": "Test",
        "MobilePhone": "787879999",
        "Email": "testEvtGuest1@mailinator.com",
        "EventID": "7015D000000SSgAQAW",
        "ModelID": "a0r5D00000323CUQAY",
        "LeadId": null,
        "TimeSlot": null,
        "PDPA": "on",
        "ContactId": "0035D00001JUy3zQAD",
        "EventDate": "2020-09-01",
        "EventStatus": "Registered",
        "Location": null,
        "Dynamic_Field_Label1": null,
        "Dynamic_Field_Label2": null,
        "Dynamic_Field_Label3": null,
        "Dynamic_Field_Label4": null,
        "Dynamic_Field_Label5": null,
        "Remarks": null,
        "Dynamic_Field_Value1": null,
        "Dynamic_Field_Value2": null,
        "Dynamic_Field_Value3": null,
        "Dynamic_Field_Value4": null,
        "Dynamic_Field_Value5": null,
        "Preffered_Time": "",
        "Preffered_Date": "",
        "DateRange": "1 Sept 2020 - 1 Feb 2021",
        "ImageURL": "",
        "LocationName": null,
        "TemplateName": "Register your interest with us"
    }

*/
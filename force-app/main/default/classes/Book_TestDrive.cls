/** *****
 * Description : API Class to create Test Drive
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20180831            Cycle & Carriage              Created Initial Version. 
 * 20200907            khanh.do@aodigy.com           Added PA - Phase 2 Changes
 * 
** *****/
@RestResource(urlMapping = '/CreateTestDrive/v1/*')
global with sharing class Book_TestDrive 
{
    
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Utility.httpSuccessResponse successResponse;
    private static Utility.httpErrorResponse errorResponse;
    private static Map<String, Branch_Configuration__mdt> mapBatchConfiguration = Utility.getBatchConfiguration();
    private static Map<String, Object> mapJSONBody = new Map<String, Object>();
    
    @HttpPost
    global static void CreateTestDrive() 
    {

        //This block of code should be changed to json object instead of static assignment. need to revisit later as part of improvements.
        mapJSONBody = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        res.addHeader('Content-Type', 'application/json');
        System.debug('reqDetails' +req);
        System.debug('mapJSONBody-'+mapJSONBody);
        String PersonId = (String)mapJSONBody.get('PersonId');
        String Type     = (String)mapJSONBody.get('Type');
        String Status   = (String)mapJSONBody.get('Status');
        String source   = (String)mapJSONBody.get('source');
        DateTime BookingDate = (DateTime)JSON.deserialize(JSON.serialize((String)mapJSONBody.get('BookingDate')), DateTime.class);
        String TModel   = (String)mapJSONBody.get('TModel');
        String TVariant = (String)mapJSONBody.get('TVariant');
        String Showroom = (String)mapJSONBody.get('Showroom');
		String CustomerInterest = (String)mapJSONBody.get('CustomerInterest');
		String CustomerComments = (String)mapJSONBody.get('CustomerComments');
        
        String Returnstr;
        Test_Drive__c testDrive;
        Opportunity[] opp;
        Opportunity newOpp;
        String ErrorCode;
        String Errormsg;
        String jsonS;
        String PDPAVal = ';';
        Date today = Date.today();
        Date oppCloseDate = today.addDays(30);
        String contact_Id = null;
        String account_Id = null;
        
        Contact[] thisContact = new List<Contact>();
        Models_Interested__c[] modIntList = new List<Models_Interested__c>();
        List<Model__c> BranchCodeLst = new List<Model__c>();
        
        String BranchCode    = '';
        String FranchiseCode = '';
        String SourceModel   = '';
        
        if( String.isNotBlank(PersonId) && String.isNotBlank(Type) && String.isNotBlank(TModel) ) 
        {
            try 
            {
                BranchCodeLst = [SELECT Branch_Code__c, Franchise_Code__c FROM Model__c WHERE Id =: TModel];
                if(BranchCodeLst.size() > 0) 
                {
                    BranchCode    = BranchCodeLst[0].Branch_Code__c;
                    SourceModel   = BranchCodeLst[0].Franchise_Code__c.substring(0, 3);
                    FranchiseCode = BranchCodeLst[0].Franchise_Code__c;
                }
                
                List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>();
                
                if( PersonId.startsWith('003') ) 
                {
                    //opp = Utility.checkOpenOppExistsForTheContact(BranchCode, PersonId);
					//Code was modified for Oppty standardisation --> NSJ
					opp = OpportunityService.activeOpportunityList(BranchCode, PersonId);
                    
                    thiscontact = [ SELECT Id, Name, Account__c, Account__r.Id, OwnerId, AccountId, IsPersonAccount
                                    FROM Contact
                                    WHERE Id =: PersonId 
                                    AND isPersonAccount = true ];
                    
                    contact_Id = PersonId;
                    account_Id = (thiscontact <> null && !thiscontact.isEmpty() ) ? thiscontact.get(0).AccountId : null;
                    
                    if( opp.size() <= 0 ) 
                    {

						//Code was modified for Oppty standardisation --> NSJ
						Id rtid = OpportunityService.getStrRecordTypeAssignment(BranchCode);
						newopp = OpportunityService.newOpportunityObject(PersonId, account_Id, rtid,
																		BranchCode, franchisecode, 'TestDrive');

						newopp.Name = OpportunityService.getStrOpportunityName(thiscontact[0].Name, franchisecode);


						string oppOwnerId = OpportunityService.getStrOwnerAssignment(PersonId, BranchCode);
                        if(oppOwnerId != '') 
						{
                            newopp.OwnerId = oppOwnerId;
                        }                                                
                        
                        //Round Robin
                        insert newopp;
                        newopp = [SELECT Id, Name, OwnerId, Opportunity_Score__c, Test_Drive__c, Contact_Person__c, LeadSource, CloseDate, Branch_Code__c 
                                      FROM Opportunity 
                                      WHERE Id =:newopp.Id];

                        Task tsk = new Task();
                        Utility.isWebTestDrive = true;
                        Utility.isWebTestDriveBrand = BranchCode;
                        tsk = new Task();
                        //tsk.Subject       = String.isNotBlank(System.Label.OppAssignment) ? System.Label.OppAssignment : 'Schedule Digital Consultation';
                        tsk.Subject       = 'Schedule Digital Consultation';
                        tsk.WhatId        = newopp.Id;
                        tsk.OwnerId       = newopp.OwnerId;
                        tsk.Status        = 'Open';
                        tsk.Priority      = 'Normal';
                        tsk.IsReminderSet = false;
                        tsk.ActivityDate  = Date.newInstance(BookingDate.year(), BookingDate.month(), BookingDate.day());
                        tsk.Description   = BookingDate.format('hh:mm:ss a');
                        insert tsk;

                        opp.add(newopp);

                        if (contact_Id != null)
                        {                            
                            lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', newopp.Contact_Person__c, newopp.OwnerId));
                        }
                    }
                }               
                
                if( !lstToCreateShare.isEmpty() ) {
                    sharingHelper.creatShare(lstToCreateShare);
                }
                
                if( opp.size() > 0) 
                {
                    List<Vehicle_Master__c> vh = new List<Vehicle_Master__c>();
                    opp = [SELECT Id, OwnerId, Owner.isActive, Opportunity_Score__c, Rating__c, Test_Drive__c FROM opportunity WHERE Id =: opp[0].Id];
                    if(String.isNotBlank(TVariant))
                    {
                        vh = [SELECT Id FROM Vehicle_Master__c WHERE Variant__c =: TVariant and Type__c = 'Test Drive' ORDER BY CreatedDate DESC LIMIT 1];
                    } 
                    else if( String.isNotBlank(TModel))
                    {
                        vh = [SELECT Id FROM Vehicle_Master__c WHERE Model__c =: TModel and Type__c = 'Test Drive' ORDER BY CreatedDate DESC LIMIT 1];
                    }
                    
                    //testDrive = new Test_Drive__c();

                    //REMOVED BY Khanh 26/11/2021: Test Drive Modification
                    // Test_Drive__c thisTestDrive = new Test_Drive__c(
                    //     Opportunity__c    = opp[0].Id,
                    //     OwnerId           = opp[0].Owner.isActive ? opp[0].OwnerId : mapBatchConfiguration.get(BranchCode).Default_OwnerId__c,
                    //     Franchise_Code__c = FranchiseCode,
                    //     TModel__c         = TModel, 
                    //     Branch_Code__c    = BranchCode, 
                    //     TVariant__c       = TVariant,
                    //     Prospect__c       = contact_Id,
                    //     Account__c        = account_Id,
					// 	Interest_Area__c  = CustomerInterest, Customer_Comments__c = CustomerComments,
                    //     Status__c         = Status, 
                    //     Date__c           = BookingDate, 
                    //     Showroom__c       = Showroom, 
                    //     Source__c         = source,
                    //     Model__c          = (vh<>null && !vh.isEmpty()) ? vh[0].Id : null
                    // );

                    // insert thisTestDrive;
                    
                    //Insert Model Interested
					//Code was modified for Oppty standardisation --> NSJ
                    Models_Interested__c modInterested = new Models_Interested__c();
					modInterested = ModelsInterestedService.newModelInterestedObject(opp[0].Id, TModel, 'Online', 'Test Drive (Web)');
                    modInterested.Status__c       = 'Open';
                    Insert modInterested;

                    
                    //testDrive.Id = thisTestDrive.Id;
                    Decimal oppScore = opp[0].Opportunity_Score__c;
                    Integer oppoScore;
                    if (opp[0].Test_Drive__c != true) 
                    {
                        if (oppScore != null) {
                            oppoScore = oppScore.intValue() + 10;
                        } 
                        else {
                            oppoScore = 10;
                        }
                        opp[0].Opportunity_Score__c = oppoScore;
                        
                        if (opp[0].Opportunity_Score__c <= 25) {
                            opp[0].Rating__c = 'Cold';
                        } 
                        else if (opp[0].Opportunity_Score__c >= 26 && opp[0].Opportunity_Score__c <= 60) {
                            opp[0].Rating__c = 'Warm';
                        } 
                        else if (opp[0].Opportunity_Score__c > 61) {
                            opp[0].Rating__c = 'Hot';
                        }
                    }

                    opp[0].Test_Drive__c = true;
                    opp[0].OwnerId       = opp[0].Owner.isActive ? opp[0].OwnerId : mapBatchConfiguration.get(BranchCode).Default_OwnerId__c;
                    update opp;
                    
                }
                res.statusCode = 200;
                //res.responseBody = Blob.valueOf(JSON.Serialize(testDrive));
            } 
            catch (Exception e) 
            {
                System.debug('A DML exception has occurred: err.cause = ' + e.getCause() + ' --- err.msg = ' + e.getMessage() + ' --- err.line = ' + e.getLineNumber() );
                res.statusCode = 400;
                errorResponse = new Utility.httpErrorResponse('Failed', e.getMessage());
                loggerDataPool.buildLogDataPool('Book_TestDrive', e);
                if(errorResponse != null)
                {
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
                }
            }
        }
        else 
        {
            Errormsg = 'Required fields not supplied. Fields: PersonId or Type or TModel';
            errorResponse = new Utility.httpErrorResponse('Failed', Errormsg);
            res.statusCode = 400;
            if(errorResponse != null)
            {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
            }
        }
        serviceDataPool.buildServiceDataPool('Test Drive (Web)', 'Book_TestDrive', '', req, res);
    }
}

/** 
Example Payload For Testing
End Point : /services/apexrest/CreateTestDrive/v1/*

PA-Customer ::
{
    "PersonId": "0035D00001JKup9QAD",
    "Type": "Contact",
    "Status": "Pending",
    "BookingDate": "2020-09-16T04:30:00",
    "TModel": "a0r5D00000323AVQAY",
    "TVariant": "a0z5D000000lt7kQAA",
    "Showroom": "a0x5D00000266GRQAY",
    "source": "Website"
}

PA-Prospect ::
{
    "PersonId": "0035D00001JUaBUQA1",
    "Type": "Lead",
    "Status": "Pending",
    "BookingDate": "2020-09-16T04:30:00",
    "TModel": "a0r5D00000323AVQAY",
    "TVariant": "a0z5D000000lt7kQAA",
    "Showroom": "a0x5D00000266GRQAY",
    "source": "Website"
} 
 **/
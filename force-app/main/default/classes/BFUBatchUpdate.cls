/** *****
 * Class name : BFUBatchUpdate
 * Description : Batch class to create Opportunity and PA(Prospect) from uploaded file
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * YYYYMMDD            C&C                           Created Initial Version. 
 * 20200908            khanh.do@aodigy.com           Added PA - Phase 2 Changes
 * 20210621            khanh.do@aodigy.com           Added Person Account Profiling creation
 * 
** *****/
global class BFUBatchUpdate implements Database.Batchable<sobject>, Database.Stateful {  
    global final List<BulkFileUpload__c> bfuList;
    global final String sDocumentId;
    
    List<BatchException> exceptions = new List<BatchException>();
    Integer UpdatedRecs = 0;
    Integer noOfProspectsCreated = 0; //PA Phase 2: Newly Added
    Integer noOfProspectsFailed = 0; //PA Phase 2: Newly Added
    Integer NoofOppsCreated = 0;
    Integer NoofOppsFailed = 0;    
    
    public BFUBatchUpdate(List<BulkFileUpload__c> listBFU, String DocumentId){
         bfuList = listBFU;
         sDocumentId = DocumentId;
    }
    
  	global List<SObject> start(Database.BatchableContext BC)
    {
        return bfuList;
    }
    
    global void execute(Database.BatchableContext BC, List<BulkFileUpload__c> bfuList)
    {
        Date today=date.today();
        
    	try{
            
            System.debug(LoggingLevel.INFO,'Bulk upload execute batch transfer');
        	List <Opportunity> lopp = new List <Opportunity>();
            List <Contact> contacts = new List <Contact>();
            
            List<BulkFileUpload__c> BulkRecsToUpdate = New List<BulkFileUpload__c>();
              
            // Get All Branch Code Mapping data
            Map<ID, Branch_Code_Name_Mapping__c> brMap = getAllBranchMap();
                
            // Get All Showroom data
            Map<ID, Showroom__c> srMap = getAllShowRoom();
                
                // Get All User Data
            //List<User> a=[select ID from User where Email=: bfu.Preferred_Sales_Consultant__c AND ISACTIVE = true LIMIT 1];     	
			Map<ID, User> urMap = getAllUser();    
            
            // Get Opportunity Record Types
            Map<ID, RecordType> rtMap = getOppRT();   
                
            list<sharingHelper.generateShare> lstToCreateShare = new list<sharingHelper.generateShare>();
             	
            Database.SaveResult sr;
                        
            Savepoint sp = Database.setSavepoint();
			
            for(BulkFileUpload__c bfu: bfuList){
                system.debug('bfu record-->' + bfu);
				Opportunity opp = New Opportunity();

                String ModId;
                String LeadSource;
                String ContId;
				String accountId;
				
                List<RecordType> rtid;
				Id OppRecTypeId;
                String franchiseCode;
                String branchCode = bfu.Branch_Code__c;

				//Get franchiseCode using Brach Code Name Mapping
				if(!brMap.isEmpty())
				{
                    system.debug('branch' + brMap);
                    for(ID idKey : brMap.keySet())
    				{
       	 				Branch_Code_Name_Mapping__c br = brMap.get(idKey);
            			if(br.Branch_Code__c == bfu.Branch_Code__c)
                        {
                            franchiseCode = br.PC_Code__c;
                            System.debug('franchiseCode =  ' + franchiseCode);                           
						}
					}		
				}


                
				//Get Opportunity RecordType Id based on Brach Code Name Mapping
				//Code was modified for Oppty standardisation --> NSJ
				OppRecTypeId = OpportunityService.getStrRecordTypeAssignment(branchCode);
                        
				// Retrive Owner Id 
				Boolean IsUserExists = false;
				ID ownId = UserInfo.getUserId();
				
				if (!String.isblank(bfu.Preferred_Sales_Consultant__c)){
					if(!urMap.isEmpty()){   
						for(ID idKey : urMap.keySet())
						{
							User u = urMap.get(idKey);
                            System.debug('u.Email = ' + u.Email);
                            System.debug('bfu.Preferred_Sales_Consultant__c = ' + bfu.Preferred_Sales_Consultant__c);
							if(u.Email == bfu.Preferred_Sales_Consultant__c){
								ownID = u.ID;
								IsUserExists = true;
								break;
							}
						}
					}
				}
                
                // 1 - Check for Contact Exists.... 
				contacts = [SELECT Id, FirstName, LastName, Name, AccountId
							FROM Contact 
							WHERE Email =:bfu.Email__c
							ORDER BY CreatedDate DESC LIMIT 1];
				if(contacts.size() > 0) {
                    accountId = contacts[0].AccountId;

					//Update Contact PDPA
					Contact UpdateContact = new Contact(id = contacts[0].id);
					UpdatePDPA.updatePDPA(UpdateContact, bfu.SMS__c, bfu.Call__c, bfu.isEmail__c, bfu.fax__c);
					update UpdateContact;
					//End of Update		
					
					// Check for Opportunity exists
					//Code was modified for Oppty standardisation --> NSJ
					lopp = OpportunityService.activeOpportunityList(bfu.Branch_Code__c, contacts[0].Id);

					if(lopp.size()>0) 
					{
						// Opportunity Exists for that Branch Code and Contact
						opp=lopp[0];
                        Integer Score = getScore(bfu.Lead_Source__c);
                        
						// No PSC or Same PSC - Update Opp
						if(bfu.Preferred_Sales_Consultant__c == NULL || opp.OwnerId == ownId) {
							Decimal oppScore = lopp[0].Opportunity_Score__c; 
							if (oppScore != null) {
								oppScore= oppScore.intValue() + Score;                
							} else {
								oppScore = Score;
							}
							opp.Opportunity_Score__c = oppScore;
							
							if (opp.Opportunity_Score__c <= 25) {
								opp.Rating__c = 'Cold';
							} 
							else if (opp.Opportunity_Score__c >= 26 && opp.Opportunity_Score__c <= 60) {
								opp.Rating__c = 'Warm';
							} 
							else if (opp.Opportunity_Score__c > 61) {
								opp.Rating__c = 'Hot';
							}
						
							TriggerExclusion.skipRR = true;
							opp.Created_Updated_From_Channel__c = 'Bulk Upload';
								
							// update existing opp
							update opp;
							
							ownId = opp.OwnerId;
								
							// Create Model Interested here..
							ModId = bfu.Models_Interested__c;
							LeadSource = bfu.Lead_Source__c;
                            createdModelInterested(opp.id, ModId, ownId, LeadSource, bfu.Comments__c); 

							// Create Event Registration here..
							if (!String.isblank(bfu.Event_Name__c)){
								createEvent(opp.Id,bfu.Event_Name__c,ownId, contacts[0].Id, ModId, bfu.First_Name__c, bfu.Last_Name__c,bfu.Mobile__c, bfu.Email__c,
									bfu.EventDate__c, bfu.Event_Time__c, bfu.Showroom__c, bfu.No_of_Pax__c, srMap
                                    , accountId); 
							}
								
							bfu.Status__c = 'U';
							UpdatedRecs = UpdatedRecs + 1;
                            bfu.Opportunity__c = opp.id;
						}
						
						// PSC has value but Invalid PSC
						System.debug('*****');
						System.debug(bfu.Preferred_Sales_Consultant__c);
						System.debug(opp.OwnerId);
						System.debug(ownId);system.debug(IsUserExists);
						System.debug('*****');
						if(bfu.Preferred_Sales_Consultant__c<>NULL && opp.OwnerId<>ownId && IsUserExists==false) {
							Decimal oppScore = lopp[0].Opportunity_Score__c; 
							if (oppScore != null) {
								oppScore= oppScore.intValue() + Score;                
							} else {
								oppScore = Score;
							}
							opp.Opportunity_Score__c = oppScore;
								
							if (opp.Opportunity_Score__c <= 25) {
								opp.Rating__c = 'Cold';
							} else if (opp.Opportunity_Score__c >= 26 && opp.Opportunity_Score__c <= 60) {
								opp.Rating__c = 'Warm';
							} else if (opp.Opportunity_Score__c > 61) {
								opp.Rating__c = 'Hot';
							}
						
							TriggerExclusion.skipRR = true;
							
							opp.Created_Updated_From_Channel__c = 'Bulk Upload';
								
							update opp;
						
							ownId = opp.OwnerId;
								
							// Create Model Interested here..
							ModId = bfu.Models_Interested__c;
							LeadSource = bfu.Lead_Source__c;
							createdModelInterested(opp.id, ModId, ownId,LeadSource, bfu.Comments__c);
							String str_acctId = contacts[0].AccountId;

							// Create Event Registration here..
							if (!String.isblank(bfu.Event_Name__c)){
								createEvent(opp.Id,bfu.Event_Name__c,ownId, contacts[0].id, ModId, bfu.First_Name__c, bfu.Last_Name__c,bfu.Mobile__c, bfu.Email__c,
									bfu.EventDate__c, bfu.Event_Time__c, bfu.Showroom__c, bfu.No_of_Pax__c, srMap
                                   , accountId); 
							}
						
							bfu.Status__c = 'U';
							UpdatedRecs = UpdatedRecs + 1;
                            bfu.Opportunity__c = opp.id;
						}						
						// PSC is different but valid PSC
						if(bfu.Preferred_Sales_Consultant__c<>NULL && ownId<>opp.OwnerId && IsUserExists==true){
							// Create Opportunity - Different PSC
							//Code was modified for Oppty standardisation --> NSJ
							Opportunity oppnew = New Opportunity();
							oppnew = OpportunityService.newOpportunityObject(contacts[0].id, contacts[0].AccountId, OppRecTypeId,
																			bfu.Branch_Code__c, franchisecode, bfu.Lead_Source__c);
							oppnew.Name = OpportunityService.getStrOpportunityName(bfu.Last_Name__c, franchiseCode);
                            oppnew.Opportunity_Score__c = Score;
						
							if (oppnew.Opportunity_Score__c <= 25) {
								oppnew.Rating__c = 'Cold';
							} else if (oppnew.Opportunity_Score__c >= 26 && oppnew.Opportunity_Score__c <= 60) {
								oppnew.Rating__c = 'Warm';
							} 
							else if (oppnew.Opportunity_Score__c > 61) {
								oppnew.Rating__c = 'Hot';
                            }
							
							Boolean IsRR = false;
							if(IsUserExists==true){
								oppnew.OwnerId = OwnId;
							    TriggerExclusion.skipRR = true;
							} else{
								// Round Robin
								IsRR = true;
								TriggerExclusion.skipRR = false;
							}
						
							oppnew.Created_Updated_From_Channel__c = 'Bulk Upload';
							
							sr = Database.insert(oppnew, false);
						
							if(sr.IsSuccess()){
								System.debug('Successfully inserted: ' + sr.getId());
								bfu.Opp_Created__c = true;
								bfu.Status__c = 'C';
								NoofOppsCreated = NoofOppsCreated + 1;
                                bfu.Opportunity__c = oppnew.id;
							
									// Because of Round Robin to get the OwnId after insert 
							    if(IsRR==true){
									List<opportunity> oppRecs = [select ID, ownerId from 
																Opportunity Where ID=:Oppnew.Id LIMIT 1];
									ownId = oppRecs[0].ownerId;
								}
															
								// Create Model Interested here...
								ModId = bfu.Models_Interested__c;
								LeadSource = bfu.Lead_Source__c;
                                createdModelInterested(oppnew.Id, ModId, ownId, LeadSource, bfu.Comments__c);

								// Create Event Registration here..
								if (!String.isblank(bfu.Event_Name__c)){
										createEvent(oppnew.Id,bfu.Event_Name__c,ownId,contacts[0].id, ModId, bfu.First_Name__c, bfu.Last_Name__c,bfu.Mobile__c, bfu.Email__c,
											bfu.EventDate__c, bfu.Event_Time__c, bfu.Showroom__c, bfu.No_of_Pax__c, srMap
                                        , accountId); 
								}

								lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', contacts[0].id, ownId));
									
									/** PA MIGRATION : Newly Added */
								if( String.isNotBlank( accountId ) ) {
									lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Account', accountId, ownId));
								} 
							} else  {
                                for(Database.Error err : sr.getErrors()){
									System.debug('The following error has occurred.');  
									System.debug(err.getStatusCode() + ': ' + err.getMessage());
									System.debug('Fields that affected this error: ' + err.getFields());
									bfu.Status__c = 'F';
									bfu.Reason__c = err.getStatusCode() + ': ' + err.getMessage();
									NoofOppsFailed = NoofOppsFailed + 1;
								}
							}
					
						}					
						BulkrecsToUpdate.add(bfu);
					} else {
						// No Open Opportunity 
						// Create New Opp, Model Interested, Event Registration
						Opportunity oppnew = New Opportunity();
						//Code was modified for Oppty standardisation --> NSJ
						oppnew = OpportunityService.newOpportunityObject(contacts[0].id, AccountId, OppRecTypeId,
																		bfu.Branch_Code__c, franchisecode, bfu.Lead_Source__c);

						oppnew.Name = OpportunityService.getStrOpportunityName(bfu.Last_Name__c, franchiseCode);
						
						Integer Score = getScore(bfu.Lead_Source__c);
						oppnew.Opportunity_Score__c = Score;
                            
						if (oppnew.Opportunity_Score__c <= 25) 
						{
							oppnew.Rating__c = 'Cold';
						} 
						else if (oppnew.Opportunity_Score__c >= 26 && oppnew.Opportunity_Score__c <= 60) 
						{
							oppnew.Rating__c = 'Warm';
						} 
						else if (oppnew.Opportunity_Score__c > 61) 
						{
							oppnew.Rating__c = 'Hot';
						}
							
						Boolean IsRR = false;
						if(IsUserExists==true){
							oppnew.OwnerId = OwnId;
							TriggerExclusion.skipRR = true;
						}
						else{
								
							// Check for Booked Opp
							List<Opportunity> lopp1 = [SELECT id,Opportunity_Score__c, Franchise_Code__c, OwnerId from Opportunity
                                                        WHERE StageName IN ('Booked', 'Open') and Branch_Code__c = :bfu.Branch_Code__c
                                                        AND Contact_Person__c=:contacts[0].id 
                                                        AND Contact_Person__c!=null
                                                        AND ownerid NOT IN (SELECT ID FROM USER WHERE 
                                                                        ExcludeFromPre_existingOpportuntity__c=TRUE)
                                                            ORDER BY createdDate DESC]; 
							if(lopp1.size()>0) { 
									ownId = lopp1[0].ownerId;
									oppnew.OwnerId = ownId;
									TriggerExclusion.skipRR = true;
							} else{
									// Round Robin
									IsRR = true;
									TriggerExclusion.skipRR = false;
							}
						}
							
						oppnew.Created_Updated_From_Channel__c = 'Bulk Upload';
							
						sr = Database.insert(oppnew, false);
							
						if(sr.IsSuccess()){
							System.debug('Successfully inserted: ' + sr.getId());
							bfu.Opp_Created__c = true;
							bfu.Status__c = 'C';
							NoofOppsCreated = NoofOppsCreated + 1;
                            bfu.Opportunity__c = oppnew.id;                                
							
							// Because fo Round Robin to get the OwnId after insert 
							if(IsRR == true){
								List<opportunity> oppRecs = [SELECT ID, ownerId FROM Opportunity WHERE ID =: Oppnew.Id LIMIT 1];
								ownId = oppRecs[0].ownerId;
							}
	
							// Create Model Interested here...
							ModId = bfu.Models_Interested__c;
							LeadSource = bfu.Lead_Source__c;
							createdModelInterested(oppnew.Id, ModId, ownId, LeadSource, bfu.Comments__c);
							// Create Event Registration here..
							if (!String.isblank(bfu.Event_Name__c)){
								createEvent(oppnew.Id,bfu.Event_Name__c,ownId,contacts[0].id, ModId, bfu.First_Name__c, bfu.Last_Name__c,bfu.Mobile__c, bfu.Email__c,
										bfu.EventDate__c, bfu.Event_Time__c, bfu.Showroom__c, bfu.No_of_Pax__c, srMap
                                    , accountId); 
							}
							lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', contacts[0].id, ownId));


							lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Account', accountId, ownId)); 
							
						} else {
							for(Database.Error err : sr.getErrors()){
								System.debug('The following error has occurred.');  
								System.debug(err.getStatusCode() + ': ' + err.getMessage());
								System.debug('Fields that affected this error: ' + err.getFields());
							    bfu.Status__c = 'F';
								bfu.Reason__c = err.getStatusCode() + ': ' + err.getMessage();
								NoofOppsFailed = NoofOppsFailed + 1;
							}
						}
						BulkrecsToUpdate.add(bfu);
					}
                } else {								
					String str_unique_key = AccountUtil.createUniqueString(); //PA MIGRATION
					/** PA MIGRATION : Newly Added -- Insert Prospect (instead of Lead) --  Start */
					Account newProspect = new Account();
					newProspect.RecordTypeId 		= AccountUtil.getProspectRecordTypeId();
					newProspect.PersonEmail 		= bfu.Email__c;
					newProspect.FirstName 			= bfu.First_Name__c;
                    newProspect.Lastname 			= bfu.Last_Name__c;
                    newProspect.Full_Name__pc       = (newProspect.FirstName + ' ' + newProspect.Lastname).trim();
					newProspect.PersonMobilePhone   = bfu.Mobile__c;
					newProspect.PersonLeadSource 	= bfu.Lead_Source__c;
					newProspect.Branch_Code__pc 	= bfu.Branch_Code__c;		
                    //newProspect.PDPA__pc 			= 'SMS;Call;Email;';
                    UpdatePDPA.updatePDPA(newProspect, bfu.SMS__c, bfu.Call__c, bfu.isEmail__c, bfu.fax__c);
                    newProspect.Identifier__c 		= str_unique_key;
                    sr = Database.insert(newProspect, false);
					/** PA MIGRATION : Newly Added Insert Prospect End */
                            
                    //If insert Prospect is successful
					if(sr.IsSuccess()){
                        System.debug('Successfully inserted: ' + sr.getId());						

                        newProspect = AccountUtil.getProspectRecordById(newProspect.Id);
						//Added by Khanh, if insert Prospect is successful, create Profiling
						if(newProspect != null && String.isNotBlank(newProspect.Id)){
							AccountUtil.createProfiling('CCS_Person_Account_Profiling_RT', newProspect);							
						}
                        
                        bfu.Prospect_Created__c = true; //PA Phase 2: Newly Added 
                        noOfProspectsCreated += 1; //PA Phase 2: Newly Added
						Database.DMLOptions dmlOpts = new Database.DMLOptions();
						dmlOpts.assignmentRuleHeader.useDefaultRule = true;
								
                        //Database.update(LeadNew, dmlOpts); //PA Phase 2: Remove Lead
                        Database.update(newProspect, dmlOpts);
								
					    /** PA MIGRATION : Newly Added */
						if( String.isNotBlank( newProspect.Id ) ) {
							lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Account', newProspect.Id, ownId));
                        }
                                
						opportunity oppnew =  new opportunity();
						//Code was modified for Oppty standardisation --> NSJ

						oppnew = OpportunityService.newOpportunityObject(newProspect.PersonContactId, newProspect.Id, OppRecTypeId,
																		bfu.Branch_Code__c, franchisecode, bfu.Lead_Source__c);

						oppnew.Name = OpportunityService.getStrOpportunityName(newProspect.LastName, franchiseCode);
							
						Integer Score = getScore(bfu.Lead_Source__c);
						oppnew.Opportunity_Score__c = Score;
							
						if (oppnew.Opportunity_Score__c <= 25) {
							oppnew.Rating__c = 'Cold';
						} else if (oppnew.Opportunity_Score__c >= 26 && oppnew.Opportunity_Score__c <= 60) {
							oppnew.Rating__c = 'Warm';
						} else if (oppnew.Opportunity_Score__c > 61) {
							oppnew.Rating__c = 'Hot';
						}
								
						system.debug('Owner ID' + ownId);
								
						// No PSC
						Boolean IsRR = false;
						if(bfu.Preferred_Sales_Consultant__c==NULL)
						{ // Round Robin 
							IsRR = true;
							TriggerExclusion.skipRR = false;
                        } else { // PSC has value
							if(IsUserExists==true) {
								oppnew.OwnerId = OwnId;
								TriggerExclusion.skipRR = true;
							} else {
								// PSC has value but No User exists
							    // Round Robin
								IsRR = true;
							    TriggerExclusion.skipRR = false;
							}
						}
								
							oppnew.Created_Updated_From_Channel__c = 'Bulk Upload';
							
							sr = Database.insert(oppnew, false);
							
							if(sr.IsSuccess()){                                        
                                System.debug('Successfully inserted: ' + sr.getId());
                                       
							    // Because of Round Robin to get the OwnId after insert 
								If(IsRR == true){
									List<opportunity> oppRecs = [select ID, ownerId from Opportunity Where ID=:Oppnew.Id LIMIT 1];
									ownId = oppRecs[0].ownerId;
								}
							
									
								// Create Model Interested
								ModId = bfu.Models_Interested__c;
								LeadSource = bfu.Lead_Source__c;
								createdModelInterested(oppnew.Id, ModId,ownId, LeadSource, bfu.Comments__c);
									
								// Create Event Registration here..
								if (!String.isblank(bfu.Event_Name__c)) {
                                    System.debug('Matthew is here event');
									createEvent(oppnew.Id,bfu.Event_Name__c,ownId,ContId,ModId,
												    bfu.First_Name__c, bfu.Last_Name__c,bfu.Mobile__c, bfu.Email__c,
                                                    bfu.EventDate__c, bfu.Event_Time__c, bfu.Showroom__c, bfu.No_of_Pax__c, srMap,
                                                    newProspect.Id
                                                    ); 
								}
								bfu.Opp_Created__c = true;
								bfu.Status__c = 'C';
								NoofOppsCreated = NoofOppsCreated + 1;
                                bfu.Opportunity__c = oppnew.id;
										
							} else{
								for(Database.Error err : sr.getErrors()){
									System.debug('The following error has occurred.');  
									System.debug(err.getStatusCode() + ': ' + err.getMessage());
									System.debug('Fields that affected this error: ' + err.getFields());
									bfu.Status__c = 'F';
									bfu.Reason__c = err.getStatusCode() + ': ' + err.getMessage();
									NoofOppsFailed = NoofOppsFailed + 1;
								}
							} 
									
					}else {
						for(Database.Error err : sr.getErrors()){
							System.debug('The following error has occurred.');  
							System.debug(err.getStatusCode() + ': ' + err.getMessage());
							System.debug('Fields that affected this error: ' + err.getFields());
							bfu.Status__c = 'F';
							bfu.Reason__c = err.getStatusCode() + ': ' + err.getMessage();
                               noOfProspectsFailed += 1;
						} 
					}
					BulkrecsToUpdate.add(bfu);
						
				}
            }
            
            // After For loop End
            // if(!Test.isRunningTest()){
            if(!lstToCreateShare.isEmpty())
            {
             	sharingHelper.creatShare(lstToCreateShare);
            }
        	//}
        	//
            if(BulkRecsToUpdate.size()>0)
            {
            	Update BulkRecsToUpdate; //detail records status
            }
            
		}
		catch(Exception e)
		{
           system.debug('@@@ Exception happened');
           exceptions.add(new BatchException(e.getMessage()));
           System.debug(' Error: '+ e.getMessage() + ' Error at line ' + e.getLineNumber() + '. Cause: ' + e.getCause());

        }
        
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        system.debug('Document Id-->' + sDocumentId);
        
        List<BulkFileUpload__c> bf = [SELECT ID, Total_No_of_Recs__c, No_of_Recs_Failed__c, No_of_OK_Records__c,
                                             No_of_Opp_Created__c, No_of_Opp_Failed__c, No_of_Prospects_Created__c, No_of_Prospects_Failed__c
                                      FROM BulkFileUpload__c
                                      WHERE DocumentId__c = :sDocumentId
                                      AND Type__c = 'S'
                                      LIMIT 1
                                      ];
        if(bf.size()>0){
            bf[0].No_of_Prospects_Created__c = noOfProspectsCreated; //PA Phase 2: Newly Added
            bf[0].No_of_Prospects_Failed__c = noOfProspectsFailed; //PA Phase 2: Newly Added
            bf[0].No_of_Opp_Created__c = NoofOppsCreated; 
            bf[0].No_of_Opp_Failed__c = NoofOppsFailed; 
            bf[0].No_of_Recs_Updated__c = UpdatedRecs;
            Update bf;
        }

 		// Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
 		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
  							TotalJobItems, CreatedBy.Email, ExtendedStatus
  							from AsyncApexJob where Id = :BC.getJobId()];
  
 		// Email the Batch Job's submitter that the Job is finished.
 		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 		String[] toAddresses = new String[] {
            a.CreatedBy.Email
           // 'lakshmi.gandhala@aodigy.com'
            };
 		mail.setToAddresses(toAddresses);
 		mail.setSubject('Bulk File Upload BatchJob Status: ' + a.Status);
        String mBody = 'The Bulk File Upload Batch Apex job processed ' + a.TotalJobItems +
  		' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus:' + '\n' ;
        mbody += 'The file results are: ' + '\n';
        
        mbody += 'Total No. of Records: ' + String.valueof(bf[0].Total_No_of_Recs__c) + '\n';
        mbody += 'No. of Records Failed: ' + String.valueof(bf[0].No_of_Recs_Failed__c) + '\n';
        mbody += 'No. of Records OK: ' + String.valueof(bf[0].No_of_OK_Records__c) + '\n';
        mbody += 'No. of Prospects Created: ' + String.valueof(bf[0].No_of_Prospects_Created__c) + '\n';  //PA Phase 2: Newly Added
        mbody += 'No. of Prospects Failed: ' + String.valueof(bf[0].No_of_Prospects_Failed__c) + '\n';    //PA Phase 2: Newly Added
 		mbody += 'No. of Opps Created: ' + String.valueof(bf[0].No_of_Opp_Created__c) + '\n';    
        mbody += 'No. of Opps Failed: ' + String.valueof(bf[0].No_of_Opp_Failed__c) + '\n'; 
        mbody += 'No. of Recs Updated: ' + String.valueof(bf[0].No_of_Recs_Updated__c) + '\n'; 
        
        mail.setPlainTextBody(mbody);
   
 		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
    global class BatchException extends Exception {}
    
    //Create Models Interested
    public static void createdModelInterested(String OppId, String ModId, String ownId, String LeadSource, String Comments)
	{

		Models_Interested__c createModInt = new Models_Interested__c();
		List<Models_Interested__c> modInterested = new List<Models_Interested__c>();
		modInterested = [SELECT Id,Model__c,Model__r.Name, Opportunity__c, Touch_Points__c, Name 
							FROM Models_Interested__c 
							WHERE Opportunity__c = :OppId AND Status__c = 'Open' 
							AND Model__c = :ModId LIMIT 1];
							
		System.debug(modInterested.size());
		if(modInterested.Size()>0)
		{
				//Code was modified for Oppty standardisation --> NSJ
				createModInt = ModelsInterestedService.newModelInterestedObject(OppId,ModId,'Online',LeadSource);
				insert createModInt;
								
				System.debug('Update Model Interested..' );
				Task tk = New Task();
				String Subj = 'Your opportunity has been updated with - ' + LeadSource + '- ' +  modInterested[0].Model__r.Name;
				tk = Utility.createTask(OppId, ownId, Subj );
				tk.Description = Comments;
                tk.Send_SMS__c = TRUE;
				insert tk;
		}
		else
		{
			createModInt.Model__c = ModId;
			createModInt.Opportunity__c = OppId; 
			//createModInt.OwnerId = ownId;
			createModInt.Channel__c = 'Online';
			createModInt.Touch_Points__c = LeadSource;
			createModInt.Status__c = 'Open';
			
			Database.SaveResult sr = Database.insert(createModInt, false);
			if(sr.IsSuccess()){
				System.debug('Successfully inserted: ' + sr.getId());
				
				List<Model__c> modelrec = [SELECT Name FROM Model__c WHERE Id = :ModId LIMIT 1];
                if(modelrec.size() > 0){
                    Task tk = New Task();
                    String Subj = 'A new opportunity has been assigned to you with - ' + LeadSource + '- ' + modelrec[0].Name;
                    tk = Utility.createTask(OppId, ownId, Subj );
                    tk.Description = Comments;
                    tk.Send_SMS__c = TRUE;
                    insert tk;
                }
				
			}
			else{
				for(Database.Error err : sr.getErrors()){
					System.debug('The following error has occurred.');  
					System.debug(err.getStatusCode() + ': ' + err.getMessage());
					System.debug('Fields that affected this error: ' + err.getFields());
				}
			}
			System.debug('create Model Interested..' );
		}
    }
	
	//Create event registration
	public static void createEvent( String OppId, String EventId, String ownId, String ContId, //String LeadId, //PA Phase 2: Remove Lead
								    String ModId, String FirstName, 
								    String LastName, String MobileNo, String EmailAddr, Date EventDate,
                                    String EventTime, String ShowRoom, String NoofPax , Map<ID, Showroom__c> srMap, String strAccountId ){ 
	
		System.debug('Campaign ID--' + EventId);
		Event_Registration__c createEventReg = new Event_Registration__c();
		//List<Campaign> campRec = [SELECT ID, NAME FROM CAMPAIGN WHERE ID=:EventId LIMIT 1];
		//createEventReg.PromoID__c 	 = campRec[0].ID;
		createEventReg.PromoID__c 		 = EventId.trim();
		createEventReg.FirstName__c 	 = FirstName;
		createEventReg.LastName__c 		 = LastName;
		createEventReg.MobilePhone__c 	 = MobileNo;
		createEventReg.Email__c 		 = EmailAddr;
		createEventReg.Event_Date__c 	 = EventDate;
		createEventReg.Preffered_Date__c = EventDate;
		createEventReg.TimeSlot__c 		 = EventTime;
		createEventReg.Preffered_Time__c = EventTime;
		createEventReg.Event_Status__c 	 = 'Registered';
		
		//if(LeadID<>NULL){ createEventReg.LeadId__c = LeadId; }  //PA Phase 2: Remove Lead
		if(ContId<>NULL){ createEventReg.ContactId__c = ContId; }
		if(OppId<>NULL){ createEventReg.Opportunity__c = OppId; }
		if(ModId<>NULL){ createEventReg.ModelCode__c = ModId; }
		
		/** PA MIGRATION : Newly Added */
		if( String.isNotBlank( strAccountId ) ) {
			createEventReg.Account__c = (Id)strAccountId;
		} 
		
		//Retrive Showroom ID
		//List<Showroom__c> srm = [SELECT ID, NAME FROM SHOWROOM__c WHERE Name=:ShowRoom LIMIT 1];
	
		if(!srMap.isempty()){
			for(ID idKey : srMap.keySet())
			{
				Showroom__c sr = srMap.get(idKey);
				if(sr.Name == showroom){
					createEventReg.Showroom__c = sr.ID;
					break;
				}
			}	
		}
	
		//if(srm.size()>0){createEventReg.Showroom__c = srm[0].ID;}
		
		if(NoofPax<>NULL && NoofPax<>''){
			createEventReg.NumberOfGuests__c = Integer.valueof(NoofPax);
		}
	
		createEventReg.OwnerId = ownId;
	
		TriggerExclusion.excludeTrigger('Event_Registration__c', true);
	
		Database.SaveResult sr = Database.insert(createEventReg, false);
		
		if(sr.IsSuccess()){
			System.debug('Successfully inserted: ' + sr.getId());
		}
		else{
			for(Database.Error err : sr.getErrors()){
				System.debug('The following error has occurred.');  
				System.debug(err.getStatusCode() + ': ' + err.getMessage());
				System.debug('Fields that affected this error: ' + err.getFields());
			}
		}
    }
    
    public static Map<ID, Branch_Code_Name_Mapping__c> getAllBranchMap(){
    	Map<ID, Branch_Code_Name_Mapping__c> brMap = New Map<ID, Branch_Code_Name_Mapping__c>([SELECT ID, Branch_Code__c, PC_Code__c FROM Branch_Code_Name_Mapping__c]);
        return brMap;
  	}
    
    public static Map<ID, Showroom__c> getAllShowRoom(){
    	Map<ID, Showroom__c> srMap = New Map<ID, Showroom__c>([SELECT ID, Name FROM Showroom__c]);
        return srMap;
  	}
    
    public static Map<ID, User> getAllUser(){
    	Map<ID, User> urMap = New Map<ID, User>([SELECT ID, Email FROM User WHERE Is_Eligible_Opp_Owner__c=True AND ISACTIVE = true]);
        return urMap;
  	}
    
    public static Map<ID, RecordType> getOppRT(){
    	Map<ID, RecordType> rtMap = New Map<ID, RecordType>([SELECT ID, SobjectType, Name FROM RecordType WHERE SobjectType ='Opportunity']);
        return rtMap;
  	}
    
    public static Integer getScore(String Lead_Source){ 
        Integer Score;
        if (Lead_Source == 'Facebook' || Lead_Source == 'Offline Events' 
           || Lead_Source == 'Principal Leads' || Lead_Source == 'Digital (Others)'
           || Lead_Source == 'Instagram' || Lead_Source == 'Ref-it-up')
        {
        	Score = 5;
        }
                        
		if (Lead_Source == 'Chat')
        {
       		Score = 10;
        }
                            
        if (Lead_Source == 'Saleswhale')
        {
			Score = 25;	
        }
    	return score;
    }
    
}
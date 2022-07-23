public without sharing class EmailMessageBL {

     public static void createChildCase( List<EmailMessage> lstEM ){
   
         String queueIdEM = [select Id, Name, DeveloperName from Group where Type = 'Queue' and 
                                     DeveloperName = 'Unassigned_Email_Queue' Limit 1].Id; 
             
         Set<Id> caseIdsOut = new Set<Id>();
         Set<Id> caseIdsIn = new Set<Id>();
         Map<Id, EmailMessage> EmMap = New Map<Id, EmailMessage>();
         
         for( EmailMessage newEM : lstEM )
         {
             String caseIdStr;
             system.debug('Email Message in EM BL-->' + newEM);
            
             if(newEM.ParentID!=NULL)
             { 
             	caseIdStr = string.valueof(newEM.ParentID);
                system.debug('Case ID-->' + caseIdStr);
                if(caseIdStr.startsWith('500'))
                {
                    if(newEM.Incoming == FALSE){
                        // for outgoing email message from case - for change request
                        caseIdsOut.add(newEM.ParentId);
                    }
                    
                    if(newEM.Incoming == TRUE){
                       // for incoming email message from case - for change request and closed case to create child case
                        caseIdsIn.add(newEM.ParentId);
                        EmMap.put(newEM.Id, newEM);
                    }
                }
             }        
         }
         
         List<Case> CasesToUpdate = New List<Case>();
         
         If(caseIdsOut.size()>0){
             String vRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Change Request (Ownership, Particulars, Vehicle Registration Number)').getRecordTypeId();
             List<Case> cList = [Select Id, Status, subject, ContactId from Case where Id IN: caseIdsOut 
                                 and recordtypeid =:vRecordTypeId and
                                 status NOT IN ('New','Pending for Documents') 
                                 and Email_Sent_Date__c=NULL];
             
             if(cList.size()>0){    
                 for(Case c : cList){
                    c.status = 'Pending for Documents';
                 	c.Email_Sent_Date__c = Date.today();
                    CasesToUpdate.add(c);
               	 }                 
             }
         } 
         
         If(caseIdsIn.size()>0){
             String vRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Change Request (Ownership, Particulars, Vehicle Registration Number)').getRecordTypeId();
             List<Case> cList = [Select Id, Status, subject, ContactId from Case where Id IN: caseIdsIn 
                                 and recordtypeid =:vRecordTypeId
                                 and status = 'Pending for Documents' and Email_Sent_Date__c!=NULL];
            
             if(cList.size()>0){    
                 for(Case c : cList){	       
                     c.status = 'Documents Received';
                     CasesToUpdate.add(c);
                 }   
             }    
             
			 /*
             List<Case> closedCasesList = [Select Id, Status, subject, ContactId 
                                           from Case where Id IN: CaseIdsIn and status='Closed'];
             if(closedCasesList.size()>0){
                 for(Case nc : closedCasesList){
                    Case newChildCase = New Case();
                    newChildCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Enquiry and Request').getRecordTypeId();
                    newChildCase.OwnerId = queueIdEM;
                   	if(nc.ContactId!=NULL){
                       	newChildCase.parentid = nc.id;
                       	newChildCase.ContactId = nc.ContactId;
                       	newChildCase.Origin = 'Email';
                       	newChildCase.Priority = 'P1';
                       	newChildCase.status = 'New';
                       	newChildCase.Subject = nc.Subject;
                       
                        EmailMessage dupEM = New EmailMessage();
                        if(!EmMap.isEmpty()){   
						    for(ID idKey : EmMap.keySet())
							{
                                EmailMessage e = EmMap.get(idKey);
                                if(e.ParentId == nc.Id){
                                    newChildCase.SuppliedEmail = e.FromAddress; 
                                    dupEM.FromAddress = e.FromAddress;
                        			dupEM.Incoming = TRUE;
                        			dupEM.Subject = e.Subject;
                        			dupEM.TextBody = e.TextBody;
                                    insert newChildCase;
									break; 
                                }
							}
						}
                        
                        dupEM.parentid = newChildCase.id;   
                 		insert dupEm;  
                    }
                    else{
                        newChildCase.parentid = nc.id;
                      	newChildCase.Origin = 'Email';
                       	newChildCase.Priority = 'P1';
                      	newChildCase.status = 'New';
                       	newChildCase.Subject = nc.Subject;
                        
                        EmailMessage dupEM = New EmailMessage();
                        
                        if(!EmMap.isEmpty()){   
						    for(ID idKey : EmMap.keySet())
							{
                                EmailMessage e = EmMap.get(idKey);
                                if(e.ParentId == nc.Id){
                     				newChildCase.SuppliedEmail = e.FromAddress;
                                    dupEM.FromAddress = e.FromAddress;
                      				dupEM.Incoming = TRUE;
                                    dupEM.Subject = e.Subject;
 									dupEM.TextBody = e.TextBody;
                                    insert newChildCase;
                                    break; 
                                }
                            }
                        }
                         
                        dupEM.parentid = newChildCase.id;
                       	insert dupEm;  
                     } 
                 }
             }
			 */
         }
         
         if(CasesToUpdate.size()>0){ Update CasesToUpdate; }
     }        
}
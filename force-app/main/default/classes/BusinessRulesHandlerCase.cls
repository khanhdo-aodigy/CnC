/*
    Author: Hari Panneerselvam
    Description: Business Rule defintion for Case Object. All the Case logic should be implemented from this class.
*/
public class BusinessRulesHandlerCase {
    
    TriggerHandlerCase caseTH;
    map <String, id> caseIdsForEmail = new map <String, id> ();
    set<String> setEmailFromInboundCase = new set<String>();
    map <String, id> caseIdsForContactID = new map <String, id> ();
    list<Contact> listContactFromInboundEmail = new list<Contact>();
    map<String, Contact> mapContactFromInboundEmail = new map<String, Contact>();
    
    set<String> setRegVehicleIDs = New set<String>();
    set<String> NewRegVehIdsSet = New set<String>();
    list<Registered_Vehicle__c> listFromRegVeh = new list<Registered_Vehicle__c>();
    map<String, Registered_Vehicle__c> mapFromRegVeh = new map<String, Registered_Vehicle__c>();
  
    public BusinessRulesHandlerCase(){
        
    }
    
    public BusinessRulesHandlerCase(TriggerHandlerCase bRcaseTH){
        caseTH = bRcaseTH;
    }
    
    //[MASTER SOQL]Prefetch all the content needed for the trigger to process. 
    public void preFetchTriggerContent(){
        
        for(Case itrCase : caseTh.lstCaseInContext){
            if(itrCase.ContactId == Null && itrCase.SuppliedEmail != Null){
                setEmailFromInboundCase.add(itrCase.SuppliedEmail);
            }
            
            //Cases with update vehicle from old to new
            if(itrCase.Registered_Vehicle__c!= Null && trigger.isupdate){
                Case OldCase = CaseTh.mapOldCaseInContext.get(itrCase.id);
                if(OldCase.Registered_Vehicle__c <> itrCase.Registered_Vehicle__c){
                  // NewRegVehIdsSet.add(itrCase.Registered_Vehicle__c);
                  // system.debug('Update Cases..' + NewRegVehIdsSet);
                setRegVehicleIds.add(itrCase.Registered_Vehicle__c);
                system.debug('Cases with Contact and/or Franchise null values....' + setRegVehicleIds);
                } 
            }
            
            
            //Cases having Registered Vehicle but no Contact and/or Franchise....
            if(itrCase.Registered_Vehicle__c != Null && (itrCase.ContactId == Null 
                                                         || itrCase.Franchise__c == Null 
                                                         || itrCase.Branch__c == null
              											 || itrCase.FranchiseCode__c == null
                                                         || itrCase.Chasis_Number__c == null))
            {
                setRegVehicleIds.add(itrCase.Registered_Vehicle__c);
                system.debug('Cases with Contact and/or Franchise null values....' + setRegVehicleIds);
            }
        }
        
        if(setEmailFromInboundCase != null && setEmailFromInboundCase.size() > 0){
            //listContactFromInboundEmail = [select id, Email from Contact where email in :setEmailFromInboundCase and isPersonAccount = false];
            listContactFromInboundEmail = [select id, Email from Contact where email in :setEmailFromInboundCase and isPersonAccount = true];
        
            if(listContactFromInboundEmail != null && listContactFromInboundEmail.size() > 0){
                for(Contact itrContact : listContactFromInboundEmail){
                    mapContactFromInboundEmail.put(itrContact.Email, itrContact);
                }
            }
        }
        
         if(setRegVehicleIds != null && setRegVehicleIds.size() > 0){
            listFromRegVeh = [select Id, Contact__c, Franchise__c, Branch__c, Autoline_Franchise_Code__c, Chasis_Number__c
                              from Registered_Vehicle__c where Id in :setRegVehicleIds];
          
            if(listFromRegVeh != null && listFromRegVeh.size() > 0){
               for(Registered_Vehicle__c itrRegVeh : listFromRegVeh){
                    mapFromRegVeh.put(itrRegVeh.Id, itrRegVeh);
                   system.debug('Reg Vehicle Details..--' + mapFromRegVeh);
                }
            }
        }
        
        }
    

    public void caseBeforeInsert(){
        Map<String, Email2Case_Origin_Setting__mdt> Email2CaseMap = New Map<String, Email2Case_Origin_Setting__mdt>();
        List<Email2Case_Origin_Setting__mdt> Email2CaseOriginList = [SELECT MasterLabel, DeveloperName, Case_Origin__c, Franchise__c FROM Email2Case_Origin_Setting__mdt];
        for(Email2Case_Origin_Setting__mdt ec : Email2CaseOriginList){
            Email2CaseMap.put(ec.MasterLabel, ec);
        }
        
        for(Case itr : caseTh.lstCaseInContext){
            
            system.debug('Case Before Insert->' + itr);
            
            // for case origin and franchise mapping...
            if(itr.SuppliedEmail != Null){
                if(!Email2CaseMap.isEmpty()){   
					for(String ecKey : Email2CaseMap.keySet())
					{
                        Email2Case_Origin_Setting__mdt ec = Email2CaseMap.get(ecKey);
                        if(itr.SuppliedEmail == ec.MasterLabel){
							itr.Origin = ec.Case_Origin__c;
                            itr.Franchise__c = ec.Franchise__c;
							break;
						}
					}
				}
            }
            
            if(itr.ContactId == Null && itr.SuppliedEmail != Null){
            if(mapContactFromInboundEmail != null && mapContactFromInboundEmail.size() > 0){
                if(mapContactFromInboundEmail.containsKey(itr.SuppliedEmail)){
                    itr.ContactId = mapContactFromInboundEmail.get(itr.SuppliedEmail).id;
                }
            }
            }
   
            // checking for contact and/or franchise blanks...
            if(itr.Registered_Vehicle__c != Null && (itr.ContactId == Null
                                                     || itr.Franchise__c == Null || itr.Branch__c== Null
                                                     || itr.FranchiseCode__c == Null
                                                     || itr.Chasis_Number__c == Null)){
            if(mapFromRegVeh != null && mapFromRegVeh.size() > 0){
                if(mapFromRegVeh.containsKey(itr.Registered_Vehicle__c)){
                    if(itr.ContactId == Null){
                    itr.ContactId = mapFromRegVeh.get(itr.Registered_Vehicle__c).Contact__c;}
                    
                    if(itr.Franchise__c == Null){
                    itr.Franchise__c = mapFromRegVeh.get(itr.Registered_Vehicle__c).Franchise__c;}
                    
                    if(itr.Branch__c == Null){
                    itr.Branch__c = mapFromRegVeh.get(itr.Registered_Vehicle__c).branch__c;}
                    
                    if(itr.FranchiseCode__c == Null){
                    itr.FranchiseCode__c = mapFromRegVeh.get(itr.Registered_Vehicle__c).Autoline_Franchise_Code__c;}

                    if(itr.Chasis_Number__c == Null){
                    itr.Chasis_Number__c = mapFromRegVeh.get(itr.Registered_Vehicle__c).Chasis_Number__c;}
                    
                    system.debug('Reg Vehicle ID..' + itr.Registered_Vehicle__c);
                    System.debug('Contact..' + itr.ContactId);
                    System.debug('Franchise..' + itr.Franchise__c);
                    System.debug('Branch..' + itr.Branch__c);
                    System.debug('Franchise Code..' + itr.FranchiseCode__c);
                    System.debug('Chasis Number..' + itr.Chasis_Number__c);
                }
            }
            }
        
        }  
      system.debug('Case before insert');
    }
    
    public void caseBeforeUpdate(){
            
        List<id> caseIds = new List<id>();
        List<Case> CasesForCBS = New List<Case>();
        List<Case> CasesForCBSCancelUpd = New List<Case>();
        List<Case> CasesForCBSCancel = New List<Case>();
        
        Date todaysdt = Date.today();
        DateTime completionDate = System.now();
                        
        String queueIdBL = [select Id, Name, DeveloperName from Group where Type = 'Queue' and 
                                       DeveloperName = 'BL_Pending_SMS_Queue' Limit 1].Id; 
        system.debug('BL Queue ID-->' + queueIdBL);
        
        ID vrecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Servicing_and_Grooming').getRecordTypeId();
        system.debug('Record Type ID-->' + vrecordTypeID);
        
        for(Case itr : caseTh.lstCaseInContext){
             /* for SLA*/
             System.debug('Case record - before update->' + itr);
             
             if( (itr.Status == 'Interim Call Made' || itr.Status == 'Reassign (Call Made)' ||
                  itr.Status == 'Interim Reply Sent' || itr.Status =='Closed' ||  itr.Status=='Reassign (Email Sent)'
                  || itr.Status =='Pending for Documents') && 
                (itr.Is_First_Response_Completed__c==False) && (itr.Is_Case_Assigned_to_SA__c == TRUE) && 
                (itr.SlaStartDate <= completionDate) && (itr.SlaExitDate == null))
             {
                    itr.Is_First_Response_Completed__c = TRUE;
                    itr.First_Response_Date_Time__c = DateTime.now();
               
                 /* checking of business hours or out of business hours - start */
                    system.debug('Case First Response Date/Time  ->' + itr.First_Response_Date_Time__c);
                    itr.Is_Not_Business_Day_FirstResponse__c = BusinessHoursUtility.IsBusinessDtTm(itr.First_Response_Date_Time__c);
                    System.debug('Is Business Day check -> ' + itr.Is_Not_Business_Day_FirstResponse__c);
                 
                    if(!itr.Is_Not_Business_Day_FirstResponse__c){
                        itr.Deferred_First_Response_Date_Time__c = BusinessHoursUtility.GetNextBusinessDtTm(itr.First_Response_Date_Time__c);
                    }else{ 
                        itr.Deferred_First_Response_Date_Time__c = itr.First_Response_Date_Time__c; }
                 
                    long BusinessHrsAgent = BusinessHoursUtility.GetBusinessHrs(itr.Deferred_Assigned_Date_Time__c, itr.Deferred_First_Response_Date_Time__c);
                    system.debug('Calculated Hrs b/w two dates Agent SLA in millisecs' + BusinessHrsAgent);
                 
                    Decimal vAgtSLAinMins = BusinessHrsAgent / 60000.00;
                    system.debug('Agent SLA mins and secs ->' + vAgtSLAinMins);
                   
                    decimal AgtSLAvar = vAgtSLAinMins.round(System.RoundingMode.DOWN);
                   
                        itr.Agent_SLA__c = AgtSLAvar.intValue();
                    system.debug('Agent SLA in Mins ->' + itr.Agent_SLA__c);
                 
                    if(itr.Status=='Interim Call Made' || itr.Status == 'Reassign (Call Made)')
                    { itr.First_Response_Channel__c = 'Call'; }
                    
                 	if(itr.Status=='Interim Reply Sent' || itr.Status=='Reassign (Email Sent)')
                    { itr.First_Response_Channel__c = 'Email';}
                 
                 	if(itr.Status=='Closed' || itr.status=='Pending for Documents')
                    { itr.First_Response_Channel__c = 'NIL';}
                 
                    caseIds.add(itr.id);
             }             
  
            if(itr.SMS_Status__c=='Confirm Appointment' && itr.Case_Category__c == 'Booking List' && itr.Status=='Open' && 
              itr.SMS_Link_Expired__c==False && itr.OwnerId!=null && itr.OwnerId==queueIdBL && itr.RecordTypeId==vrecordTypeID
              && itr.Is_CSE_Remarks_Updated__c==false){
                  system.debug('--- Queuable future call out to cbs update only ---');
                  casesForCBS.add(itr);
              }
     
            if(itr.SMS_Status__c=='Cancel Appointment' && itr.Case_Category__c == 'Booking List' && itr.Status=='Open' && 
              itr.SMS_Link_Expired__c==False && itr.OwnerId!=null && itr.OwnerId==queueIdBL && itr.RecordTypeId==vrecordTypeID
              && itr.Is_CSE_Remarks_Updated__c==false){
                  system.debug('--- Queuable future call out to cbs update for cancel booking ---');
                  casesForCBSCancelUpd.add(itr);
              }
            
            if(itr.SMS_Status__c=='Cancel Appointment' && itr.Case_Category__c == 'Booking List' && itr.Status=='Open' && 
              itr.SMS_Link_Expired__c==False && itr.OwnerId!=null && itr.OwnerId==queueIdBL && itr.RecordTypeId==vrecordTypeID
              && itr.Is_CSE_Remarks_Updated__c==true){
                  system.debug('--- Queuable future call out to cbs cancel ---');
                  casesForCBSCancel.add(itr);
              }
            
            if(itr.Registered_Vehicle__c != Null){
                if(mapFromRegVeh != null && mapFromRegVeh.size() > 0){
                    if(mapFromRegVeh.containsKey(itr.Registered_Vehicle__c)){
                        itr.ContactId = mapFromRegVeh.get(itr.Registered_Vehicle__c).Contact__c;
                        itr.Franchise__c = mapFromRegVeh.get(itr.Registered_Vehicle__c).Franchise__c;
                        itr.Branch__c = mapFromRegVeh.get(itr.Registered_Vehicle__c).Branch__c;
                        itr.FranchiseCode__c = mapFromRegVeh.get(itr.Registered_Vehicle__c).Autoline_Franchise_Code__c;
                        itr.Chasis_Number__c = mapFromRegVeh.get(itr.Registered_Vehicle__c).Chasis_Number__c;
                        system.debug('Reg Vehicle ID..' + itr.Registered_Vehicle__c);
                        System.debug('Contact..' + itr.ContactId);
                        System.debug('Franchise..' + itr.Franchise__c);
                        System.debug('Branch..' + itr.Branch__c);
                        System.debug('Franchise Code..' + itr.FranchiseCode__c);
                        System.debug('Chasis Number..' + itr.Chasis_Number__c);
                    }
                }
            }
        }
        
      
        List<CaseMilestone> milestonesToUpdate = new List<CaseMilestone>();
        system.debug('Case Ids to update milestone-->' + caseIds);
        for(CaseMilestone cm : [Select Id,CompletionDate,CaseId From CaseMilestone Where CaseId in :caseIds and completionDate = null]){
            for(String currentMilestone : caseIds){
                    cm.CompletionDate = completionDate;
                    milestonesToUpdate.add(cm);
            }
        }
        
        if(milestonesToUpdate.size()>0){update milestonesToUpdate;}
        
        if(casesForCBS.size()>0){
            // queuable job for update remarks in cbs
            System.debug('Queuable job from BusinessRulesHandlerCase - UpdateCBSQueuable');
            ID jobId = System.enqueueJob(New UpdateCBSQueuable(casesForCBS));
        }
        
        
        if(casesForCBSCancelUpd.size()>0){
            // queuable job for update and cancel remarks in cbs
            System.debug('Queuable job from BusinessRulesHandlerCase - Update CancelCBSQueuable');
            ID jobId = System.enqueueJob(New CancelCBSUpdQueuable(casesForCBSCancelUpd));
        }
        
        if(casesForCBSCancel.size()>0){
            // queuable job for update and cancel remarks in cbs
            System.debug('Queuable job from BusinessRulesHandlerCase - CancelCBSQueuable');
            ID jobId = System.enqueueJob(New CancelCBSQueuable(casesForCBSCancel));
        }
  
        
        system.debug('Case before update');
    }
        
    
        
     public void caseAfterInsert(){
        /*system.debug('After Insert');
        
        List<Case> casesList = new List<Case>();
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='Auto-assignment Hours']; 
        
        Boolean isWithin =  Businesshours.isWithin(bh.Id, System.now());
        List<STring> caseIds = new List<String>();
        if(isWithin){
            Group unassignedEmailQueue = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Unassigned_Email_Queue'];
            Group routingQueue = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Email_Auto_Assignment_Queue'];
        
        List<Case> unassignedCases = [Select Id, Assigned_Date_Time__c, EntitlementId  FROM Case WHERE OwnerId =: unassignedEmailQueue.Id FOR UPDATE];
            for(Case c: unassignedCases){
             c.OwnerId = routingQueue.Id;
             c.Status = 'Open';
             casesList.add(c);  
             caseIds.add(c.Id);
                system.debug('****INSIDE After Update' + c.Assigned_Date_Time__c);
            }
        }
        if(!casesList.isEmpty()){
            update casesList;
            SetDeferredCreatedDateTime.AssignDeferredCreatedDateTime(caseIds);
        } */
}
    
    public void caseAfterUpdate(){
        system.debug('After Update');
        
        List<Case> casesList = new List<Case>();
        Boolean runTrigger = true;
        
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='Auto-assignment Hours']; 
        
         Boolean isWithin =  Businesshours.isWithin(bh.Id, System.now());
        List<STring> caseIds = new List<String>();
        if(isWithin && runTrigger == true){
                    Group unassignedEmailQueue = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Unassigned_Email_Queue'];
                    Group routingQueue = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Email_Auto_Assignment_Queue'];
                    List<Case> unassignedCases = [Select Id, Assigned_Date_Time__c, EntitlementId  FROM Case WHERE OwnerId =: unassignedEmailQueue.Id AND Status = 'New'];
                    
            for(Case c: unassignedCases){
                     c.OwnerId = routingQueue.Id;
                     c.Status = 'Open';
					 c.Auto_assigned_case__c = true;
                     casesList.add(c);  
                     caseIds.add(c.Id);
                        system.debug('****INSIDE After Update' + casesList);
                    }
            
                    if(!casesList.isEmpty()){
                        update casesList;
                    }
                    runTrigger = false;
            }
        }
        
}
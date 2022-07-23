public class SFUTableController {
    
    //To return initial case sfu records
    @AuraEnabled
    public static SFUWrapper getSFURecords(Integer initialRows, String vLocation){
        SFUWrapper SFUWrapper= new SFUWrapper();
        try{  
            Survey_Date_Master__c SFUDates = [SELECT From_Date__c, To_Date__c FROM 
                                          Survey_Date_Master__c where Survey_Type__c = 'SFU' limit 1];
            SFUWrapper.FromDate = SFUDates.From_Date__c;
            SFUWrapper.ToDate = SFUDates.To_Date__c;
          
            for(case c: [SELECT Id, Location__c, CaseNumber, Do_Not_Call_Survey__c,
                                Survey_Status__c, Additional_Remarks__c, 
                              	Survey_Call_Log__r.Call_back_Date__c,
                              	Survey_Call_Log__r.Call_back_Time__c,
                     			Survey_Call_Log__r.X1st_Call_Date__c,
                              	Survey_Call_Log__r.X1st_Call_Status__c, 
                              	Survey_Call_Log__r.X1st_Call_Time__c,
                              	Survey_Call_Log__r.X2nd_Call_Date__c,
                              	Survey_Call_Log__r.X2nd_Call_Status__c,
                              	Survey_Call_Log__r.X2nd_Call_Time__c,
                         		Owner.alias
                        	    FROM Case 
                              	Where CreatedDate >= :SFUWrapper.FromDate and CreatedDate <= :SFUWrapper.ToDate 
                         		And Status != 'Closed'
                     			AND Survey_Type__c = 'SFU' AND Survey_Status__c NOT IN ('Completed', 'Incomplete')
                     			ORDER BY Location__c, CaseNumber
                     			Limit :initialRows OFFSET 0]){
                        
       		SFUSurvey SFUSingle = New SFUSurvey();
        	SFUSingle.CaseId = c.Id;
        	SFUSingle.CaseNo = c.CaseNumber;
			SFUSingle.DoNotCallSurvey = c.Do_Not_Call_Survey__c;
        	SFUSingle.Loca = c.Location__c;
        	SFUSingle.SurveyStatus = c.Survey_Status__c;
        	SFUSingle.AddiRemarks = c.Additional_Remarks__c;
        	SFUSingle.CallbackDate = c.Survey_Call_Log__r.Call_back_Date__c;
        	SFUSingle.CallbackTime = c.Survey_Call_Log__r.Call_back_Time__c;
        	SFUSingle.firstCallDate = c.Survey_Call_Log__r.X1st_Call_Date__c;
        	SFUSingle.firstCallTime = c.Survey_Call_Log__r.X1st_Call_Time__c;
        	SFUSingle.firstCallStatus = c.Survey_Call_Log__r.X1st_Call_Status__c;
        	SFUSingle.secondCallDate = c.Survey_Call_Log__r.X2nd_Call_Date__c;
        	SFUSingle.secondCallTime = c.Survey_Call_Log__r.X2nd_Call_Time__c;
        	SFUSingle.secondCallStatus = c.Survey_Call_Log__r.X2nd_Call_Status__c;
            SFUSingle.agentno = c.Owner.Alias;
            SFUSingle.Owner = c.OwnerId;
        	SFUWrapper.sfusList.add(SFUSingle);
       	 	}
            
         	SFUWrapper.totalRecords = [SELECT COUNT() FROM Case 
                                           where CreatedDate >= :SFUWrapper.FromDate and CreatedDate <= :SFUWrapper.ToDate
                                           AND Status!='Closed' 
                							AND Survey_Type__c ='SFU'
                							And Survey_Status__c NOT IN('Completed', 'Incomplete')
                                          ];
            system.debug(SFUWrapper.FromDate);
            system.debug(SFUWrapper.totalRecords);
            SFUWrapper.message = 'SFU Survey records are loaded';
            SFUWrapper.success = true;
        }
        catch(Exception e){
            SFUWrapper.message = e.getMessage();
            SFUWrapper.success = false;
        }
        system.debug(SFUWrapper.sfusList);
        return SFUWrapper;
    }
    
      @AuraEnabled
    public static SFUWrapper getSFUByLoc(Integer initialRows, String vLocation){
        system.debug('Location' + vLocation);
        SFUWrapper SFUWrapper= new SFUWrapper();
        try{  
            Survey_Date_Master__c SFUDates = [SELECT From_Date__c, To_Date__c FROM 
                                          Survey_Date_Master__c where Survey_Type__c = 'SFU' limit 1];
            SFUWrapper.FromDate = SFUDates.From_Date__c;
            SFUWrapper.ToDate = SFUDates.To_Date__c;
          
            for(case c: [SELECT Id, Location__c, CaseNumber,  
                                Survey_Status__c, Additional_Remarks__c, 
                              	Survey_Call_Log__r.Call_back_Date__c,
                              	Survey_Call_Log__r.Call_back_Time__c,
                     			Survey_Call_Log__r.X1st_Call_Date__c,
                              	Survey_Call_Log__r.X1st_Call_Status__c, 
                              	Survey_Call_Log__r.X1st_Call_Time__c,
                              	Survey_Call_Log__r.X2nd_Call_Date__c,
                              	Survey_Call_Log__r.X2nd_Call_Status__c,
                              	Survey_Call_Log__r.X2nd_Call_Time__c,
                         		Owner.alias
                        	    FROM Case 
                              	Where CreatedDate >= :SFUWrapper.FromDate and CreatedDate <= :SFUWrapper.ToDate 
                         		And Status != 'Closed' AND Location__c =: vLocation
                     			AND Survey_Type__c = 'SFU' AND Survey_Status__c NOT IN ('Completed', 'Incomplete')
                     			ORDER BY Location__c, CaseNumber
                     			Limit :initialRows OFFSET 0]){
                        
       		SFUSurvey SFUSingle = New SFUSurvey();
        	SFUSingle.CaseId = c.Id;
        	SFUSingle.CaseNo = c.CaseNumber;
        	SFUSingle.Loca = c.Location__c;
        	SFUSingle.SurveyStatus = c.Survey_Status__c;
        	SFUSingle.AddiRemarks = c.Additional_Remarks__c;
        	SFUSingle.CallbackDate = c.Survey_Call_Log__r.Call_back_Date__c;
        	SFUSingle.CallbackTime = c.Survey_Call_Log__r.Call_back_Time__c;
        	SFUSingle.firstCallDate = c.Survey_Call_Log__r.X1st_Call_Date__c;
        	SFUSingle.firstCallTime = c.Survey_Call_Log__r.X1st_Call_Time__c;
        	SFUSingle.firstCallStatus = c.Survey_Call_Log__r.X1st_Call_Status__c;
        	SFUSingle.secondCallDate = c.Survey_Call_Log__r.X2nd_Call_Date__c;
        	SFUSingle.secondCallTime = c.Survey_Call_Log__r.X2nd_Call_Time__c;
        	SFUSingle.secondCallStatus = c.Survey_Call_Log__r.X2nd_Call_Status__c;
            SFUSingle.agentno = c.Owner.Alias;
            SFUSingle.Owner = c.OwnerId;
        	SFUWrapper.sfusList.add(SFUSingle);
       	 	}
            
            SFUWrapper.totalRecords = [SELECT COUNT() FROM Case 
                                           where CreatedDate >= :SFUWrapper.FromDate 
                                       and CreatedDate <= :SFUWrapper.ToDate
                                           AND Status!='Closed' AND Location__c =: vLocation
                							AND Survey_Type__c ='SFU'
                							And Survey_Status__c NOT IN('Completed', 'Incomplete')
                                          ];
            system.debug(SFUWrapper.FromDate);
            system.debug(SFUWrapper.totalRecords);
            SFUWrapper.message = 'SFU Survey records are loaded for ' + vLocation;
            SFUWrapper.success = true;
        }
        catch(Exception e){
            SFUWrapper.message = e.getMessage();
            SFUWrapper.success = false;
        }
        system.debug(SFUWrapper.sfusList);
        return SFUWrapper;
    }
    
    //To return additional records based on offset
    @AuraEnabled
    public static List<SFUSurvey> loadSFURecords(Integer rowLimit,Integer rowOffset, String vLocation){
        
         	Survey_Date_Master__c SFUDates = [SELECT From_Date__c, To_Date__c FROM 
                                          Survey_Date_Master__c where Survey_Type__c = 'SFU' limit 1];
        
        	List<SFUSurvey> sfusList = new List<SFUSurvey>();
        
        	if(vLocation=='All'){
             for(case c: [SELECT Id, Location__c, CaseNumber,  
                                Survey_Status__c, Additional_Remarks__c, 
                              	Survey_Call_Log__r.Call_back_Date__c,
                              	Survey_Call_Log__r.Call_back_Time__c,
                     			Survey_Call_Log__r.X1st_Call_Date__c,
                              	Survey_Call_Log__r.X1st_Call_Status__c, 
                              	Survey_Call_Log__r.X1st_Call_Time__c,
                              	Survey_Call_Log__r.X2nd_Call_Date__c,
                              	Survey_Call_Log__r.X2nd_Call_Status__c,
                              	Survey_Call_Log__r.X2nd_Call_Time__c,
                          		Owner.alias
                        	    FROM Case 
                              	Where CreatedDate >= :SFUDates.From_Date__c and CreatedDate <= :SFUDates.To_Date__c
                     			AND Status != 'Closed'
                     			AND Survey_Type__c = 'SFU' AND Survey_Status__c NOT IN ('Completed', 'Incomplete')
                     			ORDER BY Location__c, CaseNumber
                     			LIMIT :rowLimit OFFSET :rowOffset]){
                        
       		SFUSurvey SFUSingle = New SFUSurvey();
        	SFUSingle.CaseId = c.Id;
        	SFUSingle.CaseNo = c.CaseNumber;
        	SFUSingle.Loca = c.Location__c;
        	SFUSingle.SurveyStatus = c.Survey_Status__c;
        	SFUSingle.AddiRemarks = c.Additional_Remarks__c;
        	SFUSingle.CallbackDate = c.Survey_Call_Log__r.Call_back_Date__c;
        	SFUSingle.CallbackTime = c.Survey_Call_Log__r.Call_back_Time__c;
        	SFUSingle.firstCallDate = c.Survey_Call_Log__r.X1st_Call_Date__c;
        	SFUSingle.firstCallTime = c.Survey_Call_Log__r.X1st_Call_Time__c;
        	SFUSingle.firstCallStatus = c.Survey_Call_Log__r.X1st_Call_Status__c;
        	SFUSingle.secondCallDate = c.Survey_Call_Log__r.X2nd_Call_Date__c;
        	SFUSingle.secondCallTime = c.Survey_Call_Log__r.X2nd_Call_Time__c;
        	SFUSingle.secondCallStatus = c.Survey_Call_Log__r.X2nd_Call_Status__c;
            SFUSingle.agentno = c.Owner.Alias;
            SFUSingle.Owner = c.OwnerId;
        	sfusList.add(SFUSingle);
       	 	}
        	
            }
        
        	if(vLocation!='All'){
                for(case c: [SELECT Id, Location__c, CaseNumber,  
                                Survey_Status__c, Additional_Remarks__c, 
                              	Survey_Call_Log__r.Call_back_Date__c,
                              	Survey_Call_Log__r.Call_back_Time__c,
                     			Survey_Call_Log__r.X1st_Call_Date__c,
                              	Survey_Call_Log__r.X1st_Call_Status__c, 
                              	Survey_Call_Log__r.X1st_Call_Time__c,
                              	Survey_Call_Log__r.X2nd_Call_Date__c,
                              	Survey_Call_Log__r.X2nd_Call_Status__c,
                              	Survey_Call_Log__r.X2nd_Call_Time__c,
                             	Owner.alias
                        	    FROM Case 
                              	Where CreatedDate >= :SFUDates.From_Date__c and CreatedDate <= :SFUDates.To_Date__c
                     			AND Status != 'Closed' AND Location__c=:vLocation
                     			AND Survey_Type__c = 'SFU' AND Survey_Status__c NOT IN ('Completed', 'Incomplete')
                     			ORDER BY Location__c, CaseNumber
                     			LIMIT :rowLimit OFFSET :rowOffset]){
                        
       		SFUSurvey SFUSingle = New SFUSurvey();
        	SFUSingle.CaseId = c.Id;
        	SFUSingle.CaseNo = c.CaseNumber;
        	SFUSingle.Loca = c.Location__c;
        	SFUSingle.SurveyStatus = c.Survey_Status__c;
        	SFUSingle.AddiRemarks = c.Additional_Remarks__c;
        	SFUSingle.CallbackDate = c.Survey_Call_Log__r.Call_back_Date__c;
        	SFUSingle.CallbackTime = c.Survey_Call_Log__r.Call_back_Time__c;
        	SFUSingle.firstCallDate = c.Survey_Call_Log__r.X1st_Call_Date__c;
        	SFUSingle.firstCallTime = c.Survey_Call_Log__r.X1st_Call_Time__c;
        	SFUSingle.firstCallStatus = c.Survey_Call_Log__r.X1st_Call_Status__c;
        	SFUSingle.secondCallDate = c.Survey_Call_Log__r.X2nd_Call_Date__c;
        	SFUSingle.secondCallTime = c.Survey_Call_Log__r.X2nd_Call_Time__c;
        	SFUSingle.secondCallStatus = c.Survey_Call_Log__r.X2nd_Call_Status__c;
            SFUSingle.agentno = c.Owner.Alias;
            SFUSingle.Owner = c.OwnerId;
        	sfusList.add(SFUSingle);
       	 	}
            }
        
        	return sfusList;
    }
    
    
    
    @AuraEnabled
    public static Integer assignAgent(List<SFUSurvey> vselRecs, String vselAgentNo){
        system.debug('selected records---> ' + vselRecs);
        system.debug('selected agent...>' + vselAgentNo);
        
        try{
        	List<User> u = [select id from User where Alias =: vselAgentNo];
        	list<case> listCasetoupdate = new list<case>();
        
        	for(SFUSurvey s:vselRecs){
            	Case c = New Case(); 
                	c.Id = s.Caseid;
            	c.ownerid = u <> null && u.size() > 0 ? u[0].id : null;
            	c.status = 'Open';
            	listCasetoupdate.add(c);
        	}
        
        	system.debug(listCasetoupdate);
        	if(listCasetoupdate.size()>0){
        		update listCasetoupdate;
        		return listCasetoupdate.size();
           	}
            return null;
        }catch(Exception e){ 
            throw new AuraHandledException(e.getMessage());
        	}
        }
    
    // wrapper class
    public class SFUWrapper{
        @AuraEnabled
        public Date FromDate;
        
        @AuraEnabled 
        public Date ToDate;
        
        @AuraEnabled
        public Integer totalRecords = 0;
       
        @AuraEnabled
        public List<SFUSurvey> sfusList = new List<SFUSurvey>();
        
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;
    }
    
    public class SFUSurvey{
        @AuraEnabled public id CaseId {get;set;}
        @AuraEnabled public String CaseNo {get;set;}
		@AuraEnabled public Boolean DoNotCallSurvey {get;set;}
        @AuraEnabled public String Loca {get;set;}
        @AuraEnabled public String SurveyStatus {get;set;}
        @AuraEnabled public String AddiRemarks {get;set;}
        @AuraEnabled public Date CallbackDate {get;set;}
        @AuraEnabled public String CallbackTime {get;set;}
        @AuraEnabled public Date firstCallDate {get;set;}
        @AuraEnabled public String firstCallTime {get;set;}
        @AuraEnabled public String firstCallStatus {get;set;}
        @AuraEnabled public Date secondCallDate {get;set;}
        @AuraEnabled public String secondCallTime {get;set;}
        @AuraEnabled public String secondCallStatus {get;set;}
        @AuraEnabled public String agentno {get;set;}
        @AuraEnabled public String Owner {get;set;}
	}
 
}
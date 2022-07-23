@isTest
public class Test_BusinessRulesHandlerCase {

     @isTest
    public static void testTriggerCaseInsert(){

        test.startTest();
        
        List<Account> acts = new List<Account>();
		Account myAcc = new Account(Name='TestAct', phone='1001231234');
		acts.add(myAcc);

		Account busAcc = new Account(Name = 'TestForMS', phone='4567890999');
		acts.add(busAcc);
		insert acts;
					
		Entitlement entl = new Entitlement(Name='First Response - TestForMS', AccountId=busAcc.Id, EndDate= date.today().addDays(5), StartDate= date.today());
		insert entl;

		 String entlId;
		if (entl != null)
		entlId = entl.Id; 
        
        
        /* create contact */
        Contact ct1 = new Contact();
        ct1.FirstName = 'xyzFirst';
        ct1.LastName = 'XyZLast';
        ct1.Email = 'xyzmail@mail.com';
        ct1.NRIC_Passport_No__c='12345678';
        ct1.MobilePhone='81111111';
      
        insert ct1;

        /* create registered vehicle */
        registered_vehicle__c r = New registered_vehicle__c();
        r.Name = 'test new';
        r.Branch__c ='CCK';
        r.Franchise__c = 'KIAPC';
        r.Contact__c = ct1.id;
        r.Registration_Number__c = 'SGH1234';
        insert r;
        
        List<id> caseIds = new List<id>();
        
        /* create a case */
        Case c11 = New Case(Status='New', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Franchise__c='', Registered_Vehicle__c=r.Id, 
                            contactid=ct1.id);
         
        insert c11;
        
        caseIds.add(c11.id);
        
      	//Test.setCreatedDate(c11.id, DateTime.now().addHours(-1));   
       
        registered_vehicle__c r1= New registered_vehicle__c();
        r1.Name = 'testing from old to new';
        r1.Branch__c ='CCF';
        r1.Franchise__c = 'CITPC';
        r1.Contact__c = ct1.id;
        r1.Registration_Number__c = 'SGH111';
        insert r1;       
        
        c11.Registered_Vehicle__c = r1.id;
        update c11;

    
     	Case c = New Case(Status='Open', Origin='Email', Is_Case_Assigned_to_SA__c=TRUE, 
                          Is_First_Response_Completed__c = FALSE, Assigned_Date_Time__c=datetime.now(), 
                          Deferred_Assigned_Date_Time__c=datetime.now(),
                             Deferred_Created_Date_Time__c=datetime.now(), SlaStartDate =datetime.now(),
                          EntitlementId = entlId
                         );
          
        insert c;   
          
        
        
        c.Status = 'Interim Call Made';
        
        update c;
        caseIds.add(c.id);
        
        Case c1 = New Case(Status='Open', Origin='Email', Is_Case_Assigned_to_SA__c=TRUE, 
                          Is_First_Response_Completed__c = FALSE,Assigned_Date_Time__c=datetime.now(), Deferred_Assigned_Date_Time__c=datetime.now(),
                             Deferred_Created_Date_Time__c=datetime.now(),
                          SlaStartDate =datetime.now(), EntitlementId = entlId
                         );
        insert c1;   
        
        c1.Status = 'Interim Reply Sent';
        update c1;
        caseIds.add(c1.id);
        
        Case c2 = New Case(Status='Closed', Origin='Email', Is_Case_Assigned_to_SA__c=TRUE, 
                          Is_First_Response_Completed__c = FALSE, SuppliedEmail ='xyzmail99@mail.com',
                          Assigned_Date_Time__c=datetime.now(), Deferred_Assigned_Date_Time__c=datetime.now(),
                             Deferred_Created_Date_Time__c=datetime.now(),
                           SlaStartDate =datetime.now(), EntitlementId = entlId);
        
        insert c2;   
        caseIds.add(c2.id);
        
        DateTime completionDate = System.now();
        
        List<CaseMilestone> milestonesToUpdate = new List<CaseMilestone>();
        system.debug('Case Ids to update milestone-->' + caseIds);
        for(CaseMilestone cm : [Select Id,CompletionDate,CaseId From CaseMilestone Where CaseId in :caseIds and completionDate = null]){
            for(String currentMilestone : caseIds){
                    cm.CompletionDate = completionDate;
                    milestonesToUpdate.add(cm);
            }
        }
        
        if(milestonesToUpdate.size()>0){update milestonesToUpdate;}
        
     
        test.stoptest();
          
    }
 
     
}
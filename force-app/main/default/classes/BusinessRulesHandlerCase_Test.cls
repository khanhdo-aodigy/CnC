@isTest
public class BusinessRulesHandlerCase_Test {
    
    @isTest
    public static void testTriggerCaseInsert()
    {
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
        //ct1.Email = 'xyzmail@mail.com';
        ct1.NRIC_Passport_No__c='12345678';
        ct1.MobilePhone='81111111';
      
        insert ct1;
        
        Account personAcc = Test_DataFactory.createPerson(false, 'name', 'Customer');
        personAcc.PersonEmail = 'xyzmail@mail.com';
        insert personAcc;    
        personAcc = [SELECT Id, PersonContactId, PersonEmail FROM Account WHERE IsPersonAccount = true LIMIT 1];
        Contact personCon = [SELECT Id FROM Contact WHERE Id =: personAcc.PersonContactId];

        /* create registered vehicle */
        registered_vehicle__c r = New registered_vehicle__c();
        r.Name = 'test new';
        r.Branch__c ='CCK';
        r.Franchise__c = 'KIAPC';
        r.Contact__c = personCon.id;
        r.Registration_Number__c = 'SGH1234';
        insert r;
        
        List<id> caseIds = new List<id>();
        List<Case> cases = new list<Case>();
        
        /* create a case */
        Case c11 = New Case(Status='New', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Franchise__c='', Registered_Vehicle__c=r.Id, 
                            contactid=personCon.id);
         
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
        
        
         Case c12 = New Case(Status='Closed', Origin='Email', Is_Case_Assigned_to_SA__c=TRUE, 
                          Is_First_Response_Completed__c = FALSE,Assigned_Date_Time__c=datetime.now(), Deferred_Assigned_Date_Time__c=datetime.now(),
                             Deferred_Created_Date_Time__c=datetime.now(),
                          SlaStartDate =datetime.now(), EntitlementId = entlId
                         );
        insert c12;   
        
        c12.Status = 'Closed';
        update c12;
        caseIds.add(c12.id);
        
        
        Case c2 = New Case(Status='Closed', Origin='Email', Is_Case_Assigned_to_SA__c=TRUE, 
                          Is_First_Response_Completed__c = FALSE, SuppliedEmail ='xyzmail99@mail.com',
                          Assigned_Date_Time__c=datetime.now(), Deferred_Assigned_Date_Time__c=datetime.now(),
                             Deferred_Created_Date_Time__c=datetime.now(),
                           SlaStartDate =datetime.now(), EntitlementId = entlId);
        
        //insert c2;
        cases.add(c2);
        caseIds.add(c2.id);
        
         /* create a case */
        Case c112 = New Case(Status='New', Origin='Email', SuppliedEmail ='noreply@mercedes-benz.com', 
                             Franchise__c='', Registered_Vehicle__c=r.Id 
                            );
         
        insert c112;
        
        caseIds.add(c112.id);
        
        DateTime completionDate = System.now();
        
        Group unassignedEmailQueue = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Unassigned_Email_Queue'];
        Group routingQueue = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Email_Auto_Assignment_Queue'];
        
        List<BusinessHours> bhs=[select id from BusinessHours where Name='Default'];
        Case autoAsssignmentCase = new Case(Status='New', Origin='Email', OwnerId = unassignedEmailQueue.Id, Priority='P2');
        cases.add(autoAsssignmentCase);
        insert cases;
        
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


    @isTest
    static void createDummyCase(){
        Account paCust = Test_DataFactory.createPerson(true, 'TestingPACust', 'Customer');
        paCust = [SELECT Id, PersonContactId FROM Account WHERE Id =: paCust.Id];
        System.Test.startTest();
            TriggerExclusion.excludeTrigger('Case', true);
            Test_DataFactory.createCase(true, paCust.PersonContactId);
        System.Test.stopTest();

        System.assert( ([SELECT Id FROM Case ]).size() == 1 );
    }

}
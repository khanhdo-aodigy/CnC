@isTest
public class Test_setDeferredCreatedDateTime {
	@isTest
    public static void testCaseInsert(){
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
        
		Group testGroup = new Group(Name='Unassigned Email Queue', Type='Queue');
		insert testGroup;

		System.runAs(new User(Id=UserInfo.getUserId()))
		{
    		QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
    		insert testQueue;
		}

		Case aCase = new Case(Status='New', Origin='Email', SuppliedEmail ='xyz1mail@mail.com', Franchise__c='', Registered_Vehicle__c=r.Id, 
                            contactid=ct1.id, OwnerId = testGroup.Id);
		insert aCase;
		Test.setCreatedDate(aCase.id, DateTime.now().addHours(-1));     
        
        system.debug('Case Id here-->' + aCase.id);
        
       	List<String> vCaseId = New List<string>();
		vCaseId.add(aCase.Id);
        
        system.debug('vcase id ->' + vCaseId);
        test.startTest();      
       
        /* create a case */
        Case c11 = New Case(Status='New', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Franchise__c='', Registered_Vehicle__c=r.Id, 
                            contactid=ct1.id, OwnerId = testGroup.Id);
     
          insert c11; 
        
        
      	SetDeferredCreatedDateTime.AssignDeferredCreatedDateTime(vCaseId);
        
        test.stopTest();
        
        
      	
        
        
    }
    
  
}
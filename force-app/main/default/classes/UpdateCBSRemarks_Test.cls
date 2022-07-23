@isTest
private class UpdateCBSRemarks_Test {

      @isTest static void testupdcbs(){
       
          Test.startTest();
  
          try{
            	Test.setMock(HttpCalloutMock.class, new externalMock());
  				
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
              
              UpdateCBSRemarks.UpdBookingRemarks('241477', 'P', 'test comments', 'test remarks');
              }
        	catch(exception e){}
    	Test.stopTest();
      }
}
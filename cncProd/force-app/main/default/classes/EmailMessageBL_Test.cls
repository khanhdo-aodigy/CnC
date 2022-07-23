@isTest
public class EmailMessageBL_Test {

    @isTest
    public static void testTriggerCaseInsertER(){

        test.startTest();
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and 
                                  Name = 'Enquiry and Request'].Id;
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
      
        /* create a case */
        Case c11 = New Case(Status='Closed', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Franchise__c='', Registered_Vehicle__c=r.Id, 
                            contactid=ct1.id, recordtypeid=strRecordTypeId);
         
        insert c11;
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test123@abc.org', Incoming = True, 
                                      ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', 
                                      Subject = 'Test email with att', TextBody = '23456 ', 
                                      ParentId = c11.Id)); 
        insert newEmail;
     
            
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c11.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
    }
    
    
 @isTest
    public static void testTriggerCaseInsertER1(){

        test.startTest();
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and 
                                  Name = 'Enquiry and Request'].Id;
        /* create a case */
        Case c11 = New Case(Status='Closed', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Franchise__c='',
                              recordtypeid=strRecordTypeId);
         
        insert c11;
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', 
                                      ParentId = c11.Id)); 
        insert newEmail;
    }
    
@isTest
    public static void testTriggerCaseInsertCR(){        
        //// case without contact scenario
      test.startTest();
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and 
                                  Name = 'Change Request (Ownership, Particulars, Vehicle Registration Number)'].Id;
        /* create a case */
        Case c111 = New Case(Status='Open', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Franchise__c='', recordtypeid=strRecordTypeId);
         
        insert c111;
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = false, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', 
                                      ParentId = c111.Id)); 
        insert newEmail;
        
        c111.status = 'Pending for Documents';
        c111.Email_Sent_Date__c = Date.today();
         Update c111;

        test.stoptest();
    }

    @isTest
    public static void testTriggerCaseInsertCR1(){        
        //// case without contact scenario
      test.startTest();
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and 
                                  Name = 'Change Request (Ownership, Particulars, Vehicle Registration Number)'].Id;
        /* create a case */
        Case c111 = New Case(Status='New', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Franchise__c='', recordtypeid=strRecordTypeId);
         
        insert c111;
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = false, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', 
                                      ParentId = c111.Id)); 
        insert newEmail;
        test.stoptest();
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('EmailMessage', true);
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and 
                                  Name = 'Enquiry and Request'].Id;
        /* create a case */
        Case c11 = New Case(Status='Closed', Origin='Email', SuppliedEmail ='xyzmail@mail.com', Franchise__c='',
                              recordtypeid=strRecordTypeId);
         
        insert c11;
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', 
                                      ParentId = c11.Id)); 
        insert newEmail;
        TriggerExclusion.excludeTrigger('EmailMessage', false);
    }
}
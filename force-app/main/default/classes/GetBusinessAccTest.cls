@isTest
private class GetBusinessAccTest {

	static testMethod void TestGetCustomerId(){
        List<Contact> cons = new List<Contact>();
		       string b;
        		
        for(Integer i=0;i<2;i++) {
            Contact a = new Contact(Email='TestAccount@aodigy.com' + i, firstname='Test'+i, lastname='Test'+i);
            cons.add(a);
            b = a.email;
            
        }
        insert cons;  
        
        List<Case> Casey = new List<Case>();
		       string Caseb;
        		
        for(Integer i=0;i<2;i++) {
            Case d = new Case(SuppliedEmail ='TestAccount@aodigy.com' + i, Origin = 'Email', 
                              Car_Registration_Number__c= 'bbbbbb', Status ='New', SuppliedName = 'Test'+i);
            Casey.add(d);
            if(d.Origin == 'Email' && d.SuppliedEmail!=''){
            Caseb = d.SuppliedEmail;
            }
        }
        insert Casey;  
        
        Case Casecheck = [Select id, SuppliedEmail, ContactId, Origin From Case limit 1];
		Contact con2 = [Select id, Email, firstname, lastname From Contact limit 1];
         System.AssertEquals(Caseb, b);  
         
        System.AssertNotEquals(Casecheck.ContactId,Null);
         
    }
    
    
    // method for before insert trigger event...
     static testMethod void TestCaseBeforeInsert(){ 
    
         	// create contact
            Contact a = New Contact(firstname='Test', lastname='Test');            
         	insert a;
         
         	// Create Registered Vehicle
        	Registered_Vehicle__c r = New Registered_Vehicle__c();
         	r.Registration_Number__c='SGG5678';
            r.Contact__c = a.ID;
            r.Branch__c = 'CCA';
         	r.Franchise__c = 'MITCV';  
         	insert r;
         
         	Case c = New Case(Origin = 'Phone', Status ='New', Registered_Vehicle__c = r.Id, ContactId=a.Id);
            insert c;
    }
    
    
       
    // method for before update trigger event...
    static testMethod void TestCaseBeforeUpdate(){
        
          	// create contact
            Contact a = New Contact(firstname='Test', lastname='Test');            
         	insert a;
         
         	// Create Registered Vehicle
        	Registered_Vehicle__c r = New Registered_Vehicle__c();
         	r.Registration_Number__c='SGG5678';
            r.Contact__c = a.ID;
            r.Branch__c = 'CCA';
         	r.Franchise__c = 'MITCV';  
         	insert r;

			contact a1 = New contact();
        	a1.firstname='Test Name 1';
        	a1.lastname='Test Name 2';            
         	insert a1;
        
			Registered_Vehicle__c r1 = New Registered_Vehicle__c();
        	r1.Registration_Number__c='SHY5678';
            r1.Contact__c = a.ID;
            r1.Branch__c = 'CCI';
         	r1.Franchise__c = 'MBC';  
         	insert r1;
         
         	Case c = New Case(Origin = 'Phone', Status ='New', Registered_Vehicle__c = r.Id, ContactId=a.Id);
            insert c;
 
			Case c1 = New Case(Origin = 'Phone', Status ='New', Registered_Vehicle__c = r1.Id, ContactId=a1.Id);
            insert c1; 
        
        	c1.Registered_Vehicle__c = r.id;
        	c1.ContactId = a.id;
        	c1.Franchise__c = r.Franchise__c;
        	update c1;    
    }
 
}
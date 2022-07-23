@isTest
global class Test_BookJoinController {
    Static String testRun = 'dummyData1';
    Static Account act = Test_DataFactory.createPerson(true,testRun, 'Customer');          
    Static Opportunity testOpp = Test_DataFactory.createOpportunity(true,'Dummy',act.id);
    Static Model__c testModel = Test_DataFactory.createmodelId(true,'Dummy Model','CCK','KIAPC');
    Static Variant__c testVariant = Test_DataFactory.createVariant(true,'Dummy Variant',testModel.id,'CCK');
    Static Vehicle_Master__c testvehi = Test_DataFactory.createVehicleMaster(true,'Dummy Veh Master',testVariant.id,testModel.id);
    @testSetup static void setup() {             
        List<Logo__c> logolst =new List<Logo__c>();
        logolst.Add(new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c=''));
        logolst.Add(new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC'));
        logolst.Add(new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC'));
        logolst.Add(new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c=''));
        insert logolst;
        
        Postal_Code__c pc=new Postal_Code__c();
        pc.Name='018915';
        pc.Address_Line_1__c='Qssax';
        pc.Address_Line_2__c='adad';
        pc.Address_Line_3__c='weqwew';
        pc.Country__c='Singapore';
        insert pc;
    }
    
    /*@isTest static void testBookJoin_Lead() {
        Lead testLead = Test_DataFactory.createLead(false,testRun,testRun);
        testLead.PDPA__c='SMS';
        testLead.Postalcode='018915';
        testLead.MobilePhone='6591111111';
        testLead.Email='test@test.com';
        testLead.Street='dummyStreet';
        testLead.City='dummyCity';
        testLead.State='dummyState';
        testLead.Country='dummyCont';
        testLead.Birthdate__c=Date.today();
        insert testLead;
        Test_Drive__c testdrv = Test_DataFactory.createTestDrive(false,testOpp.id);
        testdrv.Model__c=testvehi.id;
        testdrv.Lead__c=testLead.id;   
        testdrv.Date__c=date.today();
        testdrv.Franchise_Code__c='KIAPC';
        testdrv.receive_idemnity_form__c = 'Yes';
        insert testdrv;
        User testUser = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        testUser.Branch_Code__c='CCK';
        testUser.Franchise_Code__c='KIAPC';        
        insert testUser;
        
        User testUser1 = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        testUser1.Branch_Code__c='CCA';
        testUser1.Franchise_Code__c='KIAPC';        
        insert testUser1;
        
        User testUser2 = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        testUser2.Branch_Code__c='CCF';
        testUser2.Franchise_Code__c='KIAPC';        
        insert testUser2;
        

        ApexPages.currentPage().getParameters().put('testdrive_id',testdrv.id);
        ApexPages.currentPage().getParameters().put('id',testvehi.id);
        ApexPages.currentPage().getParameters().put('leadId',testLead.id); 

        system.runAs(testUser){           
            BookJoinController test1 = new BookJoinController();
            test1.custNric='12345678';
            test1.custPhone='91111111';   
            ApexPages.currentPage().getParameters().put('searchType', 'MobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', '91111111');            
            test1.searchCustNric();
            test1.custPost='018915';
            test1.postalChange(); 
            test1.save();
        }
        system.runAs(testUser1){           
            BookJoinController test1 = new BookJoinController();
        }
        system.runAs(testUser2){           
            BookJoinController test1 = new BookJoinController();
        }
                     
        
        
    }  
    @isTest static void testBookJoin_LeadCase2() {
        
        Lead testLead = Test_DataFactory.createLead(false,testRun,testRun);
        testLead.Postalcode='018915';
        testLead.MobilePhone='6591111111';
        testLead.Address_Line_1__c='dumtAdd1';
        testLead.Address_Line_2__c='dummyAdd2';
        testLead.Address_Line_3__c='dummyAdd3'; 
        insert testLead;
        Test_Drive__c testdrv = Test_DataFactory.createTestDrive(false,testOpp.id);
        testdrv.Model__c=testvehi.id;
        testdrv.Lead__c=testLead.id;  
        testdrv.Date__c=date.today();
        testdrv.Franchise_Code__c='KIAPC'; 
        testdrv.receive_idemnity_form__c = 'Yes';
        insert testdrv;
        User testUser = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        testUser.Branch_Code__c='CCK';
        testUser.Franchise_Code__c='KIAPC';         
        insert testUser;
        
        ApexPages.currentPage().getParameters().put('leadId',testLead.id);  
        ApexPages.currentPage().getParameters().put('testdrive_id',testdrv.id);
        ApexPages.currentPage().getParameters().put('id',testvehi.id);
        ApexPages.currentPage().getParameters().put('typeVal', '');
        system.runAs(testUser){           
            BookJoinController test1 = new BookJoinController();
            test1.custNric='12345678';
            test1.custPhone='91111111';   
            ApexPages.currentPage().getParameters().put('searchType', 'MobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', '91111111');            
            test1.searchCustNric();
            test1.custPost='0915';
            test1.postalChange();
            test1.custPhone='91112341';
            test1.save();
        }
    }*/
    @isTest static void testBookJoin_Contact() {
       Postal_Code__c pc=new Postal_Code__c();
        pc.Name='018915';
        pc.Address_Line_1__c='Qssax';
        pc.Address_Line_2__c='adad';
        pc.Address_Line_3__c='weqwew';
        pc.Country__c='Singapore';
        insert pc;
        pc.Name=pc.id;
        update pc;
        
        act = [Select PersonContactId From Account Limit 1];
        //Contact testContact = Test_DataFactory.createContact(false,testRun,testRun,act.id);
        Contact testContact = [Select PDPA__c, Postal_Code__c, MobilePhone, Birthdate From Contact Where Id =: act.PersonContactId];
        testContact.PDPA__c='SMS';
        testContact.Postal_Code__c=pc.id;
        testContact.MobilePhone='6591111111';
        testContact.Birthdate=Date.today();
        testContact.NRIC_Passport_No__c = '12345678';
        testContact.Branch_Code__c='CCK';
        testContact.Franchise_Code__c='KIAPC';     
        update testContact;
        
        Trade_Plate__c testTradePl = new Trade_Plate__c(Name='testTradePlate' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Active__c=true);
        insert testTradePl;
        
          User testUser = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        testUser.Branch_Code__c='CCK';
        testUser.Franchise_Code__c='KIAPC';  
        //testUser.NRIC__c =  '12345678';
        insert testUser;
        
        Test_Drive__c testdrv = Test_DataFactory.createTestDrive(false,testOpp.id);
        testdrv.Model__c=testvehi.id;
        testdrv.Prospect__c=testContact.id;  
        testdrv.Date__c=date.today();
        testdrv.Franchise_Code__c='KIAPC';
        testdrv.receive_idemnity_form__c = 'Yes';
        testdrv.Status__c = 'In';
        testdrv.Trade_Plate__c = null;//testTradePl.Id;
        testdrv.OwnerId = testUser.Id;
        insert testdrv;
        
      
        
        testvehi.Registration_No__c = '123';
        update testvehi;
        
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'oppName', act.Id);
        opp.Branch_Code__c='CCK';
        opp.Franchise_Code__c='KIAPC';  
        opp.Contact_Person__c = testContact.Id;
        opp.StageName='Open';
        opp.OwnerId = testUser.Id;

        insert opp;

        ApexPages.currentPage().getParameters().put('contactId',testContact.id);
        ApexPages.currentPage().getParameters().put('testdrive_id',testdrv.id);
        ApexPages.currentPage().getParameters().put('id',testvehi.id);

        system.runAs(testUser){           
            BookJoinController test1 = new BookJoinController();
            test1.custNric='12345678';
            test1.custPhone='91111111';  
            test1.salesNRIC = '12345678';
            test1.custPost = '018915';
            ApexPages.currentPage().getParameters().put('searchType', 'MobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', '91111111');            
            test1.searchSalesNric();
            test1.searchCustNric();
            test1.searchCustPhone();
            test1.postalChange();
            test1.salesChange();
            //test1.oppSearch();
            test1.save();
            test1.cancel();
            
            
        }
    }
    @isTest static void testBookJoin_ContactCase2() { 
        Contact testContact = Test_DataFactory.createContact(true,testRun,testRun,act.id);        
        Test_Drive__c testdrv = Test_DataFactory.createTestDrive(false,testOpp.id);
        testdrv.Model__c=testvehi.id;
        testdrv.Prospect__c=testContact.id;  
        testdrv.Date__c=date.today();
        testdrv.Franchise_Code__c='KIAPC';
        testdrv.receive_idemnity_form__c = 'Yes';
        insert testdrv;
        User testUser = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        testUser.Branch_Code__c='CCK';
        testUser.Franchise_Code__c='KIAPC';        
        insert testUser;        
        ApexPages.currentPage().getParameters().put('contactId',testContact.id);
        ApexPages.currentPage().getParameters().put('testdrive_id',testdrv.id);
        ApexPages.currentPage().getParameters().put('id',testvehi.id);        
        system.runAs(testUser){           
            BookJoinController test1 = new BookJoinController();
            test1.custNric='12345678';
            test1.custPhone='91111111';   
            ApexPages.currentPage().getParameters().put('typeVal', '');            
            test1.searchCustNric();    
            //test1.save();

        }
    }
    @isTest static void testBookJoin_searchCustNric_NoLeadNoCont() { 
       Contact testContact = Test_DataFactory.createContact(true,testRun,testRun,act.id);        
        Test_Drive__c testdrv = Test_DataFactory.createTestDrive(false,testOpp.id);
        testdrv.Model__c=testvehi.id;
        testdrv.Prospect__c=testContact.id;  
        testdrv.Date__c=date.today()+1;
        testdrv.Franchise_Code__c='KIAPC';
        testdrv.receive_idemnity_form__c = 'Yes';
        insert testdrv;
        User testUser = Test_DataFactory.createUser(false,'KIAPC Sales', 'ksa2');
        testUser.Branch_Code__c='CCK';
        testUser.Franchise_Code__c='KIAPC';        
        insert testUser;        
        ApexPages.currentPage().getParameters().put('contactId',testContact.id);
        ApexPages.currentPage().getParameters().put('testdrive_id',testdrv.id);
        ApexPages.currentPage().getParameters().put('id',testvehi.id);        
        system.runAs(testUser){           
            BookJoinController test1 = new BookJoinController();
            test1.custNric='';
            test1.custPhone='a';   
            ApexPages.currentPage().getParameters().put('searchType', 'MobilePhone');
            ApexPages.currentPage().getParameters().put('typeVal', '');            
            test1.searchCustNric();
            system.debug('ok');
            //test1.custEmail=null;
            test1.customer.Birthdate=date.today();
            test1.customer.Lastname=null;
            //test1.save();
            system.debug('test');
        }
    }
}
@isTest
global class Test_EventRegistrationManager {
    @TestSetup
    global static void createData(){
        Date OppCreatedDate     = Date.today().addMonths(-6);                                                     
        String testRun                = 'dummyData';                                                           
        String branchCode             = 'CCA';                                                                 
        String franchiseCode          = 'MITPC';                                                               
        Account ac                    = Test_DataFactory.createAccount(true,testRun);
        Account pa                    = Test_DataFactory.createPerson(true, 'PA', 'Customer');
        Contact TestCon               = Test_DataFactory.createContact(false,testRun,testRun,ac.id);  
        TestCon.Account__c = pa.Id;
        insert TestCon;
        
        /*Lead TestLead                 = Test_DataFactory.createLead(false,testRun,testRun);
        TestLead.Account__c = pa.Id;
        insert TestLead;*/
        pa = [SELECT Id, PersonContactId FROM Account WHERE isPersonAccount = true];
        Model__c mc                  = Test_DataFactory.createmodelId(true,testRun,branchCode,franchiseCode); 
        Opportunity oppInsCon        = Test_DataFactory.createOpportunity(true,testRun, ac.Id); 
        oppInsCon.StageName = 'Booked';
        update oppInsCon; 
        System.debug('Opp 1 >>>>>>>>>>>> ' + oppInsCon);

        Models_Interested__c modelInterested = Test_DataFactory.createmodelsInterested(false, mc.Id, null, '', '');
        modelInterested.Opportunity__c = oppInsCon.Id;
        insert modelInterested;
        
        Opportunity oppConWithModelId = Test_DataFactory.createOpportunity(true,testRun, pa.Id); 
        //oppConWithModelId.Contact_Person__c = TestCon.id;
        oppConWithModelId.Account__c = pa.id;
        oppConWithModelId.Opportunity_Score__c = 321132;
        oppConWithModelId.Branch_Code__c = branchCode;
        oppConWithModelId.Model_c__c = mc.Id;
        oppConWithModelId.Contact_Person__c = pa.PersonContactId;
        oppConWithModelId.StageName = 'Open';
        update oppConWithModelId; 
        System.debug('Opp 2 >>>>>>>>>>>> ' + oppConWithModelId);
        Opportunity oppConInsertLead  = Test_DataFactory.createOpportunity(true,testRun,pa.Id);   
        oppConInsertLead.Branch_Code__c = branchCode;
        oppConInsertLead.Account__c = pa.id;
        oppConInsertLead.Contact_Person__c = pa.PersonContactId;
        oppConWithModelId.StageName = 'Open';
        update oppConInsertLead; 
        System.debug('Opp 3 >>>>>>>>>>>> ' + oppConInsertLead);
        Campaign cp = Test_DataFactory.createCamp(false,'Test camp','Paid Events','CCA');
        cp.Do_Not_Create_Oppty_Contact__c = false;
        cp.EndDate = Date.today();
        insert cp; 
        
        CampaignMember cm = new CampaignMember(CampaignId = cp.Id, ContactId = TestCon.Id);
        insert cm;
        
        Invoice__c nv = Test_DataFactory.createInvoice(false,TestCon.id,null);       
        nv.Department__c = 'test';
        nv.Transaction_Type__c = 'Purchase';
        nv.Payment_Type__c = 'Receipt';
        nv.Campaign_ID__c = cp.id;
        nv.Account__c = pa.Id;
        insert nv;
    }
    global static testMethod void testInsertException1(){
        Test.startTest();         
        String JsonMsg = '{"test":"test"}';        
        Test_DataFactory.createReq('EventRegistration',JsonMsg);                 
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,JsonMsg));
        EventRegistrationManager.EventRegistrationManager();
        Test.stopTest();
    }
    global static testMethod void testInsertContactWithModelId(){
        Model__c mc = [SELECT Id FROM Model__c LIMIT 1];
        Contact TestCon = [SELECT Id FROM Contact LIMIT 1];
        Campaign cp = [SELECT Id FROM Campaign LIMIT 1];
        Invoice__c nv = [SELECT Id FROM Invoice__c LIMIT 1];
        Account pa = [SELECT Id, PersonContactId FROM Account WHERE isPersonAccount = true];

        String JsonMsg = '{"NumberOfGuests":0,"FirstName":"Varinder","LastName":"Kaur","MobilePhone":"981111111","Email":"varinderk@grazitti.com","EventID":"'+cp.id+'","ModelID":"'+mc.id+'","LeadId":"","ContactId":"'+pa.PersonContactId+'","EventDate":"2018-3-3","EventStatus":"Registered","PaymentId":"'+ nv.id + '","WaitList":false,"Remarks":"postman","Preffered_Date":"2018-3-3","Preffered_Time":"13:22","PDPA":"on"}';              
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'{"accessToken": "Successful"}'));
        Test_DataFactory.createReq('EventRegistration',JsonMsg);                               
        EventRegistrationManager.EventRegistrationManager();
        Test.stopTest();     
    }
    
     global static testMethod void testInsertContactWithoutModelId()
     {
        Contact TestCon = [SELECT Id FROM Contact LIMIT 1];
        Campaign cp = [SELECT Id FROM Campaign LIMIT 1];
        Invoice__c nv = [SELECT Id FROM Invoice__c LIMIT 1];
		Account pa = [SELECT Id, PersonContactId FROM Account WHERE isPersonAccount = true];
         
        String JsonMsg = '{"NumberOfGuests":0,"FirstName":"Varinder","LastName":"Kaur","MobilePhone":"981111111","Email":"varinderk@grazitti.com","EventID":"'+cp.id+'","ModelID":"","LeadId":"","ContactId":"'+pa.PersonContactId+'","EventDate":"2018-3-3","EventStatus":"Registered","PaymentId":"'+ nv.id + '","WaitList":false,"Remarks":"postman","Preffered_Date":"2018-3-3","Preffered_Time":"13:22","PDPA":"on"}';              
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'{"accessToken": "Successful"}'));
        Test_DataFactory.createReq('EventRegistration',JsonMsg);                               
        EventRegistrationManager.EventRegistrationManager();
        Test.stopTest();     
    }
    /*global static testMethod void testInsertLeadWithoutModelId(){
        Model__c mc = [SELECT Id FROM Model__c LIMIT 1];
        Lead TestLead = [SELECT Id FROM Lead LIMIT 1];
        Campaign cp = [SELECT Id FROM Campaign LIMIT 1];
        Invoice__c nv = [SELECT Id FROM Invoice__c LIMIT 1];
        String JsonMsg = '{"NumberOfGuests":0,"FirstName":"Varinder","LastName":"Kaur","MobilePhone":"981111111","Email":"varinderk@grazitti.com","EventID":"'+cp.id+'","ModelID":"","ContactId":"","LeadId":"'+TestLead.id+'","EventDate":"2018-3-3","EventStatus":"Registered","PaymentId":"'+ nv.id + '","WaitList":false,"Remarks":"postman","TimeSlot":"13:22","PDPA":"on"}';              
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'[{"success Messaged": "Successful"}]'));
        Test_DataFactory.createReq('EventRegistration',JsonMsg);                        
        
        EventRegistrationManager.EventRegistrationManager();
        Test.stopTest();     
    }*/
}
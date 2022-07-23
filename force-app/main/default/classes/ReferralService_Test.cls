@isTest
private class ReferralService_Test 
{  
    @testSetup
    static void createData()
    {
        String testEmail = 'testEmail@fakedomain.com';
        Account personAcc = Test_DataFactory.createPerson(false, 'name', 'Prospect');
        personAcc.PersonEmail = testEmail;
        insert personAcc;        
        Contact personCon = Test_DataFactory.createContact(true, 'fname', 'lname', personAcc.Id);
        
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'OppName', personAcc.Id);
        opp.Account__c = personAcc.Id;
        opp.Contact_Person__c = personCon.Id;
        insert opp;  
    }
    
    @isTest
    static void testGetUserRecordMap(){
        List<User> usersList = new List<User>();        
        Profile userProfile = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%' LIMIT 1];
        
        for(Integer i = 0; i < 6; i++){
            User newUser = new User();
            newUser.LastName = 'LastName ' + i;
            newUser.Email = 'test'+ i + '@jcc.com';
            newUser.Username = 'test_datafactory' + i +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
            newUser.LocaleSidKey = 'en_US';
            newUser.TimeZoneSidKey = 'GMT';
            newUser.Alias = 'fake' + i;            
            if(userProfile!=null) {
                newUser.ProfileID = userProfile.id; 
            }            
            newUser.LanguageLocaleKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            
            usersList.add(newUser);
        }
        insert usersList;
        Set<String> userIds = new Set<String>();
        for(User user: usersList)
        {
            userIds.add(user.Id);
        }
        
        Test.startTest();
        Map<Id,User> result = ReferralService.getUserRecordMap(userIds);
        Test.stopTest();
        System.assertEquals(result.size(), 6);
    }
    
    @isTest
    private static void testFilterDuplicateReferral()
    {
        Account personAcc = [SELECT Id, PersonContactId, PersonEmail FROM Account LIMIT 1];
        Contact personCon = [SELECT Id FROM Contact WHERE Id =: personAcc.PersonContactId];
        
        Referral__c referral = new Referral__c();
        referral.Referrer__c = personCon.Id;
        referral.Stage__c = 'Opened';
        referral.Referee_Account__c = personAcc.Id;
        referral.Brand_Picklist__c = 'MIT';
        insert referral;
        
        Map<String, ReferralWrapper> mapReferralToProcess = new Map<String, ReferralWrapper>();
        
        String requestBody = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "' + personAcc.PersonEmail + '","PreferredSC": "005280000055uQ1","PDPA": "True","UserId" : "005p0000000NEg9"}';
        ReferralWrapper referralWrap = (ReferralWrapper)JSON.deserialize( requestBody, ReferralWrapper.class );
        
        List<ReferralWrapper> ReferralWrapList = new List<ReferralWrapper>{ referralWrap };
        for(ReferralWrapper referWrap: ReferralWrapList)
        {
            String theKey = referWrap.Email.toLowerCase();
            mapReferralToProcess.put(theKey, referWrap);
        }
        Test.startTest();
		Set<string> setStrBrands = new Set<string>();
		setStrBrands.add('MIT');
        ReferralService.filterDuplicateReferral(mapReferralToProcess, setStrBrands);
        Test.stopTest();
    }
    
    @isTest
    private static void testProcessReferralRequest()
    {           
        Account personAcc = [SELECT Id, PersonContactId, PersonEmail FROM Account LIMIT 1];
        Contact personCon = [SELECT Id FROM Contact WHERE Id =: personAcc.PersonContactId];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
         
        Map<String, ReferralWrapper> mapReferralToProcess = new Map<String, ReferralWrapper>();
        
        String requestBody = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "' + personAcc.PersonEmail + '","PreferredSC": "005280000055uQ1","PDPA": "True","UserId" : "005p0000000NEg9",'
            + '"referrerContactId" : "'+personCon.Id+'","referrerPAId" : "'+personAcc.Id+'"}';
        
        ReferralWrapper referralWrap = (ReferralWrapper)JSON.deserialize( requestBody, ReferralWrapper.class );
        Map<Id, User> mapUser = ReferralService.getUserRecordMap(new Set<String>{referralWrap.PreferredSC});
        referralWrap.prospectObj = ReferralWrapper.populateProspectRecord(referralWrap, mapUser); 
        referralWrap.opportunityObj = ReferralWrapper.populateOpportunityRecord(referralWrap, mapUser);
        referralWrap.referralObj = ReferralWrapper.populateReferralRecord(referralWrap);
        
        List<ReferralWrapper> ReferralWrapList = new List<ReferralWrapper>{ referralWrap };
        for(ReferralWrapper referWrap: ReferralWrapList)
        {
            String theKey = referWrap.Email.toLowerCase();
            mapReferralToProcess.put(theKey, referWrap);
        }
        Test.startTest();
        ReferralService.processReferralRequest(mapReferralToProcess);            
        Test.stopTest();  
    }
    
    @isTest
    private static void testProcessReferralRequest_nullSObject_ExceptionThrown(){        
        String testEmail = 'testEmail@fakedomain.com';
        Map<String, ReferralWrapper> mapReferralToProcess = new Map<String, ReferralWrapper>();
        
        String requestBody = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "' + testEmail + '","PreferredSC": "005280000055uQ1","PDPA": "True","UserId" : "005p0000000NEg9"}';
        ReferralWrapper referralWrap = (ReferralWrapper)JSON.deserialize( requestBody, ReferralWrapper.class );
        
        List<ReferralWrapper> ReferralWrapList = new List<ReferralWrapper>{ referralWrap };
            for(ReferralWrapper referWrap: ReferralWrapList){
                String theKey = referWrap.Email.toLowerCase();
                mapReferralToProcess.put(theKey, referWrap);
            }
        Test.startTest();
        try
        {
            ReferralService.processReferralRequest(mapReferralToProcess);            
        } 
        catch (Exception ex)
        {
            System.debug(' ====== processReferralRequest exception == ' + ex.getCause() + ' +++ ' + ex.getMessage());
            System.assertNotEquals(null, ex);
        }
        Test.stopTest();      
    }
    /*@isTest
    private static void testGetReferralListByContactAndStage(){        
        Account acc = Test_DataFactory.createAccount(true, 'name');
  
        Contact con = Test_DataFactory.createContact(true, 'fname', 'lname', acc.Id);
        
        Lead lead = Test_DataFactory.createLead(true, 'Aodigy', 'lName'); 
        
        Referral__c ref = Test_DataFactory.createReferral(false, con.Id, lead.Id);
        ref.Stage__c = 'Open';
        insert ref;

        Test.startTest();
        List<Referral__c> refs = ReferralService.getReferralListByContactAndStage(new Set<String>{con.Id}, new Set<String>{'Open'});            
        Test.stopTest();  
        System.assertNotEquals(0, refs.size());
    } */
    @isTest
    private static void testGetReferralListByPersonAccountAndStage()
    {        
        Account personAcc = [SELECT Id, PersonContactId, PersonEmail FROM Account LIMIT 1];
        Contact personCon = [SELECT Id FROM Contact WHERE Id =: personAcc.PersonContactId];
        Account referee = Test_DataFactory.createPerson(true, 'referee', 'Prospect');
        
        Referral__c ref = Test_DataFactory.createReferral(false, personCon.Id, null);
        ref.Stage__c = 'Open';
        ref.Referrer_Account__c = personAcc.Id;
        ref.Referee_Account__c = referee.Id;
        insert ref;

        Test.startTest();
        List<Referral__c> refs = ReferralService.getReferralListByPersonAccountAndStage(new Set<String>{personAcc.Id}, new Set<String>{'Open'});
        System.debug(refs);
        Test.stopTest(); 
        System.assertNotEquals(0, refs.size());
    } 
    
    @isTest
    private static void testCall_Map_Id_to_Stage_Referral()
    {        
        Account personAcc = [SELECT Id, PersonContactId, PersonEmail FROM Account LIMIT 1];
        Contact personCon = [SELECT Id FROM Contact WHERE Id =: personAcc.PersonContactId];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Referral__c ref = Test_DataFactory.createReferral(false, personCon.Id, null);
        ref.Stage__c = 'Open';
        ref.Referrer_Account__c = personAcc.Id;
        ref.Opportunity__c = opp.Id;
        insert ref;
        
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);        
        Model_Master__c modelCode = Test_DataFactory.createModelCode(true, 'Test Model Code');
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        

        Stock_Reservation__c stockReservation = Test_DataFactory.StockReservation(true, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        Sales_Agreement__c sa = Test_DataFactory.createSalesAgreement(false, 'CCA', '123', stockReservation.Id, 'customerName');
        sa.Stage__c = 'Car Collected';
        sa.Opportunity__c = opp.Id;
        //insert sa;
        
        Test.startTest();
        ReferralService.call_Map_Id_to_Stage_Referral(new List<Referral__c>{ref});   
        Test.stopTest();  
    }

    @isTest
    private static void testPopulateProspectRecord()
    {        
        Account personAcc = [SELECT Id, PersonContactId, PersonEmail FROM Account LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test@user.com',
            Username = 'test@user.com',
            Alias = 'TestPA', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = personAcc.PersonContactId
        );
        insert u;
        
        Map<String, ReferralWrapper> mapReferralToProcess = new Map<String, ReferralWrapper>();
        
        String requestBody = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "' + personAcc.PersonEmail + '","PreferredSC": "'+u.Id+'","PDPA": "True","UserId" : "005p0000000NEg9"}';
        
        ReferralWrapper referralWrap = (ReferralWrapper)JSON.deserialize( requestBody, ReferralWrapper.class );

        Test.startTest();
        ReferralWrapper.populateProspectRecord(referralWrap, new Map<Id,User>{u.Id => u});            
        Test.stopTest();  
    }
    
    @isTest
    private static void testPopulateOpportunityRecord()
    {        
        Account personAcc = [SELECT Id, PersonContactId, PersonEmail FROM Account LIMIT 1];
       
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'OppName', personAcc.Id);
        opp.Account__c = personAcc.Id;
        insert opp;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test@user.com',
            Username = 'test@user.com',
            Alias = 'TestPA', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = personAcc.PersonContactId
            );
        insert u;
        
        Map<String, ReferralWrapper> mapReferralToProcess = new Map<String, ReferralWrapper>();
        
        String requestBody = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "' + personAcc.PersonEmail + '","PreferredSC": "'+u.Id+'","PDPA": "True","UserId" : "005p0000000NEg9"}';
        
        ReferralWrapper referralWrap = (ReferralWrapper)JSON.deserialize( requestBody, ReferralWrapper.class );
        referralWrap.prospectObj = personAcc; 
        
        Test.startTest();
        ReferralWrapper.populateOpportunityRecord(referralWrap, new Map<Id,User>{u.Id => u});            
        Test.stopTest();  
    }
    
    @isTest
    private static void testPopulateReferralRecord()
    {        
        Account personAcc = [SELECT Id, PersonContactId, PersonEmail FROM Account LIMIT 1];
        
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'OppName', personAcc.Id);
        opp.Account__c = personAcc.Id;
        insert opp;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test@user.com',
            Username = 'test@user.com',
            Alias = 'TestPA', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = personAcc.PersonContactId
            );
        insert u;
        
        Map<String, ReferralWrapper> mapReferralToProcess = new Map<String, ReferralWrapper>();
        
        String requestBody = '{"Firstname": "TestLead-2","LastName": "zzz","MobileNumber": "09876543","Email": "' + personAcc.PersonEmail + '","PreferredSC": "'+u.Id+'","PDPA": "True","UserId" : "005p0000000NEg9",'
            + '"referrerContactId" : "'+personAcc.PersonContactId+'","referrerPAId" : "'+personAcc.Id+'"}';
        
        ReferralWrapper referralWrap = (ReferralWrapper)JSON.deserialize( requestBody, ReferralWrapper.class );
        referralWrap.prospectObj = personAcc; 
        referralWrap.opportunityObj = opp; 
        
        Test.startTest();
        ReferralWrapper.populateReferralRecord(referralWrap);            
        Test.stopTest();  
    }
    
    @isTest
    static void testGetPersonContactId()
    {
        Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Prospect');
        Test.startTest();
        ReferralService.getPersonContactId(new Set<Id>{personAcc.Id});
        Test.stopTest();
    } 
}
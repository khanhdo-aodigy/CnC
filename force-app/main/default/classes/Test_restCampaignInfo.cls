@isTest
global class Test_restCampaignInfo {
    Static Account acct 		     = Test_DataFactory.createAccount(true,'testRun');                   
    Static Lead testLead             = Test_DataFactory.createLead(true,'testRun','testRun'); 
    Static Opportunity opp         = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);      
    Static Model__c testMod          = Test_DataFactory.createmodelId(true,'testRun','CCA','MITPC');        
    global static testMethod void test_CampaignInfo(){
        Test.startTest();           
        Campaign TestCamp2 = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');           
        TestCamp2.Description = 'testing the test event';
        TestCamp2.UnitPrice__c = 25;
        TestCamp2.Number_of_Guests__c = 5;
        insert TestCamp2;
        
        
        Event_Registration__c tempInsertER1 = Test_DataFactory.createEventReg(false,null,TestCamp2.id,null,opp.id,testLead.id,testMod.id); // Insertion of Event_Registration__c using TestDataFactory
        tempInsertER1.Event_Reminder_Status__c=true;
        tempInsertER1.Waitlist__c = true;
        tempInsertER1.NumberOfGuests__c = 5;
        tempInsertER1.Opportunity__c = opp.id;
        Insert tempInsertER1;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/Campaign/';  
        req.addParameter('cmpId ', TestCamp2.Id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        restCampaignInfo.getCampaignDetails();
        restCampaignInfo.getDetails(TestCamp2.id);
        
        
        Test.stopTest();
    }
    global static testMethod void test_CampaignInfo1(){
        Test.startTest();           
        Campaign TestCamp2 = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');          
        TestCamp2.Description = 'testing the test event';
        TestCamp2.UnitPrice__c = 25;
        TestCamp2.Number_of_Guests__c = 5;
        insert TestCamp2;
        
        
        Event_Registration__c tempInsertER1 = Test_DataFactory.createEventReg(false,null,TestCamp2.id,null,opp.id,testLead.id,testMod.id); // Insertion of Event_Registration__c using TestDataFactory
        tempInsertER1.Event_Reminder_Status__c=true;
        tempInsertER1.Waitlist__c = false;
        tempInsertER1.PromoID__c = TestCamp2.id;
        tempInsertER1.NumberOfGuests__c = 5;
        Insert tempInsertER1;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CampaignInfo/*';  
        req.addParameter('Id', TestCamp2.Id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;       
        restCampaignInfo.getCampaignDetails();
        restCampaignInfo.getDetails(TestCamp2.id);

        Test.stopTest();
    }
}
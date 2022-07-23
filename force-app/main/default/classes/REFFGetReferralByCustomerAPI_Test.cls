@isTest
public class REFFGetReferralByCustomerAPI_Test 
{
    static testMethod void testGetReferralByCustomer()
    {
        Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Prospect');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id =: personAcc.Id];
        Contact c = [SELECT Id FROM Contact WHERE ID =: personAcc.PersonContactId];
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'End User' limit 1];
        user uc = Test_DataFactory.createUserWithProfileID(false,'re','re','test@force.com',userProfile.id); 
        uc.contactId = c.id;    
        uc.Account_Activation_Random_Number__c = '504503';
        uc.isValid__c = true;
        insert uc;
        Referral__c ref = Test_DataFactory.createReferral(true, null, null);
        ref.Brand_Picklist__c = 'KIA';
        ref.Referrer_Account__c = personAcc.Id;
        update ref;

        Test.startTest();        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
		request.requestUri ='services/apexrest/GetReferralByCustomer/v1/User/' + uc.id + '/Brand/KIA';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        
        REFFGetReferralByCustomerAPI.getReferralByCustomer();
        System.assert(response.statusCode == 200);       
        Test.stopTest();
    }
    static testMethod void testGetReferralByCustomerFailed()
    {
        Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Prospect');
        personAcc = [SELECT PersonContactId FROM Account WHERE Id =: personAcc.Id];
        Contact c = [SELECT Id FROM Contact WHERE ID =: personAcc.PersonContactId];
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'End User' limit 1];
        user uc = Test_DataFactory.createUserWithProfileID(false,'re','re','test@force.com',userProfile.id); 
        uc.contactId = c.id;    
        uc.Account_Activation_Random_Number__c = '504503';
        uc.isValid__c = true;
        insert uc;
        Referral__c ref = Test_DataFactory.createReferral(true, null, null);
        ref.Brand_Picklist__c = 'KIA';
        ref.Referrer_Account__c = personAcc.Id;
        ref.Stage__c = 'SuccessfullyReferred';
        update ref;

        Test.startTest();        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
		request.requestUri ='services/apexrest/GetReferralByCustomer/v1/User/' + uc.id + '/Brand/KIA';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        
        REFFGetReferralByCustomerAPI.getReferralByCustomer();
        System.assert(response.statusCode == 200);       
        Test.stopTest();
    }
}
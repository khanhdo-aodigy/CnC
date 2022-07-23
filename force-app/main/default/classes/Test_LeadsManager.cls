@isTest
public class Test_LeadsManager {
    
    Public static testMethod void testGetLead()
    {    
        contact con= new contact(lastname='test', email='test@123.com');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/leads_accountManager'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();         
        Lead TestLead =  new Lead(LastName='Customer',NRIC__c='TestRunNRIC', Email='test@123.com');
        insert TestLead;     
        leadclass manager = new leadclass();
        manager.LeadFName = 'test';
        manager.LeadLName = 'Customer';
        manager.LeadPhone = '89999999';
        manager.LeadEmail = 'test@123.com';
        manager.LeadBrand = 'KIA';
        manager.LeadCountry = 'SG';
        manager.PDPAText = 'yes';
        manager.LeadSourceVal = 'TestDrive';
        manager.StreetName='test3';
        manager.BuildingName='test4';
        manager.FloorUnit='5';
        manager.PostalCode='1443';
        String JsonMsg=JSON.serialize(manager);
        
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        LeadsManager.getLeadByName();
        Test.stopTest();
    }
    
    Public static testMethod void testGetLeadsManager()
    {    
        contact con= new contact(lastname='test', email='test@123.com');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/leads_accountManager'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();         
        Lead TestLead =  new Lead(LastName='TestRunL',NRIC__c='TestRunNRIC', Email='test@123.com');  
        leadclass manager = new leadclass();
        manager.LeadFName = 'test';
        manager.LeadLName = 'test';
        manager.LeadPhone = '89999999';
        manager.LeadEmail = 'test@123.com';
        manager.LeadBrand = 'KIA';
        manager.LeadCountry = 'SG';
        manager.PDPAText = 'yes';
        manager.LeadSourceVal = 'TestDrive';
        manager.StreetName='test3';
        manager.BuildingName='test4';
        manager.FloorUnit='5';
        manager.PostalCode='1443';
        String JsonMsg=JSON.serialize(manager);
        
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        LeadsManager.getLeadByName();
        Test.stopTest();
    }
    
    //PA MIGRATION: Newly Added -- Start
    //PA MIGRATION: TO-DO: Assert the expected result
    @isTest 
    private static void testGetLead_withExistingPersonContact(){
        String email = 'test@123.com';
        Account personAccToInsert = Test_DataFactory.createPerson(true, 'AccountName', 'Customer');
        Account personAcc = [SELECT Id, Name, IsPersonAccount, PersonContactId FROM Account];
        Contact personCon = [SELECT Id FROM Contact WHERE Id = :personAcc.PersonContactId];
        personCon.Email = email;
        update personCon;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/leads_accountManager'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        leadclass manager = new leadclass();
        manager.LeadFName = 'test';
        manager.LeadLName = 'test';
        manager.LeadPhone = '89999999';
        manager.LeadEmail = email;
        manager.LeadBrand = 'KIA';
        manager.LeadCountry = 'SG';
        manager.PDPAText = 'yes';
        manager.LeadSourceVal = 'TestDrive';
        manager.StreetName='test3';
        manager.BuildingName='test4';
        manager.FloorUnit='5';
        manager.PostalCode='1443';
        String jsonMsg=JSON.serialize(manager);
        
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        SObject actualResult = LeadsManager.getLeadByName();
        System.debug('@@@@ actualResult = ' + actualResult);
        Test.stopTest();
    }
    
    @isTest 
    private static void testGetLead_withExistingBusinessContact(){
        String dummyEmail = 'test@123.com';
        Account businessAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact businessCon = Test_DataFactory.createContact(false, 'fname', 'lname', businessAcc.Id);
		businessCon.Email = dummyEmail;
        insert businessCon;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/leads_accountManager'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        leadclass manager = new leadclass();
        manager.LeadFName = 'test';
        manager.LeadLName = 'test';
        manager.LeadPhone = '89999999';
        manager.LeadEmail = dummyEmail;
        manager.LeadBrand = 'KIA';
        manager.LeadCountry = 'SG';
        manager.PDPAText = 'yes';
        manager.LeadSourceVal = 'TestDrive';
        manager.StreetName='test3';
        manager.BuildingName='test4';
        manager.FloorUnit='5';
        manager.PostalCode='1443';
        String jsonMsg=JSON.serialize(manager);
        
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        LeadsManager.getLeadByName();
        Test.stopTest();
    }
    
    @isTest
    private static void testGetLead_caseNoBusinessContactButExistingLead(){
        String email = 'test@123.com'; 
        Lead TestLead =  new Lead(LastName='Customer',NRIC__c='TestRunNRIC', Email=email);
        insert TestLead; 
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/leads_accountManager'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        leadclass manager = new leadclass();
        manager.LeadFName = 'test';
        manager.LeadLName = 'test';
        manager.LeadPhone = '89999999';
        manager.LeadEmail = email;
        manager.LeadBrand = 'KIA';
        manager.LeadCountry = 'SG';
        manager.PDPAText = 'yes';
        manager.LeadSourceVal = 'TestDrive';
        manager.StreetName='test3';
        manager.BuildingName='test4';
        manager.FloorUnit='5';
        manager.PostalCode='1443';
        String jsonMsg=JSON.serialize(manager);
        
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;
               
        Test.startTest();         
        LeadsManager.getLeadByName();
        Test.stopTest();
    }
    
    @isTest
    private static void testGetLead_caseNoBusinessContactAndNoLead(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/leads_accountManager'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        leadclass manager = new leadclass();
        manager.LeadFName = 'test';
        manager.LeadLName = 'test';
        manager.LeadPhone = '89999999';
        manager.LeadEmail = 'test@123.com';
        manager.LeadBrand = 'KIA';
        manager.LeadCountry = 'SG';
        manager.PDPAText = 'yes';
        manager.LeadSourceVal = 'TestDrive';
        manager.StreetName='test3';
        manager.BuildingName='test4';
        manager.FloorUnit='5';
        manager.PostalCode='1443';
        String jsonMsg=JSON.serialize(manager);
        
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();  
        LeadsManager.getLeadByName();
        Test.stopTest();
    }
    //PA MIGRATION: Newly Added -- End //
    
    public class leadclass{
        public string LeadFName;
        public string LeadLName;
        public string LeadPhone;
        public string LeadEmail;
        public string LeadBrand;
        public string LeadCountry;
        public string PDPAText;
        public string LeadSourceVal;
        public string StreetName;   
        public string BuildingName; 
        public string FloorUnit;    
        public string PostalCode;
        
    }
}
@IsTest
public class TestGetCampaign_RegisteredVehicle_myMB {
    @testSetup
    public static void createData(){
        Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id];
        Contact personCon = new Contact(Id = personAcc.PersonContactId);
        personCon.NRIC_Passport_No__c = 'ProdNRIC';
        update personCon;
        
        Campaign c = Test_DataFactory.createCamp(false, 'name', 'type', 'CCK');
        c.EndDate = Date.today().addDays(2);
        insert c;
        
		Campaign_Member_Vehicle__c cmv = new Campaign_Member_Vehicle__c();
		cmv.Contact__c = personCon.Id;
		cmv.Campaign__c = C.Id;
		insert cmv;

        CampaignMember cm = new CampaignMember();
        cm.ContactId = personCon.Id;
        cm.CampaignId = c.Id;
        //insert cm;

		global_var__c JCC_GlobalVar = new global_var__c();     
		JCC_GlobalVar.APIgateway_URL__c = 'A';
		JCC_GlobalVar.APIGateway_key__c = 'B';
		insert JCC_GlobalVar;
    }
    
    @isTest public static void testPositiveGetMethod() {
        Contact personCon = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCampaign_RegisteredVehicle_fromNRICMB/v1/' + personCon.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCampaign_RegisteredVehicle_fromNRICMB.GetCampaign_RegisteredVehicle_fromNRICMB();
        System.assert(response.statusCode == 200);
        Test.stopTest();
    }
    
    @isTest public static void testBlankIDGetMethod() {        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCampaign_RegisteredVehicle_fromNRICMB/v1/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCampaign_RegisteredVehicle_fromNRICMB.GetCampaign_RegisteredVehicle_fromNRICMB();
        System.assert(response.statusCode == 400);
        Test.stopTest();
    }
}
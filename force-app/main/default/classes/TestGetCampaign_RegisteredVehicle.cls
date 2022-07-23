@IsTest
private class TestGetCampaign_RegisteredVehicle {
    @testSetup
    private static void createData(){
        Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Contact personCon = new Contact(Id = personAcc.PersonContactId); //Workaround to update Person Contact
        personCon.NRIC_Passport_No__c = 'S0159630F';
        update personCon;

        
        Campaign campaign = Test_DataFactory.createCamp(false, 'name', 'type', 'CCK');
        campaign.EndDate = Date.today().addDays(2);
        insert campaign;

		Campaign_Member_Vehicle__c cmv = new Campaign_Member_Vehicle__c();
		cmv.Contact__c = personCon.Id;
		cmv.Campaign__c = campaign.Id;
		insert cmv;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = personCon.Id;
        cm.CampaignId = campaign.Id;
        //insert cm;

		global_var__c JCC_GlobalVar = new global_var__c();     
		JCC_GlobalVar.APIgateway_URL__c = 'A';
		JCC_GlobalVar.APIGateway_key__c = 'B';
		insert JCC_GlobalVar;

    }
    
	
    @isTest
    private static void testPositiveGetMethod() {
        Contact personCon = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCampaign_RegisteredVehicle_fromNRIC/v1/' + personCon.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCampaign_RegisteredVehicle_fromNRIC.GetCampaign_RegisteredVehicle_fromNRIC();
        System.assert(response.statusCode == 200);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }
    
	
    @isTest public static void testBlankIDGetMethod() {      
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/GetCampaign_RegisteredVehicle_fromNRIC/v1/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        GetCampaign_RegisteredVehicle_fromNRIC.GetCampaign_RegisteredVehicle_fromNRIC();
        System.assert(response.statusCode == 400);
        System.debug('Response Code =='+response.statusCode);
        Test.stopTest();
    }    
	
}
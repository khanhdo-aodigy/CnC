@isTest
private class Test_AddCampaignMember{
    
    @isTest
    private static void testInsertCampaignMember(){
        Account personAccToInsert = Test_DataFactory.createPerson(true, 'lastName', 'Customer');
        Account personAcc = [SELECT PersonContactId FROM Account WHERE Id = :personAccToInsert.Id];
        Contact personCon = [SELECT Id FROM Contact WHERE Id = :personAcc.PersonContactId];
        Campaign testCamp = Test_DataFactory.createCamp(true, 'Test', 'Events', 'CCK');
        Registered_Vehicle__c regVehicle = Test_DataFactory.createregVehicle(true,'Test', 'CCK', 'KIAPC', '74L1001', personCon.Id);
        
        List<Id> campIds = new List<Id>();
        Campaign_Member_Vehicle__c campMemVehicle = Test_DataFactory.createCampVehicle(false, 'Test', testCamp.Id, personCon.Id, regVehicle.Id);
        campMemVehicle.Account__c = personAcc.Id;
        insert campMemVehicle;
        campIds.add(campMemVehicle.Id);
        
		global_var__c JCC_GlobalVar = new global_var__c();     
		JCC_GlobalVar.APIgateway_URL__c = 'A';
		JCC_GlobalVar.APIGateway_key__c = 'B';
		insert JCC_GlobalVar;


        Test.startTest();
        AddCampaignMember.insertRecords(campIds);
        Test.stopTest();
    }
}
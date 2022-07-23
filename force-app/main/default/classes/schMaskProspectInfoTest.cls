@isTest
private class schMaskProspectInfoTest {
	@isTest
    private static void testMaskProspectInfo() {
        Test.startTest();
        global_var__c gVar = new global_var__c(Prospect_Aging_Number__c = 0);
        upsert gVar;
        
        Account paProspect = Test_DataFactory.createPerson(true, 'lastName', 'Prospect');
        paProspect = [SELECT Id, PersonContactId FROM Account WHERE Id = :paProspect.Id];
        
        Contact prospectCon = new Contact(Id = paProspect.PersonContactId);
        prospectCon.FirstName = 'First';
		prospectCon.LastName  = 'Last';
		prospectCon.MobilePhone = '98769999';
		prospectCon.Email = 'notblankval@test.com';
		prospectCon.Address_Line_1__c = 'Address Line 1';
		prospectCon.Address_Line_2__c = 'Address Line 2';
		prospectCon.Address_Line_3__c = 'Address Line 3';
		prospectCon.Address_Line_4__c = 'Address Line 4';
		prospectCon.Address_Line_5__c = 'Address Line 5';
        update prospectCon;
        
        schMaskProspectInfo sJob = new schMaskProspectInfo();
        sJob.execute(null);
        
        Test.stopTest();
        Contact updatedCon = [SELECT FirstName, LastName, Email, MobilePhone, Address_Line_1__c
                              FROM Contact
                              LIMIT 1
                             ];
        System.debug('updatedCon = ' + updatedCon);
        System.assertEquals('Masked', updatedCon.FirstName);
        System.assertEquals('Masked', updatedCon.LastName); 
        System.assertEquals(null, updatedCon.Email); 
        System.assertEquals(null, updatedCon.MobilePhone); 
        System.assertEquals(null, updatedCon.Address_Line_1__c);
        
    }
}
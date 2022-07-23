@isTest
private class Test_send_NoShowTriggeredEmail {
	private static testMethod void testSendEmail()
    {
        Test.startTest(); 
        //Lead TestLead =  new Lead(LastName='TestRunL',NRIC__c='TestRunNRIC',Email='abc@xyz.com');
        //insert TestLead;
        Contact TestCon =  new Contact(LastName='TestRun',NRIC_Passport_No__c='TestRunNRIC',Email='abc@xyz.com');
        insert TestCon;
        Model__c TestMod =  new Model__c(Name='TestMod',Branch_Code__c='CCK',Franchise_Code__c='KIAPC',DWH_Model_ID__c='abc12345');
        insert TestMod;        
        Variant__c TestVar =  new Variant__c(Name='TestVar',Branch__c='CCK',Franchise__c='KIAPC',Model_ID__c=TestMod.Id);
        insert TestVar;
        
        send_NoShowTriggeredEmail.sendNoShowEmail('abc@123.com','CCK',TestVar.Id,'OwnerName','OwnerPhone',TestCon.Id,'ConName');        
        send_NoShowTriggeredEmail.sendNoShowEmail('abc@123.com','CCI',TestVar.Id,'OwnerName','OwnerPhone',TestCon.Id,'ConName'); 
        send_NoShowTriggeredEmail.sendNoShowEmail('abc@123.com','CCA',TestVar.Id,'OwnerName','OwnerPhone',TestCon.Id,'ConName'); 
        send_NoShowTriggeredEmail.sendNoShowEmail('abc@123.com','CCF',TestVar.Id,'OwnerName','OwnerPhone',TestCon.Id,'ConName'); 
        
        Test.stopTest();
    }
}
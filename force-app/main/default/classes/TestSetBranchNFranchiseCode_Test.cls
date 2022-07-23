@isTest
private class TestSetBranchNFranchiseCode_Test {
	@isTest
    static void Test_AfterInsert() {
        Profile p = [SELECT Id FROM Profile WHERE Name like '%KIAPC Sales%' LIMIT 1];//KIA SALES//KIAPC Sales//End user
        User u2 = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert u2;
        //tp plate master
        System.runAs(u2) {
            Trade_Plate__c tp1=new Trade_Plate__c(Name='12345',Active__c=true);
            insert tp1;            
        }
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('Trade_Plate__c', true);
        Trade_Plate__c tp2=new Trade_Plate__c(Name='12345',Active__c=true);
        insert tp2;
        TriggerExclusion.excludeTrigger('Trade_Plate__c', false);
   	}
}
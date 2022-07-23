@isTest
private class ShareLeadContactTest { 
    @testSetUp
    static void createData(){
        Test.startTest();
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getName());
        Contact con = Test_DataFactory.createContact(true,
                                       UserInfo.getFirstName(),
                                      UserInfo.getLastName(),
                                      acc.Id);
        
        Account personAcc = Test_DataFactory.createPerson(true, 'Test PA', 'Customer'); 
        
        //Other User as owner of the opportunity
        String otherOwner = [SELECT Id 
                             FROM User 
                             WHERE isActive=true 
                             AND Profile.Name='System Administrator' 
                             ORDER BY CreatedDate DESC 
                             LIMIT 1].Id;
        
        //Create multiple opportunities under the same contact but with different record Owner
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0; i<20; i++){
            Opportunity opp = Test_DataFactory.createOpportunity(false,
                                                                 UserInfo.getName(),
                                                                 acc.Id);
            opp.Contact_Person__c = con.Id;
            opp.Account__c = personAcc.Id; 
            //randomiser
            if( Math.mod(i,2) == 0){
                opp.OwnerId = otherOwner;
            }
            oppList.add(opp);
        }
        insert oppList;
        Test.stopTest();
    }

    static testMethod void testSharing(){
        Test.startTest();
        String otherOwner = [SELECT Id 
                             FROM User 
                             WHERE isActive=true 
                             AND Profile.Name='System Administrator' 
                             ORDER BY CreatedDate DESC 
                             LIMIT 1].Id;
        
        Opportunity opp = [SELECT Id, Contact_Person__c 
                           FROM Opportunity 
                           WHERE OwnerId=:otherOwner 
                           LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        ShareLeadContact shr = new ShareLeadContact(sc);
        shr.shareDetails();
        Test.stopTest();
    }
}
//Write by HH
@isTest
public class ClashOpportunityQueueable_Test {
    
    @istest
    public static void testClashOpportunityQueueable(){
        Test.startTest();
        //Update Branch and Franchise Code
        User u = new User(Id=UserInfo.getUserId(), 
                          Branch_Code__c = 'CCA', 
                          Franchise_Code__c='MITPC');
        update u;

        Contact con;
        System.runAs(u){
            Account acc = Test_DataFactory.createAccount(true, 'Test');
            con = Test_DataFactory.createContact(false, 'Test', 'Test', acc.Id);
            insert con;
            
            //Create a new Opportunity where Owner = running user
            List<Opportunity> oppList = new List<Opportunity>();
            for(Integer i=0; i<5; i++){
                Opportunity opp = Test_DataFactory.createOpportunity(false, 'Opp for ' + UserInfo.getLastName(),acc.Id);
                opp.OwnerId = UserInfo.getUserId();
                opp.Contact_Person__c = con.Id;
                opp.StageName = 'Open'; 
                oppList.add(opp);
            }
            insert oppList;
            
            TriggerHandlerOpportunity.isAfterInsertRun = false;
            TriggerHandlerOpportunity.isAfterUpdateRun = false;
            Opportunity oppNew = Test_DataFactory.createOpportunity(false, 'Opp for ' + UserInfo.getLastName(), acc.Id );
            oppNew.OwnerId = UserInfo.getUserId(); 
            oppNew.StageName = 'Open'; 
            oppNew.Contact_Person__c = con.Id;

            insert oppNew;            
        }
        
        Test.stopTest();
        
    }
    
}
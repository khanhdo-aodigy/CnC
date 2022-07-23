/*
 * Class Name: BatchPurgeFilesTest
 * Description: Test Class for BatchPurgeFiles
*/
@isTest
private class SchedulePurgeNRICTest {
    
    /*
     * Method Name: createData
     * Description: Create Data on Initial Run
     */ 
    @testSetUp
    static void createData(){
        Test.startTest();
        String invIC = 'S123456TEST';
        
        String usrLName = UserInfo.getLastName();
        //Create Account
        Account acc = Test_DataFactory.createAccount(true, usrLName);
        
        //Create Contact
        Contact con = Test_DataFactory.createContact(true, usrLName, usrLName, acc.Id);

        //Create Payment with IC
        Invoice__c vc = Test_DataFactory.createInvoice(false, con.Id, null);
        vc.NRIC__c = invIC;
        insert vc;

        //Create Opportunity with IC
        Opportunity opp = Test_DataFactory.createOpportunity(false, UserInfo.getLastName(), acc.Id);
        opp.NRIC__c =  invIC;
        insert opp;
        
        //Create Test Drive with IC
        Test_Drive__c td = Test_DataFactory.createTestDrive(false, opp.Id);
        td.NRIC__c = invIC;
        insert td;
        
        //Create Stock Reservation with IC
        Stock_Reservation__c rsv = new Stock_Reservation__c(Opportunity__c=opp.Id, 
                                                            Customer_Social_ID__c=invIC);
        insert rsv;
        Test.stopTest();
    }
    
    /*
     * Method Name: testScheduler
     * Description: Test scheduler with for Purging
     */ 
    static testMethod void testScheduler(){
        //Get Preliminary Test Data
        //Query is outside start and stop Test blocks due to constraint of Test.setCreatedDate()
        Invoice__c vc = [SELECT Id FROM Invoice__c ORDER BY CreatedDate LIMIT 1];
        
        Test_Drive__c td = [SELECT Id, Opportunity__c FROM Test_Drive__c ORDER BY CreatedDate LIMIT 1];
        
        Stock_Reservation__c rv = [SELECT Id FROM Stock_Reservation__c ORDER BY CreatedDate LIMIT 1];
        
        DateTime dt7Ago = Date.today().addMonths(-7);
        Test.setCreatedDate(vc.Id, dt7Ago);
        Test.setCreatedDate(td.Id, dt7Ago);
        Test.setCreatedDate(td.Opportunity__c, dt7Ago);
        Test.setCreatedDate(rv.Id, dt7Ago);
        
        Test.startTest();
        Id jbId = System.schedule('Test Purge IC', '0 0 0 ? * * *', new SchedulePurgeNRICValues());
        Test.stopTest();
        vc = [SELECT Id, NRIC__c FROM Invoice__c LIMIT 1];
        
    }
  
}
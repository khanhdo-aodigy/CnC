/*
 * Class Name: BatchPurgeFilesTest
 * Description: Test Class for BatchPurgeFiles
*/
@isTest
private class BatchPurgeFilesTest {
    //create Initial data
	@testSetUp
    static void createTestData(){
        Test.startTest();
        //Account
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getName());
        
        //create Attachment to delete
        Attachment atc = new Attachment();
        atc.Name = 'IndemnityForm.pdf';
        atc.Body = Blob.valueOf('test');
        atc.ParentId = acc.Id;
        insert atc;
        Test.stopTest();
    }
    
    //Test File Purge
    static testMethod void testPurge(){
        Attachment atc = [SELECT Id, Name 
                          FROM Attachment 
                          WHERE Name='IndemnityForm.pdf' 
                          ORDER BY CreatedDate 
                          LIMIT 1];
        //Set Created Date to more than 6 months ago
        Test.setCreatedDate(atc.Id, Date.today().addMonths(-7));
        Test.startTest();
        Database.executeBatch( new BatchPurgeFiles() );
        Test.stopTest();
        
        //Verify attachment is deleted
        System.assertEquals(0, [SELECT COUNT() FROM Attachment WHERE Id=: atc.Id LIMIT 1]);
    }
    
    //Verify Scheduler
    static testMethod void testSchedule(){
        Test.startTest();
        Id jbId = System.schedule('Test Purge Files1', '0 0 0 ? * * *', new BatchPurgeFiles());
        Test.stopTest();
        
        //Verify job is fired
        System.assert( jbId != null );
    }
}
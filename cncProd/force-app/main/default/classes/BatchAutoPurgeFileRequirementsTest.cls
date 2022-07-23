@isTest
private with sharing class BatchAutoPurgeFileRequirementsTest {
    @testSetup() 
    static void setUp() {
        User sysAdminUser = Test_DataFactory.createUserWithProfileID(true, 'SysAdm', 'LastName', 'test@sysadmin.com', [Select Id From Profile Where Name = 'System Administrator'].Id);
        Account acc = Test_DataFactory.createAccount(true, 'test account');
        System.runAs(sysAdminUser) {
            Test_DataFactory.attachFilesToRecord(
                new Map<Id, List<Blob>>{acc.Id => new List<Blob>{Blob.valueOf('Passport')}},
                'Passport',
                'pdf'
			);
        }
    }
	@isTest
    static void test() {
        /*BatchAutoPurgeFileRequirements.mockFileRequirements = new List<File_Requirements__mdt>{new File_Requirements__mdt(DeveloperName = 'Test_Doc',
                                                                                                                          Document_Name__c = 'Test Doc',
                                                                                                                          Auto_Purge_in_Months__c = 0)};*/
        Test.startTest();
        BatchAutoPurgeFileRequirements b = new BatchAutoPurgeFileRequirements();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();
    }

    @isTest
    static void test_Schedule() {
        /*BatchAutoPurgeFileRequirements.mockFileRequirements = new List<File_Requirements__mdt>{new File_Requirements__mdt(DeveloperName = 'Test_Doc',
                                                                                                                          Document_Name__c = 'Test Doc',
                                                                                                                          Auto_Purge_in_Months__c = 0)};*/
        Test.startTest();
        String str = system.now().addSeconds(5).format('ss mm HH dd MM ? yyyy');
        String jobId = System.schedule('BatchAutoPurgeFileRequirements',str, new BatchAutoPurgeFileRequirements());
        CronTrigger ctx = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id =: jobId];
        System.assertEquals(str, ctx.CronExpression);
        System.assertEquals(0, ctx.TimesTriggered);
        Test.stopTest();
    }
}
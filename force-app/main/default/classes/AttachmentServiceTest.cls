@isTest
private class AttachmentServiceTest {
    
	@testSetup
    static void setUp() {
		Account acc = Test_DataFactory.createAccount(true, 'test account');      
        Test_DataFactory.createFileAttachment(acc.Id);
        Test_DataFactory.createFileAttachment(acc.Id);
        Test_DataFactory.createFileAttachment(acc.Id);
        
        List<ContentDocument> documents = [Select Id From ContentDocument];
		documents[0].Description = 'test document desc';
		documents[1].Description = 'test document desc';
        update documents;
    }
    
    @isTest
    static void Test_getMappedFilesByDescription() {
		Map<String, List<ContentDocument>> mappedFilesByDesc = AttachmentService.getMappedFilesByDescription([Select Id From Account].Id);
        
        System.assertEquals(2, mappedFilesByDesc.size());
        System.assert(mappedFilesByDesc.containsKey('test document desc'));
        System.assertEquals(2, mappedFilesByDesc.get('test document desc').size());
    }
    
    @isTest
    static void Test_deleteFilesByDescription() {
        AttachmentService.deleteFilesByDescription(new Map<Id, String>{
        	[Select Id From Account].Id => 'test document desc'
        });
        
        System.assertEquals(1, [Select COUNT() From ContentDocument]);
        
        AttachmentService.deleteFilesByDescription(new Map<Id, String>{
        	[Select Id From Account].Id => null
        });
        
        System.assertEquals(0, [Select COUNT() From ContentDocument]);        
    }

    @isTest
    static void Test_deleteFiles() {
        AttachmentService.deleteFiles(new List<Id>{[SELECT Id FROM Account].Id}, new List<String>{'test document desc'});
        System.assertEquals(1, [Select COUNT() From ContentDocument]);
    }
}
@isTest
private class DeleteFilesInvocableTest {

	@isTest
    static void Test_deleteFiles() {
        Account acc = Test_DataFactory.createAccount(true, 'test account');
        Test_DataFactory.attachFilesToRecord(
            new Map<Id, List<Blob>>{acc.Id => new List<Blob>{Blob.valueOf('Acc File')}},
            'Acc File',
            'pdf'
        ); 
        
        DeleteFilesInvocable.DeleteFileRequest deleteFileReq = new DeleteFilesInvocable.DeleteFileRequest();
        deleteFileReq.recordId = acc.Id;
        deleteFileReq.fileDescription = 'Acc File';
        List<DeleteFilesInvocable.DeleteFileRequest> requests = new List<DeleteFilesInvocable.DeleteFileRequest>{deleteFileReq};
            
        DeleteFilesInvocable.deleteFiles(requests);    
        System.assert([Select Id From ContentDocument].isEmpty());
    }
}
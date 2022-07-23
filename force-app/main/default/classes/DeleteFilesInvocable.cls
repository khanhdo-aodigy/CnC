public without sharing class DeleteFilesInvocable {
    
    @InvocableMethod(label='Delete Files' description='Delete files for record based on File Description')
    public static void deleteFiles(List<DeleteFileRequest> requests) {
        for(DeleteFileRequest request : requests) {
            AttachmentService.deleteFilesByDescription(new Map<Id, String>{request.recordId => request.fileDescription});
		}
    }    
    
    public class DeleteFileRequest {
        @InvocableVariable(required=true)
        public Id recordId;        

        @InvocableVariable(required=true)
        public String fileDescription;
    }
}
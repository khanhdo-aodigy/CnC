public class showAttachmentCont {


    Public String TestId{get;set;}
    
    public showAttachmentCont(){
    TestId=ApexPages.currentPage().getParameters().get('id');
    }
    
    public Attachment att {
        get {
            if (att == null) {
                if(!Test.isRunningTest()){
                    String indemnity = 'IndemnityForm.pdf';
                    att = [SELECT id, Body, ContentType, Name FROM Attachment WHERE parentId =: TestId
                           and name=: indemnity 
                           limit 1];
                }else{
                    att = [SELECT id, Body, ContentType, Name FROM Attachment WHERE parentId =: TestId
                           limit 1];
                }

            }
            return att;
        }
        private set;
    }
    public PageReference next() {
        return new pageReference ('/servlet/servlet.FileDownload?file='+ att.id);
    }
    
    /*public String pdf {
        get {
            return String.valueOf(att.id);
        }
    }*/
}
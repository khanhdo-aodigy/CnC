/** ******
 * Description: Helper class for trigger on Test_Drive__c to create IndemnityForm.pdf attachment
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20201111			   KD@aodigy			Removed parts related to Lead 
 * 
** ******/
global without sharing class Helper_Class {
    
    @future (callout=true)
    public static void AttachPDF(String tdId)
    {
        List<Test_Drive__c> lstTDrive = new List<Test_Drive__c>();
        lstTDrive = [SELECT Id, Name, receive_idemnity_form__c, Branch_Code__c, Franchise_Code__c, 
                        Prospect__c, Prospect__r.Name, Prospect__r.Email, Prospect__r.Account.RecordTypeId
                     FROM Test_Drive__c 
                     WHERE Id = :tdId];
        
        Test_Drive__c td = (lstTDrive<>null && !lstTDrive.isEmpty()) ? lstTDrive.get(0) : null;
        if( td <> null )
        {    
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            PageReference pdfPage;
            pdfPage = setPageReference(td);
            System.debug('@@@@DEBUG AttachPDF :: pdfPage = ' + pdfPage);
            
            pdfPage.getParameters().put('id', td.id);
            pdfPage.setRedirect(true); 
            Blob pdfBlob;
            try {
                pdfBlob = pdfPage.getContentAsPdf();
            } 
            catch (Exception e) {
                pdfBlob = Blob.valueOf('Some Text');
                loggerDataPool.buildLogDataPool('Helper_Class.AttachPDF', e);
            }
            
            // Create the email attachment 
            Messaging.Emailfileattachment efaList = new Messaging.Emailfileattachment();
            efaList.setFileName('IndemnityForm.pdf');
            efaList.setBody(pdfBlob);
            

            String theTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Test_Drive_Email'].Id;
            email.setTemplateId(theTemplate);
            
            if(td.Prospect__c!=null) {
                email.setTargetObjectId(td.Prospect__c);
            }

            email.setSaveAsActivity(false);
            email.setWhatId( td.id );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efaList} );
            if(td.receive_idemnity_form__c != null){
                if(td.receive_idemnity_form__c == 'Yes'){
                    if (!Test.isRunningTest()){
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
                    }
                }
            }

            System.debug('After sending email');
            Attachment at = new Attachment(parentId = tdId, name='IndemnityForm.pdf', body = pdfBlob);
            try{
                insert at;
            }
            catch(Exception e){
                loggerDataPool.buildLogDataPool('Helper_Class.AttachPDF', e);
            }
            
            System.debug('After attachment');
            PageReference pdfPageImages;
            pdfPageImages = Page.TestDrivePDFImage;
            pdfPageImages.getParameters().put('id', td.Id);
            pdfPageImages.setRedirect(true); 
            Blob pdfBlobImages;
            
            try {
                pdfBlobImages = pdfPageImages.getContentAsPdf();
            } 
            catch (Exception e) {
                loggerDataPool.buildLogDataPool('Helper_Class.AttachPDF', e);
            }
            
            List<Attachment> listAttachments = new List<Attachment>();
            listAttachments = [SELECT Id FROM Attachment WHERE ParentId =:td.id AND Description = :td.Id];
            
            if(listAttachments.size() > 0){
                Attachment atthPdfImage = new Attachment(parentId = tdId, name='NRICImages.pdf', body = pdfBlobImages);
                insert atthPdfImage;
            }
            
            if(listAttachments.size() > 0){
                delete listAttachments;
            }
        }
    }


    private static Pagereference setPageReference( Test_Drive__c tdrive)
    {
        PageReference pdfPage;

        if( tdrive.Prospect__c <> null )
        {
            if ( tdrive.Franchise_Code__c == 'KIAPC'){
                if( AccountUtil.isCustomer( tdrive.Prospect__r.Account.RecordTypeId, null ) ) {
                    pdfPage = Page.TestDrivePDF;
                }
                else if( AccountUtil.isProspect( tdrive.Prospect__r.Account.RecordTypeId, null ) ){
                    pdfPage = Page.TestDrivePDF_Lead;
                }
            }
            if ( tdrive.Franchise_Code__c == 'MITPC'){
                if( AccountUtil.isCustomer( tdrive.Prospect__r.Account.RecordTypeId, null ) ) {
                    pdfPage = Page.TestDrivePDF_MIT;
                }
                else if( AccountUtil.isProspect( tdrive.Prospect__r.Account.RecordTypeId, null ) ){
                    pdfPage = Page.TestDrivePDF_MIT_Lead;
                }
            }
            if ( tdrive.Franchise_Code__c == 'CITPC'){
                if( AccountUtil.isCustomer( tdrive.Prospect__r.Account.RecordTypeId, null ) ) {
                    pdfPage = Page.TestDrivePDF_citroen;
                }
                else if( AccountUtil.isProspect( tdrive.Prospect__r.Account.RecordTypeId, null ) ){
                    pdfPage = Page.TestDrivePDF_citroen_Lead;
                }
            }
        }

        return pdfPage;
    }
}
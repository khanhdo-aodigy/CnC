/** ******
 * Description : Service class for generating Attachments.
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20200820             TP@aodigy.com                   Created Initial Version. 
 * 
***** **/

public with sharing class CMAttachmentService 
{
    public static Attachment generateDebitUsageAttachment (String rewardProfileId, 
                                                            Decimal totalRemainderBefore, 
                                                            Date usageDate, 
                                                            String invoiceNumber, 
                                                            Decimal invoiceAmount, 
                                                            Decimal creditAmount, 
                                                            Decimal outStandingAmount, 
                                                            Decimal totalRemainder)
    {
        PageReference debitPage = new PageReference('/apex/CMDebitUsageTranscript');
        debitPage.getParameters().put('Id', rewardProfileId);
        debitPage.getParameters().put('totalRemainderBefore', String.valueOf(totalRemainderBefore));
        debitPage.getParameters().put('usageDate', String.valueOf(usageDate));
        debitPage.getParameters().put('invoiceNumber', invoiceNumber);
        debitPage.getParameters().put('invoiceAmount', String.valueOf(invoiceAmount));
        debitPage.getParameters().put('creditAmount', String.valueOf(creditAmount));
        debitPage.getParameters().put('outStandingAmount', String.valueOf(outStandingAmount)); 
        debitPage.getParameters().put('totalRemainder', String.valueOf(totalRemainder)); 
        
        // Blob debitPageData = debitPage.getContentAsPDF();
        Blob debitPageData = Test.isRunningTest() ? Blob.valueOf('TestBlob') : debitPage.getContentAsPDF();
        
        return createAttachment(rewardProfileId, usageDate, invoiceNumber, debitPageData);
    }
    

    public static void generateCreditUsageAttachment (String rewardProfileId, 
                                                        Date issuedDate, 
                                                        String invoiceNumber, 
                                                        String creditNoteNumber, 
                                                        Decimal refundAmount, 
                                                        String refundReason,
                                                        Decimal totalRemainderAfter,
                                                        Decimal totalCreditedUsage)
    {
        PageReference creditPage = new PageReference('/apex/CMCreditUsageTranscript');
        creditPage.getParameters().put('Id', rewardProfileId);
        creditPage.getParameters().put('issuedDate', String.valueOf(issuedDate));
        creditPage.getParameters().put('invoiceNumber', invoiceNumber);
        creditPage.getParameters().put('creditNoteNumber', creditNoteNumber);
        creditPage.getParameters().put('refundAmount', String.valueOf(refundAmount));
        creditPage.getParameters().put('refundReason', refundReason);
        creditPage.getParameters().put('totalRemainderAfter', String.valueOf(totalRemainderAfter)); 
        creditPage.getParameters().put('totalCreditedUsage', String.valueOf(totalCreditedUsage)); 
        
        // Blob creditPageData = creditPage.getContentAsPDF();
        Blob creditPageData = Test.isRunningTest() ? Blob.valueOf('TestBlob') : creditPage.getContentAsPDF();
        
        createAttachment(rewardProfileId, issuedDate, creditNoteNumber, creditPageData);
    }
    

    public static Attachment createAttachment(String rewardProfileId, Date createdDate, String key, Blob pageData)
    {
        Attachment newAttachment = new Attachment(ParentId = rewardProfileId,
                                                  Body = pageData,
                                                  Name = String.valueOf(createdDate).remove('-') + '_' +  key + '.pdf');
        System.debug('createAttachment :: ' + newAttachment);
        
        insert newAttachment;

        return newAttachment;
    }
    

    public static Attachment getAttachmentById(String rewardProfileId, String key, Date createdDate)
    {
        String attachmentName = String.valueOf(createdDate).remove('-') + '_' +  key + '.pdf';
        System.debug('IN APEX CONTROLLER: ' + attachmentName);
        
        return [SELECT Id FROM Attachment WHERE ParentId =: rewardProfileId AND Name =: attachmentName];
    }
}
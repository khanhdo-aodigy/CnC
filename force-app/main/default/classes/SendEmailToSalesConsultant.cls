public class SendEmailToSalesConsultant {
    
    public static void sendEmail(String userId,String model,String variant,String showroom,String bookingDate)
    {
        User[] salesConsultant =[Select Name,Id from User where Id=: userId];
        List<EmailTemplate> emailTemplateLst = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE Name =: 'SalesConsultantNotificationEmail'];    
        
        EmailTemplate emailTemplate;
        If(emailTemplateLst!=null && emailTemplateLst.size()>0){
            emailTemplate = emailTemplateLst[0];
        }
        // process the merge fields
        String subject = emailTemplate.Subject;
        
        /*String htmlBody = emailTemplate.HtmlValue;
        
        htmlBody = htmlBody.replace('{!Test_Drive__c.OwnerId}', salesConsultant[0].Name);
        htmlBody = htmlBody.replace('{!Test_Drive__c.TModel__c}', model);
        htmlBody = htmlBody.replace('{!Test_Drive__c.TVariant__c}', variant);
        htmlBody = htmlBody.replace('{!Test_Drive__c.Showroom__c}', showroom);
        //htmlBody = htmlBody.replace('{!Test_Drive__c.Date__c}', bookingDate.valueOf(bookingDate));*/
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!Test_Drive__c.OwnerId}', salesConsultant[0].Name);
        plainBody = plainBody.replace('{!Test_Drive__c.TModel__c}', model);
        plainBody = plainBody.replace('{!Test_Drive__c.TVariant__c}', variant);
        plainBody = plainBody.replace('{!Test_Drive__c.Showroom__c}', showroom);
        plainBody = plainBody.replace('{!Test_Drive__c.Date__c}', bookingDate);
        
        //build the email message
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setReplyTo('profile.sg@e.cyclecarriage.com');
        email.setSenderDisplayName('Your C&C Profile');
        email.setTargetObjectId(salesConsultant[0].Id);
        email.setSaveAsActivity(false);
        email.setSubject(subject);
        //email.setHtmlBody(htmlBody);
        email.setPlainTextBody(plainBody);
        try {
            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
            system.debug('send email=========');
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}
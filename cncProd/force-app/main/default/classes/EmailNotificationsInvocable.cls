public with sharing class EmailNotificationsInvocable {
    @InvocableMethod(label = 'Send Email Notifications' description = 'Send email notifcations based on template name')
    public static void sendEmailNotifications(List<EmailNotificationsRequest> requests) {
        System.enqueueJob(new SendEmailNotificationQueueable(requests));
        // List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        // for (EmailNotificationsRequest request : requests) {
		// 	Messaging.SingleEmailMessage mail = EmailNotificationsService.renderToEmail(request.recordId, request.templateNm);
        //     mails.add(mail);
        //     system.debug('========= TEMPLATE NAME =========');
        //     system.debug(request.templateNm);
        // }

        // if (mails.size() > 0) {
        //     Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
        //     if (results[0].success) {
        //         system.debug('All emails was sent successfully');
        //         system.debug('========= TOTAL OF SENT MAILS =========');
        // 		system.debug(mails.size());
        //     } else {
        //         system.debug('Failed to send: ' + results[0].errors[0].message);
        //     }
        // }
    }

    public class SendEmailNotificationQueueable implements Queueable
    {
        public List<EmailNotificationsRequest> requests;

        public SendEmailNotificationQueueable(List<EmailNotificationsRequest> requestList) 
        {
            this.requests = requestList;
        }

        public void execute(QueueableContext qc)
        {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for (EmailNotificationsRequest request : requests) 
            {
                Messaging.SingleEmailMessage mail = EmailNotificationsService.renderToEmail(request.recordId, request.templateNm);
                mails.add(mail);
                system.debug('========= TEMPLATE NAME =========');
                system.debug(request.templateNm);
            }

            if (mails.size() > 0) 
            {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
                if (results[0].success) 
                {
                    system.debug('All emails was sent successfully');
                    system.debug('========= TOTAL OF SENT MAILS =========');
                    system.debug(mails.size());
                } 
                else 
                {
                    system.debug('Failed to send: ' + results[0].errors[0].message);
                }
            }
        }
    }

    public class EmailNotificationsRequest {
        @InvocableVariable(required=true)
        public Id recordId;

        @InvocableVariable(required=true)
        public String templateNm;
    }
}
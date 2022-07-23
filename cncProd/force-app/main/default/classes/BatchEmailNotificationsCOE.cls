global class BatchEmailNotificationsCOE implements Database.Batchable<sObject>{
	// @TestVisible static Integer emailLimits;

    public class EmailNotificationsException extends Exception{}

    global static Database.QueryLocator start(Database.BatchableContext bc) {
        Date d = Date.today().addDays(30);

        return Database.getQueryLocator([SELECT Id, Owner.Name, SOH_SONO__c, emailaddress__c, COE__r.Id,
                                         		COE__r.COH_COENO__c, COE__r.COH_SUCCESSFROMDT__c, COE__r.COH_SUCCESSTODT__c,
                                         		COE__r.COH_EXPMONTH__c, COE_Expiry_Date__c, SOH_REGNO__c, Stage__c
                                         FROM Sales_Agreement__c
                                         WHERE COE_Expiry_Date__c =: d and SOH_REGNO__c = null and Stage__c != 'Cancelled']);
    }

    global void execute(Database.BatchableContext bc, List<Sales_Agreement__c> records) {
        system.debug('***** START EXECUTION *****');
        OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName 
                                   FROM OrgWideEmailAddress 
                                   WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg' 
                                   LIMIT 1];

        EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body 
                                  FROM EmailTemplate 
                                  WHERE Name = 'COE_Expiry_Email'];

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Sales_Agreement__c sa : records) {
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, null, sa.Id);
            //mail.setSenderDisplayName(sa.Owner.Name);
            mail.setOrgWideEmailAddressId(owa.Id);
            String customerEmail = Test.isRunningTest() ? 'test@gmail.com' : sa.emailaddress__c;
            mail.setToAddresses(new List<String>{customerEmail});
            //mail.setToAddresses(new List<String>{sa.emailaddress__c});
            system.debug(mail.getToAddresses());
            mails.add(mail);
        }

        if (mails.size() > 0) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
            } catch (Exception e) {
                loggerDataPool.buildLogDataPool('EmailNotificationsCOEBatch', e);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        batchDataPool.buildBatchDataPool('EmailNotificationsCOEBatch', bc.getJobId());
		// For testing purpose
        // BatchEmailNotificationsCOE.emailLimits = Limits.getEmailInvocations();
    }
}
/********************************************************************
 * Date(YYMMDD)                Name                 Description
 * 20220728                    Thanh Ly             Create Initial Version
 */
global class BatchEmailCOEBiddingReport implements Database.Batchable<sObject>{
	// @TestVisible static Integer emailLimits;

    public class BatchEmailCOEBiddingReportException extends Exception{}

    global static Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, From_Date__c, To_Date__c
                                         FROM COE_Bid_Period__c
                                         WHERE From_Date__c = :Date.today()]);
    }

    global void execute(Database.BatchableContext bc, List<COE_Bid_Period__c> records) {
        system.debug('***** START EXECUTION *****');
       
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'CITPC Sales' OR Name = 'MITPC Sales' OR Name = 'KIAPC Sales'];
        List<Id> profileIds = new List<Id>();
        for (Profile profile : profiles){
            profileIds.add(profile.Id);
        }
        // System.debug('Profile ::' + profileIds);

        List<User> salesConsultants = [SELECT Id, Email FROM User WHERE ProfileId IN :profileIds AND IsActive = true];
        List<String> emails = new List<String>();
        if (salesConsultants.size()>0){
            for (User salesConsultant : salesConsultants){
                emails.add(salesConsultant.Email);
            }
            emails.add('thanh.ly@aodigy.com');
        }
        // System.debug('Email ::' + emails);

        Report coeReport = [SELECT Id, DeveloperName FROM Report WHERE DeveloperName = 'DSAs_for_COE_Bidding_aVt'];
        String URL = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Report/' + coeReport.Id + '/view?queryScope=userFolders';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (COE_Bid_Period__c coe : records) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emails);
            mail.setSubject('COE Bidding report to verify !');
            mail.setHtmlBody(URL);
            System.debug('Email Address :' + mail.getToAddresses());
            mails.add(mail);
        }

        if (mails.size() > 0) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
                for (Messaging.SendEmailResult rs : results) 
                {
                    if (!rs.isSuccess()) 
                    {
                        for (Messaging.SendEmailError err : rs.getErrors()) 
                        {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                    else
                    {
                        System.debug('Successfull send email to Sales Consultant');  
                    }
                }

                System.debug('***** END EXECUTION *****');
            } catch (Exception e) {
                loggerDataPool.buildLogDataPool('BatchEmailCOEBiddingReport', e);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        batchDataPool.buildBatchDataPool('BatchEmailCOEBiddingReport', bc.getJobId());
    }
}
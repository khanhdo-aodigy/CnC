public with sharing class BPETemplatePreviewCtrl {

    public Sales_Agreement__c getSalesAgreement() {
        ID recordID = ApexPages.CurrentPage().getParameters().get('id');
        return [SELECT CUM_FIRSTNAME__c, Owner.Name, SOH_SONO__c, emailaddress__c, OwnerId, BalancePayment__c, TradeInBalance__c, GMS_Package__c FROM Sales_Agreement__c WHERE ID = :recordID];
    }

    public string getBPETemplate () {
        
        Sales_Agreement__c currentSA = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, OwnerId, BalancePayment__c, TradeInBalance__c, GMS_Package__c FROM Sales_Agreement__c WHERE ID = :ApexPages.CurrentPage().getParameters().get('id')];

        EmailTemplate BpeTemplate = templateSelector(currentSA);
        
        Messaging.SingleEmailMessage renderEmail = Messaging.renderStoredEmailTemplate(BpeTemplate.Id, currentSA.OwnerId, currentSA.ID);
        
        return renderEmail.getHtmlBody();
    }

    public void emailToCustomer() {

        string recordID = ApexPages.CurrentPage().getParameters().get('id');
        Sales_Agreement__c currentSA = [SELECT Owner.Name, SOH_SONO__c, emailaddress__c, OwnerId, BalancePayment__c, TradeInBalance__c, GMS_Package__c, Balance_Payment_Email__c FROM Sales_Agreement__c WHERE ID = :recordID];
        
        EmailTemplate template = templateSelector(currentSA);
        
        // dummy contact required to render the template, will delete when the email sent
        //Contact dummyContact = new Contact(FirstName = 'Test', LastName = 'Test', email = currentSA.emailaddress__c);
        //insert dummyContact;

        // render email template
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, null, recordID);
        
        // set display name in email
        mail.setSenderDisplayName(currentSA.Owner.Name);

        // set target email address
        string customerEmail = Test.isRunningTest()? 'test@gmail.com' : currentSA.emailaddress__c;
        List<string> toAddress = new List<string> {customerEmail};
        mail.setToAddresses(toAddress);
        
        // send email
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>{mail};

        // process the response and delete dummy contact
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
            system.debug('Email Result');
            system.debug(results);
            if (results[0].success) {
                currentSA.Balance_Payment_Email__c = true;
                update currentSA;
                system.debug('Send success');
                //delete dummyContact;
            } else {
                system.debug('Send failed');
                //delete dummyContact;
            }
            return;
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
    }

    private enum Template {NORMAL, DEFICIT, DEFICIT_RA, CUSTOMER_REFUND}

    private EmailTemplate templateSelector(Sales_Agreement__c salesAgreement) {
        decimal totalBalance = salesAgreement.BalancePayment__c;
        decimal tradeInBalance = salesAgreement.TradeInBalance__c;
        decimal gmsBalance = salesAgreement.GMS_Package__c;
        boolean negativeTotalBalance = (totalBalance <= 0 || totalBalance == null) ? true : false;
        boolean negativeTradeInBalance = (tradeInBalance < 0 || tradeInBalance == null) ? true : false;
        boolean negativeGmsBalance = (gmsBalance < 0 || gmsBalance == null) ? true : false;
        string templateName = Template.NORMAL.name(); // baseline scenario: NORMAL
        
        if (negativeTotalBalance) {
            templateName = Template.CUSTOMER_REFUND.name();
        }
        
        if (!negativeTotalBalance && !negativeTradeInBalance) {
            templateName = Template.NORMAL.name();
        }

        if (!negativeTotalBalance && negativeTradeInBalance && !negativeGmsBalance) {
            templateName = Template.DEFICIT.name();
        }

        if (!negativeTotalBalance && negativeTradeInBalance && negativeGmsBalance) {
            templateName = Template.DEFICIT_RA.name();
        }

        List<BPE_Template_Configuration__mdt> templates = (List<BPE_Template_Configuration__mdt>) [SELECT MasterLabel, Template_ID__c, Active__c FROM BPE_Template_Configuration__mdt WHERE Active__c = true AND MasterLabel = :templateName];
        if (templates.size() == 1) {
            string templateId = templates[0].Template_ID__c;
            system.debug('BPE Template ID: ' + templateId);
            system.debug('BPE Template Label: ' + templates[0].MasterLabel);
            if (!Test.isRunningTest()) {
                return [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE ID = :templateId];
            } else {
                templateName = 'BalancePaymentInfo_' + templateName;
                return [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :templateName];
            }
            
        } else {
            throw new templateSelectorException('There are no or more than 1 template found');
        }
    }

    private class templateSelectorException extends Exception {}
}
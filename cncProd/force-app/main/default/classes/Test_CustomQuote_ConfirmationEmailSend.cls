@isTest(seeAllData=true)
public class Test_CustomQuote_ConfirmationEmailSend {

    Public static testMethod void testSendEmail()
    {
        Decimal BasePrice = 56000;
        Decimal CustomizedPrice = 54000;
        Test.startTest(); 
        CustomQuote_ConfirmationEmailSend.sendEmail('ContactName','test@xyz.com','subcriberKey','8585','CCK','ModelName','VariantName',BasePrice,CustomizedPrice,'customQuoteId','relatedCustomQuotesId','SalesConsultant','SalesConsultantMobileNumber', '', '', '', '', '', '', '', '', '', '', '', '');
        CustomQuote_ConfirmationEmailSend.SendHttpEmail('ContactName','test@xyz.com','subcriberKey','8585','tokenValue','CCK','ModelName','VariantName',BasePrice,CustomizedPrice,'customQuoteId','relatedCustomQuotesId','SalesConsultant','SalesConsultantMobileNumber', '', '', '', '', '', '', '', '', '', '', '', '');
        CustomQuote_ConfirmationEmailSend.SendHttpEmail('ContactName','test@xyz.com','subcriberKey','8585','tokenValue','CCI','ModelName','VariantName',BasePrice,CustomizedPrice,'customQuoteId','relatedCustomQuotesId','SalesConsultant','SalesConsultantMobileNumber', '', '', '', '', '', '', '', '', '', '', '', '');
        CustomQuote_ConfirmationEmailSend.SendHttpEmail('ContactName','test@xyz.com','subcriberKey','8585','tokenValue','CCA','ModelName','VariantName',BasePrice,CustomizedPrice,'customQuoteId','relatedCustomQuotesId','SalesConsultant','SalesConsultantMobileNumber', '', '', '', '', '', '', '', '', '', '', '', '');
        CustomQuote_ConfirmationEmailSend.SendHttpEmail('ContactName','test@xyz.com','subcriberKey','8585','tokenValue','CCF','ModelName','VariantName',BasePrice,CustomizedPrice,'customQuoteId','relatedCustomQuotesId','SalesConsultant','SalesConsultantMobileNumber', '', '', '', '', '', '', '', '', '', '', '', '');
        Test.stopTest();
    }
}
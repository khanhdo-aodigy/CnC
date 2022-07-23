public class CustomQuote_ConfirmationEmailSend {

public static HTTPResponse res{get; set;}
public static String resBody{get; set;}
    
@future (callout=true)
    public static void sendEmail(String personName,String personEmail,String SubscriberKey, String triggeredSendMessageId,
								String BranchCode, String ModelName,String VariantName,Decimal BasePrice,Decimal CustomizedPrice,
								String customQuoteId,String relatedCustomQuotesId,String SalesConsultant,String SalesConsultantMobileNumber,
								String Trim, String Color, String TradeinModel, String TradeinBrand, String Tradeinregnumber, String TradeinMileage,
								String Lastfournric, String BankName, String LoanInterest, String LoanAmount, String LoanTerm, String MonthlyInstallment)
    {
        String tokenValue = '';
    //If(Test.isRunningTest()==False){
        tokenValue = GenerateRequestToken.getRequestToken();
        If(tokenValue!='') SendHttpEmail(personName, personEmail, SubscriberKey, triggeredSendMessageId, tokenValue,
										BranchCode, ModelName, VariantName, BasePrice, CustomizedPrice, customQuoteId,
										relatedCustomQuotesId, SalesConsultant, SalesConsultantMobileNumber,
										Trim, Color, TradeinModel, TradeinBrand, Tradeinregnumber, TradeinMileage,
										Lastfournric, BankName, LoanInterest, LoanAmount, LoanTerm, MonthlyInstallment);
     //}   

}
    public static void SendHttpEmail(String personName,String personEmail,String SubscriberKey, String triggeredSendMessageId,
									String tokenValue,String BranchCode,String ModelName,String VariantName,Decimal BasePrice,Decimal CustomizedPrice,
									String customQuoteId,String relatedCustomQuotesId,String SalesConsultant,String SalesConsultantMobileNumber,
									String Trim, String Color, String TradeinModel, String TradeinBrand, String Tradeinregnumber, String TradeinMileage,
									String Lastfournric, String BankName, String LoanInterest, String LoanAmount, String LoanTerm, String MonthlyInstallment)
    {
        if(String.isNotBlank(personEmail))
        {
            try
            {
                HttpRequest reqPrimaryEmail = new HttpRequest();
                reqPrimaryEmail.setMethod('POST');
                reqPrimaryEmail.setHeader('content-type', 'application/json;charset=utf-8');    
                reqPrimaryEmail.setHeader('Authorization', 'Bearer '+tokenValue);
                reqPrimaryEmail.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+triggeredSendMessageId+'/send');
                
                if(BranchCode=='CCK'){
                
                reqPrimaryEmail.setBody('{ "From": {"Address": "sales.kia.sg@e.cyclecarriage.com","Name": "C&C Kia Showroom"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"Name": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'","VariantName": "'+VariantName+'","BasePrice": "'+BasePrice+'","CustomizedPrice": "'+CustomizedPrice+'","customQuoteId": "'+customQuoteId+'","relatedCustomQuotesId": "'+relatedCustomQuotesId+'","SalesConsultant": "'+SalesConsultant+'","SalesConsultantMobileNumber": "'+SalesConsultantMobileNumber+'","Trim": "'+Trim+'","Color": "'+Color+'","TradeinModel": "'+TradeinModel+'","TradeinBrand": "'+TradeinBrand+'","Tradeinregnumber": "'+Tradeinregnumber+'","TradeinMileage": "'+TradeinMileage+'","Lastfournric": "'+Lastfournric+'","BankName": "'+BankName+'","LoanInterest": "'+LoanInterest+'","LoanAmount": "'+LoanAmount+'","LoanTerm": "'+LoanTerm+'","MonthlyInstallment": "'+MonthlyInstallment+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }
                Else If(BranchCode=='CCA')
                {
                  //reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mitsubishi.sg@e.cyclecarriage.com","Name": "C&C Mitsubishi Showroom"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"Name": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'","VariantName": "'+VariantName+'","BasePrice": "'+BasePrice+'","CustomizedPrice": "'+CustomizedPrice+'","customQuoteId": "'+customQuoteId+'","relatedCustomQuotesId": "'+relatedCustomQuotesId+'","SalesConsultant": "'+SalesConsultant+'","SalesConsultantMobileNumber": "'+SalesConsultantMobileNumber+'"}}},"Options": {"RequestType": "ASYNC"}}');  
                  reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mitsubishi@e.cyclecarriage.com","Name": "C&C Mitsubishi Sales"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"Name": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'","VariantName": "'+VariantName+'","BasePrice": "'+BasePrice+'","CustomizedPrice": "'+CustomizedPrice+'","customQuoteId": "'+customQuoteId+'","relatedCustomQuotesId": "'+relatedCustomQuotesId+'","SalesConsultant": "'+SalesConsultant+'","SalesConsultantMobileNumber": "'+SalesConsultantMobileNumber+'","Trim": "'+Trim+'","Color": "'+Color+'","TradeinModel": "'+TradeinModel+'","TradeinBrand": "'+TradeinBrand+'","Tradeinregnumber": "'+Tradeinregnumber+'","TradeinMileage": "'+TradeinMileage+'","Lastfournric": "'+Lastfournric+'","BankName": "'+BankName+'","LoanInterest": "'+LoanInterest+'","LoanAmount": "'+LoanAmount+'","LoanTerm": "'+LoanTerm+'","MonthlyInstallment": "'+MonthlyInstallment+'"}}},"Options": {"RequestType": "ASYNC"}}');  
                
                }
                Else If(BranchCode=='CCF')
                {
                   reqPrimaryEmail.setBody('{ "From": {"Address": "sales.citroen.sg@e.cyclecarriage.com","Name": "C&C Citroen Showroom"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"Name": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'","VariantName": "'+VariantName+'","BasePrice": "'+BasePrice+'","CustomizedPrice": "'+CustomizedPrice+'","customQuoteId": "'+customQuoteId+'","relatedCustomQuotesId": "'+relatedCustomQuotesId+'","SalesConsultant": "'+SalesConsultant+'","SalesConsultantMobileNumber": "'+SalesConsultantMobileNumber+'","Trim": "'+Trim+'","Color": "'+Color+'","TradeinModel": "'+TradeinModel+'","TradeinBrand": "'+TradeinBrand+'","Tradeinregnumber": "'+Tradeinregnumber+'","TradeinMileage": "'+TradeinMileage+'","Lastfournric": "'+Lastfournric+'","BankName": "'+BankName+'","LoanInterest": "'+LoanInterest+'","LoanAmount": "'+LoanAmount+'","LoanTerm": "'+LoanTerm+'","MonthlyInstallment": "'+MonthlyInstallment+'"}}},"Options": {"RequestType": "ASYNC"}}');  
                
					if(ModelName.contains('DS'))
					{
						reqPrimaryEmail.setBody('{ "From": {"Address": "sales.DS.sg@e.cyclecarriage.com","Name": "C&C DS Showroom"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"Name": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'","VariantName": "'+VariantName+'","BasePrice": "'+BasePrice+'","CustomizedPrice": "'+CustomizedPrice+'","customQuoteId": "'+customQuoteId+'","relatedCustomQuotesId": "'+relatedCustomQuotesId+'","SalesConsultant": "'+SalesConsultant+'","SalesConsultantMobileNumber": "'+SalesConsultantMobileNumber+'","Trim": "'+Trim+'","Color": "'+Color+'","TradeinModel": "'+TradeinModel+'","TradeinBrand": "'+TradeinBrand+'","Tradeinregnumber": "'+Tradeinregnumber+'","TradeinMileage": "'+TradeinMileage+'","Lastfournric": "'+Lastfournric+'","BankName": "'+BankName+'","LoanInterest": "'+LoanInterest+'","LoanAmount": "'+LoanAmount+'","LoanTerm": "'+LoanTerm+'","MonthlyInstallment": "'+MonthlyInstallment+'"}}},"Options": {"RequestType": "ASYNC"}}');  
					}
				}				
                Else If(BranchCode=='CCI')
                {
                    reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mercedes-benz.sg@e.cyclecarriage.com","Name": "C&C Mercedes Showroom"},"To":{"Address": "'+personEmail+'","SubscriberKey": "'+SubscriberKey+'","ContactAttributes": {"SubscriberAttributes":{"Name": "'+personName+'","Brand": "'+BranchCode+'","ModelName": "'+ModelName+'","VariantName": "'+VariantName+'","BasePrice": "'+BasePrice+'","CustomizedPrice": "'+CustomizedPrice+'","customQuoteId": "'+customQuoteId+'","relatedCustomQuotesId": "'+relatedCustomQuotesId+'","SalesConsultant": "'+SalesConsultant+'","SalesConsultantMobileNumber": "'+SalesConsultantMobileNumber+'","Trim": "'+Trim+'","Color": "'+Color+'","TradeinModel": "'+TradeinModel+'","TradeinBrand": "'+TradeinBrand+'","Tradeinregnumber": "'+Tradeinregnumber+'","TradeinMileage": "'+TradeinMileage+'","Lastfournric": "'+Lastfournric+'","BankName": "'+BankName+'","LoanInterest": "'+LoanInterest+'","LoanAmount": "'+LoanAmount+'","LoanTerm": "'+LoanTerm+'","MonthlyInstallment": "'+MonthlyInstallment+'"}}},"Options": {"RequestType": "ASYNC"}}');
                }
                
                
                
                Http http1 = new Http(); 
                    If(Test.isRunningTest()==False)
                    {
                        HTTPResponse res1 = http1.send(reqPrimaryEmail); 
                        resBody=res1.getBody(); 
                        system.debug('resBody==============='+resBody);
                    }
            }
            catch(Exception e)
            {
                System.debug('An Error Occured: ' + e.getMessage());
            }
        }
    }
}
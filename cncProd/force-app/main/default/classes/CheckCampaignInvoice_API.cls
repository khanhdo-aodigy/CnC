@RestResource(urlMapping='/CampaignInvoiceAmounts/v1/*')
global with sharing class CheckCampaignInvoice_API {

    @HttpGet
    global static ResponseWrapper doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ResponseWrapper response = new ResponseWrapper();

        try {
            Decimal amountWithGST = Decimal.valueOf(req.params.get('AmountWithGST'));
            Decimal netAmount = Decimal.valueOf(req.params.get('NetAmount'));
            Decimal discount = Decimal.valueOf(req.params.get('Discount'));
            String campaignId = req.params.get('CampaignId');

            CampaignPriceService.CampaignInvoiceDetails campInvDetails = new CampaignPriceService.CampaignInvoiceDetails(
                campaignId, netAmount, discount
            );

            if(CampaignPriceService.verifyCampaignPrices(new List<CampaignPriceService.CampaignInvoiceDetails>{campInvDetails})) {
                if(amountWithGST == netAmount) {
                    response.isVerified = true;
                } else {
                    logVerificationFailure(req, 'AmountWithGST not equal to NetAmount');
                    response.isVerified = false;
                }
            } else {
                response.isVerified = false;
            }
            res.statusCode = 200;
        } catch(Exception e) {
            logVerificationException(req, e);
            res.statusCode = 400;
        }

        return response;
    }
    
    private static void logVerificationFailure(RestRequest req, String message) {
		Logger_Data_Pool__c newLogDataPool = new Logger_Data_Pool__c(
        	Instance__c = 'CheckCampaignInvoice_API',
            Type__c = 'Verification Failure'
        );
		newLogDataPool.Message__c = req.toString() + ' - ' + message;

		insert newLogDataPool;
    }    
    
    private static void logVerificationException(RestRequest req, Exception exce) {
		Logger_Data_Pool__c newLogDataPool = new Logger_Data_Pool__c(
        	Cause__c = String.valueOf(exce.getCause()),
            Instance__c = 'CheckCampaignInvoice_API',
            Line_Number__c = exce.getLineNumber(),
            Message__c = req.toString() + ' - ' + exce.getMessage(),
            Stack_Trace__c = exce.getStackTraceString(),
            Type__c = exce.getTypeName()
        );
        
        insert newLogDataPool;
    }        

    global class ResponseWrapper {
        @TestVisible Boolean isVerified;

        ResponseWrapper() {}
    }

}
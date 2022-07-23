@RestResource(urlMapping='/CampaignPaymentAmounts/v1/*')
global with sharing class CheckCampaignPayment_API {

    @HttpGet
    global static ResponseWrapper doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ResponseWrapper response = new ResponseWrapper();

        try {
            Decimal amount = Decimal.valueOf(req.params.get('Amount'));
            Decimal taxAmount = Decimal.valueOf(req.params.get('TaxAmount'));
            Decimal discountAmount = Decimal.valueOf(req.params.get('DiscountAmount'));
            Decimal unitAmount = Decimal.valueOf(req.params.get('UnitAmount'));
            Decimal quantity = Decimal.valueOf(req.params.get('Quantity'));
            Decimal unitTaxAmount = Decimal.valueOf(req.params.get('UnitTaxAmount'));
            Decimal totalAmount = Decimal.valueOf(req.params.get('TotalAmount'));
            String campaignId = req.params.get('CampaignId');

            CampaignPriceService.CampaignInvoiceDetails campInvDetails = new CampaignPriceService.CampaignInvoiceDetails(
                campaignId, amount, discountAmount
            );
            CampaignPriceService.CampaignPaymentDetails campPayDetails = new CampaignPriceService.CampaignPaymentDetails(
            	campInvDetails, unitAmount
            );

            if(CampaignPriceService.verifyCampaignPrices(new List<CampaignPriceService.CampaignPaymentDetails>{campPayDetails})) {
                if(taxAmount == 0 && quantity == 1 && unitTaxAmount == 0 && amount == totalAmount) {
                    response.isVerified = true;
                } else {
                    logVerificationFailure(req, 'Invalid request body data');
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
            Instance__c = 'CheckCampaignPayment_API',
            Type__c = 'Verification Failure'
        );
        newLogDataPool.Message__c = req.toString() + ' - ' + message;
        
        insert newLogDataPool;
    } 
    
    private static void logVerificationException(RestRequest req, Exception exce) {
		Logger_Data_Pool__c newLogDataPool = new Logger_Data_Pool__c(
        	Cause__c = String.valueOf(exce.getCause()),
            Instance__c = 'CheckCampaignPayment_API',
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
/** *****
 * Description : API used to check for valid Promotion code on Campaign
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer                  Details
 * 20210417             khanh.do@aodigy            Created initial version
 ** *****/
@RestResource(urlMapping='/promotion/checkPromoCode/*')
global with sharing class CheckCampaignPromoCodeAPI {
    private static RestRequest request   = RestContext.request;
    private static RestResponse response = RestContext.response;
    private static RequestBody reqBody   = new RequestBody();
    private static ResponseBody resBody  = new ResponseBody();
    private static ErrorResponse errorResponse;

    @HttpPost
    global static void checkCampaignPromoCode() 
    {
        try {
            processRequest();
        } 
        catch(Exception ex) {
            //response.statusCode = 400;            
            //response.responseBody = Blob.valueOf(JSON.Serialize(ex.getMessage()));
            errorResponse = new ErrorResponse('Failed', ex.getMessage(), 603);
            loggerDataPool.buildLogDataPool('CheckCampaignPromoCodeAPI', ex);
            System.debug ('Exception: ' + ex.getMessage() + ' || At line: ' + ex.getLineNumber());
        }

        if(/*String.isNotBlank(errorResponse.Message)*/ errorResponse != null && errorResponse.status == 'Failed') {    
            response.addHeader('Content-Type', 'application/json');
            //response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        
        serviceDataPool.buildServiceDataPool('checkCampaignPromoCode', 'CheckCampaignPromoCodeAPI', '', request, response);
    }

    private static void processRequest() {
        reqBody = (RequestBody)JSON.deserialize(request.requestBody.toString(), RequestBody.class);
        String campaignId = reqBody.CampaignID;
        String promoCode  = reqBody.PromoCode;

        if(String.isBlank(campaignId) || String.isBlank(promoCode)) {
            //errorResponse.Message = 'Mandatory field is missing, please refer to API doc. ';
            errorResponse = new ErrorResponse('Failed', 'Sorry. Mandatory field is missing. Fields: CampaignId/PromoCode', 600);  
            return;
        }

        Campaign campaign = CampaignService.getCampaignById(campaignId);
        if( campaign == null ) {
            errorResponse = new ErrorResponse('Failed', 'Sorry. There is no Campagin found.', 601);  
            return;  
        }

        Promo_Code_Master__c promo = PromoCodeMasterService.getPromoByNameAndCampaignId(promoCode, campaignId);

        if(promo == null) {
            errorResponse = new ErrorResponse('Failed', 'Sorry, this promo code is not valid.', 602);  
            return;
        }

        if( !PromoCodeMasterService.isPromoCodeExpired(promo) ) {
            resBody.Message      = 'Valid';
            resBody.ExpiryDate   = promo.Expiry_Date__c.format();
            resBody.Type         = promo.Promo_Discount_Type__c;
            resBody.Amount       = promo.Amount__c;
        
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;            
            response.responseBody = Blob.valueOf(JSON.serialize(resBody));
        } else {
            errorResponse = new ErrorResponse('Failed', 'Sorry, this promo code has expired.', 603);
        }
        
    }

    // public class ErrorResponse {
    //     public Integer ErrorCode = 400;
    //     public String Message;
    // }

    public class ErrorResponse{
        public String Status;
        public String Message;
        public Integer ErrorCode;

        public ErrorResponse(String statusValue, String messageValue, Integer error){
            Status = statusValue;
            Message = messageValue;
            ErrorCode = error;
        }
    }

    public class ResponseBody 
    {
        public Integer SuccessCode = 201;
        public String Message;
        public String ExpiryDate;
        public String Type;
        public Double Amount;
    }

    public class RequestBody 
    {
        public String CampaignID; 
        public String PromoCode;
    }
}
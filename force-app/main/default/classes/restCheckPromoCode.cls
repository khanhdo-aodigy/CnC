/*******
 * Description : API class for Promotion Code Validation
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200508             TP     Created Initial Version 
 * 20200512             TP     Added Description 
 * 20200514             TP     Added httpErrorResponse inner class
 * 20200520             TP     Added Success Message and Code
 * 20200526             TP     Added Price Discount to Description
 * 20200601             TP     Handled case of Campaign with no Campaign Invited Member
 * 20200611             TP     Addd case of Fully Redeemed 
*******/

@RestResource (urlMapping = '/PromoCode/*')
global class restCheckPromoCode {
    
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static httpErrorResponse errorResponse;
    private static RequestBody reqBody = new RequestBody();
    private static List<Campaign> campaignList = new List<Campaign>(); 
    private static List<Campaign_Invited_members__c> cpgInvitedMemList = new List<Campaign_Invited_members__c>();
    private static List<Promo_gift_line_item__c> giftLineItemList = new List<Promo_gift_line_item__c>();
    private static ResponseBody resBody = new ResponseBody();
    
    @HttpPost
    global static void doPost() {
        res.addHeader('Content-Type', 'application/json');
        
        try {  
            
            processPostRequest();    
            
        }catch(Exception e) {
            
            loggerDataPool.buildLogDataPool('restCheckPromoCode', e);
            errorResponse = new httpErrorResponse('Failed', e.getMessage(), 605);
            
        }
        
        if(errorResponse != null && errorResponse.status == 'Failed') {    
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        
        serviceDataPool.buildServiceDataPool('checkPromoCode', 'restCheckPromoCode', '', req, res);
    }
    
    public static void processPostRequest() {
        reqBody = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);

        campaignList = [SELECT Id, StartDate, EndDate, Promo_Category__c, Fully_Redeemed__c FROM Campaign WHERE Promo_Code__c =: reqBody.PromoCode
                                                                                          //AND Promo_Category__c includes :reqBody.PromoCategory
                                                                                            AND Brand__c =: reqBody.Brand
                                                                                            AND Branch_Code__c =: reqBody.Branch];
        
        if (campaignList != null && !campaignList.isEmpty()) 
		{
            if (Date.today() >= campaignList[0].StartDate && Date.today() <= campaignList[0].EndDate && campaignList[0].Promo_Category__c.contains(reqBody.PromoCategory)) 
			{    
                if (campaignList[0].Fully_Redeemed__c) 
                {
                    errorResponse = new httpErrorResponse('Failed', 'Sorry. The promotion code is fully redeemed.', 600);    
                }   
                else 
                {
                    getPromoDetails();      
                }          
            } 
			else 
			{                
                errorResponse = new httpErrorResponse('Failed', 'Sorry. The promotion code is no longer valid.', 601);                
            }
        } 
		else 
		{            
            errorResponse = new httpErrorResponse('Failed', 'Sorry. There is no campaign available.', 602);
            
        }
    }

    public static void getPromoDetails() {
        Map<String, Campaign_Invited_members__c> cpgInvitedMemMap = new Map<String, Campaign_Invited_members__c>();
        
    	giftLineItemList = [SELECT Id, Name, Gift_type__c FROM Promo_gift_line_item__c WHERE Campaign__c =: campaignList[0].Id];
        cpgInvitedMemList = [SELECT Id, Email__c, Redeem__c FROM Campaign_Invited_members__c WHERE Campaign__c =: campaignList[0].Id];

        if (cpgInvitedMemList.size() > 0) {
            for (Campaign_Invited_members__c invitedMember : cpgInvitedMemList) {
                cpgInvitedMemMap.put(invitedMember.Email__c, invitedMember);
            }

            if (cpgInvitedMemMap.get(reqBody.Email) != null) {
                if (cpgInvitedMemMap.get(reqBody.Email).Redeem__c == 'Open') {     
    
                    resBody.invitedMemberId = cpgInvitedMemMap.get(reqBody.Email).Id;
					resBody.isPromoOpen = false;
                    generateResponseBody();
                
                } else {
    
                    errorResponse = new httpErrorResponse('Failed', 'Sorry. The promotion code associated with this email address has been redeemed.', 603);
    
                }     
            } else {
    
                errorResponse = new httpErrorResponse('Failed', 'Sorry. The email address is not eligible for promotion code.', 604);
                
            }   
        } else {
            resBody.invitedMemberId = '';
			resBody.isPromoOpen = true;
            generateResponseBody();
        }    
    }

    public static void generateResponseBody () {
        List<GiftItem> giftItems = new List<GiftItem>();
        List<String> giftItemsStr = new List<String>();
        resBody.CampaignId =  campaignList[0].Id;
        for (Promo_gift_line_item__c giftLineItem : giftLineItemList) {
            String giftItemStr = '';
            if (giftLineItem.Gift_type__c == 'Gift') {
                giftItemStr = 'Free ' + giftLineItem.Name;
            } else {
                giftItemStr = '$' + giftLineItem.Name + ' ' + giftLineItem.Gift_type__c;
            }
            
            if (giftLineItem.Gift_type__c == 'Price Discount' && giftItemsStr.size() > 0) {
                giftItemsStr.add(0, giftItemStr);
            } else {
                giftItemsStr.add(giftItemStr);
            }
            
            GiftItem giftItem = new GiftItem();
            giftItem.Value = giftLineItem.Name;
            giftItem.Type =  giftLineItem.Gift_type__c;
            giftItems.add(giftItem);
        }
        resBody.Description = giftItemsStr.isEmpty() ? '' : String.join(giftItemsStr, ', ');
        resBody.GiftItems = giftItems;
        resBody.successCode = 201;
        resBody.message = 'The promotion code assosociated with this email address is valid.';

        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.Serialize(resBody));
    }
    
    public class RequestBody {
        public String Email;
        public String PromoCode;
        public String PromoCategory;
        public String Brand;
        public String Branch;
    }
    
    public class ResponseBody {
        public String CampaignId;
        public String invitedMemberId;
        public List<GiftItem> GiftItems;
        public String Description;
        public String message;
		public boolean isPromoOpen;
        public Integer successCode;
    }
    
    public class GiftItem {
        public String Value;
        public String Type;
    }

    public class httpErrorResponse{
        public String status;
        public String message;
        public Integer errorCode;

        public httpErrorResponse(String stausValue, String messageValue, Integer error){
            status = stausValue;
            message = messageValue;
            errorCode = error;
        }
    }
}
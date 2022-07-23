/** *****
* Description : Get Campaigns for public
* End Point: 
* Method : POST 
* 
* Change History
* Date(YYYYMMDD)       Name                            Description
* 20210407             tphung@aodigy.com             	Created Initial Version. 
* 
** *****/
@RestResource(urlMapping = '/promotion/getCampaigns/*')
global with sharing class CampaignPromoForPublicAPI {
    
    private static RestRequest req = RestContext.request;
    private static RestResponse res = RestContext.response;
    private static RequestBody reqBody = new RequestBody();
    private static ResponseBody resBody = new ResponseBody();
    private static httpErrorResponse errorResponse;     
    private static List<Campaign> campaignList = new List<Campaign>();
    private static List<String> campaignsNoTC = new List<String>();
    
    @HttpPost
    global static void doPost(){
        res.addHeader('Content-Type','application/json');
        
        try{
            processPostRequest();
            
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('CampaignPromoForPublicAPI', e);
            errorResponse = new httpErrorResponse('Failed',e.getMessage());
        }
        if(errorResponse !=null && errorResponse.status == 'Failed'){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
        }
        serviceDataPool.buildServiceDataPool('CampaignPromoForPublicAPI', 'CampaignPromoForPublicAPI', '', req, res);

        if (campaignsNoTC.size() > 0)
        {
            InvoiceEmail_ProcessBuilder_RestTC.apexcallout(campaignsNoTC);
        }
    }
    
    public static void processPostRequest(){
        reqBody = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);
        String brand = reqBody.Brand;
        String branchCode = reqBody.BranchCode;
        if(String.isBlank(brand) || String.isBlank(branchCode)){
            errorResponse = new httpErrorResponse('Failed','Mandatory Fields Missing');
        }
        else{
            // query cond: status planned, public, matching brand,branchcode, isactive 
            campaignList = CampaignService.getCampaignListByBrandAndBranchCode(brand, branchCode);
            generateResponseBody();
        }
        
    }
    
    public static void generateResponseBody(){
        List<PromoCampaign> promoCampaigns = new List<PromoCampaign>();
        if(campaignList.size() > 0){
            for (Campaign proCampaign :campaignList)
            {
                PromoCampaign cam = new PromoCampaign();
                cam.CampaignID = proCampaign.Id;
                cam.Name = proCampaign.Name;
                cam.Description = proCampaign.Description;
                cam.Type = proCampaign.Type;
                cam.Status = proCampaign.Status;
                cam.StartDate = proCampaign.StartDate <> null ?  proCampaign.StartDate.format() : ''; //check if null to prevent null exception
                cam.EndDate = proCampaign.EndDate <> null ? proCampaign.EndDate.format() : ''; //check if null to prevent null exception           
                cam.ActualCost = proCampaign.Actual_Cost_in_Campaign__c;
                cam.DiscountCost = proCampaign.Budgeted_Cost_in_Campaign__c;
                cam.CTA = proCampaign.CTA__c <> null ? proCampaign.CTA__c : '';
                cam.Brand = proCampaign.Brand__c;
                cam.BranchCode = proCampaign.Branch_Code__c;
                promoCampaigns.add(cam);

                if (proCampaign.TC_Val__c == null)
                {
                    campaignsNoTC.add(proCampaign.Id);
                }
            }            
        }

        resBody.Campaigns = promoCampaigns;
        //resBody.message = 'This is a message.';
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(resBody));
    }
    public class RequestBody{
        public String BranchCode;
        public String Brand;
    }
    
    public class ResponseBody{
        public List<PromoCampaign> Campaigns; 
        //public String message;
    }
    
    public class PromoCampaign{
        public String CampaignID;
        public String Name;
        public String Description;
        public String Type;
        public String Status;
        public String StartDate;
        public String EndDate;
        public Decimal ActualCost;
        public Decimal DiscountCost;
        public String CTA;
        public String BranchCode;
        public String Brand;
    }
    
    public class httpErrorResponse{
        public String status;
        public String message;
        public httpErrorResponse(String statusValue,String messageValue){
            status = statusValue;
            message = messageValue;
            
        }
    }
    
    
}
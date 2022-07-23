/** *****
* Description : Get Sales Targeted Campaign and related Promo Line Items
* 
* Change History
* Date(YYYYMMDD)       Name                            Description
* 20220324             thanh.ly@aodigy.com             Created Initial Version. 
* 
** *****/
@RestResource(urlMapping = '/promotion/getSalesTargetedCampaign/*')
global class SalesTargetedPromoItemsAPI{

    private static RestRequest req  = RestContext.request;
    private static RestResponse res = RestContext.response;
    private static RequestBody reqBody  = new RequestBody();
    private static ResponseBody resBody = new ResponseBody();
    private static List<String> campaignsNoTC = new List<String>();
    private static httpErrorResponse errorResponse;

    @HttpPost
    global static void doPost()
    {
        res.addHeader('Content-Type', 'application/json');
        try
        {
            processPostRequest();
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('SalesTargetedCampaignAPI', e);
            errorResponse = new httpErrorResponse('Failed', e.getMessage() + ' ' + e.getLineNumber());
        }

        if(errorResponse != null && errorResponse.status == 'Failed')
        {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
        }

        serviceDataPool.buildServiceDataPool('SalesTargetedCampaignAPI', 'SalesTargetedCampaignAPI', '', req, res);

        if (!campaignsNoTC.isEmpty())
        {
            InvoiceEmail_ProcessBuilder_RestTC.apexcallout(campaignsNoTC);
        }
    }

    public static void processPostRequest()
    {
        reqBody = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);

        if(String.isBlank(reqBody.CampaignID))
        {
            errorResponse = new httpErrorResponse('Failed', 'Mandatory Fields Missing');
        }
        else 
        {
            generateResponseBody();
        }
    }

    public static void generateResponseBody()
    {
        List<Campaign_Promo_Line_Item__c> campaignPromoItems = new List<Campaign_Promo_Line_Item__c>();
        List<Campaign> campaigns                             = new List<Campaign>();

        campaigns =  [SELECT Id, Type, Status, StartDate, Name, EndDate, Description, Brand__c, Branch_Code__c, TC_Val__c,
                            (SELECT Id, Promo_Line_Item__c, Promo_Line_Item__r.Item_Display_Name__c, 
                                    Promo_Line_Item__r.Variant_Display_Name__c, Promo_Line_Item__r.Group_Display_Name__c, Promo_Line_Item__r.Item_Group_Code__c, 
                                    Promo_Line_Item__r.Usual_Price__c, Promo_Line_Item__r.Promo_Price__c, Promo_Line_Item__r.No_of_Stock__c
                            FROM Campaign_Promo_Line_Items__r)
                    FROM Campaign
                    WHERE Id =: reqBody.CampaignID AND IsActive = true
                    LIMIT 1];

        if (campaigns.isEmpty())
        {
            errorResponse = new httpErrorResponse('Failed', 'Invalid Campaign Id: ' + reqBody.CampaignID);
            return;
        }

        resBody.Type        = campaigns[0].Type;
        resBody.Status      = campaigns[0].Status;
        resBody.StartDate   = campaigns[0].StartDate;
        resBody.Name        = campaigns[0].Name;
        resBody.EndDate     = campaigns[0].EndDate;
        resBody.Description = campaigns[0].Description;
        resBody.CampaignID  = campaigns[0].Id;
        resBody.Brand       = campaigns[0].Brand__c;
        resBody.BranchCode  = campaigns[0].Branch_Code__c;
        campaignPromoItems  = campaigns[0].Campaign_Promo_Line_Items__r;

        if (campaigns[0].TC_Val__c == null)
        {
            campaignsNoTC.add(campaigns[0].Id);
        }

        if(!campaignPromoItems.isEmpty())
        {
            Map<String, Accessory> accMap = new Map<String, Accessory>();
            List<Accessory> accs          = new List<Accessory>();
            Accessory tempAcc; 
            Item tempItem;

            for (Campaign_Promo_Line_Item__c item : campaignPromoItems)
            {
                tempItem               = new Item();
                tempItem.ItemID        = item.Promo_Line_Item__c;
                tempItem.ActualPrice   = item.Promo_Line_Item__r.Usual_Price__c;
                tempItem.DiscountPrice = item.Promo_Line_Item__r.Promo_Price__c;
                tempItem.Quantity      = item.Promo_Line_Item__r.No_of_Stock__c;
                tempItem.Label         = String.isNotBlank(item.Promo_Line_Item__r.Item_Group_Code__c) ? item.Promo_Line_Item__r.Variant_Display_Name__c : '';
                tempItem.Name          = item.Promo_Line_Item__r.Item_Display_Name__c;

                if (String.isNotBlank(item.Promo_Line_Item__r.Item_Group_Code__c))
                {
                    if (accMap.containsKey(item.Promo_Line_Item__r.Item_Group_Code__c))
                    {
                        tempAcc = accMap.get(item.Promo_Line_Item__r.Item_Group_Code__c);
                        tempAcc.Items.add(tempItem);
                        accMap.put(item.Promo_Line_Item__r.Item_Group_Code__c, tempAcc);
                    }
                    else 
                    {
                        accMap.put(item.Promo_Line_Item__r.Item_Group_Code__c, new Accessory(item.Promo_Line_Item__r.Group_Display_Name__c, new List<Item>{tempItem}));
                    }
                }
                else 
                {
                    accs.add(new Accessory('', new List<Item>{tempItem}));
                }
            }

            System.debug('accMap: ' + accMap);

            accs.addAll(accMap.values());
            resBody.Accessories = accs;
        }
           
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(resBody));
    }

    public class RequestBody
    {
        public String CampaignID; 
    }

    public class ResponseBody
    {
        public String Type;
        public String Status;
        public Date StartDate;
        public String Name;
        public Date EndDate;
        public String Description;
        public String CampaignID;
        public String Brand;
        public String BranchCode;
        public List<Accessory> Accessories;
    }

    public class Accessory
    {
        public String GroupName;
        public List<Item> Items;

        public Accessory(String groupName, List<Item> items)
        {
            this.GroupName = groupName;
            this.Items     = items;
        }
    }

    public class Item
    {
        public String Name;
        public String ItemID;
        public Double ActualPrice;
        public Double DiscountPrice;
        public String Label;
        public Decimal Quantity; 
    }
    
    public class httpErrorResponse
    {
        public String status;
        public String message;

        public httpErrorResponse(String statusValue, String messageValue)
        {
            status = statusValue;
            message = messageValue;
        }
    }


}
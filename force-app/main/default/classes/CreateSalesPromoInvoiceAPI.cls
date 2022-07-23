/*******
 * Description : API Class to create Invoice for Sales Targeted Promo
 * 
 * Change History :
 * Date(YYYYMMDD)      Name                    Description
 * 20220328         thu.phan@aodigy.com     Created Initial Version 
*******/

@RestResource(urlMapping = '/upsertSalesPromoInvoice/*')
global class CreateSalesPromoInvoiceAPI 
{
    private static RestResponse response       = RestContext.response;
    private static RestRequest request         = RestContext.request;
    private static RequestBody reqBody         = new RequestBody();
    private static Map<String, Object> resBody = new Map<String, Object>();

    private static String errMessage = '';

    @HttpPost
    global static void doPost() 
    {
        response.addHeader('Content-Type', 'application/json');
        
        try 
        {   
            createInvoice();                
        }
        catch(Exception ex) 
        {
            loggerDataPool.buildLogDataPool('CreateSalesPromoInvoiceAPI', ex);
            errMessage = ex.getMessage() + ' ' + ex.getLineNumber();
            System.debug ('@@@@DEBUG CreateSalesPromoInvoiceAPI :: Exception :: err.msg = ' + ex.getMessage() + ' || err.cause = ' + ex.getCause() + ' || err.line : ' + ex.getLineNumber() );
        }
        
        if( String.isNotBlank( errMessage ) )
        {
            resBody.put('status', 'Failed');
            resBody.put('message', errMessage);
            response.statusCode = 400;
        }
        else
        {
            response.statusCode = 200;   
        }

        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf(JSON.serialize(resBody));  

        serviceDataPool.buildServiceDataPool('CreateSalesPromoInvoiceAPI', 'CreateSalesPromoInvoiceAPI', '', request, response);
    }

    public static void createInvoice()
    {
        ADGLIB_SObjectUnitOfWork uow      = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Invoice__c.SObjectType,
                                                                                                   /*Campaign_Member_Vehicle__c.SObjectType,*/
                                                                                                   Invoice_Promo_Line_Item__c.SObjectType});
        Invoice__c invoice                            = new Invoice__c();
        //List<Campaign_Member_Vehicle__c> campaignMems = new List<Campaign_Member_Vehicle__c>();
        List<Campaign> relatedCampaigns               = new List<Campaign>();
        List<Contact> conList                         = new List<Contact>();     
        Decimal GST                                   = Decimal.valueOf(Label.GST);
        
        reqBody = (RequestBody)JSON.deserialize(request.requestBody.toString(), RequestBody.class);      
		System.debug('@@@@DEBUG CreateSalesPromoInvoiceAPI :: reqBody = ' + JSON.serialize(reqBody));

        if (String.isBlank(reqBody.CampaignId) || String.isBlank(reqBody.ContactId) || String.isBlank(reqBody.Department) || String.isBlank(reqBody.SalesAgreementId))
        {
            errMessage += 'Required fields are missing: CampaignId/ContactId/Department/SalesAgreementId.';
            return; 
        }
        
        // campaignMems = [SELECT Purchased__c, Purchased_Date__c, Sales_Agreement__c 
        //                 FROM Campaign_Member_Vehicle__c 
        //                 WHERE Contact__c =: reqBody.ContactId 
        //                   AND Campaign__c =: reqBody.CampaignId 
        //                   AND Sales_Agreement__c =: reqBody.SalesAgreementId
        //                 LIMIT 1];

        // if (campaignMems <> null && !campaignMems.isEmpty())
        // {
        //     campaignMems[0].Purchased__c      = true;
        //     campaignMems[0].Purchased_Date__c = Date.today();            

        //     uow.registerDirty(campaignMems);
        // }
            
        String invEvt                 = 'Sales Targeted Promo';
        invoice.SeqNum__c             = Utility.getSequenceNoEvent(reqBody.Department , reqBody.CampaignId);
        invoice.SequenceIdentifier__c = invEvt;
        invoice.Campaign_ID__c        = reqBody.CampaignId;
        invoice.CountryCode__c        = 'SG';
        invoice.RecordTypeId          = OrderService.getRecordTypeId('Sales_Targeted_Promo_Payment_RT');

        relatedCampaigns  = [SELECT Id, Brand__c FROM Campaign WHERE Id =: reqBody.CampaignId LIMIT 1];
        invoice.Brand__c  = relatedCampaigns <> null && !relatedCampaigns.isEmpty() ? relatedCampaigns[0].Brand__c : '';
              
        conList = [SELECT Id, AccountId, FirstName, LastName, Email, MobilePhone FROM Contact WHERE Id =: reqBody.ContactId LIMIT 1];
        if (conList <> null && conList.size() > 0)
        {
            invoice.Account__c        = conList[0].AccountId;
            invoice.Contact__c        = conList[0].Id;
            invoice.NRIC__c           = conList[0].Id;
            invoice.First_Name__c     = conList[0].FirstName;
            invoice.Last_Name__c      = conList[0].LastName;
            invoice.Customer_Email__c = conList[0].Email;
            invoice.Mobile__c         = conList[0].MobilePhone;
        }

        invoice.Sales_Agreement__c = reqBody.SalesAgreementId;
        invoice.Department__c      = reqBody.Department;
        invoice.Net_Amount__c      = reqBody.NetAmount;
        invoice.Amount_With_GST__c = reqBody.NetAmount;
        invoice.Discount__c        = reqBody.Discount;
        invoice.GST_Value__c       = reqBody.NetAmount * (GST / (1 + GST));
        invoice.Amount_wo_GST__c   = reqBody.NetAmount / (1 + GST);

        insert invoice;

        if (reqBody.Items <> null && reqBody.Items.size() > 0)
        {
            Set<String> promoItemIds = new Set<String>();
            Id recordTypeId          = Schema.SObjectType.Invoice_Promo_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Promo_Line_Item_RT_Sales_Targeted').getRecordTypeId();

            for (Item item : reqBody.Items)
            {
                promoItemIds.add(item.ItemID);
            }

            Map<Id, Promo_Line_Item__c> promoItems = new Map<Id, Promo_Line_Item__c>(PromoLineItemService.getPromoLineItemsByIds(promoItemIds));

            for (Item item : reqBody.Items)
            {
                uow.registerNew(new Invoice_Promo_Line_Item__c(recordTypeId        = recordTypeId,
                                                                Payment__c         = invoice.Id,
                                                                Promo_Line_Item__c = item.ItemID,
                                                                Usual_Price__c = item.ActualPrice,
                                                                Promo_Price__c = item.DiscountPrice,
                                                                Quantity__c    = item.Quantity,
                                                                Cost_Price__c  = promoItems.get(item.ItemID).Cost_Price__c,
                                                                Commission_Value__c = promoItems.get(item.ItemID).Commission_Value__c,
                                                                Total_Cost_Price__c = promoItems.get(item.ItemID).Cost_Price__c * item.Quantity,
                                                                Total_Commission_Value__c = promoItems.get(item.ItemID).Commission_Value__c * item.Quantity));                                             
            }
        }

        uow.commitWork();

        invoice = [SELECT Invoice_Number__c, Department__c, Campaign__r.Id, CreatedDate FROM Invoice__c WHERE Id =: invoice.Id LIMIT 1];
        resBody.put('InvoiceNumber', invoice.Invoice_Number__c);
        resBody.put('CreatedDate', String.valueof(invoice.CreatedDate));
    }

    public class RequestBody
    {
        public Double NetAmount;
        public Double Discount;
        public String Department;
        public String CampaignId;
        public String ContactId;
        public String SalesAgreementId;
        public List<Item> Items;
    }
    
    public class Item
    {
        public String ItemID;
        public Double ActualPrice;
        public Double DiscountPrice;
        public Integer Quantity;
    }
}
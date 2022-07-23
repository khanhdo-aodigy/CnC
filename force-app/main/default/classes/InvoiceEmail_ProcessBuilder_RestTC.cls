/** *****
* Description : REST call to CMS to get T&C and update on Campaign
* 
* Change History
* Date(YYYYMMDD)       Name                             Description
* XXXXXXXX             XXXXX                        Created Initial Version.
* 20210427           tphan@aodigy.com             	Modified to update T&C on Campaign instead of Payment - Generic AfterSales Promotions 
* 
** *****/

//Update T&C into Invoice object via REST call to CMS for each Promo
public class InvoiceEmail_ProcessBuilder_RestTC 
{
    @future(Callout=true)
    public static void apexcallout(/*String promoid, Id Invoice_Id*/List<String> recordIds)
    {
        HttpRequest req = new HttpRequest();
        HttpResponse resInput = new HttpResponse();
        RequestBody reqBody = new RequestBody();
        Http http = new Http();
        List<Campaign> updatedCampaigns = new List<Campaign>();

        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String  APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c; /*'https://api.stg.cyclecarriage.com/CmsAPI/GetPromos';*/
        String  APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;      
        
        reqBody.PromoIDs = recordIds;

        //Rest call to CMS for getting the T&C data.
        req.setEndpoint(APIGateway_url+'/CmsAPI/GetPromos');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        req.setHeader('apikey', '1b58ae26-48d4-4efc-944d-f089258f81sf2');       
        req.setBody(JSON.serialize(reqBody));
        req.setTimeout(120000); 
       
        system.debug('1=== '+req.getBody());
        try 
        {   
            //Send http request, capture response and pass the response to mothod       
            resInput = http.send(req); 
        }
        catch(exception ex1)
        {
            system.debug(ex1.getMessage());
        }
        if(resInput.getBody()!=null && resInput.getBody().trim()!='')
        {
            // Parse entire JSON response.        
            Invoice_TC_JSON2Apex sVar = Invoice_TC_JSON2Apex.parse(resInput.getBody());        
            List<Invoice_TC_JSON2Apex.Promo> promoList = sVar.Result.Promo;
            //TC_Val=sVar.Result.Promo[0].PromoTermsAndConditions.Content;
            //Update T&C into SF Invoice object.
            // Invoice__c TempInvoice  = new Invoice__c();
            // TempInvoice.Id = Invoice_Id;
            // TempInvoice.TC_Val__c = TC_Val;
            // Update TempInvoice;

            if (promoList.size() > 0)
            {
                for (Invoice_TC_JSON2Apex.Promo promo : promoList)
                {
                    Campaign c = new Campaign();
                    c.Id       = promo.PromoID;
                    c.TC_Val__c= promo.PromoTermsAndConditions.Content;

                    updatedCampaigns.add(c);
                }
            }

            if (updatedCampaigns.size() > 0 && !Test.isRunningTest())
            {
                update updatedCampaigns;
            }
        }
    }

    public class RequestBody 
    {
        public List<String> PromoIDs;
        public String CountryName = 'SG';
    }
}
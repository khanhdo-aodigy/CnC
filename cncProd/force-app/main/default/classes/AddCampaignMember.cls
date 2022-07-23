public class AddCampaignMember {

    @InvocableMethod
    public static void InsertRecords(List<Id> Campaign_Contact_ID)
    {

		string cmpgId ='';
        List<Campaign_Member_Vehicle__c> cmv = [SELECT Contact__c,Campaign__c, Campaign__r.Campaign_ID_18_Char__c, Account__c from Campaign_Member_Vehicle__c
                                                WHERE Id in :Campaign_Contact_ID];

        List<CampaignMember> CM = new List<CampaignMember>();
        for(Campaign_Member_Vehicle__c TempCmv : cmv)
        {
            CampaignMember TempCM = new CampaignMember();
            TempCM.CampaignId = TempCmv.Campaign__c;
            TempCM.ContactId = TempCmv.Contact__c;
            CM.add(TempCM);
			cmpgId = TempCmv.Campaign__r.Campaign_ID_18_Char__c;
        }
        try
        {
			updateTC_Cmpg(cmpgId);
            database.insert(CM,false);
        }
        catch(Exception e)
        { 
            loggerDataPool.buildLogDataPool('AddCampaignMember', e);
            System.debug('An exception occurred: ' + e.getMessage());		
		}

    }

	//replicated method from InvoiceEmail_ProcessBuilder_RestTC
	@future (callout=true)
	public static void updateTC_Cmpg (string CampaignId)
	{
		string promoid = CampaignId;

		HttpRequest req = new HttpRequest();
		HttpResponse resInput = new HttpResponse();
		Http http = new Http();
		String TC_Val = '';
		global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
		System.debug('+++ '+ JCC_GlobalVar);
		//String  APIGateway_url =   'https://api.stg.cyclecarriage.com/CmsAPI/GetPromos' ;
		String  APIGateway_url =	(String)JCC_GlobalVar.APIGateway_url__c;
		String  APIGateway_key =    (String)JCC_GlobalVar.APIGateway_key__c;     
    
		//Rest call to CMS for getting the T&C data.
		req.setEndpoint(APIGateway_url+'/CmsAPI/GetPromos');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
		//req.setHeader('apikey', '1b58ae26-48d4-4efc-944d-f089258f81sf2');  
		System.debug('+++ '+ APIGateway_url + '+++ ' + APIGateway_key);
		req.setHeader('apikey', APIGateway_key);             
		req.setBody('{"PromoIDs": ["'+promoid+'"], "CountryName": "SG"}');
		req.setTimeout(120000);  
		system.debug('1==='+req.getBody());
		try 
		{   
			//Send http request, capture response and pass the response to mothod       
			resInput = http.send(req); 
			Invoice_TC_JSON2Apex sVar = Invoice_TC_JSON2Apex.parse(resInput.getBody());           
			TC_Val = sVar.Result.Promo[0].PromoTermsAndConditions.Content;
			system.debug('2==='+TC_Val);

			Campaign updateCmpgObj = new Campaign(id = CampaignId);
			updateCmpgObj.TC_Val__c = TC_Val;
			update updateCmpgObj;

		}
		catch(exception ex1)
		{
			system.debug(ex1.getMessage());
		}

	}

}
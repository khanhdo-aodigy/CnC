/*******
 * Description :	Service class for notification API related for campaign-member
 * 
 * Useful Link :	https://salesforce.stackexchange.com/questions/212491/create-custom-button-in-lightning-that-calls-an-apex-class-method
 *					https://developer.salesforce.com/docs/atlas.en-us.noversion.mc-apis.meta/mc-apis/postMessageBatch.htm
 *					https://developer.salesforce.com/docs/atlas.en-us.noversion.mc-apis.meta/mc-apis/postMessageContactSendPush.htm
 *
 * Change History : 
 * Date(YYYYMMDD)		Name			Description
 * 20200712             NSJ				Created Initial Version 
*******/



global class CM_Notification_Service  
{

	public static string strPNKeyword_Prod_cnc = callPNKeyword('mycnc_prod'); //'MTI5OjExNDow';
	public static string strPNKeyword_Prod_mb =  callPNKeyword('mymb_prod'); //'MTk2OjExNDow';
	public static string strPNKeyword_UAT_cnc =  callPNKeyword('mycnc_uat'); //'MjoxMTQ6MA';
	public static string strPNKeyword_UAT_mb =   callPNKeyword('mymb_uat'); //'ODU6MTE0OjA';
	
	public static collect_PN_Wrapper cPN = new collect_PN_Wrapper();

	WebService static String callPN_Api(String CampaignId)
	{
		Database.executeBatch(new BatchCM_notification(CampaignId),200);

		Return 'Please refresh the page';		
	}

	@future (callout=true)
    public static void SendHttpPUSH_CM(List<String> subscriber_tokens, string body, string keyword, string openDirect)
	{
		string tokenValue = GenerateRequestToken.getRequestToken();

		System.debug('+++ subscriber_tokens ' + subscriber_tokens);
		string strOfDeviceTokens = appendDeviceTokens(subscriber_tokens);
		System.debug('+++ strOfDeviceTokens ' + strOfDeviceTokens);
		System.debug('+++ input PN param ' + body + ' ++ ' + keyword + ' ++ ' + openDirect);

		try
		{    
			HttpRequest req = new HttpRequest();
			req.setMethod('POST');                                    
			req.setHeader('content-type', 'application/json;charset=utf-8');    
			req.setHeader('Authorization', 'Bearer '+tokenValue);
            req.setEndpoint('https://www.exacttargetapis.com/push/v1/messageContact/'+keyword+'/send');
			req.setBody('{"deviceTokens":['+strOfDeviceTokens+'], "Override": 1, "MessageText": "'+body+'","alert": "Push Alert","title":"", "subtitle": "" ,"MessageCategory": { "Name": "ApiTriggeredMessage"}, "OpenDirect": "'+openDirect+'", "mutable-content": 0}'); 
			Http http1 = new Http(); 
            HTTPResponse res = http1.send(req); 
            String resBody = res.getBody();

		}
		catch(Exception e)
		{
			loggerdatapool.buildLogDataPool('send_PushMessage', e);
		}
	}


	public static string appendDeviceTokens(List<string> listStrDeviceTokens)
	{

        String strDeviceTokens = '';

        for(String strCurrentDeviceTokens : listStrDeviceTokens) 
		{
            strDeviceTokens += '"'+ strCurrentDeviceTokens + '"' + ',';
        }
        strDeviceTokens = strDeviceTokens.trim().removeEnd(',');

		return strDeviceTokens;

	}


	public class collect_PN_Wrapper 
	{

		public String push_body; 
		public string push_SMS;
		public List<String> subscriber_tokens = new List<String>();
		public List<String> mobilePhones= new List<String>(); 
		public String keyword;
		public String openDirect; 	
		public boolean isFire;	

	}

	public static string callPNKeyword(string appType)
	{

		global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();  
		string strPNKeyword_Prod_cnc = JCC_GlobalVar.TriggeredPush__c;
		string strPNKeyword_Prod_mb =  JCC_GlobalVar.TriggeredPush_MB__c;
		string strPNKeyword_UAT_cnc =  JCC_GlobalVar.TriggeredPush__c;
		string strPNKeyword_UAT_mb =   JCC_GlobalVar.TriggeredPush_MB__c;

		Map<String,string> mapKeyToPN = new Map<String,string>();
		
		mapKeyToPN.put('mycnc_prod', strPNKeyword_Prod_cnc);
		mapKeyToPN.put('mymb_prod', strPNKeyword_Prod_mb);
		mapKeyToPN.put('mycnc_uat', strPNKeyword_UAT_cnc);
		mapKeyToPN.put('mymb_uat', strPNKeyword_UAT_mb);

		string strKeyword = mapKeyToPN.get(appType);

		return strKeyword;

	}

	/*
	public static void callPN_Api(string CampaignId)
	{
		boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox; 

		list<Campaign> listCmpg = new list<Campaign>();
		List<CampaignMember> listCmpgMember = new list<CampaignMember>(); 

		listCmpgMember = [select Contact.MobilePhone, Contact.Device__c, Campaign.Id, Campaign.Name, Campaign.Promo_PUSH_Text__c,
                          Campaign.Promo_SMS_Text__c, Campaign.Promo_SMS_Link__c, Campaign.EndDate, Campaign.type
						  FROM CampaignMember 
                          WHERE Campaign.id =: CampaignId];


		cPN.isFire = false;

		for(CampaignMember cm : listCmpgMember)
		{ 
			cPN.keyword = strPNKeyword_Prod_mb;
			if(isSandbox)
			{
				cPN.keyword = strPNKeyword_UAT_mb;
			}

			cPN.openDirect = '';
			cPN.push_body = cm.Campaign.Promo_PUSH_Text__c;
			cPN.push_sms = cm.Campaign.Promo_SMS_Text__c;
			if(cm.Contact.Device__c != '' && cm.Contact.Device__c != null)
			{
				cPN.subscriber_tokens.add(cm.Contact.Device__c);
			}
			if(cm.Contact.MobilePhone != '' && cm.Contact.MobilePhone != null)
			{
				cPN.mobilePhones.add(cm.Contact.MobilePhone);
			}

			cPN.isFire = true;
		}

		if(cPN.isFire == true)
		{
			CM_Notification_Service.SendHttpPUSH_CM(cPN.subscriber_tokens, cPN.push_body, cPN.keyword, '');
		}		
	}
	*/




}
/*******
 * Description :	Batch class for notification API related for campaign-member
 * 
 * Useful Link :	https://salesforce.stackexchange.com/questions/212491/create-custom-button-in-lightning-that-calls-an-apex-class-method
 *					https://developer.salesforce.com/docs/atlas.en-us.noversion.mc-apis.meta/mc-apis/postMessageBatch.htm
 *					https://developer.salesforce.com/docs/atlas.en-us.noversion.mc-apis.meta/mc-apis/postMessageContactSendPush.htm
 *
 * Change History : 
 * Date(YYYYMMDD)		Name			Description
 * 20200712             NSJ				Created Initial Version 
*******/

global class BatchCM_notification implements Database.Batchable<sObject>, Schedulable, Database.stateful
{

	public Integer i = 0;
	global string strCampaignId;
	//global List<CampaignMember> listCmpgMemberUpdate;
	global Boolean isSandbox;

	global BatchCM_notification(string CampaignId) 
	{
		this.strCampaignId = CampaignId;
		//listCmpgMemberUpdate = new List<CampaignMember>();
		this.isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox; 
	}

	//start
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		string statusPush = 'Push';
		string strSOQL = 'select Contact.MobilePhone, Contact.Device__c, Campaign.Id, Campaign.Deep_linking_URL__c, Campaign.Branch_Code__c, Campaign.Name, Campaign.Promo_PUSH_Text__c, Campaign.Promo_SMS_Text__c, Campaign.Promo_SMS_Link__c, Campaign.EndDate, Campaign.type FROM CampaignMember where Campaign.id =: strCampaignId and Notification_Status__c !=: statusPush'; 
		return Database.getQueryLocator(strSOQL);
	}
	
	//execute
	global void execute(Database.BatchableContext BC, List<CampaignMember> listCmpgMemberInput)
	{
		List<CampaignMember> listCmpgMemberUpdate = new List<CampaignMember>();
		Set<Id> setContactIds = new Set<Id>();

		System.debug('++ +memberSize ' + listCmpgMemberInput.size());

		CM_Notification_Service.collect_PN_Wrapper cPN = new CM_Notification_Service.collect_PN_Wrapper ();

		cPN.isFire = false;

		for(CampaignMember cm : listCmpgMemberInput)
		{ 

			cPN.keyword = CM_Notification_Service.strPNKeyword_Prod_cnc;
			if(isSandbox)
			{
				cPN.keyword = CM_Notification_Service.strPNKeyword_UAT_cnc;
			}

			if(cm.Campaign.Branch_Code__c == 'CCI')
			{
				cPN.keyword = CM_Notification_Service.strPNKeyword_Prod_mb;
				if(isSandbox)
				{
					cPN.keyword = CM_Notification_Service.strPNKeyword_UAT_mb;
				}
			}

			cPN.openDirect = '';
			if(String.isNotEmpty(cm.Campaign.Deep_linking_URL__c))
			{
				cPN.openDirect = cm.Campaign.Deep_linking_URL__c;
			}
			cPN.push_body = cm.Campaign.Promo_PUSH_Text__c;
			cPN.push_sms = cm.Campaign.Promo_SMS_Text__c;

			cm.Notification_Status__c = 'No device token';
			if(cm.Contact.Device__c != '' && cm.Contact.Device__c != null)
			{
				cPN.subscriber_tokens.add(cm.Contact.Device__c);
				cm.Notification_Status__c = 'Push';
			}
			if(cm.Contact.MobilePhone != '' && cm.Contact.MobilePhone != null)
			{
				cPN.mobilePhones.add(cm.Contact.MobilePhone);
			}

			cPN.isFire = true;

			listCmpgMemberUpdate.add(cm);
			setContactIds.add( cm.ContactId );
		}


		Campaign camp = CampaignService.getCampaignById(strCampaignId);		
		List<CustomerAlerts__c> custAlertList = new List<CustomerAlerts__c>();
		System.debug('@@ DEBUG camp = ' + camp);
		if(camp != null && camp.Type == 'Promotions') {		
			Map<String,Schema.RecordTypeInfo> recType = BroadcastController.getCustomerAlertRtByDeveloperName();
			String broadcastTypeId = recType.get('Broadcast').getRecordTypeId();

			// Get Campaign_Member_Vehicle__c By Campaign_Member__c.Contact__c => Get Campaign_Member_Vehicle__c.Registered_Vehicle__c
			
			List<Campaign_Member_Vehicle__c> campMemberVehicles = [ SELECT Id, Account__c, Contact__c, Registered_Vehicle__c
																	FROM Campaign_Member_Vehicle__c
																	WHERE Campaign__c = :strCampaignId AND Contact__c IN :setContactIds ];

			for(Campaign_Member_Vehicle__c campMemVeh: campMemberVehicles) {
				System.debug('@@ DEBUG campMemVeh = ' + campMemVeh);
				CustomerAlerts__c customerAlert     = new CustomerAlerts__c();	
				customerAlert.RecordTypeId          = broadcastTypeId;
				customerAlert.Campaign__c           = strCampaignId;
				customerAlert.Name                  = camp.Type;//'Broadcast';
				customerAlert.Date__c               = System.today();
				customerAlert.DateTime__c           = System.now();
				customerAlert.Status__c             = 'unread';
				customerAlert.Registered_Vehicle__c = campMemVeh.Registered_Vehicle__c;
				customerAlert.Account__c            = campMemVeh.Account__c;
				customerAlert.Contact__c            = campMemVeh.Contact__c;
				customerAlert.Alert_Description__c  = camp.Promo_Inbox_Text__c;
				customerAlert.Description__c        = camp.Promo_Inbox_Text__c;
				customerAlert.Deep_Linking_URL__c   = camp.Deep_linking_URL__c;
				customerAlert.isAlert__c            = true;		
				customerAlert.isPush__c             = true;
				customerAlert.isSMS__c              = false;
				customerAlert.isEmail__c            = false;
				customerAlert.Type__c               = 'Broadcast';
				customerAlert.SubType__c            = camp.Type;

				custAlertList.add(customerAlert);
			}		
		}

		try
		{
			System.enqueueJob(new CM_notification_queueable(cPN));
			if(listCmpgMemberUpdate.size() > 0)
			{
				Database.update(listCmpgMemberUpdate);
			}

			System.debug('@@@@DEBUG BatchCM_notification :: custAlertList = ' + custAlertList.size() + ' --- ' + custAlertList );
			if(custAlertList.size() > 0)
			{
				TriggerExclusion.excludeTrigger('CustomerAlerts__c', true); 
				Database.insert(custAlertList);
				TriggerExclusion.excludeTrigger('CustomerAlerts__c', false); 
			}
		}
		
		catch(Exception e)
		{
			Utility.httpErrorResponse errorResponse;
            loggerDataPool.buildLogDataPool('BatchCM_notification', e);
            errorResponse = new Utility.httpErrorResponse('Failed', e.getMessage());
		}


	}
	
	//finish
	global void finish(Database.BatchableContext BC)
	{			
	}

    //execute Schedule
    public void execute (SchedulableContext ctx)
	{   
      Database.executeBatch(new BatchCM_notification(''));
    }

}
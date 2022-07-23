/*******
 * Description :	Test coverage for classes below
 * 
 * Apex Class code Coverage :	CM_Notification_Service
								BatchCM_notification
								CM_notification_queueable

 * Change History : 
 * Date(YYYYMMDD)		Name			Description
 * 20200716             NSJ				Created Initial Version 
 * 20210707				HS@aodigy		Updated Code coverage (i.e. testCM_PromotionCustomerAlert)
*******/

@isTest 
private class Test_CM_Notification_Service 
{

	@isTest
	private static void testCM_Notification() 
	{

        Campaign cmpg = new Campaign(Name = 'MB Special Discount Exclusive Promo',
										 Promo_PUSH_Text__c = 'Hello',
                                         Branch_Code__c = 'CCI',
                                         Brand__c = 'MB',
                                         StartDate = Date.today().addDays(-1),
                                         EndDate = Date.today().addDays(5)
                                         );
										 insert cmpg;
		contact c = new contact();
		c.FirstName = 'A';
		c.LastName = 'B';
		c.MobilePhone = '6598765432';
		c.Device__c = 'Hello';
		TriggerExclusion.excludeTrigger('Contact', true);
		insert c;

		CampaignMember cm = new CampaignMember();
		cm.ContactId = c.Id;
		cm.CampaignId = cmpg.Id;
		insert cm;

		BatchCM_notification batchCM = new BatchCM_notification(cmpg.id);
		DataBase.executeBatch(batchCM);

		list<string> listDevice = new List<string>();
		listDevice.add('A');
		listDevice.add('B');
		CM_Notification_Service.appendDeviceTokens(listDevice);

		CM_Notification_Service.SendHttpPUSH_CM(listDevice, '', '', '');
	}

	@isTest
	private static void testCM_PromotionCustomerAlert() 
	{

        Campaign cmpg = new Campaign(Name = 'MB Special Discount Exclusive Promo',
									 Promo_PUSH_Text__c = 'Hello2',
									 Branch_Code__c = 'CCK',
									 Brand__c = 'KIA',
									 StartDate = Date.today().addDays(-1),
									 EndDate = Date.today().addDays(5),
									 Type='Promotions' );
		insert cmpg;
		
		Account pa = new Account();
		pa.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Customer' ).getRecordTypeId(); 
		pa.FirstName   = 'A1';
		pa.LastName    = 'B1';
		pa.PersonMobilePhone = '6588779900';
		pa.Device__pc   = 'Hello2';
		TriggerExclusion.excludeTrigger('Account', true);
		insert pa;
		pa = [SELECT Id, PersonContactId FROM Account WHERE ID = :pa.Id];

		Registered_Vehicle__c rv = Test_DataFactory.createRegVehicle(false, 'Dunno2', 'CCK', 'KIAPC', 'Dunno2', pa.PersonContactId);
		insert rv;

		CampaignMember cm = new CampaignMember();
		cm.ContactId  = pa.PersonContactId;
		cm.CampaignId = cmpg.Id;
		TriggerExclusion.excludeTrigger('CampaignMember', true);
		insert cm;

		Campaign_Member_Vehicle__c cmv = new Campaign_Member_Vehicle__c();
		cmv.Campaign__c = cmpg.Id;
		cmv.Contact__c = pa.PersonContactId;
		cmv.Account__c = pa.Id;
		cmv.Registered_Vehicle__c = rv.Id;
		insert cmv;

		BatchCM_notification batchCM = new BatchCM_notification(cmpg.id);
		System.Test.startTest();	
			DataBase.executeBatch(batchCM);
		System.Test.stopTest();


	}
}
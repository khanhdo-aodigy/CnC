global class schMaskProspectInfo implements Database.Batchable<sObject>, Schedulable, Database.stateful
{

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		string strProspect = 'Prospect';

        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        Decimal decAging = (Decimal)JCC_GlobalVar.Prospect_Aging_Number__c;
		string strMasked = 'Masked';
		if(Test.isRunningTest())
		{
			decAging = 0;
		}
		//, FirstName, LastName, Email, MobilePhone, NRIC_Passport_No__c, Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Address_Line_4__c,Address_Line_5__c
		string strSOQL = 'select Id from contact where FirstName !=:strMasked and LastName !=: strMasked and prospect_aging__c >=: decAging and Account_RecordType__c =: strProspect'; 
		return Database.getQueryLocator(strSOQL);
	}

	global void execute(Database.BatchableContext BC, List<contact> contactList)
	{
		list<Contact> updateListContact =new List<Contact>();

		if(contactList.size() > 0)
		{
			for(Contact con : contactList)
			{	
				con.FirstName = 'Masked';
				con.LastName  = 'Masked';
				con.MobilePhone = '';
				con.Email = '';
				con.Address_Line_1__c = '';
				con.Address_Line_2__c = '';
				con.Address_Line_3__c = '';
				con.Address_Line_4__c = '';
				con.Address_Line_5__c = '';

				updateListContact.add(con);

			}

		}

		if(updateListContact.size()>0)
		{
			Database.update(updateListContact);
		}

	}

	global void finish(Database.BatchableContext BC)
	{

	}



	global void execute(SchedulableContext sc) 
	{
		Database.executeBatch(new schMaskProspectInfo());	
	}
}
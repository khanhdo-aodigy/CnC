public class ContactStagingHandler  
{

	public static void uncheckPDPA_email(List<Contact_Staging__c> csList)
	{

		List<string> conId_List = new List<string>();
		List<string> emailAddrList = new List<string>();

		List<contact> contactList_update = new List<contact>();
		
		for(Contact_Staging__c csObj : csList)
		{
			if(csObj.Contact_Key__c.startsWith('003'))
			{
				conId_List.add(csObj.Contact_Key__c);		
			}
			else if(csObj.Contact_Key__c.contains('@'))
			{
				emailAddrList.add(csObj.Contact_Key__c);
			}
		} 

		if(conId_List.size() > 0)
		{
			for(contact con : [select id, Email__c from contact where id in: conId_List])
			{
				con.Email__c = false;
				contactList_update.add(con);

			}
		}
		if(emailAddrList.size() > 0)
		{
			for(contact con : [select id, Email__c from contact where Email in: emailAddrList])
			{
				con.Email__c = false;
				contactList_update.add(con);
			}
		}

		if(contactList_update.size() > 0)
		{
			update contactList_update;
		}

	}

}
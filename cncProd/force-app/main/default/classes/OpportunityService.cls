public without sharing class OpportunityService  
{

	public static List<Opportunity> activeOpportunityList (String branchCode, string contactId)
	{
		List<Opportunity> activeOpportunityList = new List<Opportunity>();
		System.debug('+++ active ' + branchCode + ' ++ ' + contactId);
        /*activeOpportunityList = [ SELECT Id, Opportunity_Score__c, Franchise_Code__c 
								FROM Opportunity
								WHERE StageName NOT IN ('Booked', 'Lost') 
								AND OwnerId =:owerId 
								AND Contact_Person__c = :contactId
								ORDER BY CreatedDate DESC];*/  

		//This SOQL can be promoted to selector class for scalability 
		activeOpportunityList = [SELECT Id, Name, Rating__c, RecordTypeId, Custom_Quote__c, Old_Car_No__c, 
								Date_of_Registration__c, Make_Model__c, Test_Drive__c, Preferred_Model__c , 
								Contact_Person__c, Lead__c, Account__c , StageName, Branch_Code__c, Franchise_Code__c, 
								Model_c__c, Opportunity_Score__c, PriceAlert__c, TotalOpportunityQuantity, 
								EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone
								FROM Opportunity 
								WHERE Branch_Code__c = :branchCode 
								AND Contact_Person__c = :contactId 
								AND StageName NOT IN ('Booked', 'Lost')
								AND CloseDate > :Date.today() 
								ORDER BY CreatedDate DESC];
		System.debug('+++ active size ' + activeOpportunityList.size());
		return activeOpportunityList;

	}


	public static opportunity newOpportunityObject (string contactId, string contactAccId, string recordTypeId, 
											string BranchCode, string FranchiseCode, string leadSource)
	{
		Opportunity newOpp = new Opportunity();
		newOpp.Contact_Person__c	= contactId;
		newOpp.Account__c			= contactAccId;
		newOpp.StageName			= 'Open';
		newOpp.CloseDate			= Date.today() + 180;
        newOpp.Branch_Code__c		= BranchCode;
        newOpp.Franchise_Code__c	= FranchiseCode;
		newOpp.RecordTypeId			= recordTypeId;
		newOpp.LeadSource			= leadSource;
		return newOpp;

	}
	
	public static Opportunity updateOpportunity(Opportunity newOpp, String contactId, String contactAccId, String recordTypeId, 
											String BranchCode, String FranchiseCode, String leadSource)
	{
		newOpp.Contact_Person__c	= contactId;
		newOpp.Account__c			= contactAccId;
		newOpp.StageName			= 'Open';
		newOpp.CloseDate			= Date.today() + 180;
        newOpp.Branch_Code__c		= BranchCode;
        newOpp.Franchise_Code__c	= FranchiseCode;
		newOpp.RecordTypeId			= recordTypeId;
		newOpp.LeadSource			= leadSource;
		return newOpp;

	}

	public static string getStrOpportunityName (string custLastName, string franchiseCode)
	{
		string strOpportunityName = CustlastName + ' - ' + franchiseCode.substring(0,3);

		return strOpportunityName;

	}

	public static string getStrOwnerAssignment (string contactId, string BranchCode)
	{
		string strOwerId = ''; 

		List<Opportunity> lastOpportunityList = new List<Opportunity>();

		//This SOQL can be promoted to selector class for scalability 
        lastOpportunityList = [ SELECT Id, OwnerId, Owner.IsActive, Opportunity_Score__c, Test_Drive__c, Rating__c
								FROM Opportunity 
								WHERE Contact_Person__c =: contactId
								AND Branch_Code__c =: BranchCode
								AND Owner.isActive = true
								ORDER BY CreatedDate DESC
								LIMIT 1 ];

		if(lastOpportunityList.size() > 0)
		{
			strOwerId = lastOpportunityList[0].OwnerId;
		}							

		return strOwerId;

	}

	public static string getStrRecordTypeAssignment (string BranchCode)
	{
		string strRecordTypeId;
		string strRecordTypeName;

		//This can enhance into custom metadata in the future to prevent hardcoding
		map<String, string> mapOpptyRTName = new Map<String, string>();
		mapOpptyRTName.put('CCA', 'MIT');
		mapOpptyRTName.put('CCK', 'KIAPC');
		mapOpptyRTName.put('CCF', 'CITPC');

		if(mapOpptyRTName.containsKey(BranchCode))
		{
			strRecordTypeName = mapOpptyRTName.get(BranchCode);
		}

		if(strRecordTypeName != '')
		{
			strRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
		}

		Return strRecordTypeId;

	}

	//Maybe not needed. 
	public string getStrUpdateStage (string stage)
	{
		string strStage;

		Return strStage;

	}	
}
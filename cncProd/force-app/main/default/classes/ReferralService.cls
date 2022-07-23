/** ******
 * Description : Service Class for Referral object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        Description
 * 20200211             HS          Created Initial Version. 
 * 20200311             HS          Added getReferralListByPersonAccountAndStage & getReferralListByContactAndStage methods 
 * 20202309             TP          Added getPersonContactId method and linked Contact_Person__c of Opp obj to PA Contact Id
 * 20210315             HS          Removed unused code. Changed insert lstProspectToInsert to upsert
 * 
***** **/
public with sharing class ReferralService {
    
    private static ReferralSelector selector = new ReferralSelector();
    
    public static Map<Id,User> getUserRecordMap( Set<String> setUserIds )
    {
        return new Map<Id,User>([SELECT Id, ContactId__c, ContactId, Contact.AccountId, Branch_Code__c, Franchise_Code__c, Profile.Name , IsActive
                                 FROM User 
                                 WHERE ID IN: setUserIds LIMIT 500] );
    }
    
    public static Map<String,Boolean> getProspectReferValidityByReferrer( Set<String> setProspectEmails, Set<string> setStrBrands ){
        
        Map<String,Boolean> mapProspectValidity = new Map<String,Boolean>();
        for( String strEmail : setProspectEmails ){
            mapProspectValidity.put( strEmail.toLowerCase() , true );
        }
        
        for( Referral__c reff : selector.selectByRefereeEmails( mapProspectValidity.keySet(), setStrBrands ) )
        {
            if( mapProspectValidity.containsKey(reff.Referee_Account__r.PersonEmail) )
            {
                mapProspectValidity.put( String.valueOf(reff.Referee_Account__r.PersonEmail).toLowerCase() , false);
            }
        }
        return mapProspectValidity;
    }
    
    
    public static Map<String, ReferralWrapper> filterDuplicateReferral( Map<String, ReferralWrapper> mapReferralToProcess, Set<string> setStrBrands )
    {
        Map<String, ReferralWrapper> mapDuplicateReferral = new Map<String, ReferralWrapper>();    
        Map<String,Boolean> mapProspectValidity = ReferralService.getProspectReferValidityByReferrer( mapReferralToProcess.keySet(), setStrBrands );
        
        for( String eKey : mapReferralToProcess.keySet() )
        {
            if( mapProspectValidity.containsKey( eKey ) && mapProspectValidity.get( eKey ) == false )
            {
                mapDuplicateReferral.put( eKey, mapReferralToProcess.get( eKey ) );
                mapReferralToProcess.remove( eKey );
            }
        }
        return mapDuplicateReferral;
    }
    
    
    public static void processReferralRequest( Map<String, ReferralWrapper> mapReferralToProcess )
    {
        try
        {
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Account.SObjectType, 
                                                                                                    Contact.sObjectType,
                                                                                                    Opportunity.SObjectType,
                                                                                                    Referral__c.SObjectType } );
            
            List<Lead> lstLeadToInsert = new List<Lead>();
            List<Account> lstProspectToInsert = new List<Account>();
            for( String eKey : mapReferralToProcess.keySet() )
            {
                if(mapReferralToProcess.get( eKey ).prospectObj != null)
                {
                    lstProspectToInsert.add( mapReferralToProcess.get( eKey ).prospectObj );
                }              
            }
            
            if( !lstProspectToInsert.isEmpty() ){
                upsert lstProspectToInsert;
            }

            Set<Id> prospectIds = new Set<Id>();
            for (Account acct : lstProspectToInsert) 
            {
                prospectIds.add(acct.Id);
            }
            
            for( String eKey : mapReferralToProcess.keySet() ) {
                Referral__c thisReferral    = mapReferralToProcess.get( eKey ).referralObj; 
                Opportunity thisOpportunity = mapReferralToProcess.get( eKey ).opportunityObj;
                Account thisProspect        = mapReferralToProcess.get( eKey ).prospectObj;
                uow.registerRelationship( thisOpportunity, Opportunity.Account__c, thisProspect );
                uow.registerNew( thisOpportunity );
                
                //REGISTER REFERRAL RECORD
                uow.registerRelationship(thisReferral, Referral__c.Referee_Account__c, thisProspect);
                uow.registerRelationship(thisReferral, Referral__c.Opportunity__c, thisOpportunity);
                uow.registerNew( thisReferral );
            }
            uow.commitWork();
            
            
            //Loop through the Opportunity(s) and create task(s)
            Map<Id, Id> contactIdMap = getPersonContactId(prospectIds);
            List<Opportunity> lstNewOppo = new List<Opportunity>();
            for( String eKey : mapReferralToProcess.keySet() ) {
                Opportunity newOppo = mapReferralToProcess.get( eKey ).opportunityObj;
                if( newOppo.Id <> null )
                {
                    if(contactIdMap.containsKey(newOppo.Account__c))
                    {
                        newOppo.Contact_Person__c = contactIdMap.get(newOppo.Account__c);
                    }

                    lstNewOppo.add( newOppo );
                }   
            }
            if( !lstNewOppo.isEmpty() ){
                System.debug('@@@@DEBUG processReferralRequest :: lstNewOppo = ' + lstNewOppo );
                update lstNewOppo;

                createOppoTaskForSC( lstNewOppo );
				createModelInterested (lstNewOppo);
            }



            //Create Record Sharing
            List<sharingHelper.generateShare> lstShareToCreate = new List<sharingHelper.generateShare>();
            for( String eKey : mapReferralToProcess.keySet() ) {
                Opportunity oppo = mapReferralToProcess.get( eKey ).opportunityObj;
                Referral__c reff = mapReferralToProcess.get( eKey ).referralObj;
                if( reff.Id <> null && oppo.Id <> null ){
                    if( reff.Referrer__c <> null ){
                        lstShareToCreate.add( new sharingHelper.generateShare('Read', 'Contact', reff.Referrer__c, oppo.OwnerId ) );
                    }
                    if( reff.Referrer_Account__c <> null ){
                        lstShareToCreate.add( new sharingHelper.generateShare('Read', 'Account', reff.Referrer_Account__c, oppo.OwnerId ) );
                    }
                    if( reff.Referee_Account__c <> null ){
                        lstShareToCreate.add( new sharingHelper.generateShare('Read', 'Account', reff.Referee_Account__c, oppo.OwnerId ) );
                    }
                }
            }
            if( !lstShareToCreate.isEmpty() ){
                sharingHelper.creatShare(lstShareToCreate);
            }

        }
        catch(Exception ex)
        {
            loggerDataPool.buildLogDataPool('ReferralService >> processReferralRequest', ex);
            System.debug('@@@@DEBUG processReferralRequest :: ERROR :: err.cause = ' + ex.getCause() + ' --- err.msg = ' + ex.getMessage() + ' --- err.line = ' + ex.getLineNumber() );
        }    
    }

    public static void createOppoTaskForSC( List<Opportunity> lstNewOppo ){
        List<Task> lstReffOppoTask = new List<Task>();
        Map<Id,Account> mapProspectAcct = new Map<Id,Account>();
        for( Opportunity oppo : lstNewOppo ){
            mapProspectAcct.put( oppo.Account__c, null );
        }
        mapProspectAcct = new Map<Id,Account>([SELECT ID, Name, RecordTypeId, IsPersonAccount, PersonContactId FROM Account WHERE ID IN:mapProspectAcct.keySet() ]);

        for( Opportunity opp : lstNewOppo ){
            Task tsk = new Task();
            tsk = Utility.createTask( opp.Id, opp.OwnerId, System.Label.OppReffAssignment );
            if( mapProspectAcct.containsKey( opp.Account__c )){
                tsk.WhoId = mapProspectAcct.get( opp.Account__c).PersonContactId;
            }
            lstReffOppoTask.add( tsk );
        }
        if( !lstReffOppoTask.isEmpty() ){
            insert lstReffOppoTask;
        }
    }

	//Code was modified for Oppty standardisation --> NSJ
    public static void createModelInterested( List<Opportunity> lstNewOppo )
	{
		list<Models_Interested__c> createModIntList = new list<Models_Interested__c>();

        for( Opportunity opp : lstNewOppo )
		{
			//Code was modified for Oppty standardisation --> NSJ
			Models_Interested__c createModInt = new Models_Interested__c();
			createModInt = ModelsInterestedService.newModelInterestedObject(opp.Id, null, 'Online', 'Referral - App');
            createModIntList.add( createModInt );
        }
        if( !createModIntList.isEmpty() ){
            insert createModIntList;
        }
    }

    public static void grantRecordShare(){

    }
    
    public static List<Referral__c> getReferralListByPersonAccountAndStage( Set<String> setPersonAcctIds , Set<String> setStages ) 
    {
        return selector.selectByReferrerPersonAccountIdsAndStages( setPersonAcctIds, setStages );
    }
    
    public static map <Id, Referral__c> call_Map_Id_to_Stage_Referral(List<Referral__c> listRef)
    {
        map <Id, Referral__c> return_MapId_to_Stage_Referral = new map <Id, Referral__c>();
        map <Id, string> MapId_w_OpptyId_Referral = new map <Id, string>();
        
        set<string> setOpptyId = new Set<string>();
        for(Referral__c r : listRef)
        {
            setOpptyId.add(r.Opportunity__r.id);
            MapId_w_OpptyId_Referral.put(r.Opportunity__r.id , r.id);
        }
        
        list <Sales_Agreement__c> SA_list = new list <Sales_Agreement__c>();
        
        SA_list = [select id, Opportunity__r.id from Sales_Agreement__c where Opportunity__r.id in: setOpptyId and stage__c = 'Car Collected' ];
        
        
        for(Sales_Agreement__c sa : SA_list)
        {
            if(MapId_w_OpptyId_Referral.containsKey(sa.Opportunity__r.id))
            {
				Referral__c tempObjRef = new Referral__c();
				tempObjRef.Stage__c = 'SuccessfullyReferred';
				tempObjRef.Referee_Sales_Agreement_Prospect__c = sa.id;
				return_MapId_to_Stage_Referral.put(MapId_w_OpptyId_Referral.get(sa.Opportunity__r.id), tempObjRef);
            }				
        }
        
        return return_MapId_to_Stage_Referral;
        
    }

	public static string call_Str_Brand_to_Branch_Convertor(string brand)
	{
		string strBranch = '';
		map<string, string> map_Str_Brand_to_Branch = new map<string, string>();
		map_Str_Brand_to_Branch.put('DS', 'CCF');
		map_Str_Brand_to_Branch.put('CIT', 'CCF');
		map_Str_Brand_to_Branch.put('KIA', 'CCK');
		map_Str_Brand_to_Branch.put('MIT', 'CCA');
		map_Str_Brand_to_Branch.put('MB', 'CCI');
		
		if(map_Str_Brand_to_Branch.containsKey(brand))
		{
			strBranch = map_Str_Brand_to_Branch.get(brand);
		}

		Return strBranch;
	}


	//Due to lack of time this method is not bulkify ---
	public static Registered_Vehicle__c call_Reg_veh (string accountId, string brand)
	{
		string strBranch = ReferralService.call_Str_Brand_to_Branch_Convertor(brand);
		Registered_Vehicle__c [] arrVehReg = new Registered_Vehicle__c[]{};

		arrVehReg = [select id from Registered_Vehicle__c where Branch__c =: strBranch and Contact__c =: accountId ORDER by LastModifiedDate DESC];

		if(arrVehReg.size() > 0)
		{
			return arrVehReg[0];
		}

		return null;
    }
    
    public static Map<Id, Id> getPersonContactId (Set<Id> acctIds)
    {
        Map<Id, Id> contactIdMap = new Map<Id, Id>();
        Map<Id, Account> accountMap = new Map<ID, Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN: acctIds]);
        for (Account acct : accountMap.values())
        {
            contactIdMap.put(acct.Id, acct.PersonContactId);
        }

        return contactIdMap;
    }    
}
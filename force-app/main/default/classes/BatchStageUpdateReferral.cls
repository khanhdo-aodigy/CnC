global class BatchStageUpdateReferral implements Database.Batchable<sObject>, Schedulable, Database.stateful
{

	public Integer i = 0;

	global List<Referral__c> finListReferral;
	global Set<Id> setTargetedIds = new Set<Id>();

	global BatchStageUpdateReferral() 
	{
		finListReferral	= new List<Referral__c>();
	}

	global BatchStageUpdateReferral( Set<Id> setTargetReffIds ){
		finListReferral	= new List<Referral__c>();
		setTargetedIds = setTargetReffIds;
	}

	//start
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		//string strId = 'a2ZO0000001YKJV';
		String strStageExpired = 'Expired';
		String strStageSuccess = 'SuccessfullyReferred';
		String strSOQL = ' SELECT Id, Name, Opportunity__r.Id, Referrer__r.Device__c, Referrer_Account__r.Device__pc, Number_of_Days_before_expired__c, Stage__c '+
						 ' FROM Referral__c WHERE stage__c !=: strStageExpired AND stage__c !=:strStageSuccess '; 

		if( setTargetedIds <> null && setTargetedIds.size() > 0 ){
			strSOQL = strSOQL + ' AND ID IN :setTargetedIds ';
		}
		return Database.getQueryLocator(strSOQL);
	}
	
	//execute
	global void execute(Database.BatchableContext BC, List<Referral__c> referralList)
	{
		try
		{
			System.debug('++ +C ' + referralList.size());

			map <Id, Referral__c> MapId_to_Stage_Referral = new map <Id, Referral__c>();
			MapId_to_Stage_Referral = ReferralService.call_Map_Id_to_Stage_Referral(referralList);
			System.debug('@@@@DEBUG BatchStageUpdateReferral <<execute>> :: referralList = ' + referralList.size() + ' --- ' + referralList );
			System.debug('@@@@DEBUG BatchStageUpdateReferral <<execute>> :: MapId_to_Stage_Referral = ' + MapId_to_Stage_Referral.size() + ' --- ' + MapId_to_Stage_Referral );

			for(referral__c r : referralList)
			{
				boolean isAddtoList = false;
				
				if(r.Number_of_Days_before_expired__c < 0 && r.Stage__c != 'SuccessfullyReferred')
				{
					r.Stage__c = 'Expired';
					isAddtoList = true;
				}
				else if(r.Number_of_Days_before_expired__c == 7 && r.Stage__c != 'SuccessfullyReferred')
				{
					r.Stage__c = 'Expiring';
					isAddtoList = true;
				}
				else if(MapId_to_Stage_Referral.containsKey(r.id))
				{
					System.debug('++ r.id' + r.id);
					System.debug('++ MapId_to_Stage_Referral' + MapId_to_Stage_Referral.get(r.id));
					if(MapId_to_Stage_Referral.get(r.id).Stage__c == 'SuccessfullyReferred')
					{
						r.Stage__c = 'SuccessfullyReferred';
						r.Referee_Sales_Agreement_Prospect__c = MapId_to_Stage_Referral.get(r.id).Referee_Sales_Agreement_Prospect__c;
						isAddtoList = true;
					}
				}	
				
				if(isAddtoList == true)
				{
					finListReferral.add(r);			
				}	
				
			}

			if(finListReferral.size() > 0)
			{
				update finListReferral;
			}
		}
		catch(Exception ex ){
			System.debug('@@@@DEBUG BatchStageUpdateReferral :: Error :: err.msg = ' + ex.getMessage() + ' --- + err.cause = ' + ex.getCause() + ' --- err.line = ' + ex.getLineNumber() );
			loggerDataPool.buildLogDataPool('BatchStageUpdateReferral', ex);
		}

	}
	
	//finish
	global void finish(Database.BatchableContext BC)
	{
		System.enqueueJob( new ReferralQueueable(finListReferral) );
	}

    //execute Schedule
    public void execute (SchedulableContext ctx)
	{   
      Database.executeBatch(new BatchStageUpdateReferral());
    }

}
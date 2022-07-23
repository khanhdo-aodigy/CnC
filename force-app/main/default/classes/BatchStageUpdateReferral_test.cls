/*
Test Coverage cover below classes:
ReferralQueueable
BatchStageUpdateReferral

*/

@isTest 
private class BatchStageUpdateReferral_test 
{

	@isTest
	private static void BatchStageUpdateReferral_test1() 
	{
		contact c = new contact();
		c.FirstName = 'A';
		c.LastName = 'B';
		c.Device__c = 'C';

		insert c;

		Opportunity opp = new Opportunity();
		opp.Contact_Person__c = c.id;
		opp.Name = 'hh';
		opp.StageName = 'Open';
		opp.CloseDate = Date.today() + 100 ;
		insert opp;

		Referral__c ref = new Referral__c();
		ref.Referrer__c = c.id;
		ref.Stage__c = 'Opened';
		ref.Referred_Date__c = Date.today() + 7;
		ref.Expiry_Referred_Date__c = Date.today();
		insert ref;

		Referral__c ref2 = new Referral__c();
		ref2.Referrer__c = c.id;
		ref2.Stage__c = 'Opened';
		ref2.Referred_Date__c = Date.today();
		ref2.Expiry_Referred_Date__c = Date.today() + 7;
		insert ref2;

		Id batchJobId = Database.executeBatch(new BatchStageUpdateReferral(), 5);

		BatchStageUpdateReferral x = new BatchStageUpdateReferral( new Set<Id>{ ref.Id } );
		Id batchJobId1 = Database.executeBatch( x , 5);
	}

}
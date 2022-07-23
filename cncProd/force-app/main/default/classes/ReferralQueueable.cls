public with sharing class ReferralQueueable implements Queueable {
    
    public list<referral__c> newFinListReferral = new list<referral__c>();

    public ReferralQueueable( list<referral__c> finListReferral ) 
    {
        newFinListReferral = finListReferral;
    }

    public void execute(QueueableContext con)
    {
		Set<string> setDeviceExpiry = new Set<string>();
		Set<string> setDeviceSuccess = new Set<string>();

		for(referral__c r : newFinListReferral)
		{
			if( String.isNotBlank( r.Referrer_Account__r.Device__pc ) && r.Stage__c == 'Expiry')
			{
				// setDeviceExpiry.add(r.Referrer__r.Device__c);
				setDeviceExpiry.add(r.Referrer_Account__r.Device__pc);
			}
			else if( String.isNotBlank( r.Referrer_Account__r.Device__pc ) && r.Stage__c == 'SuccessfullyReferred')
			{
				// setDeviceSuccess.add(r.Referrer__r.Device__c);
				setDeviceExpiry.add(r.Referrer_Account__r.Device__pc);
			}
		}

		string ArrayDeviceExpiry = '';
		for(string a : setDeviceExpiry)
		{
			ArrayDeviceExpiry += '"'+ a + '"' + ',';
		}

		string ArrayDeviceSuccess = '';
		for(string a : setDeviceSuccess)
		{
			ArrayDeviceSuccess += '"'+ a + '"' + ',';
		}

		ArrayDeviceExpiry = ArrayDeviceExpiry.removeEnd(',');
		ArrayDeviceSuccess = ArrayDeviceSuccess.removeEnd(',');

		send_PushMessage.SENDAPPPUSH_MultipleTokens('Your Referral is Expiring in 7 Days! ','', ArrayDeviceExpiry);
		send_PushMessage.SENDAPPPUSH_MultipleTokens('Congratulations! Your Referral is Successful! ', '', ArrayDeviceSuccess);
    }

}
public class ModelsInterestedService  
{	
    //Create Models Interested
    public static Models_Interested__c newModelInterestedObject ( String OppId, String ModId, String channel, string touchpoint )
    {
		Models_Interested__c createModInt = new Models_Interested__c();

		if(!String.isEmpty(ModId))
		{
			createModInt.Model__c        = ModId;
		}
		createModInt.Opportunity__c  = OppId;
		//createModInt.OwnerId         = ownId;
		createModInt.Channel__c = channel;
		createModInt.Touch_Points__c = touchpoint;

		return createModInt;
    }

}
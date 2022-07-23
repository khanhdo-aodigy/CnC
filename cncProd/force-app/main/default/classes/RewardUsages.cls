/** *****
 * Description : Trigger Handler for Reward Usage Object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200629            HS@aodigy            Created Initial Version 
 * 
** *****/
public class RewardUsages extends ADGLIB_SObjectDomain{
    
    public RewardUsages(List<Reward_Usage__c> sObjectList)
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
        public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new RewardUsages(sObjectList);
		}
    }
    
    public override void onAfterInsert() 
    {   
        List<Reward_Usage__c> lstNewRewardUsages = (List<Reward_Usage__c>)Records;

        RewardUsageService.createPaymentForDebitUsage( lstNewRewardUsages );

        RewardUsageService.createPaymentForCreditUsage( lstNewRewardUsages );

        RewardUsageService.createDebitUsageforCNforExpiredReward( lstNewRewardUsages );

        RewardUsageService.triggerRelatedListPlatformEvent( lstNewRewardUsages );    
    }

}
/** ******
 * Description : Controller for Component cm_CreditUsage
 *  
 * Change History:
 * Date(YYYYMMDD)           Name                            Description
 * 20200630                 khanh.do@aodigy.com             Created Initial Version.
 * 
***** **/
public with sharing class CMCreditRewardUsageController {

    @AuraEnabled
    public static List<Reward_Usage__c> createRewardCreditUsage(String rewardProfileId, String invoiceNumber, String creditNote, Decimal refundAmount, String refundReason, Date issuedDate)
    {
        return CMCreditUsageService.createRewardCreditUsage(rewardProfileId, invoiceNumber, creditNote, refundAmount, refundReason, issuedDate);
    }

}
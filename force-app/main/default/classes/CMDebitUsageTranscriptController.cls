/** ******
 * Description : Controller class for CMDebitUsageTranscript VFP.
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20200820             TP@aodigy.com                   Created Initial Version. 
 * 
***** **/

public with sharing class CMDebitUsageTranscriptController 
{  
    private String rewardProfileId;
    public Decimal totalRemainderBefore {get;set;}
    public Date usageDate {get;set;}
    public String invoiceNumber {get;set;}
    public Decimal invoiceAmount {get;set;}
    public Decimal creditAmount {get;set;}
    public Decimal outStandingAmount {get;set;}
    public Decimal totalRemainder {get;set;}
    
    public CMDebitUsageTranscriptController()
    {
        rewardProfileId = ApexPages.currentPage().getParameters().get('Id');
        totalRemainderBefore = Decimal.valueOf(ApexPages.currentPage().getParameters().get('totalRemainderBefore'));
        usageDate       = Date.valueOf(ApexPages.currentPage().getParameters().get('usageDate'));
        invoiceNumber   = ApexPages.currentPage().getParameters().get('invoiceNumber');
        invoiceAmount   = Decimal.valueOf(ApexPages.currentPage().getParameters().get('invoiceAmount'));
        creditAmount    = Decimal.valueOf(ApexPages.currentPage().getParameters().get('creditAmount'));
        outStandingAmount = Decimal.valueOf(ApexPages.currentPage().getParameters().get('outStandingAmount'));    
        totalRemainder  = Decimal.valueOf(ApexPages.currentPage().getParameters().get('totalRemainder'));
    }
    
    public Reward_Profile__c rewardProfileRec 
    {
        get {
            rewardProfileRec = [SELECT Id, Name, Contact__r.Name, Brand__c, Type__c FROM Reward_Profile__c WHERE Id =:  rewardProfileId];
            return rewardProfileRec;
        }
        private set;
    } 
}
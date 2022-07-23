/** ******
 * Description : Controller class for CMCreditUsageTranscript VFP.
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20200821             TP@aodigy.com                   Created Initial Version. 
 * 
***** **/

public with sharing class CMCreditUsageTranscriptController 
{  
    private String rewardProfileId;
    public Date issuedDate {get;set;}
    public String invoiceNumber {get;set;}
    public String creditNoteNumber {get;set;}
    public Decimal refundAmount {get;set;}
    public String refundReason {get;set;}
    public Decimal totalRemainderAfter {get;set;}
    public Decimal totalCreditedUsage {get;set;}
    
    public CMCreditUsageTranscriptController()
    {
        rewardProfileId   = ApexPages.currentPage().getParameters().get('Id');
        issuedDate        = Date.valueOf(ApexPages.currentPage().getParameters().get('issuedDate'));
        invoiceNumber     = ApexPages.currentPage().getParameters().get('invoiceNumber');
        creditNoteNumber  = ApexPages.currentPage().getParameters().get('creditNoteNumber');
        refundAmount      = Decimal.valueOf(ApexPages.currentPage().getParameters().get('refundAmount'));
        refundReason      = ApexPages.currentPage().getParameters().get('refundReason');
        totalRemainderAfter = Decimal.valueOf(ApexPages.currentPage().getParameters().get('totalRemainderAfter'));
        totalCreditedUsage = Decimal.valueOf(ApexPages.currentPage().getParameters().get('totalCreditedUsage'));
    }
    
    public Reward_Profile__c rewardProfileRec 
    {
        get {
            rewardProfileRec = [SELECT Id, Name, Contact__r.Name, Brand__c, Type__c, Total_Credit__c, Total_Remainder__c, Total_Credited_Usage__c FROM Reward_Profile__c WHERE Id =:  rewardProfileId];
            return rewardProfileRec;
        }
        private set;
    }

}
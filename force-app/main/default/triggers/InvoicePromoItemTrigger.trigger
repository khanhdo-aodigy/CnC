/** ******
 * Description: InvoicePromoLineItem Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		         Description
 * 20220413            thanh.ly@aodigy           Created Initial Version.
 * 
** ******/
trigger InvoicePromoItemTrigger on Invoice_Promo_Line_Item__c (after insert) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('Invoice_Promo_Line_Item__c') || TriggerExclusion.isBypassTriggerExecution('Invoice_Promo_Line_Item__c') || automationSetting.Bypass_Triggers__c){
        return;
    }
    
    if(Trigger.isAfter && Trigger.isInsert){}
}
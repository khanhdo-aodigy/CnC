/** ******
 * Description : Invoked to perform API Callout when the Campaign Members are inserted via Batch context (i.e. OnboardCustToSalesTargetedPromo.cls )
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                       Description
 * 20220519         tphan@aodigy.com         Created Initial Version
 * 
** ******/
public with sharing class InvoiceEmail_RestTCQueueable implements Queueable 
{    
    public List<String> campaignIds = new List<String>();
    public Set<Id> alertIds         = new Set<Id>();

    public InvoiceEmail_RestTCQueueable( List<String> idsOfCampaigns, Set<Id> idsOfAlerts ) 
    {
        campaignIds = idsOfCampaigns;
        alertIds    = idsOfAlerts;
    }

    public void execute(QueueableContext con)
    {
        System.debug('@@@@DEBUG InvoiceEmail_RestTCQueueable :: campaignIds = ' + campaignIds.size() + ' --- ' + campaignIds );

        if(campaignIds <> null && !campaignIds.isEmpty())
        {   
            InvoiceEmail_ProcessBuilder_RestTC.apexcallout(campaignIds);
        }

        if (alertIds <> null && !alertIds.isEmpty())
        {
            BroadcastController.pushCustomerBroadcast(alertIds);
        }
    }
}
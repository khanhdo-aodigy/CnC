/** ******
 * Description : Batch Job to create Customer Alert for Broadcast
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200305            HS         Created Initial Version
 * 20200906            TPhan      Made changes to cater for RA and NonC&C Cars - IDP Revamp Phase 2
** ******/
global class BroadcastCreationBatch implements Database.Batchable<SObject>, Database.Stateful  
{
    private List<String> errMsgs = new List<String>();
    public BroadcastFilterWrapper the_filters;
    public String the_alertMessage; 
    public String the_campaignId;
    public String the_subType;
    public String the_deepLinkingURL;
    public String the_alertName;

    public BroadcastCreationBatch( BroadcastFilterWrapper filters, String alertMessage, String subType, String campaignRefId, String deepLinkingURL, String alertName ) 
    {
        the_filters        = filters;
        the_alertMessage   = alertMessage;
        the_subType        = subType;
        the_campaignId     = campaignRefId;
        the_deepLinkingURL = deepLinkingURL;
        the_alertName      = alertName;
    }

    global List<SObject> start(Database.BatchableContext BC) 
    {
        return (List<SObject>)( BroadcastController.getFilteredRegVehicles( the_filters, 0 ).records );
    }
 
    global void execute(Database.BatchableContext info, List<SObject> lstVehicles ) 
    {
        System.debug('@@@@DEBUG BroadcastCreationBatch :: lstVehicles = ' + lstVehicles.size() );
        if( lstVehicles <> null && !lstVehicles.isEmpty() ) 
        {
            BroadcastController.createBroadcastRecords( lstVehicles, the_alertMessage, the_subType, the_campaignId, the_deepLinkingURL, the_alertName );
        }
    }
 
    global void finish(Database.BatchableContext info) 
    { 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.setSaveAsActivity(false);

        String body;
        if(!errMsgs.isEmpty())
        {
            for(Integer i=0; i<errMsgs.size(); i++)
            {
                body += (String.valueof(i+1)+' '+errMsgs[i]+ '\r\n');
            }   
        }
        else
        {
            body = 'The Customer Broadcast has been processed successfully.';
        }
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
/*******
 * Description :	Queueable class for notification API related for campaign-member
 * 
 * Useful Link :	https://salesforce.stackexchange.com/questions/212491/create-custom-button-in-lightning-that-calls-an-apex-class-method
 *					https://developer.salesforce.com/docs/atlas.en-us.noversion.mc-apis.meta/mc-apis/postMessageBatch.htm
 *					https://developer.salesforce.com/docs/atlas.en-us.noversion.mc-apis.meta/mc-apis/postMessageContactSendPush.htm
 *
 * Change History : 
 * Date(YYYYMMDD)		Name			Description
 * 20200712             NSJ				Created Initial Version 
*******/


public with sharing class CM_notification_queueable implements Queueable {
    
    public CM_Notification_Service.collect_PN_Wrapper new_cPN = new CM_Notification_Service.collect_PN_Wrapper();

    public CM_notification_queueable(CM_Notification_Service.collect_PN_Wrapper cPN) 
    {
        new_cPN = cPN;
    }

    public void execute(QueueableContext con)
    {
		if(new_cPN.isFire == true)
		{
			CM_Notification_Service.SendHttpPUSH_CM(new_cPN.subscriber_tokens, new_cPN.push_body, new_cPN.keyword, new_cPN.openDirect);
		}		
    }

}
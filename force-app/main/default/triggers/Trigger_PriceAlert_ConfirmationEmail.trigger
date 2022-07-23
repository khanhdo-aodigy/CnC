/** ******
 * Description: Trigger for set branch code and franchise code
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added bypass trigger via custom setting
 * 
** ******/
trigger Trigger_PriceAlert_ConfirmationEmail on price_alert__c (after insert) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    if(TriggerExclusion.isTriggerExclude('price_alert__c')
        || TriggerExclusion.isBypassTriggerExecution('price_alert__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    String personName;
    String personEmail;
    String SubscriberKey;
    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    String triggeredSendMessageId = (String)JCC_GlobalVar.PriceAlertTriggeredId__c;
    String BranchCode;
    String ModelName;
      
    List <price_alert__c> priceAlert = new list <price_alert__c>();
    
    if (Trigger.isAfter)  
	{
        for(price_alert__c prcAlrt : trigger.new)
        {
            try
			{
                priceAlert = [SELECT Id, Opportunity__r.Contact_Person__r.FirstName, Opportunity__r.Contact_Person__r.Email,
                                Opportunity__r.Contact_Person__r.Id, Model__r.Branch_Code__c,Model__r.Name,
                                Opportunity__r.Contact_Person__r.LastName,Opportunity__r.Lead__r.LastName,
                                Opportunity__r.Account__c, Opportunity__r.Account__r.FirstName, 
                                Opportunity__r.Account__r.personemail,
                                Opportunity__r.Account__r.Id, Opportunity__r.Account__r.LastName 
                              FROM price_alert__c 
                              WHERE Id =: prcAlrt.Id];

                if(priceAlert.size()>0)
                {
                    if(priceAlert[0].Opportunity__r.Account__c != null)
                    {
                        if(priceAlert[0].Opportunity__r.Account__r.FirstName != null) {
							personName = priceAlert[0].Opportunity__r.Account__r.FirstName;
                        }
                        else {
                            personName = priceAlert[0].Opportunity__r.Account__r.LastName;
                        }
                        personEmail   = priceAlert[0].Opportunity__r.Account__r.personEmail;
                        SubscriberKey = priceAlert[0].Opportunity__r.Account__r.Id;
                        BranchCode    = priceAlert[0].Model__r.Branch_Code__c;
                        ModelName     = priceAlert[0].Model__r.Name;
                        //call email method from future class
                        PriceAlert_ConfirmationEmailSend.sendEmail( personName, personEmail, SubscriberKey, triggeredSendMessageId, BranchCode, ModelName );                        
                    }
                    else if(priceAlert[0].Opportunity__r.Contact_Person__r.Id != null)
                    {
                        if(priceAlert[0].Opportunity__r.Contact_Person__r.FirstName!=null){
                            personName = priceAlert[0].Opportunity__r.Contact_Person__r.FirstName;
                        }
                        else {
                            personName = priceAlert[0].Opportunity__r.Contact_Person__r.LastName;
                        }
                        personEmail   = priceAlert[0].Opportunity__r.Contact_Person__r.Email;
                        SubscriberKey = priceAlert[0].Opportunity__r.Contact_Person__r.Id;
                        BranchCode    = priceAlert[0].Model__r.Branch_Code__c;
                        ModelName     = priceAlert[0].Model__r.Name;
                        //call email method from future class
                        PriceAlert_ConfirmationEmailSend.sendEmail( personName, personEmail, SubscriberKey, triggeredSendMessageId, BranchCode, ModelName );                        
                    }
                }
                else
                {
                    System.debug('No PriceAlerts found');
                }
                
            }
            catch (Exception e)
            {
                System.debug('Error Occured : ' + e.getMessage());
            }
            
        }
    }
    
}
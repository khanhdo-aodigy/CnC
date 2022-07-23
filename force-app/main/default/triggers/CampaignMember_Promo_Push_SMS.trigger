/** ******
 * Description: CampaignMember Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C			        Created Initial Version.
 * 20210706            khanh.do             Added Trigger exclusion
 * 
** ******/
trigger CampaignMember_Promo_Push_SMS on CampaignMember (after insert, after update) 
{
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if(TriggerExclusion.isTriggerExclude('CampaignMember')
         || TriggerExclusion.isBypassTriggerExecution('CampaignMember')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
	
    public boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    
    if (Trigger.isAfter)
    {
        String PUSH_Body ;
        String ContactPhone;
        String ContactKey;
        String Location ; 
        String DeviceToKenValue ;
        String RegistrationNumber ;
        DateTime DateValue ;
        String Campaign_ID ; 
		String CampType;
        String Campaign_Name ;
        String registered_Vehicle ;
        String customerRemarks ; 
        String PUSH_txt;
        String SMS_txt;
        String SMS_link;
        String End_Date;
		String openDirect;
        
        if (Trigger.isUpdate)
        {
            for(CampaignMember CMem : trigger.new)
            {  
                List<CampaignMember> contactInfo = new list<CampaignMember>(); 
                CampaignMember oldCM = Trigger.oldMap.get(CMem.ID);
                System.debug('Old==='+oldCM.Status+'New===='+CMem.Status);
                
                if((oldCM.Status!='PUSH' && CMem.Status=='PUSH') || Test.isRunningTest())
                {
                    contactInfo = [SELECT Contact.MobilePhone, Contact.Device__c, Campaign.Id, Campaign.Name, Campaign.Promo_PUSH_Text__c,
                                         Campaign.Promo_SMS_Text__c, Campaign.Promo_SMS_Link__c, Campaign.EndDate, Campaign.type, Campaign.deep_linking_URL__c
                                   FROM CampaignMember 
                                   WHERE Id =: CMem.Id];
                    
                    if (contactInfo != null  && contactInfo.size()>0)
                    {
                        ContactPhone =  contactInfo[0].Contact.MobilePhone;             
                        if(contactInfo[0].Contact.Device__c  != null)
                        {
                            DeviceToKenValue =  contactInfo[0].Contact.Device__c ;	
                        }
                        if(contactInfo[0].Campaign.Id  != null)
                        {
                            Campaign_ID     = contactInfo[0].Campaign.Id;
                            Campaign_Name   = contactInfo[0].Campaign.Name;      
							CampType        = contactInfo[0].Campaign.type;          
                            ContactPhone    = contactInfo[0].Contact.MobilePhone;
                            ContactKey      = contactInfo[0].Contact.Id;
                            PUSH_txt        = contactInfo[0].Campaign.Promo_PUSH_Text__c;
                            SMS_txt         = contactInfo[0].Campaign.Promo_SMS_Text__c;
                            End_Date        = contactInfo[0].Campaign.EndDate.format();
							openDirect		= contactInfo[0].Campaign.Deep_linking_URL__c;
                            //SMS_link =  contactInfo[0].Campaign.Promo_SMS_Link__c;
                            //SMS_link = 'https://scsit.cyclecarriage.com/kia/promos/'+Campaign_Name+'?sc_device=mobile&enddate=11/28/2019&Type=Promo&Id='+Campaign_ID;
                        }
                    }      
                    
                    if(DeviceToKenValue!=null && DeviceToKenValue.trim()!='')
                    {
						System.debug(' push ++ is calling prod' );
                        send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','',DeviceToKenValue,'MTI5OjExNDow','Promo',Campaign_ID,PUSH_txt, campType, Campaign_Name, '','', openDirect); 
						send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','',DeviceToKenValue,'MTk2OjExNDow','Promo',Campaign_ID,PUSH_txt, campType, Campaign_Name, '','', openDirect);

						if(isSandbox == true)
						{
							System.debug(' push ++ is calling sandbox' + ' ' + Campaign_Name + ' '  + campType);
							send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','',DeviceToKenValue,'MjoxMTQ6MA','Promo',Campaign_ID,PUSH_txt, campType, Campaign_Name, '','', openDirect);  							
							send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','',DeviceToKenValue,'ODU6MTE0OjA','Promo',Campaign_ID,PUSH_txt, campType, Campaign_Name, '','', openDirect); 
						}
                    }
                    
                    if((ContactPhone!=null && ContactPhone.trim()!='') && (SMS_txt!=null && SMS_txt.trim()!=''))
                    {
						System.debug(' sms ++ is calling prod' );
						send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS(ContactKey,ContactPhone,'','NzE6Nzg6MA','Promo',Campaign_ID, '','', '',SMS_txt,End_Date, openDirect); 
						if(isSandbox == true)
						{
							System.debug(' sms ++ is calling sandbox' );
							send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS(ContactKey,ContactPhone,'','MTg6Nzg6MA','Promo',Campaign_ID, '','', '',SMS_txt,End_Date, openDirect);
						} 
                    }
                }
            }
        }
        else if (Trigger.isInsert)
        {
            for(CampaignMember CMem : trigger.new)
            {  
                list <CampaignMember> contactInfo  =  new list<CampaignMember>(); 
                System.debug('New===='+CMem.Status);
                if(CMem.Status=='PUSH' || Test.isRunningTest())
                {
                    contactInfo = [SELECT Contact.MobilePhone, Contact.Device__c, Campaign.Id, Campaign.Name, Campaign.Promo_PUSH_Text__c,
                                        Campaign.Promo_SMS_Text__c, Campaign.Promo_SMS_Link__c, Campaign.EndDate, Campaign.Deep_linking_URL__c
                                   FROM CampaignMember 
                                   WHERE Id =: CMem.Id];
                    
                    if (contactInfo != null && contactInfo.size()>0)
                    {
                        ContactPhone = contactInfo[0].Contact.MobilePhone;             
                        if(contactInfo[0].Contact.Device__c  != null)
                        {
                            DeviceToKenValue =  contactInfo[0].Contact.Device__c ;	
                        }
                        if(contactInfo[0].Campaign.Id  != null)
                        {
                            Campaign_ID     = contactInfo[0].Campaign.Id;
                            Campaign_Name   = contactInfo[0].Campaign.Name;                
                            ContactPhone    = contactInfo[0].Contact.MobilePhone;
                            ContactKey      = contactInfo[0].Contact.Id;
                            PUSH_txt        = contactInfo[0].Campaign.Promo_PUSH_Text__c;
                            SMS_txt         = contactInfo[0].Campaign.Promo_SMS_Text__c;
                            End_Date        = contactInfo[0].Campaign.EndDate.format();
							openDirect		= contactInfo[0].Campaign.Deep_Linking_URL__c;
                            //SMS_link =  contactInfo[0].Campaign.Promo_SMS_Link__c;
                            //SMS_link = 'https://scsit.cyclecarriage.com/kia/promos/'+Campaign_Name+'?sc_device=mobile&enddate=11/28/2019&Type=Promo&Id='+Campaign_ID;
                        }
                    }      
                    
                    if(DeviceToKenValue!=null && DeviceToKenValue.trim()!='')
                    {
						System.debug(' push ++ is calling prod' );
                        //send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','',DeviceToKenValue,'NTU6MTE0OjA','Promo',Campaign_ID,PUSH_txt,'',''); 
                        send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','',DeviceToKenValue,'MTI5OjExNDow','Promo',Campaign_ID,PUSH_txt,campType, Campaign_Name, '',Campaign_Name, openDirect); 
						send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','',DeviceToKenValue,'MTk2OjExNDow','Promo',Campaign_ID,PUSH_txt, campType, Campaign_Name, '',Campaign_Name, openDirect);

						if(isSandbox == true)
						{
							System.debug(' push ++ is calling sandbox' + ' ' + Campaign_Name + ' '  + campType);
							send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','',DeviceToKenValue,'MjoxMTQ6MA','Promo',Campaign_ID,PUSH_txt,campType, Campaign_Name, '',Campaign_Name, openDirect); 							
							send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS('','',DeviceToKenValue,'ODU6MTE0OjA','Promo',Campaign_ID,PUSH_txt,campType, Campaign_Name, '',Campaign_Name, openDirect); 
						}
                    }
                    
                    if((ContactPhone!=null && ContactPhone.trim()!='') && (SMS_txt!=null && SMS_txt.trim()!=''))
                    {
						System.debug(' push ++ is calling prod' );
						send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS(ContactKey,ContactPhone,'','NzE6Nzg6MA','Promo',Campaign_ID,'','','', SMS_txt,End_Date, openDirect); 
						if(isSandbox == true)
						{
							System.debug(' push ++ is calling sandbox' );
							send_Push_SMS_CustomKeys.SENDAPP_PUSH_SMS(ContactKey,ContactPhone,'','MTg6Nzg6MA','Promo',Campaign_ID,'','','', SMS_txt,End_Date, openDirect);
						} 
                    }
                }
            }        
        }
    }
}
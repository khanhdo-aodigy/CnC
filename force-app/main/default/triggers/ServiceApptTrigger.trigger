/** ******
* Description: Trigger to send sms on new service appointment 
* 
* Change History:
* Date(YYYYMMDD)    Name        		    Description
* 20180709          Cycle & Carriage        Created Initial Version. 
* 20200221			HS					    Added isTriggerExclude & isBypassTriggerExecution to perform additional check based on mdt data setup to bypass Trigger execution
* 20200322          SJ                      Added PA migration changes
* 20210706          KD                      Added bypass trigger via custom setting
* 
** ******/
//Trigger to send sms on new service appointment 
trigger ServiceApptTrigger on Service_Appointment__c (after insert ,after update)
{   
    //Trigger exclusion check
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if( TriggerExclusion.isTriggerExclude('Service_Appointment__c') 
        || TriggerExclusion.isBypassTriggerExecution('Service_Appointment__c') 
            || automationSetting.Bypass_Triggers__c
    )
    {
        return;
    }
    
    if (Trigger.isAfter)
    {
        //check if its a insert trigger 
        String SMS_Body;
        String PUSH_Body ;
        String ContactPhone;
        String ContactKey;
        String Location ; 
        String ServiceCentreName = '';
        String DeviceToKenValue ;
        String RegistrationNumber ;
        DateTime DateValue ;
        String booking_ID ; 
        String registered_Vehicle ;
        String customerRemarks ; 
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String triggeredCreateSendMessageId = (String)JCC_GlobalVar.Create_Service_MC_TriggerId__c;
        String triggeredEditSendMessageId = (String)JCC_GlobalVar.Edit_Service_MC_TriggerId__c;
        String triggeredCancelSendMessageId = (String)JCC_GlobalVar.Cancel_Service_MC_TriggerId__c;
        String triggeredPushId = (String)JCC_GlobalVar.TriggeredPush__c;
        String triggeredPushId_MB = (String)JCC_GlobalVar.TriggeredPush_MB__c;
        String triggeredSmsId =  (String)JCC_GlobalVar.TriggeredsmsId__c;
        String subcriberKey ; 
        String emailAddress ; 
        String serviceType ;
        String formatedDate ;
        String formatedDateForSMS;
        String mileage ;
        String branch ;
        String variantName ;
        String variantID ;
        String alternateEmailAddr ;
        String dateVal;
        String hourMinutes;
        DateTime convertedDate ;
        Customer_Detail__c customDetails;
        list <Service_Appointment__c> contactInfo  =  new list<Service_Appointment__c>(); 
        for(Service_Appointment__c sAPP : trigger.new)
        {
            try
            {
                //select email and phone from contact 
                contactInfo = [SELECT Contact__r.Email, Registered_Vehicle__r.Branch__c, Registered_Vehicle__r.Variant__c, Registered_Vehicle__r.Variant__r.Name, 
                               Contact__c, Contact__r.MobilePhone, Contact__r.Device__c, Do_not_send_notification_to_Customer__c,
                               Account__c, Account__r.PersonMobilePhone, Account__r.Device__pc, Account__r.PersonContactId, //PA MIGRATION
                               Non_Owner_Email__c, Non_Owner_Name__c, Non_Owner_Phone_Number__c, Is_Non_Owner__c, Branch__c 
                               FROM Service_Appointment__c 
                               WHERE Id =: sAPP.Id
							   AND Do_not_send_notification_to_Customer__c != true];
                
                if (contactInfo != null  && contactInfo.size()>0)
                {
                    ContactPhone =  contactInfo[0].Contact__r.MobilePhone ; 
                    
                    if(sAPP.Service_Centre_Name__c != null)
                    {
                        ServiceCentreName =  sAPP.Service_Centre_Name__c + ', ' ;
                    }
                    
                    if(sAPP.Service_Centre_Location__c != null)
                    {
                        Location =  sAPP.Service_Centre_Location__c ;
                        if(String.isNotBlank(Location) && Location.contains('Singapore '))
                        {
                            Location = Location.replace('Singapore ', 'S');
                            
                            if(Location.contains('Road,'))
                            {
                                Location = Location.replace('Road,','Rd ');
                            }
                        }
                    }
                    
                    if(sAPP.Service_Appointment_Date_Time__c != null)
                    {
                        DateValue = sAPP.Service_Appointment_Date_Time__c;
                        //for email
                        dateVal      = DateValue.format('dd MMMMM yyyy,EEEEE');
                        hourMinutes  = DateValue.format('hh:mm a');  
                        
                        //for push and sms
                        formatedDate = STRING.valueof(DateValue.format('dd/MM/YY'));
                        formatedDate = formatedDate+' '+DateValue.format('hh:mm aaa');
                        formatedDateForSMS = DateValue.format('dd/MM/YY HH:mm');
                    }
                    
                    if(sAPP.Car_Registration_No__c != null)
                    {
                        RegistrationNumber = sAPP.Car_Registration_No__c ;   
                    }
                    
                    if (contactInfo[0].Contact__r.Device__c != null)
                    {
                        DeviceToKenValue =  contactInfo[0].Contact__r.Device__c ; 
                    }
                    
                    booking_ID = sAPP.Booking_ID__c ;
                    
                    if(sAPP.Registered_Vehicle__c != null)
                    {
                        registered_Vehicle = sAPP.Registered_Vehicle__c;
                    }
                    
                    if(sAPP.Customer_Remarks__c != null)
                    {
                        customerRemarks  = sAPP.Customer_Remarks__c ;
                    }
                    
					if(sAPP.Contact__c != null)
                    {
                        subcriberKey = sAPP.Contact__c ;
                    } 
                    
                    if(sAPP.Service_Code__c != null)
                    {
                        serviceType = sAPP.Service_Code__c ;
                    } 
                    
                    
                    branch = string.isNotEmpty(sAPP.Branch__c) ? sAPP.Branch__c : contactInfo[0].Registered_Vehicle__r.Branch__c;
                    
                    
                    if(sAPP.Mileage__c != null)
                    {
                        mileage =  sAPP.Mileage__c ;
                    }                          
                    if( contactInfo[0].Registered_Vehicle__r.Variant__c != null && contactInfo[0].Registered_Vehicle__r.Variant__r.Name != null)
                    {
                        variantName =  contactInfo[0].Registered_Vehicle__r.Variant__r.Name ; 
                        variantName =  variantName.replace('\"',' \\"');
                    }  
                    if(string.isNotEmpty(sAPP.Brand__c))
                    {
                        variantName = sAPP.Brand__c;
                    }  
                    
                }
                
                if(sAPP.Flag__c == false)
                {  
                    if(contactInfo != null  && contactInfo.size() > 0)
                    {
                        //for sending sms notification .          
                        if((contactInfo[0].Is_Non_Owner__c == true) && (contactInfo[0].Non_Owner_Email__c == null) && (contactInfo[0].Non_Owner_Phone_Number__c != null))
                        {
                            ContactPhone = contactInfo[0].Non_Owner_Phone_Number__c; 
                        }
                    
                        else if((contactInfo[0].Is_Non_Owner__c == false) && (contactInfo[0].Contact__r.Email == null)  &&  (contactInfo[0].Contact__r.MobilePhone != null))
                        {
                            ContactPhone = contactInfo[0].Contact__r.MobilePhone; 
                        }
                    
                        if((ContactPhone != null && contactInfo[0].Contact__r.Email == null && contactInfo[0].Is_Non_Owner__c != true) || 
                           (contactInfo[0].Is_Non_Owner__c == true && contactInfo[0].Non_Owner_Email__c == null) )
                        {
                        
                            if( Trigger.isInsert && sAPP.Action__c == 'Create' )
                            {
                                SMS_Body = 'C&C: The service appt for your car '+RegistrationNumber+' on '+formatedDateForSMS+' at ' + Location +' is confirmed. Thks & see you soon!'; 
                                if( contactInfo[0].Is_Non_Owner__c == true ) {
                                    send_APP_Confirmation_SMS.SENDAPPSMS( SMS_Body, ContactPhone, ContactPhone, triggeredSmsId );              
                                } 
                                else {
                                    send_APP_Confirmation_SMS.SENDAPPSMS( SMS_Body,ContactPhone, String.valueOf(sAPP.Contact__c), triggeredSmsId );              
                                }
                                customDetails = new Customer_Detail__c( Name__c = 'Service Appointment Booked',
                                                                       Type__c = 'SMS',
                                                                       Contact__c = contactInfo[0].Contact__c,
                                                                       Account__c = contactInfo[0].Account__c);
                            }
                        
                            if( Trigger.isUpdate && sAPP.Action__c == 'Edit' )
                            {
                                SMS_Body = 'C&C: The service appt for your car '+RegistrationNumber+' has been rescheduled to '+formatedDateForSMS+' at ' + Location +'. Thks & see you soon!';                   
                                if( contactInfo[0].Is_Non_Owner__c == true ) {
                                    send_APP_Confirmation_SMS.SENDAPPSMS( SMS_Body, ContactPhone, ContactPhone, triggeredSmsId );
                                }
                                else {
                                    send_APP_Confirmation_SMS.SENDAPPSMS( SMS_Body, ContactPhone, String.valueOf(sAPP.Contact__c), triggeredSmsId );
                                }
                                customDetails = new Customer_Detail__c( Name__c = 'Service Appointment Rescheduled',
                                                                       Type__c = 'SMS',
                                                                       Contact__c = contactInfo[0].Contact__c,
                                                                       Account__c = contactInfo[0].Account__c );
                            }
                        
                            if( Trigger.isUpdate && sAPP.Action__c == 'Cancel')
                            {
                                SMS_Body = 'C&C: The service appt for your car '+RegistrationNumber+' on '+formatedDateForSMS+' at ' + Location +' has been cancelled.';                   
                                if( contactInfo[0].Is_Non_Owner__c == true )  {
                                    send_APP_Confirmation_SMS.SENDAPPSMS( SMS_Body, ContactPhone, ContactPhone, triggeredSmsId );
                                }
                                else {
                                    send_APP_Confirmation_SMS.SENDAPPSMS( SMS_Body, ContactPhone, String.valueOf(sAPP.Contact__c), triggeredSmsId );
                                }
                                customDetails = new Customer_Detail__c( Name__c = 'Service Appointment Cancelled',
                                                                       Type__c = 'SMS',
                                                                       Contact__c = contactInfo[0].Contact__c,
                                                                       Account__c = contactInfo[0].Account__c );
                            }                   
                            
                        
                            if( customDetails != null )
                            {
                                Database.insert(customDetails , false);
                            }
                    	}
                    	/******* SMS End********/
                    
                        if( (contactInfo[0].Contact__r.Email != null) || (contactInfo[0].Contact__r.MobilePhone == null && contactInfo[0].Contact__r.Email == null) )
                        {
                            if(Trigger.isInsert && sAPP.Action__c == 'Create') {
                                PUSH_Body = 'The service appt for your car '+RegistrationNumber+' on '+ formatedDate + ' at '+ ServiceCentreName + ' is confirmed. See you soon!';
                                send_PushMessage.SENDAPPPUSH( PUSH_Body, DeviceToKenValue, triggeredPushId, '' );  
                                send_PushMessage.SENDAPPPUSH( PUSH_Body, DeviceToKenValue, triggeredPushId_MB, '' );  
                            }
                            
                            if(Trigger.isUpdate && sAPP.Action__c == 'Edit') {
                                PUSH_Body = 'The service appt for your car '+RegistrationNumber +' has been rescheduled to '+ formatedDate + ' at '+  ServiceCentreName +'. See you soon!';  
                                send_PushMessage.SENDAPPPUSH( PUSH_Body, DeviceToKenValue, triggeredPushId, '' ); 
                                send_PushMessage.SENDAPPPUSH( PUSH_Body, DeviceToKenValue, triggeredPushId_MB, '' );  
                            }
                            
                            if(Trigger.isUpdate && sAPP.Action__c == 'Cancel') {
                                PUSH_Body = 'The service appt for your car '+RegistrationNumber+ ' on ' + formatedDate + ' at '+ ServiceCentreName +' has been cancelled.';  
                                send_PushMessage.SENDAPPPUSH( PUSH_Body, DeviceToKenValue, triggeredPushId, '' );
                                send_PushMessage.SENDAPPPUSH( PUSH_Body, DeviceToKenValue, triggeredPushId_MB, '' );     
                            }
                        }
                    	/******* Push End********/
                    
                        //for sending primary email via trigger
                        if( (contactInfo[0].Is_Non_Owner__c == true) && (String.isNotBlank(contactInfo[0].Non_Owner_Email__c)) )
                        {
                            emailAddress = contactInfo[0].Non_Owner_Email__c;
                        }
    
                        else if( (contactInfo[0].Is_Non_Owner__c == false) && String.isNotBlank(contactInfo[0].Contact__r.Email) )
                        {                        
                            emailAddress = contactInfo[0].Contact__r.Email ;
                        }
                    
                    	if(String.isNotBlank(emailAddress))
                    	{
                       	 	System.debug('contactInfo[0].Is_Non_Owner__c' + contactInfo[0].Is_Non_Owner__c);
                            if( contactInfo[0].Is_Non_Owner__c == true ) 
                            {
                                subcriberKey = emailAddress;
                                triggeredCreateSendMessageId = 'Appointment_Confirmed_NonOwner';
                                triggeredEditSendMessageId   = 'Appointment_Rescheduled_NonOwner';
                                triggeredCancelSendMessageId = 'Appointment_Cancelled_NonOwner';
                            }
                        
                            if( Trigger.isInsert && sAPP.Action__c == 'Create') {              
                                
                                if( contactInfo[0].Is_Non_Owner__c == true ) {    
                                    System.debug('Calling sendEmailNonOwner ' + branch + ' ++ ' + sAPP.Branch__c);
                                    }
                                else {  
                                    //send_TriggeredEmail.sendEmail( variantName, branch, mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, Location, booking_ID, emailAddress, subcriberKey, triggeredCreateSendMessageId );                    
                                } 
                            }
                        
                            if( sAPP.Action__c == 'Edit' )
                            {              
                                if(branch != 'CCI' && contactInfo[0].Is_Non_Owner__c == true)
                                {
                                    string edmEdit = (String)JCC_GlobalVar.Edit_Service_MC_TriggerId__c;	
                                                                    
                                    if((String.isNotBlank(contactInfo[0].Non_Owner_Email__c) && (String.isNotBlank(((contactInfo[0].Contact__r.Email))))
                                        && contactInfo[0].Non_Owner_Email__c != contactInfo[0].Contact__r.Email))
                                    {
                                        System.debug('here is two call for edit guest booking');
                                        //send_TriggeredEmail.sendEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,contactInfo[0].Non_Owner_Email__c,subcriberKey,'Appointment_Rescheduled_NonOwner',contactInfo[0].Non_Owner_Name__c);
                                        //send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,contactInfo[0].Contact__r.Email,sAPP.Contact__c,edmEdit);   
                                    }
                                    else if ((String.isNotBlank(contactInfo[0].Non_Owner_Email__c) && (String.isNotBlank(((contactInfo[0].Contact__r.Email))))
                                              && contactInfo[0].Non_Owner_Email__c == contactInfo[0].Contact__r.Email))
                                    {   
                                        System.debug('here is one call for edit guest booking');                     
                                        //send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,contactInfo[0].Non_Owner_Email__c,sAPP.Contact__c,edmEdit);   
                                    }
                                    else
                                    {
                                        //send_TriggeredEmail.sendEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,contactInfo[0].Non_Owner_Email__c,subcriberKey,'Appointment_Rescheduled_NonOwner',contactInfo[0].Non_Owner_Name__c);	
                                    }
                                }
                                else if(contactInfo[0].Is_Non_Owner__c == True) 
                                {
                                    System.debug('branch check for send_triggeredEmail ++ ' + branch);
                                    //send_TriggeredEmail.sendEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredEditSendMessageId,contactInfo[0].Non_Owner_Name__c);
                                }
                                else 
                                {                
                                    //send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredEditSendMessageId);      
                                }
                            }   
                        
                            if(sAPP.Action__c == 'Cancel')
                            {              
                                if(branch != 'CCI' && contactInfo[0].Is_Non_Owner__c == true)
                                {				
                                    string edmCancel = (String)JCC_GlobalVar.Cancel_Service_MC_TriggerId__c;				
        
                                    if((String.isNotBlank(contactInfo[0].Non_Owner_Email__c) && (String.isNotBlank(((contactInfo[0].Contact__r.Email))))
                                        && contactInfo[0].Non_Owner_Email__c != contactInfo[0].Contact__r.Email))
                                    {
                                        //send_TriggeredEmail.sendEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,contactInfo[0].Non_Owner_Email__c,subcriberKey,triggeredCancelSendMessageId,contactInfo[0].Non_Owner_Name__c);
                                        //send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,contactInfo[0].Contact__r.Email,sAPP.Contact__c,edmCancel);   
                                    }
                                    else if ((String.isNotBlank(contactInfo[0].Non_Owner_Email__c) && (String.isNotBlank(((contactInfo[0].Contact__r.Email))))
                                              && contactInfo[0].Non_Owner_Email__c == contactInfo[0].Contact__r.Email))
                                    { 
                                        //send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,contactInfo[0].Non_Owner_Email__c,sAPP.Contact__c,edmCancel);   
                                    }
                                    else
                                    {                        
                                        
                                        //send_TriggeredEmail.sendEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,contactInfo[0].Non_Owner_Email__c,subcriberKey,triggeredCancelSendMessageId,contactInfo[0].Non_Owner_Name__c);
                                    }
                                }
                                else if(contactInfo[0].Is_Non_Owner__c == True) 
                                {
                                    //send_TriggeredEmail.sendEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredCancelSendMessageId,contactInfo[0].Non_Owner_Name__c);
                                }
                                else
                                {                 
                                    //send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredCancelSendMessageId);      
                                }
                            }   
                    	}             
                	}
                }
                //flag check ends
            }
            /******* Email  End********/
            /****Loop end****/ 
            catch(Exception e)
            {
                loggerDataPool.buildLogDataPool('ServiceApptTrigger',e);
            }
        }
        
    }
    //returns utc time 
    /*
    public DateTime getUTCDateTime(DateTime dt)
    {
        Datetime GMTDate = Datetime.newInstanceGmt(
        dt.year(),
        dt.month(),
        dt.day(),
        dt.hour(),
        dt.minute(),
        dt.second());
        return GMTDate;
    }
    */ 
}
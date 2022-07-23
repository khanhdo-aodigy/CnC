//Trigger to send sms on new service appointment 
trigger Trigger_Service_App_Booking_Conf_SMS_PUSH_EMAIL on Service_Appointment__c (after insert ,after update)
{
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
        String triggeredSmsId =  (String)JCC_GlobalVar.TriggeredsmsId__c;
        String subcriberKey ; 
        String emailAddress ; 
        String serviceType ;
        String formatedDate ;
        String mileage ;
        String branch ;
        String variantName ;
        String variantID ;
        String alternateEmailAddr ;
        String dateVal;
        String hourMinutes;
        DateTime convertedDate ;
        list <Service_Appointment__c> contactInfo  =  new list<Service_Appointment__c>(); 
        for(Service_Appointment__c sAPP : trigger.new)
        {
            try
            {
            //select email and phone from contact 
                contactInfo = [SELECT Contact__r.Email,Registered_Vehicle__r.Branch__c,Registered_Vehicle__r.Variant__r.Name,Contact__r.MobilePhone,Contact__r.Device__c,
                                      Non_Owner_Email__c,Non_Owner_Name__c,Non_Owner_Phone_Number__c,Is_Non_Owner__c,
                                      Account__c, Account__r.PersonMobilePhone, Account__r.Device__pc, Account__r.PersonContactId // PA - Phase 2
                                      from Service_Appointment__c where Id =: sAPP.Id];
                if (contactInfo != null  && contactInfo.size()>0)
                {
                    ContactPhone =  contactInfo[0].Contact__r.MobilePhone ; 

                    /**  PA - Phase 2 */
                    // if(contactInfo[0].Account__c != null)
                    // {
                    //     ContactPhone =  contactInfo[0].Account__r.PersonMobilePhone ; 
                    // }
                    // else
                    // {
                    //     ContactPhone =  contactInfo[0].Contact__r.MobilePhone ; 
                    // }
                    /** END */

                    if(sAPP.Service_Centre_Name__c != null)
                    {
                        ServiceCentreName =  sAPP.Service_Centre_Name__c + ',' ;
                    }
                    
                    if(sAPP.Service_Centre_Location__c != null)
                    {
                        Location =  sAPP.Service_Centre_Location__c ;
                    }
                    if(sAPP.Service_Appointment_Date_Time__c != null)
                    {
                        DateValue = sAPP.Service_Appointment_Date_Time__c;
                        //convertedDate =  getUTCDateTime(DateValue);
                        //for email
                        dateVal = DateValue.format('dd MMMMM yyyy,EEEEE');
                        hourMinutes = DateValue.format('hh:mm a');  
                        //for push and sms
                        formatedDate = STRING.valueof(DateValue.format('dd/MM/YY'));
                        formatedDate = formatedDate+' '+DateValue.format('hh:mm');
                        system.debug('Formate Date Time ====='+formatedDate);
                    }
                    if(sAPP.Car_Registration_No__c != null)
                    {
                        RegistrationNumber = sAPP.Car_Registration_No__c ;   
                    }
                    
                    if(contactInfo[0].Contact__r.Device__c  != null)
                    {
                        DeviceToKenValue =  contactInfo[0].Contact__r.Device__c ; 
                    }
                    /**  PA - Phase 2 */
                    // if(contactInfo[0].Account__r.Device__pc != null)
                    // {
                    //     DeviceToKenValue =  contactInfo[0].Account__r.Device__pc ; 
                    // }
                    // else if (contactInfo[0].Contact__r.Device__c != null)
                    // {
                    //     DeviceToKenValue =  contactInfo[0].Contact__r.Device__c ; 
                    // }
                    /** END */
                    booking_ID  =   sAPP.Booking_ID__c ;
                    if(sAPP.Registered_Vehicle__c  != null)
                    {
                        registered_Vehicle = sAPP.Registered_Vehicle__c;
                    }
                    
                    if(sAPP.Customer_Remarks__c  != null)
                    {
                        customerRemarks  = sAPP.Customer_Remarks__c ;
                    }

                    if(sAPP.Contact__c != null)
                    {
                        subcriberKey = sAPP.Contact__c ;
                    } 
                    // PA - Phase 2
                    // if(sAPP.Account__c != null)
                    // {
                    //     subcriberKey = sAPP.Account__c;
                    // }
                    // else if(sAPP.Contact__c != null)
                    // {
                    //     subcriberKey = sAPP.Contact__c ;
                    // } 
                    //
                    if(sAPP.Service_Code__c != null)
                    {
                        serviceType = sAPP.Service_Code__c ;
                    } 
                    
                    if(contactInfo[0].Registered_Vehicle__r.Branch__c != null)
                    {
                        branch = contactInfo[0].Registered_Vehicle__r.Branch__c ;
                    } 
                    
                    if(sAPP.Mileage__c != null)
                    {
                        mileage =  sAPP.Mileage__c ;
                    }                          
                    if( contactInfo[0].Registered_Vehicle__r.Variant__r.Name != null)
                    {
                        variantName =  contactInfo[0].Registered_Vehicle__r.Variant__r.Name ; 
                        variantName =  variantName.replace('\"',' \\"');
                    }  
                    
                    if(sAPP.Branch__c != null)
                    {
                        branch =  sAPP.Branch__c ;
                    } 
                }
         
                if(sAPP.Flag__c == False)
                {  
                    //for sending sms notification .          
                    if((contactInfo[0].Is_Non_Owner__c == True) && (contactInfo[0].Non_Owner_Email__c == null) && (contactInfo[0].Non_Owner_Phone_Number__c != null))
                    {
                        ContactPhone = contactInfo[0].Non_Owner_Phone_Number__c; 
                    }
                    else if((contactInfo[0].Is_Non_Owner__c == False) && (contactInfo[0].Contact__r.Email == null)  &&  (contactInfo[0].Contact__r.MobilePhone != null))
                    {
                        ContactPhone = contactInfo[0].Contact__r.MobilePhone;           
                    }
                    // PA - Phase 2
                    // else if((contactInfo[0].Is_Non_Owner__c == False) && (contactInfo[0].Account__r.personEmail == null)  &&  (contactInfo[0].Account__r.personMobilePhone != null))
                    // {
                    //     ContactPhone = contactInfo[0].Account__r.personMobilePhone; 
                    // }
                    //
                    System.debug('Contact Phone : ' + ContactPhone);
                
                    if((ContactPhone != null && contactInfo[0].Contact__r.Email == null && contactInfo[0].Is_Non_Owner__c != true) || (contactInfo[0].Is_Non_Owner__c == true && contactInfo[0].Non_Owner_Email__c == null))
                    {
                        System.debug('Sending SMS...........1');
                                
                        if(trigger.isInsert  && sAPP.Action__c == 'Create')
                        {
                            System.debug('Sending SMS...........2');  
                            SMS_Body='C&C: The service appt for your car '+RegistrationNumber+' on '+formatedDate+' at '+ ServiceCentreName + Location +' is confirmed. Thks & see you soon!'; 
                            if(contactInfo[0].Is_Non_Owner__c == True) 
                            {
                                System.debug('Sending SMS...........3');
                                send_APP_Confirmation_SMS.SENDAPPSMS(SMS_Body,ContactPhone,ContactPhone,triggeredSmsId);              
                            } 
                            else 
                            {
                                send_APP_Confirmation_SMS.SENDAPPSMS(SMS_Body,ContactPhone,STRING.valueOf(sAPP.Contact__c),triggeredSmsId);              
                            }
                        }
                                
                        if(trigger.isUpdate && sAPP.Action__c == 'Edit')
                        {       
                            SMS_Body = 'C&C: The service appt for your car '+RegistrationNumber+' has been rescheduled to '+formatedDate+' at '+ ServiceCentreName + Location +' is confirmed. Thks & see you soon!';                   
                            if(contactInfo[0].Is_Non_Owner__c == True) 
                            {
                                send_APP_Confirmation_SMS.SENDAPPSMS(SMS_Body,ContactPhone,ContactPhone,triggeredSmsId);
                            }
                            else
                            {
                                send_APP_Confirmation_SMS.SENDAPPSMS(SMS_Body,ContactPhone,STRING.valueOf(sAPP.Contact__c),triggeredSmsId);
                            }
                        }

                        if(trigger.isUpdate && sAPP.Action__c == 'Cancel')
                        {
                            SMS_Body = 'C&C: The service appt for your car '+RegistrationNumber+' on '+formatedDate+' at '+ ServiceCentreName + Location +' has been cancelled.';                   
                            if(contactInfo[0].Is_Non_Owner__c == True) 
                            {
                                send_APP_Confirmation_SMS.SENDAPPSMS(SMS_Body,ContactPhone,ContactPhone,triggeredSmsId);
                            }
                            else 
                            {
                                send_APP_Confirmation_SMS.SENDAPPSMS(SMS_Body,ContactPhone,STRING.valueOf(sAPP.Contact__c),triggeredSmsId);
                            }
                        }                                                
                    }
                    /******* SMS End********/
                 
                    //for sending push notification .
                    if((contactInfo[0].Contact__r.Email != null) || (contactInfo[0].Contact__r.MobilePhone == null && contactInfo[0].Contact__r.Email == null))
                    {      
                        if(Trigger.isInsert && sAPP.Action__c == 'Create')
                        {
                            PUSH_Body = 'The service appt for your car '+RegistrationNumber+' on '+ formatedDate + ' at '+ Location +' is confirmed. See you soon!';
                            send_PushMessage.SENDAPPPUSH(PUSH_Body,DeviceToKenValue,triggeredPushId);  
                            system.debug('Inside push message******');
                        }
                     
                        if(Trigger.isUpdate && sAPP.Action__c == 'Edit')
                        {
                            PUSH_Body = 'The service appt for your car '+RegistrationNumber +' has been rescheduled to '+ formatedDate + ' at '+ Location +' is confirmed. See you soon!';  
                            send_PushMessage.SENDAPPPUSH(PUSH_Body,DeviceToKenValue,triggeredPushId); 
                            system.debug('Inside push message edit ******');
                        }
                    
                        if(Trigger.isUpdate && sAPP.Action__c == 'Cancel')
                        {
                        PUSH_Body = 'The service appt for your car '+RegistrationNumber+ ' on ' + formatedDate + ' at '+ Location +' has been cancelled.';  
                        send_PushMessage.SENDAPPPUSH(PUSH_Body,DeviceToKenValue,triggeredPushId);   
                        }
                    }
                    /******* Push End********/
                    //for sending primary email via trigger
                
                    if((contactInfo[0].Is_Non_Owner__c == True) && (String.isNotBlank(contactInfo[0].Non_Owner_Email__c)))
                    {
                        emailAddress = contactInfo[0].Non_Owner_Email__c;
                    }  
                    else if((contactInfo[0].Is_Non_Owner__c == False) && (String.isNotBlank(((contactInfo[0].Contact__r.Email)))))
                    {        
                        emailAddress = contactInfo[0].Contact__r.Email ;
                    }
                    // PA - Phase 2
                    // else if((contactInfo[0].Is_Non_Owner__c == false) && String.isNotBlank(contactInfo[0].Account__r.PersonEmail))
                    // {                        
                    //     emailAddress = contactInfo[0].Account__r.PersonEmail ;
                    // }
                    //
                    if(String.isNotBlank(emailAddress))
                    {
                        System.debug('contactInfo[0].Is_Non_Owner__c' + contactInfo[0].Is_Non_Owner__c);
                        if(contactInfo[0].Is_Non_Owner__c == True) 
                        {
                            subcriberKey = emailAddress;
                            triggeredCreateSendMessageId = 'Appointment_Confirmed_NonOwner';
                            triggeredEditSendMessageId = 'Appointment_Rescheduled_NonOwner';
                            triggeredCancelSendMessageId = 'Appointment_Cancelled_NonOwner';
                        }
                        
                        if(Trigger.isInsert && sAPP.Action__c == 'Create')
                        {              
                    
                            if(contactInfo[0].Is_Non_Owner__c == True) 
                            {	
                                System.debug('Calling sendEmailNonOwner');
                                send_TriggeredEmail.sendEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredCreateSendMessageId,contactInfo[0].Non_Owner_Name__c);
                            }
                            else
                            {	
                                send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredCreateSendMessageId);                    
                            }  
                        }
                          
                        if(sAPP.Action__c == 'Edit')
                        {              
                            if(contactInfo[0].Is_Non_Owner__c == True) 
                            {
                                send_TriggeredEmail.sendEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredEditSendMessageId,contactInfo[0].Non_Owner_Name__c);

                            }else 
                            {				           
                                send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredEditSendMessageId);      
                            }
                        }   
                          
                        if(sAPP.Action__c == 'Cancel')
                        {              
                            if(contactInfo[0].Is_Non_Owner__c == True) 
                            {
				                send_TriggeredEmail.sendEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredCancelSendMessageId,contactInfo[0].Non_Owner_Name__c);
                            }
                            else
                            {				   
                                send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredCancelSendMessageId);      
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
                System.debug('Error'+e.getMessage());
            }
        }        
    }

    //returns utc time 
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
}
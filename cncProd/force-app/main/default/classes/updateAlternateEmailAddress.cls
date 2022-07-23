//Apex class to Update Alternate Email Address
@RestResource(urlMapping='/updatealternateemailaddress/v1/*')

global with sharing  class updateAlternateEmailAddress 
{
    @HttpPost
    //CallOut method for Expose API
    global static Map<String, String> updateAlerts(String bookingID, String emailAddress) 
    {   
        String errorMsg='';
        List<SObject>  returnObject = new List<SObject>();
        RestResponse res = RestContext.response;
        Map<String, String> responseMap = new Map<String, String>();
        Service_Appointment__c [] serviceAppointmentList ; 
        Service_Appointment__c  serviceAppointmentObj ;
        RestContext.response = res;
        String RegistrationNumber ;
        DateTime DateValue ;
        String booking_ID ; 
        String registered_Vehicle ;
        String customerRemarks ; 
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String triggeredCreateSendMessageId = (String)JCC_GlobalVar.Create_Service_MC_TriggerId__c;
        String triggeredEditSendMessageId = (String)JCC_GlobalVar.Edit_Service_MC_TriggerId__c;
        String triggeredCancelSendMessageId = (String)JCC_GlobalVar.Cancel_Service_MC_TriggerId__c;
        String subcriberKey ; 
        String serviceType ;
        String formatedDate ;
        String mileage ;
        String branch ;
        String variantName ;
        String variantID ;
        String alternateEmailAddr ;
        String Location ; 
        DateTime convertedDate; 
        String dateVal ;
        String hourMinutes ;
        
        if(bookingID !='' && emailAddress != '')
        {
            try 
            { 
                Long TimeStartObj = system.currentTimeMillis();
                
                serviceAppointmentList = [SELECT Id, Flag__c, Contact__c, Action__c, Service_Code__c, Mileage__c, Account__c,
											Service_Centre_Location__c, Service_Appointment_Date_Time__c, Car_Registration_No__c,
											Registered_Vehicle__c, Registered_Vehicle__r.Branch__c, Customer_Remarks__c,
											Registered_Vehicle__r.Variant__r.Name 
                                            FROM Service_Appointment__c 
                                            WHERE Booking_ID__c = : bookingID];  
											 
                if (serviceAppointmentList != null  && serviceAppointmentList.size()>0)
                {
                    if(serviceAppointmentList[0].Service_Code__c != null) {
                        serviceType = serviceAppointmentList[0].Service_Code__c;
                    }

                    if(serviceAppointmentList[0].Service_Centre_Location__c != null) {
                        Location = serviceAppointmentList[0].Service_Centre_Location__c ;
                    }
                    
                    if(serviceAppointmentList[0].Service_Appointment_Date_Time__c != null) {
                        DateValue = serviceAppointmentList[0].Service_Appointment_Date_Time__c;
                        //convertedDate =  getUTCDateTime(DateValue);
                        dateVal = DateValue.format('dd MMMMM yyyy,EEEEE');//convertedDate.format('dd MMMMM yyyy,EEEEE');
                        hourMinutes = DateValue.format('hh:mm a');  
                    }  

                    if(serviceAppointmentList[0].Car_Registration_No__c != null) {
                        RegistrationNumber = serviceAppointmentList[0].Car_Registration_No__c ;   
                    }

                    if(serviceAppointmentList[0].Registered_Vehicle__c != null) {
                        registered_Vehicle = serviceAppointmentList[0].Registered_Vehicle__c ;   
                    }
                    
                    if(serviceAppointmentList[0].Customer_Remarks__c != null) {
                        customerRemarks = serviceAppointmentList[0].Customer_Remarks__c ;   
                    }

                    if(serviceAppointmentList[0].Mileage__c != null) {
                        mileage = serviceAppointmentList[0].Mileage__c;   
                    }
                    
                    if( serviceAppointmentList[0].Registered_Vehicle__r.Variant__r.Name != null) {
                        variantName =  serviceAppointmentList[0].Registered_Vehicle__r.Variant__r.Name;
                        variantName =  variantName.replace('\"',' \\"');
                    }   
                    
                    if( serviceAppointmentList[0].Registered_Vehicle__r.Branch__c != null) {
                        branch =  serviceAppointmentList[0].Registered_Vehicle__r.Branch__c;
                    }   
                    
                    subcriberKey = serviceAppointmentList[0].Contact__c;

					//PA MIGRATION
					if(serviceAppointmentList[0].Account__c != null) {
						subcriberKey = serviceAppointmentList[0].Account__c;
					}
					//PA MIGRATION

                    booking_ID = bookingID;

                    try
                    { 
                        serviceAppointmentObj =  serviceAppointmentList[0]; 
                        serviceAppointmentObj.Alternate_Email_Address__c = emailAddress ;
                        serviceAppointmentObj.Flag__c =  True ;
						serviceAppointmentObj.System_don_t_fire_MC__c = true;
                        
                        update serviceAppointmentObj;
                        system.debug(LoggingLevel.INFO,'Time in MS for Select & Update serviceAppointmentObj: '+String.ValueOf(system.currentTimeMillis()-TimeStartObj));
                        
                        if(serviceAppointmentList[0].Action__c == 'Create')
                        {  
                            TimeStartObj = system.currentTimeMillis();
                            //send_TriggeredEmail.sendEmail( variantName, branch, mileage, serviceType, RegistrationNumber, 
                            //                                    customerRemarks, registered_Vehicle, dateVal, hourMinutes, Location, 
                            //                                        booking_ID, emailAddress, subcriberKey, triggeredCreateSendMessageId );                    
                            system.debug(LoggingLevel.INFO,'Time in MS for Create TriggeredEmail: '+String.ValueOf(system.currentTimeMillis()-TimeStartObj));
                        }   
                        
                        if(serviceAppointmentList[0].Action__c == 'Edit')
                        {     
                            TimeStartObj = system.currentTimeMillis();
                            //send_TriggeredEmail.sendEmail( variantName, branch, mileage, serviceType, RegistrationNumber, 
                            //                                    customerRemarks, registered_Vehicle, dateVal, hourMinutes, Location, 
                            //                                        booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId );      
                            system.debug(LoggingLevel.INFO,'Time in MS for Edit TriggeredEmail: '+String.ValueOf(system.currentTimeMillis()-TimeStartObj));
                        }   
                        
                        if(serviceAppointmentList[0].Action__c == 'Cancel')
                        {   
                            TimeStartObj = system.currentTimeMillis();
                            //send_TriggeredEmail.sendEmail( variantName, branch, mileage, serviceType, RegistrationNumber, 
                            //                                    customerRemarks, registered_Vehicle, dateVal, hourMinutes, Location, 
                            //                                        booking_ID, emailAddress, subcriberKey, triggeredCancelSendMessageId );      
                            system.debug(LoggingLevel.INFO,'Time in MS for Cancel TriggeredEmail: '+String.ValueOf(system.currentTimeMillis()-TimeStartObj));
                        }     
                                                
                        res.statusCode = 200;
                        responseMap.put('Status', 'Success');
                    }
                    catch (DmlException e)
                    {
                        errorMsg = 'A system exception has occurred, Please contact your administrator.';
                        res.statusCode = 400;
                        responseMap.put('ErrorCode', 'Err04-SF');
                        responseMap.put('Message', errorMsg); 
                        responseMap.put('Status', errorMsg);
                    }  
                }
                else
                {
                    errorMsg ='No record found against booking id';
                    res.statusCode = 400;
                    responseMap.put('ErrorCode', 'Err03-SF');
                    responseMap.put('Message', errorMsg); 
                    responseMap.put('Status', errorMsg);   
                }
            }
            catch(DmlException e)
            {
                errorMsg ='A system exception has occurred, Please contact your administrator.';
                responseMap.put('ErrorCode', 'Err04-SF');
                responseMap.put('Message', errorMsg);  
                responseMap.put('Status', errorMsg);
                res.statusCode = 400;   
            }
        }
        else if(bookingID =='' && emailAddress == '')
        {
            errorMsg = 'bookingID  and emailAddress is blank';
            responseMap.put('Status',errorMsg);
            res.statusCode=400;
            responseMap.put('ErrorCode', 'Err02-SF');
            responseMap.put('Message', errorMsg);  
            
        }
        else if (bookingID !='' && emailAddress == '')
        {
            errorMsg = 'emailAddress is blank';
            responseMap.put('Status',errorMsg );
            res.statusCode=400;
            responseMap.put('ErrorCode', 'Err02-SF');
            responseMap.put('Message', errorMsg);  
            responseMap.put('Status', errorMsg);
        }
        else
        {
            errorMsg =  'bookingID is blank';
            responseMap.put('Status',errorMsg );
            res.statusCode=400;
            responseMap.put('ErrorCode', 'Err02-SF');
            responseMap.put('Message', errorMsg); 
        }   
        
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));           
        return responseMap;
    }
    //returns utc time 
	/*
    public static DateTime getUTCDateTime(DateTime dt)
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
@IsTest
global class Test_send_TriggeredEmail implements HttpCalloutMock 
{
     global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        //res.setStatusCode(200);
        return res;
   }

      static testMethod void testPositiveGetMethod() 
    {
		HTTPResponse res1;
		send_TriggeredEmail.res =res1;
		send_TriggeredEmail.resBody = '';
     
       Test.setMock(HttpCalloutMock.class, new Test_send_TriggeredEmail());
         RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
         request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        String variantName ;
        String branch ;
        String serviceType ;
        String RegistrationNumber;
        String customerRemarks ;
        String registered_Vehicle ;
        DateTime DateValue ;
        String hourMinutes ;
        String booking_ID ;
        String emailAddress ;
        String subcriberKey ;
        String Location ; 
        DateTime convertedDate; 
        Service_Appointment__c [] serviceAppointmentList ; 
        Service_Appointment__c  serviceAppointmentObj ;
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String triggeredCreateSendMessageId = (String)JCC_GlobalVar.Create_Service_MC_TriggerId__c;
        String triggeredEditSendMessageId = (String)JCC_GlobalVar.Edit_Service_MC_TriggerId__c;
        String triggeredCancelSendMessageId = (String)JCC_GlobalVar.Cancel_Service_MC_TriggerId__c;

        serviceAppointmentList = [SELECT Contact__r.Email,Booking_ID__c,Id,Contact__c,Action__c,Service_Code__c,Mileage__c,Service_Centre_Location__c,Service_Appointment_Date_Time__c,Car_Registration_No__c,Registered_Vehicle__c,Registered_Vehicle__r.Branch__c,Registered_Vehicle__r.Variant__r.Name FROM Service_Appointment__c WHERE Id = : 'a10O0000004VNJd'];   
                       ///if (serviceAppointmentList != null  && serviceAppointmentList.size()>0)
                           // {
                               serviceType = 'ABC';//serviceAppointmentList[0].Service_Code__c;
                               Location = 'ABC';//serviceAppointmentList[0].Service_Centre_Location__c ;
                               DateValue = Date.today();//serviceAppointmentList[0].Service_Appointment_Date_Time__c;
                               convertedDate =  getUTCDateTime(DateValue);
                               String  dateVal = convertedDate.format('dd MMMMM yyyy,EEEEE');
                                hourMinutes = DateValue.format('hh:mm a');  
                               convertedDate =  getUTCDateTime(DateValue);
                               RegistrationNumber = 'ABC';// serviceAppointmentList[0].Car_Registration_No__c ; 	
                               registered_Vehicle = null;// serviceAppointmentList[0].Registered_Vehicle__c;                               
                              String  mileage =  'ABC';//serviceAppointmentList[0].Mileage__c ;
                                variantName =  'ABC';//serviceAppointmentList[0].Registered_Vehicle__r.Variant__r.Name;
                               variantName =  variantName.replace('\"',' \\"');
                               branch = 'CCK';//serviceAppointmentList[0].Registered_Vehicle__r.Branch__c;
                               subcriberKey = 'ABC';//serviceAppointmentList[0].Contact__c;
                            booking_ID = 'ABC';//serviceAppointmentList[0].Booking_ID__c;
                             emailAddress =  'ABC@ABC.com';//serviceAppointmentList[0].Contact__r.Email;
        send_TriggeredEmail.sendEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registered_Vehicle,dateVal,hourMinutes,Location,booking_ID,emailAddress,subcriberKey,triggeredEditSendMessageId);                        
         send_TriggeredEmail.sendEmailNonOwner( variantName, branch, mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, 'ABC');
		 send_TriggeredEmail.SendHttpEmailNonOwner( variantName, branch, mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, '', 'ABC');
		 send_TriggeredEmail.SendHttpEmailNonOwner( variantName, 'CCA', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, '', 'ABC');
		 send_TriggeredEmail.SendHttpEmailNonOwner( variantName, 'CCI', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, '', 'ABC');
		 send_TriggeredEmail.SendHttpEmailNonOwner( variantName, 'CCF', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, '', 'ABC');
		 send_TriggeredEmail.SendHttpEmailNonOwner( 'DS', 'CCF', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, '', 'ABC');
		 send_TriggeredEmail.SendHttpEmailNonOwner( variantName, 'CCF1', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, '', 'ABC');

		 send_TriggeredEmail.SendHttpEmail( variantName, branch, mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, 'ABC');
		 send_TriggeredEmail.SendHttpEmail( variantName, 'CCA', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, 'ABC');
		 send_TriggeredEmail.SendHttpEmail( variantName, 'CCI', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, 'ABC');
		 send_TriggeredEmail.SendHttpEmail( variantName, 'CCF', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, 'ABC');
		 send_TriggeredEmail.SendHttpEmail( 'DS', 'CCF', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, 'ABC');
		 send_TriggeredEmail.SendHttpEmail( 'DS1', 'CCF1', mileage, serviceType, RegistrationNumber, customerRemarks, registered_Vehicle, dateVal, hourMinutes, location, booking_ID, emailAddress, subcriberKey, triggeredEditSendMessageId, 'ABC');
		          //system.assert(response.statusCode == 200);        
                            //}
                        
  
    }
      //returns utc time 
    public static DateTime getUTCDateTime(DateTime dt){
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
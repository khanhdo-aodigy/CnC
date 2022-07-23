public  with sharing class send_TriggeredEmail
{
public static HTTPResponse res{get; set;}
public static String resBody{get; set;}

@future (callout=true)
public static void sendEmail(String variantName,String branch,String mileage,String serviceType,String RegistrationNumber,String customerRemarks,String registeredVehicle,String dateValue,String hourMinutes,String location,String bookingID,String emailAddress,String subcriberKey,String triggeredSendMessageId)
{  
    String tokenValue = '';
    If(Test.isRunningTest()==False)
    {
        tokenValue = GenerateRequestToken.getRequestToken();
        If(tokenValue!=''){
            SendHttpEmail(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registeredVehicle,dateValue,hourMinutes,location,bookingID,emailAddress,subcriberKey,triggeredSendMessageId, tokenValue);}
    }    
} 

@future (callout=true)
public static void sendEmailNonOwner(String variantName,String branch,String mileage,String serviceType,String RegistrationNumber,String customerRemarks,String registeredVehicle,String dateValue,String hourMinutes,String location,String bookingID,String emailAddress,String subcriberKey,String triggeredSendMessageId, String name)
{  
    String tokenValue = '';
    If(Test.isRunningTest()==False){
        tokenValue = GenerateRequestToken.getRequestToken();
        If(tokenValue!=''){
            SendHttpEmailNonOwner(variantName,branch,mileage,serviceType,RegistrationNumber,customerRemarks,registeredVehicle,dateValue,hourMinutes,location,bookingID,emailAddress,subcriberKey,triggeredSendMessageId, tokenValue, name);}
    }    
} 
   

public static void SendHttpEmail(String variantName,String branch,String mileage,String serviceType,String RegistrationNumber,String customerRemarks,String registeredVehicle,String dateValue,String hourMinutes,String location,String bookingID,String emailAddress,String subcriberKey,String triggeredSendMessageId, String tokenValue)
{
    if((String.isNotBlank(emailAddress)))
    {  
        try
        {
            HttpRequest reqPrimaryEmail = new HttpRequest();
            reqPrimaryEmail.setMethod('POST');                                    
            //Seting HttpRequest Method
            reqPrimaryEmail.setHeader('content-type', 'application/json;charset=utf-8');    
            reqPrimaryEmail.setHeader('Authorization', 'Bearer '+tokenValue);
            reqPrimaryEmail.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+triggeredSendMessageId+'/send');
            If (branch=='CCK')
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.kia.sg@e.cyclecarriage.com","Name": "C&C Kia Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else If(branch=='CCA')
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.mitsubishi.sg@e.cyclecarriage.com","Name": "C&C Mitsubishi Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else If(branch=='CCF' && String.isNotBlank(variantName) && variantName.StartsWith('DS'))
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.ds.sg@e.cyclecarriage.com","Name": "C&C DS Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else If(branch=='CCF')
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.citroen.sg@e.cyclecarriage.com","Name": "C&C Citroen Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else If(branch=='CCI')
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.mercedes-benz.sg@e.cyclecarriage.com","Name": "C&C Mercedes-Benz Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Http http1 = new Http(); 
            If(Test.isRunningTest()==False){
                HTTPResponse res1 = http1.send(reqPrimaryEmail); 
                resBody=res1.getBody();       }
        }
        catch(System.CalloutException e)       
        {
            //Exception handling goes here..
            resBody=e.getMessage();
        }
    }
}

public static void SendHttpEmailNonOwner(String variantName,String branch,String mileage,String serviceType,String RegistrationNumber,String customerRemarks,String registeredVehicle,String dateValue,String hourMinutes,String location,String bookingID,String emailAddress,String subcriberKey,String triggeredSendMessageId, String tokenValue, String name)
{
    if((String.isNotBlank(emailAddress)))
    {  
        try
        {
            HttpRequest reqPrimaryEmail = new HttpRequest();
            reqPrimaryEmail.setMethod('POST');                                    
            //Seting HttpRequest Method
            reqPrimaryEmail.setHeader('content-type', 'application/json;charset=utf-8');    
            reqPrimaryEmail.setHeader('Authorization', 'Bearer '+tokenValue);
            reqPrimaryEmail.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+triggeredSendMessageId+'/send');
            If (branch=='CCK')
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.kia.sg@e.cyclecarriage.com","Name": "C&C Kia Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'","Name":"'+name+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else If(branch=='CCA')
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.mitsubishi.sg@e.cyclecarriage.com","Name": "C&C Mitsubishi Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'","Name":"'+name+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else If(branch=='CCF' && String.isNotBlank(variantName) && variantName.StartsWith('DS'))
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.ds.sg@e.cyclecarriage.com","Name": "C&C DS Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'","Name":"'+name+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }            
            Else If(branch=='CCF')
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.citroen.sg@e.cyclecarriage.com","Name": "C&C Citroen Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'","Name":"'+name+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else If(branch=='CCI')
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "service.mercedes-benz.sg@e.cyclecarriage.com","Name": "C&C Mercedes-Benz Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","Branch":"'+branch+'","VariantModelName":"'+variantName+'","Name":"'+name+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else {
            reqPrimaryEmail.setBody('{ "From": {"Address": "service.mercedes-benz.sg@e.cyclecarriage.com","Name": "C&C Mercedes-Benz Service"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"Booking_ID__c": "'+bookingID+'","Service_Centre_Location__c" : "'+location+'","Service_Appointment_Date_Time__c" : "'+dateValue+'","Time":"'+hourMinutes+'","Car_Registration_No__c": "'+RegistrationNumber+'","Customer_Remarks__c": "'+customerRemarks+'","Contact_Id": "'+subcriberKey+'","Registered_Vehicle__Id" : "'+registeredVehicle+'","Service_Type": "'+serviceType+'","Mileage" :"'+mileage+'","VariantModelName":"'+variantName+'","Name":"'+name+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Http http1 = new Http(); 
            If(Test.isRunningTest()==False){
                HTTPResponse res1 = http1.send(reqPrimaryEmail); 
                resBody=res1.getBody();       }
        }
        catch(System.CalloutException e)       
        {
            //Exception handling goes here..
            resBody=e.getMessage();
        }
    }
}
            
}
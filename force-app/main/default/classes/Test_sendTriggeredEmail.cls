@isTest(SeeAllData=true)
public class Test_sendTriggeredEmail  
{ 
    public static testmethod void Test_sendEmail() 
    {      
        Test.startTest();
        send_TriggeredEmail.sendEmail('variantName','branch','mileage','serviceType','RegistrationNumber','customerRemarks','registeredVehicle','dateValue','hourMinutes','location','bookingID','emailAddress','subcriberKey','triggeredSendMessageId');
    	Test.stopTest();
        httpResponse resTest;
        send_TriggeredEmail.res = resTest;
        send_TriggeredEmail.resBody = '';        
    }
    
    public static testmethod void Test_sendHttpEmail() 
    {      
        Test.startTest();
        send_TriggeredEmail.SendHttpEmail('variantName','CCA','mileage','serviceType','RegistrationNumber','customerRemarks','registeredVehicle','dateValue','hourMinutes','location','bookingID','emailAddress','subcriberKey','triggeredSendMessageId','val');
        send_TriggeredEmail.SendHttpEmail('variantName','CCI','mileage','serviceType','RegistrationNumber','customerRemarks','registeredVehicle','dateValue','hourMinutes','location','bookingID','emailAddress','subcriberKey','triggeredSendMessageId','val');
        send_TriggeredEmail.SendHttpEmail('variantName','CCF','mileage','serviceType','RegistrationNumber','customerRemarks','registeredVehicle','dateValue','hourMinutes','location','bookingID','emailAddress','subcriberKey','triggeredSendMessageId','val');
        send_TriggeredEmail.SendHttpEmail('variantName','CCK','mileage','serviceType','RegistrationNumber','customerRemarks','registeredVehicle','dateValue','hourMinutes','location','bookingID','emailAddress','subcriberKey','triggeredSendMessageId','val');
    	Test.stopTest();
    }
}
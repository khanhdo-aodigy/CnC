public class TestDriveAckSendEmail 
{
    
public static HTTPResponse res{get; set;}
public static String resBody{get; set;}
    
@future (callout=true)
public static void sendEmail(String TestDriveID,String ModelID,String VariantID,String Branch_Code,String Booking_Time,Datetime  DateValue,String ShowroomID,String emailAddress,String triggeredSendMessageId,String ContactName)
{  
    String tokenValue = '';
    //If(Test.isRunningTest()==False){
        tokenValue = GenerateRequestToken.getRequestToken();
        If(tokenValue!='') SendHttpEmail(TestDriveID, ModelID, VariantID, Branch_Code,Booking_Time,DateValue, ShowroomID,emailAddress,triggeredSendMessageId,ContactName,tokenValue);
    //}    
}    

public static void SendHttpEmail(String TestDriveID,String ModelID,String  VariantID,String  Branch_Code,String Booking_Time,Datetime DateValue,String  ShowroomID,String emailAddress,String triggeredSendMessageId,String ContactName,String tokenValue)
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
            System.debug('id---'+'https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+triggeredSendMessageId+'/send');
            If (Branch_Code=='CCK')
            {
                reqPrimaryEmail.setBody('{ "From": {"Address": "sales.kia.sg@e.cyclecarriage.com","Name": "C&C Kia Showroom"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"TestDriveID": "'+TestDriveID+'","ModelID" : "'+ModelID+'","VariantID" : "'+VariantID+'","Branch_Code":"'+Branch_Code+'","Booking_Time": "'+Booking_Time+'","DateValue": "'+DateValue+'","ShowroomID": "'+ShowroomID+'","ContactName": "'+ContactName+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else If(Branch_Code=='CCA')
            {
               
                
                 //reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mitsubishi.sg@e.cyclecarriage.com","Name": "C&C Mitsubishi Showroom"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"TestDriveID": "'+TestDriveID+'","ModelID" : "'+ModelID+'","VariantID" : "'+VariantID+'","Branch_Code":"'+Branch_Code+'","Booking_Time": "'+Booking_Time+'","DateValue": "'+DateValue+'","ShowroomID": "'+ShowroomID+'","ContactName": "'+ContactName+'"}}},"Options": {"RequestType": "ASYNC"}}');
                 reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mitsubishi.sg@e.cyclecarriage.com","Name": "C&C Mitsubishi Sales"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"TestDriveID": "'+TestDriveID+'","ModelID" : "'+ModelID+'","VariantID" : "'+VariantID+'","Branch_Code":"'+Branch_Code+'","Booking_Time": "'+Booking_Time+'","DateValue": "'+DateValue+'","ShowroomID": "'+ShowroomID+'","ContactName": "'+ContactName+'"}}},"Options": {"RequestType": "ASYNC"}}');
            }
            Else If(Branch_Code=='CCF')
            {

                reqPrimaryEmail.setBody('{ "From": {"Address": "sales.citroen.sg@e.cyclecarriage.com","Name": "C&C Citroen Showroom"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"TestDriveID": "'+TestDriveID+'","ModelID" : "'+ModelID+'","VariantID" : "'+VariantID+'","Branch_Code":"'+Branch_Code+'","Booking_Time": "'+Booking_Time+'","DateValue": "'+DateValue+'","ShowroomID": "'+ShowroomID+'","ContactName": "'+ContactName+'"}}},"Options": {"RequestType": "ASYNC"}}');

				if(String.isNotEmpty(ModelID) && ModelID != 'ModelID')
				{
					Model__c md = [select name from Model__c where id =: ModelID limit 1];
					if(md.name.contains('DS'))
					{
						reqPrimaryEmail.setBody('{ "From": {"Address": "sales.DS.sg@e.cyclecarriage.com","Name": "C&C DS Sales"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"TestDriveID": "'+TestDriveID+'","ModelID" : "'+ModelID+'","VariantID" : "'+VariantID+'","Branch_Code":"'+Branch_Code+'","Booking_Time": "'+Booking_Time+'","DateValue": "'+DateValue+'","ShowroomID": "'+ShowroomID+'","ContactName": "'+ContactName+'"}}},"Options": {"RequestType": "ASYNC"}}');
					}
				}

            }
            Else If(Branch_Code=='CCI')
            {
                
                     reqPrimaryEmail.setBody('{ "From": {"Address": "sales.mercedes-benz.sg@e.cyclecarriage.com","Name": "C&C Mercedes Showroom"},"To":{"Address": "'+emailAddress+'","SubscriberKey": "'+emailAddress+'","ContactAttributes": {"SubscriberAttributes":{"TestDriveID": "'+TestDriveID+'","ModelID" : "'+ModelID+'","VariantID" : "'+VariantID+'","Branch_Code":"'+Branch_Code+'","Booking_Time": "'+Booking_Time+'","DateValue": "'+DateValue+'","ShowroomID": "'+ShowroomID+'","ContactName": "'+ContactName+'"}}},"Options": {"RequestType": "ASYNC"}}');
                
                
            } 
            Http http1 = new Http(); 
            System.debug('body==='+reqPrimaryEmail.getBody());
            If(Test.isRunningTest()==False){
                HTTPResponse res1 = http1.send(reqPrimaryEmail); 
                resBody=res1.getBody();      
                //system.debug('Body=========='+res1.getBody());
            }
        }
        catch(System.CalloutException e)       
        {
            //Exception handling goes here..
            resBody=e.getMessage();
        }
    }
}
}
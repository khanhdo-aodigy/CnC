@RestResource(urlMapping='/UpdateDeviceTokenMB/v1/*')
global with sharing class UpdateDeviceTokenMB 
{
    @HttpPost
    global static void UpdateDeviceTokenMB(String nric, String deviceId) 
    {
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        Contact[] contactList;
		Contact contact;
		
        Boolean isSuccess = false;
        String errorCode;
        String errorMsg;
        String jsonS;
        Map<String, String> responseMap = new Map<String, String>();
		System.debug('+++ '+ nric);
		JSONGenerator gen = JSON.createGenerator(true);
		if(nric != null && nric.trim() != '')
		{
		   try
		   {
				Long timeStartObj = System.currentTimeMillis();
    			contactList = [SELECT Id FROM Contact WHERE id = :nric];
				
				if (contactList != null && contactList.size() > 0)
				{
					contact = contactList[0];
					contact.Device__c = deviceId;
					update contact;
					isSuccess = true;
					res.statusCode = 200;
					responseMap.put('Status', 'Success');
				}
				else
				{
					errorMsg ='Invalid ContactId';
					res.statusCode = 400;
					responseMap.put('ErrorCode', 'Err03-SF');
					responseMap.put('Message', errorMsg);  
				}
				System.debug(LoggingLevel.INFO,'Time in MS for Select & Update contact statement: '+String.ValueOf(System.currentTimeMillis()-timeStartObj));
            
			}
			catch (DmlException e)
			{
				errorMsg = 'Something went wrong. Please try again.';
				res.statusCode = 400;
				responseMap.put('ErrorCode', 'Err03-SF');
				responseMap.put('Message', errorMsg);     
			}  
		}
		else
		{
			errorMsg = 'Required fields not supplied.';
			res.statusCode = 400;
			responseMap.put('ErrorCode', 'Err02-SF');
			responseMap.put('Message', errorMsg);  
		}   
        
		RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        
	}
}
@RestResource(urlMapping='/UpdateDeviceToken/v1/*')
global with sharing class UpdateDeviceToken 
{
    @HttpPost
    global static void UpdateDeviceToken(String nric, String deviceId) 
    {
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        Contact[] contactList;
		Contact contact;
		
        Boolean isSuccess = false;
        String errorCode;
        String errormsg;
        String jsonS;
        Map<String, String> responseMap = new Map<String, String>();
     
		JSONGenerator gen = JSON.createGenerator(true);
		if(nric != null && nric.trim() != '')
		{		
			try
			{ 
    			Long TimeStartObj = System.currentTimeMillis();
    			contactList = [SELECT Id FROM Contact WHERE id = :nric]; 

				if (contactList != null && contactList.size()>0)
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
					errormsg ='Invalid ContactId';
					res.statusCode = 400;
					responseMap.put('ErrorCode', 'Err03-SF');
					responseMap.put('Message', errormsg);       
				}
				System.debug(LoggingLevel.INFO,'Time in MS for Select & Update contact statement: '+String.ValueOf(System.currentTimeMillis()-TimeStartObj));
            
			}
			catch (DmlException e)
			{ 
			   errormsg = 'Something went wrong. Please try again.';
			   res.statusCode = 400;
			   responseMap.put('ErrorCode', 'Err03-SF');
			   responseMap.put('Message', errormsg);   
			   System.debug('++errormsg ' + errormsg);  
			}  
		}
		else
		{
			errormsg = 'Required fields not supplied.';
			res.statusCode = 400;
			responseMap.put('ErrorCode', 'Err02-SF');
			responseMap.put('Message', errormsg);  
		}   
        
		RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
	}
}
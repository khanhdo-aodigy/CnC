public class GetServiceBookingDetails {   
	          
    public static String calloutToExternal(String vBookingIDParam, String vFranchiseCode){    
       
        String sVar;
        String responseToReturn = '';
        HttpRequest req = new HttpRequest();
        HttpResponse resInput = new HttpResponse();
        Http http = new Http();
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String cbsAPIurl = (String)JCC_GlobalVar.APIGateway_url__c;
        String cbsAPIKey = (String)JCC_GlobalVar.APIGateway_key__c;   
        
        system.debug(cbsAPIurl);
        system.debug(cbsAPIKey);
        req.setHeader('host', 'api.cyclecarriage.com'); 
        req.setHeader('Content-Type', 'application/json');
        
        if(Test.isRunningTest()){
               req.setHeader('apikey', 'H10JaPE54rGCPzpRFM016pybQvbGk5gOLRkYW15aFaQ14TbF94n5baYBX');
        }
        else{
            req.setHeader('apikey', cbsAPIKey);
        }
        
        string v = '{"bookingId":'+ vBookingIDParam +',"franchiseCode":"'+ vFranchiseCode +'"}';
        system.debug('body..' + v);
        
        req.setBody('{"bookingId":'+ vBookingIDParam +',"franchiseCode":"'+ vFranchiseCode +'"}');
      
        string ep = cbsAPIurl+'/CBSServices/CBS_GetBooking';
    
        system.debug(ep);
        req.setEndpoint(ep);
        req.setTimeout(12000);  
        req.setMethod('POST');
        
        try 
        {   
            //Send http request, capture response and pass the response to mothod       
            resInput = http.send(req); 
           serviceDataPool.buildServiceDataPoolHttp('calloutToExternal', 'GetServiceBookingDetails', '', req, resInput);
        }
        
        catch(exception ex1)
        {
            system.debug(ex1.getMessage());
            loggerDataPool.buildLogDataPool('GetServiceBookingDetails', ex1);
        }
        
        if(resInput.getBody()!=NULL && resInput.getBody().trim()!='')
        {
            system.debug('Response....' + resInput.getBody());
            sVar = resinput.getBody();
            system.debug('value after json2apex:----' + sVar);

            
             // Get Car ID   
           		responseToReturn += '<1>'; 
				responseToReturn += parseJsonResponse('carId', sVar);   
                responseToReturn += '<2>';
            
            // Get time
            	responseToReturn += '<3>';
				responseToReturn += parseJsonResponse('time', sVar); 
                responseToReturn += '<4>';
            
          	// Get pickUpAddress
                responseToReturn += '<5>';
				responseToReturn += parseJsonResponse('pickUpAddress', sVar);  
                responseToReturn += '<6>';
        
			// Get ReturnAddress
				responseToReturn += '<7>';
				responseToReturn += parseJsonResponse('returnAddress', sVar);  
                responseToReturn += '<8>';
            
            // Get ReturnPostalCode
				responseToReturn += '<9>';
				responseToReturn += parseJsonResponse('returnPostalCode', sVar);  
                responseToReturn += '<10>';
            
            // Get pickUpPostalCode
				responseToReturn += '<11>';
				responseToReturn += parseJsonResponse('pickUpPostalCode', sVar);  
                responseToReturn += '<12>';
            
            // Get Name
            	responseToReturn += '<13>';
				responseToReturn += parseJsonResponse('name', sVar);  
                responseToReturn += '<14>';
            
            // Get Remarks
            	responseToReturn += '<15>';
				responseToReturn += parseJsonResponse('remarks', sVar);  
                responseToReturn += '<16>';
            
             // Get Mobile
            	responseToReturn += '<17>';
				responseToReturn += parseJsonResponse('mobileNo', sVar);  
                responseToReturn += '<18>';
            
            // Get Email
            	responseToReturn += '<19>';
				responseToReturn += parseJsonResponse('email', sVar);  
                responseToReturn += '<20>';
            
            // Get Service Center Code  
                responseToReturn += '<21>';
				responseToReturn += parseJsonResponse('serviceCenterCode', sVar);    
                responseToReturn += '<22>';
            
            // Get Current Mileage    
                responseToReturn += '<23>';
				responseToReturn += parseJsonResponse('currentMileage', sVar);    
                responseToReturn += '<24>';
            
           // Get Service Code    
                responseToReturn += '<25>';
				responseToReturn += parseJsonResponse('serviceCode', sVar);    
                responseToReturn += '<26>';
            
            // Get Service Type   
                responseToReturn += '<27>';
				responseToReturn += parseJsonResponse('serviceType', sVar);    
                responseToReturn += '<28>';
            
            // Get Service Name  
                responseToReturn += '<29>';
				responseToReturn += parseJsonResponse('serviceName', sVar);    
                responseToReturn += '<30>';
            
            // Get Service Center Name  
                responseToReturn += '<31>';
				responseToReturn += parseJsonResponse('serviceCenterName', sVar);    
                responseToReturn += '<32>';
        }     

		return responseToReturn;
      
        
    }
    
    private static String parseJsonResponse(String searchKey, String responseBody) {
        System.JSONParser parser = JSON.createParser(responseBody);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == searchKey)) {
                    parser.nextToken();
                    return parser.getText();
                }
        }
        return null;
    }              
    
}
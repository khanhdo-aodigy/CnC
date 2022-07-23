public class UpdateCBSRemarks {   
	          
    public static String UpdBookingRemarks(String vBookingID, String vFranchiseCode, String vComments, String vCSERemarks){    
       
        String sVar;
        String responseToReturn = '';
        HttpRequest req = new HttpRequest();
        HttpResponse resInput = new HttpResponse();
        Http http = new Http();
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String cbsAPIurl = (String)JCC_GlobalVar.APIGateway_url__c;
        String cbsAPIKey = (String)JCC_GlobalVar.APIGateway_key__c;   
        
        if(Test.isRunningTest()){
            req.setHeader('host', 'api.stg.cyclecarriage.com');   
            req.setHeader('apikey', '9-bMiOlUatsidmlzYSIsIm1hc3RlcmNhcmQiXX1H10JaPE54rGCPzpRFM016pybQvbGk5gOLRkYW15aFaQ14TbF94n5baYBX');
        }else{
            req.setHeader('host', 'api.cyclecarriage.com'); 
            req.setHeader('apikey', cbsAPIKey);     	
        }
        
        string v =  '{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments+'","remarkCse":"'+vCSERemarks+'"}';
        req.setBody('{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments+'","remarkCse":"'+vCSERemarks+'"}');
      
        system.debug('req body-->' + v);
        
        string ep = cbsAPIurl+'/CBSServices/CBS_AdminUpdateBookingComment';
    
        system.debug(ep);
        req.setEndpoint(ep);
        req.setTimeout(12000);  
        req.setMethod('POST');
        
        try 
        {   
            //Send http request, capture response and pass the response to mothod       
        	resInput = http.send(req); 
            system.debug('Response-->' + resInput);
            system.debug('Response-->' + resInput.getStatus());
		    serviceDataPool.buildServiceDataPoolHttp('calloutToExternal', 'UpdateCBSRemarks', '', req, resInput);
        }catch(exception ex1)
        {
            system.debug(ex1.getMessage());
            loggerDataPool.buildLogDataPool('UpdateCBSRemarks', ex1);
        }
        
      	return responseToReturn;
        
    }
    
}
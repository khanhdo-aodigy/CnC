public class CancelCBSUpdQueuable implements Queueable,Database.AllowsCallouts{

    public class FromJSON2Apex {
		public Data data;
		public Error error;

		public FromJSON2Apex parse(String json) {
			return (FromJSON2Apex) System.JSON.deserialize(json, FromJSON2Apex.class);
		}
	}
    
    public class Error {
		public Integer code;
		public String message;
	}

	public class Data {
	}

    public List<Case> Cases; 
    public CancelCBSUpdQueuable(List<Case> caseList){
        this.Cases = caseList;
    }
    
    public void execute(QueueableContext qc){
        System.debug('cases'+cases[0]);

        // 1st callout
        try{
        String sVar;

        String queueIdUnBL = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Unassigned_BL_Queue' Limit 1].Id;                		
    
        HttpRequest req = new HttpRequest();
        HttpResponse resInput = new HttpResponse();
        Http http = new Http();
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String cbsAPIurl = (String)JCC_GlobalVar.APIGateway_url__c;
        String cbsAPIKey = (String)JCC_GlobalVar.APIGateway_key__c;   
        
        if(Test.isRunningTest()){
            req.setHeader('host', 'api.stg.cyclecarriage.com');   
            req.setHeader('apikey', '9-bMiOlUatsidmlzYSIsIm1hc3RlcmNhcmQiXX1H10JaPE54rGCPzpRFM016pybQvbGk5gOLRkYW15aFaQ14TbF94n5baYBX');
        }
        else{
            req.setHeader('host', 'api.cyclecarriage.com'); 
            req.setHeader('apikey', cbsAPIKey);     	
        }
        
            String ep = cbsAPIurl+'/CBSServices/CBS_AdminUpdateBookingComment';
            System.debug(ep);
        	
            req.setEndpoint(ep);
            req.setTimeout(60000);  
            req.setMethod('POST');
        
            for(Case c : cases)
            {                       
                String vBookingId     = String.valueof(c.Booking_ID_Text__c);
               	String vFranchiseCode = c.FranchiseCode__c;
                String vNRIC          = c.contact.NRIC__c;
     
               	DateTime d          = Date.Today() ;
				String currDateStr  =  d.format('dd/MM/yyyy') ;
        		Datetime myDateTime = DateTime.now();
				String currTime     = myDateTime.format('hh:mm a');
               	String vCSERemarks;
               	
               if(c.CSE_Remarks__c!=null || c.CSE_Remarks__c!=''){
        			vCSERemarks = (c.CSE_Remarks__c + ' ' + 'Booking cancelled by customer via SMS on ' + currDateStr + ' ' + currTime);
                }
               
               	if(c.CSE_Remarks__c==null || c.CSE_Remarks__c==''){
        			vCSERemarks = ('Booking cancelled by customer via SMS on ' + currDateStr + ' ' + currTime);
                }
               
               	String vComments = vCSERemarks;
           	   
        		// String v =  '{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments+'","remarkCse":"'+vCSERemarks+'"}';
        		// req.setBody('{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments+'","remarkCse":"'+vCSERemarks+'"}');

                String v =  '{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments.replace('\"','\\"')+'","remarkCse":"'+vCSERemarks.replace('\"','\\"')+'"}';
        		req.setBody('{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments.replace('\"','\\"')+'","remarkCse":"'+vCSERemarks.replace('\"','\\"')+'"}');
      
        		System.debug('req body-->' + v);
    
            	//Send http request, capture response and pass the response to mothod       
        		resInput = http.send(req); 
            	System.debug('Response-->' + resInput);
            	System.debug('Response-->' + resInput.getStatus());
		    	serviceDataPool.buildServiceDataPoolHttp('calloutToExternal', 'CancelCBSUpdQueuable', String.valueOf(c.Id), req, resInput);
                if(resInput.getStatusCode()==200 && resInput.getBody()!=NULL && resInput.getBody().trim()!=''){
                    FromJSON2Apex data =  (FromJSON2Apex) System.JSON.deserialize(resInput.getBody(), FromJSON2Apex.class);
            		System.debug('data...' + data);
                    System.debug('Error->' + data.error);
                    Error e = data.error;
                    if(e.code !=200)
                    {
                        c.CSE_Remarks__c = vCSERemarks;
                        c.OwnerId = queueIdUnBL;
                        c.Response_from_CBS__c = e.message;
                    }
                    if(e.code == 200){
                        c.CSE_Remarks__c = vCSERemarks;
                        c.Is_CSE_Remarks_Updated__c = true;
                    }
                }
                else{	
                    c.CSE_Remarks__c = vCSERemarks;
                    c.OwnerId = queueIdUnBL;    
                }
            } 
            	
            Update cases;
            
        }catch(exception ex1)
        {
            System.debug(ex1.getMessage());
            loggerDataPool.buildLogDataPool('CancelCBSUpdQueuable', ex1);
        }
        
    }
    
}
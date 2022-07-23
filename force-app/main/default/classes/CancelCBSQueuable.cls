public class CancelCBSQueuable implements Queueable,Database.AllowsCallouts{

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

	public class Data { }

    public List<Case> Cases; 
    
    public CancelCBSQueuable(List<Case> caseList){
        this.Cases = caseList;
    }
    
    public void execute(QueueableContext qc){
        System.debug('cases'+cases[0]);
    
        // 2nd callout
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
			    req.setHeader('Content-Type', 'application/json');
                req.setHeader('host', 'api.stg.cyclecarriage.com');   
                req.setHeader('apikey', '9-bMiOlUatsidmlzYSIsIm1hc3RlcmNhcmQiXX1H10JaPE54rGCPzpRFM016pybQvbGk5gOLRkYW15aFaQ14TbF94n5baYBX');
            }
            else{
			    req.setHeader('Content-Type', 'application/json');
                req.setHeader('host', 'api.cyclecarriage.com'); 
                req.setHeader('apikey', cbsAPIKey);     	
            }
        
            String ep = cbsAPIurl+'/CBSService/CBS_CancelBookingSF';         
            System.debug(ep);
            req.setEndpoint(ep);
            req.setTimeout(60000);  
            req.setMethod('POST');

            for(Case c : cases){                       
                String vBookingId     = String.valueof(c.Booking_ID_Text__c);
               	String vFranchiseCode = c.FranchiseCode__c;
                String vNRIC          = c.Contact_NRIC__c;
                Boolean vIsFromAdmin  = true;
                String vCancelledBy   = 'Salesforce';
                Boolean vDisableNotification = true;
                           
                // 2nd call out for cancel...
                String v =  '{"bookingId":'+ vBookingId +',"franchiseCode":"'+ vFranchiseCode +'","IsFromAdmin":'+vIsFromAdmin+',"CancelledBy":"'+vCancelledBy+'","DisableNotification":'+vDisableNotification+'}';
        		req.setBody('{"bookingId":'+ vBookingId +',"franchiseCode":"'+ vFranchiseCode +'","IsFromAdmin":'+vIsFromAdmin+',"CancelledBy":"'+vCancelledBy+'","DisableNotification":'+vDisableNotification+'}');
        		System.debug('req body-->' + v);    
            	resInput = http.send(req); 
            	System.debug('Response-->' + resInput);
            	System.debug('Response-->' + resInput.getStatus());
                
                serviceDataPool.buildServiceDataPoolHttp('calloutToExternal', 'CancelCBSQueuable-Cancel', String.valueOf(c.Id), req, resInput);
                
                if(resInput.getStatusCode()==200 && resInput.getBody()!=NULL && resInput.getBody().trim()!=''){
                	FromJSON2Apex data =  (FromJSON2Apex) System.JSON.deserialize(resInput.getBody(), FromJSON2Apex.class);
            		System.debug('data...' + data);
                    System.debug('Error->' + data.error);
                    Error e = data.error;
                    if(e.code !=200){
                        // Not successful
                        
                        if(e.code == 540 ) //code:540, message:The booking cannot be cancelled again
                        {
                            c.Status = 'Closed';
                        }
                        else{
                            c.OwnerId = queueIdUnBL;
                            c.Response_from_CBS__c = e.message;
                        }
                        //if(e.code==541){c.SMS_Status__c = 'Change Appointment';}
                    }    
                    if(e.code == 200){
                        c.Status = 'Closed'; 
                    }
                }
                else{
                    c.OwnerId = queueIdUnBL;
                }
            }
            Update cases;
            
        }
        catch(exception ex1)
        {
            System.debug('@@@@DEBUG CancelCBSQueuable :: error = ' + ex1.getMessage());
            loggerDataPool.buildLogDataPool('CancelCBSQueuable', ex1);
        }
    }
    
}
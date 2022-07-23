/** ******
 * Description: UpdateCBSQueuable
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		    Description
 * YYYYMMDD             Hari Panneerselvam      Created Initial Version. 
 * 20200513             KD                      Moved Datapool insertion out of the loop
** ******/
public class UpdateCBSQueuable implements Queueable,Database.AllowsCallouts
{
    // private static Http http = new Http();    
    private static List<serviceDataPool.ServiceDataPoolWrapper> serviceDataPools = new List<serviceDataPool.ServiceDataPoolWrapper>();   

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
    public UpdateCBSQueuable(List<Case> caseList){
        this.Cases = caseList;
    }
    
    public void execute(QueueableContext qc){
        System.debug('cases '+cases[0]);

        try{ 
            

            String queueIdUnBL = [select Id, Name, DeveloperName from Group where Type = 'Queue' and 
                                        DeveloperName = 'Unassigned_BL_Queue' Limit 1].Id;                		
            
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
            
                string ep = cbsAPIurl+'/CBSServices/CBS_AdminUpdateBookingComment';
                system.debug(ep);
                
                req.setEndpoint(ep);
                
                req.setTimeout(120000);  
                
                req.setMethod('POST');
                
                for(Case c : cases)
                {      

                    Decimal dBookingId = c.Booking_ID__c;
                    String vBookingId = dBookingId <> null ? String.valueOf( dBookingId.intValue() ) : null;
                    String vFranchiseCode = c.FranchiseCode__c;
        
                    DateTime d = Date.Today() ;
                    String currDateStr =  d.format('dd/MM/yyyy') ;
                    Datetime myDateTime = DateTime.now();
                    string currTime = myDateTime.format('hh:mm a');
                    String vCSERemarks;
                    
                    if(c.CSE_Remarks__c!=null || c.CSE_Remarks__c!=''){
                        vCSERemarks = (c.CSE_Remarks__c + ' ' + 'Booking confirmed by customer via SMS on ' + currDateStr + ' ' + currTime );
                    }
                
                    if(c.CSE_Remarks__c==null || c.CSE_Remarks__c==''){
                        vCSERemarks = ('Booking confirmed by customer via SMS on ' + currDateStr + ' ' + currTime);
                    }
                
                    String vComments = vCSERemarks;
                
                    
                    // string v =  '{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments+'","remarkCse":"'+vCSERemarks+'"}';
                    // req.setBody('{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments+'","remarkCse":"'+vCSERemarks+'"}');
                    string v =  '{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments.replace('\"','\\"')+'","remarkCse":"'+vCSERemarks.replace('\"','\\"')+'"}';
                    req.setBody( '{"franchiseCode":"'+ vFranchiseCode +'","bookingId":'+ vBookingId +',"comment":"'+vComments.replace('\"','\\"')+'","remarkCse":"'+vCSERemarks.replace('\"','\\"')+'"}' );
        
                    system.debug('req body-->' + v);

                
                    //Send http request, capture response and pass the response to mothod       
                    resInput = http.send(req); 
                    system.debug('Response-->' + resInput);
                    system.debug('Response-->' + resInput.getStatus());

                    serviceDataPools.add(new serviceDataPool.ServiceDataPoolWrapper('calloutToExternal', 'UpdateCBSQueuable', c.Id, req, resInput));

                    if(resInput.getStatusCode()==200 && resInput.getBody()!=NULL && resInput.getBody().trim()!=''){
                        FromJSON2Apex data =  (FromJSON2Apex) System.JSON.deserialize(resInput.getBody(), FromJSON2Apex.class);
                        system.debug('data...' + data);
                        System.debug('Error->' + data.error);
                        Error e = data.error;
                        if(e.code !=200){
                            c.CSE_Remarks__c = vCSERemarks;
                            c.OwnerId = queueIdUnBL;
                            c.Response_from_CBS__c = e.message;
                        }
                        
                        if(e.code == 200){
                            c.CSE_Remarks__c = vCSERemarks;
                            c.Is_CSE_Remarks_Updated__c = true;
                            c.Status = 'Closed';     
                        }
                    }else{
                                c.CSE_Remarks__c = vCSERemarks;
                                c.OwnerId = queueIdUnBL;
                    }

                }

            update cases;

            if(serviceDataPools.size() > 0) {
                serviceDataPool.buildListServiceDataPoolHttp(serviceDataPools);               
            }
        }catch(exception ex1)
        {
            system.debug(ex1.getMessage() + ' ' + ex1.getLineNumber());
            loggerDataPool.buildLogDataPool('UpdateCBSQueuable', ex1);
        }
        
    }

    public class cbsRequestJSON{
        public String franchiseCode;
        public String bookingId;
        public String comment;
        public String remarkCse;
    }

}
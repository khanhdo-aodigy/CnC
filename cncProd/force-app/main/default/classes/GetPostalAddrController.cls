public class GetPostalAddrController {
    
    public class fromJSON{
        public String BUILDING;	//TAMPINES PALMSVILLE
        public String LONGTITUDE;	//103.940623987817
        public String ADDRESS;	//942 TAMPINES AVENUE 5 TAMPINES PALMSVILLE SINGAPORE 520942
        public String LONGITUDE;	//103.940623987817
        public String POSTAL;	//520942
        public String X;	//39941.8981861482
        public String Y;	//36876.3724740781
        public String SEARCHVAL;	//TAMPINES PALMSVILLE
        public String ROAD_NAME;	//TAMPINES AVENUE 5
        public String BLK_NO;	//942
        public String LATITUDE;	//1.34976895413461
    }
    
    // private static CBSSystem__c cbs = CBSSystem__c.getInstance();
    @Auraenabled
    public static String getAddr(String vpostalcode)
    {    
      
        String returnAddr;
        String responseToReturn;
        HttpRequest req = new HttpRequest();
        HttpResponse resInput = new HttpResponse();
        Http http = new Http();
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String cbsAPIurl = (String)JCC_GlobalVar.APIGateway_url__c;
        String cbsAPIKey = (String)JCC_GlobalVar.APIGateway_key__c;    
        
        req.setHeader('host', 'api.cyclecarriage.com'); 
        req.setHeader('Content-Type', 'application/json');
        if(Test.isRunningTest()){
            req.setHeader('apikey', '3-bMiOlsidmlzYSIsIm1hc3RlcmNhcmQiXX1'); 
        }
        else{
            req.setHeader('apikey', cbsAPIKey);
        }
        
        system.debug('postalcode'+vpostalcode);
        string ep = cbsAPIurl+'/GetAddress?Postalcode='+vpostalcode;
        
        system.debug(ep);
        req.setEndpoint(ep);
        
       // req.setEndpoint(cbsAPIurl+'/GetAddress?Postalcode='+vpostalcode);
        req.setTimeout(12000);  
        req.setMethod('GET');
        
        
        try 
        {   
            //Send http request, capture response and pass the response to mothod       
            resInput = http.send(req); 
            serviceDataPool.buildServiceDataPoolHttp('getAddr', 'GetPostalAddrController', '', req, resInput);
        }
        
        catch(exception ex1)
        {
            system.debug(ex1.getMessage());
             loggerDataPool.buildLogDataPool('GetPostalAddrController', ex1);
        }
        
        if(resInput.getBody()!=NULL && resInput.getBody().trim()!='')
        {
            fromJSON data =  (fromJSON) System.JSON.deserialize(resInput.getBody(), fromJSON.class);
            returnAddr = data.address;
            system.debug('data...' + data);
            
        }
        
        if (returnAddr!=null){
            return returnAddr;
        }else
            return responseToReturn; 
    }
    
}
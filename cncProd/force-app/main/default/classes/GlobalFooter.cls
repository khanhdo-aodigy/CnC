public class GlobalFooter {

    public String footer{get;set;}
    
    public GlobalFooter(){
 			
        	Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res;
            try {        
                req.setEndpoint('https://www.cyclecarriage.com/sg/sf-footerweb');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');      
                req.setMethod('GET');                
                res = http.send(req);                
               	footer = res.getBody();
            } catch (Exception e) {
                System.debug('Error'+e);
            }
        
    }

}
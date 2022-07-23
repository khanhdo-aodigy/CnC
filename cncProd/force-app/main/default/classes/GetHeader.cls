public with sharing class GetHeader 
{
    	public String header { get;set;}

   public GetHeader()            
        {
         
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res;
            try {        
                req.setEndpoint('https://www.cyclecarriage.com/sg/sf-headerweb');
                system.debug('Entered here');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');      
                req.setMethod('GET');                
                res = http.send(req);                
               	header = res.getBody();
            } catch (Exception e) {
                System.debug('Error'+e);
            }

        }

 }
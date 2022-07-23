//Class to trigger Update Nric Automation 
public class CallUpdateNricAutomation {
     
   @future (callout=true)
    public static void makeHTTPXMLPost()
    {
      String accessToken = '';
      String resBody = '';
      String reqTokenEndPoint = 'https://auth.exacttargetapis.com/v1/requestToken' ;
      String webserviceEndPoint = 'https://webservice.s10.exacttarget.com/Service.asmx';
      global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();
       String  MC_clientId = (String)JCC_GlobalVar.MC_ClientId__c;
       String  MC_clientSecret = (String)JCC_GlobalVar.MC_ClientSecret__c; 
       String clientId = (String)JCC_GlobalVar.buId__c; 
       String objectId = (String)JCC_GlobalVar.objectId__c; 
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');                                    
        //Seting HttpRequest Method
        req.setHeader('content-type', 'application/json');            
        req.setEndpoint(reqTokenEndPoint); 
        req.setBody('{"clientId": "'+MC_clientId+'","clientSecret": "'+MC_clientSecret+'"}');
        Http http = new Http();
        
        try
      {
            HTTPResponse res = http.send(req);  
            JSONParser parser = JSON.createParser(res.getBody());  
            resBody=res.getBody();
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'accessToken')) {
                        parser.nextValue();
                        accessToken=parser.getText();                    
                    }
                }
            Http h = new Http();
            HttpRequest r = new HttpRequest();
            r.setTimeout(60000);
            r.setEndpoint(webserviceEndPoint);  
            r.setMethod('POST');
            r.setHeader('SOAPAction','Perform'); 
            r.setHeader('Accept','text/xml');  
            r.setHeader('Content-type','text/xml');    
            r.setHeader('charset','UTF-8'); 
            String soapEnvelopeTemplate = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
           '<soapenv:Header>'+
            '<fueloauth xmlns="http://exacttarget.com">'+accessToken+'</fueloauth>'+
         '</soapenv:Header>'+
                       '<soapenv:Body>'+
                          '<PerformRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
                             '<Action>start</Action>'+
                             '<Definitions>'+
                                '<Definition xsi:type="Automation">'+
                                   '<Client>'+
                                      '<ID>'+clientId+'</ID>'+
                                   '</Client>'+
                                   '<ObjectID>'+objectId+'</ObjectID>'+
                                '</Definition>'+
                             '</Definitions>'+
                          '</PerformRequestMsg>'+
                       '</soapenv:Body>'+
                    '</soapenv:Envelope>';
            r.setBody(soapEnvelopeTemplate);
            //reqLLogin.setBody(soapBody);    
            HttpResponse s = h.send(r);
            //return s.getBody();
    }
    
     catch(System.CalloutException e)
     {      
            //Exception handling goes here..
            resBody=e.getMessage();
     }
   
    }

}
@RestResource(urlMapping='/validatetoken/v1/*')
global with sharing class JCCReturnSuccess 
{
     @HttpPost 
     global static void returnSuccess()   
     {
          Map<String, String> responseMap =   new Map<String, String>();
          RestResponse res = RestContext.response;
          responseMap.put('Status', 'Success');
          res.addHeader('Content-Type', 'application/json');
          res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
     }

}
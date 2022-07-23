// Apex class for Variant Price list  Expose Api 
    @RestResource(urlMapping='/GetVariantPrice/v1/*')
    global with sharing class GetVariantPrice
    {
    @HttpGet
        //callout method for expose api
    global static void getPriceMethod() 
{
    //Get variant id  from the request URL here
    RestRequest request = RestContext.request;
    String variantStr = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
    String errorMsg='';
    List<SObject>  returnObject = new List<SObject>();
    RestResponse res = RestContext.response;
    Map<String, String> errorRes = new Map<String, String>();
   List<Map<String, String>> errorResList = new List<Map<String, String>>();
//Check if variant id is blank  
    try {
            if (variantStr.trim() =='' || variantStr == null)
            {
                
                        errorMsg='Please provide variant id';
                        res.statusCode=400;
                        errorRes.put('ErrorCode', 'Err02-SF');
                        errorRes.put('Message', errorMsg);  
                        errorResList.add(errorRes);
                        res.responseBody = Blob.valueOf(JSON.serialize(errorResList));   
                    
                                    
            } 
         //Check if  variant id is present 

           else
            {
                returnObject=[SELECT  Listed_price__c  FROM Variant__c WHERE id = :variantStr];
                res.responseBody = Blob.valueOf(JSON.serialize(returnObject));
                res.statusCode = 200;
                
                
                if(returnObject.size()==0)
                    {
                        errorRes.put('ErrorCode', 'Err03-SF');
                        errorRes.put('Message', 'Invalid Variant Id: '+variantStr);
                        errorResList.add(errorRes);
                        res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
                        res.statusCode = 400;
                    }
                 
            } 
                            
            
         }
      catch (DMLException e)
                { 
                    res.statusCode=400;
                    errorMsg = 'A system exception has occurred, Please contact your administrator.';
                    errorRes.put('ErrorCode', 'Err04-SF');
                    errorRes.put('Message', errorMsg);  
                    errorResList.add(errorRes);
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
                }
    
      //Return Price List For Variant  
          RestContext.response = res;
           res.addHeader('Content-Type', 'application/json');
           
           
   
      
}
}
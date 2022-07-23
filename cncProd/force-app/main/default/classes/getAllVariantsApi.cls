// Apex class for All Variants  Expose Api 
@RestResource(urlMapping='/GetVariants/v1/*')
global with sharing class getAllVariantsApi {
    @HttpGet
    //callout method for expose api
    global static void getAllVariantsMethod() 
    {
        //Get model id   from the request URL here
        RestRequest request = RestContext.request;
        String country = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        //country = 'Singapore';
        String errorMsg='';
        List<SObject>  returnObject = new List<Variant__c>();
        Map<String, String> errorRes = new Map<String, String>();
        List<Map<String, String>> errorResList = new List<Map<String, String>>();
        
        RestResponse res = RestContext.response;
        //Check if input country is blank  
        try {
            /*country = 'SG';
            if (String.isblank(country))
            { 
                Errormsg='Please Enter Country Name';
                res.statusCode = 400;  
                errorRes.put('ErrorCode', 'Err02-SF');
                errorRes.put('Message', errorMsg);  
                errorResList.add(errorRes);
                res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
                //throw new QueryException(errorMsg);
                //country = 'Singapore';
            } 
            
            else
            { 
                if(country == 'Singapore' || country == 'SG') {  */
            If(country == 'SG' || country == 'Singapore' || country == '')
            { 
                returnObject=[SELECT Id,Name,Active__c,BHP__c,Branch__c,Country__c,Description__c,DWH_Variant_ID__c,Engine_Capacity__c,Franchise__c,Fuel_Type__c,Model_ID__c,Number_of_Doors__c,Transmission__c,Year__c FROM Variant__c WHERE (Country__c = 'Singapore' OR Country__c = 'SG' OR Country__c = '') AND Source__c = 'DWH' ];
                res.statusCode = 200;                     
            } 
            else {
                returnObject=[SELECT Id,Name,Active__c,BHP__c,Branch__c,Country__c,Description__c,DWH_Variant_ID__c,Engine_Capacity__c,Franchise__c,Fuel_Type__c,Model_ID__c,Number_of_Doors__c,Transmission__c,Year__c FROM Variant__c WHERE Country__c = :country AND Source__c = 'DWH' ];
                res.statusCode = 200;  
            }                  
            
            if(returnObject.size()<=0)
            {
                errorMsg='We have no Variants to display for this country or Country is Invalid.';    
                res.statusCode = 400;  
                errorRes.put('ErrorCode', 'Err03-SF');
                errorRes.put('Message', errorMsg);  
                errorResList.add(errorRes);
                res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
                //throw new QueryException(errorMsg);
            }
            
            //}
        }
        catch (Exception e)
        { 
            System.debug('A exception has occurred: ' + e.getMessage());    
            //res = RestContext.response;
            res.statusCode=400;
            errorMsg = 'A system exception has occurred, Please contact your administrator.';
            errorRes.put('ErrorCode', 'Err04-SF');
            errorRes.put('Message', errorMsg);  
            errorResList.add(errorRes);
            res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
            //throw e;
        }
        
        //Return List of all colors 
        if(res.statusCode==200)
        {
            res.responseBody = Blob.valueOf(JSON.serialize(returnObject));
        }
        RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
    }
}
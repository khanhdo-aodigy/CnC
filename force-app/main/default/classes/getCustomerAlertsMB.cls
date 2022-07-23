//Apex class to Get All Alerts
@RestResource(urlMapping='/GetCustomerAlertsMB/v1/*')
global with sharing class getCustomerAlertsMB {
    
    //CallOut method for Expose API
    @HttpGet
    global static Void getAlertsMB() 
    {   
        //Get NRIC from request URL
        RestRequest request = RestContext.request;
        String nricStr = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        Map<String, String> errorRes = new Map<String, String>();
        List<Map<String, String>> errorResList = new List<Map<String, String>>();
        
        String errorMsg='';
        List<SObject>  returnObject = new List<SObject>();
        RestResponse res = RestContext.response;
        try
        {
            //Check if entered nric  is blank  
            if(nricStr!='')
            {   
                Long TimeStartObj = system.currentTimeMillis();
                returnObject=[ SELECT Id,
                                      Name,
                                      Contact__r.NRIC_Passport_No__c,
                                      Registered_Vehicle__r.Registration_Number__c,
                                      Alert_Description__c,
                                      Date__c, 
                                      DateTime__c, 
                                      Status__c, 
                                      Type__c, 
                                      SubType__c,                                      
                                      RecordTypeId, RecordType.Name
                              FROM CustomerAlerts__c 
                              WHERE
                              (Contact__c =:nricStr)
                              AND Registered_Vehicle__r.Franchise__c = 'MBP'
                              AND isAlert__c = True
							  AND Registered_Vehicle__c != null];
                res.statusCode=200;
            }
            else
            {
                errorMsg='Please Provide NRIC';  
                res.statusCode=400;
                errorRes.put('ErrorCode', 'Err02-SF');
                errorRes.put('Message', errorMsg);  
                errorResList.add(errorRes);
                res.responseBody = Blob.valueOf(JSON.serialize(errorResList));   
            }           
            
        }
        //Catch the error If any
        catch (Exception e)
        { 
            res.statusCode=400;
            errorMsg = 'A system exception has occurred, Please contact your administrator.';
            errorRes.put('ErrorCode', 'Err04-SF');
            errorRes.put('Message', errorMsg);  
            errorResList.add(errorRes);
            res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
        }
        
        
        //Return List of Alerts
        if(res.statusCode==200)
        {
            res.responseBody = Blob.valueOf(JSON.serialize(returnObject));
        }
        RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');      
    }
}
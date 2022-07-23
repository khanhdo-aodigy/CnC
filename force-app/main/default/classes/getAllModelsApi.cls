//Apex class to Get All models
@RestResource(urlMapping='/GetAllModels/v1/*')
global with sharing class getAllModelsApi {
@HttpGet
//CallOut method for Expose API
global static Void getModels() 
{   
    //Get Country from request URL
    RestRequest request = RestContext.request;
    String countryStr = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
    String errorMsg='';
    List<SObject>  returnObject = new List<SObject>();
    Map<String, String> errorRes = new Map<String, String>();
    List<Map<String, String>> errorResList = new List<Map<String, String>>();
    
    RestResponse res = RestContext.response;
    try
    {
        //Get all the models having country Singapore,SG or have no value
        
        If(countryStr == 'SG' || countryStr == 'Singapore' || countryStr == '')
        {   
            returnObject=[SELECT Id, Name, Country__c, Branch_Code__c, Franchise_Code__c, Model_Description__c, DWH_Model_ID__c FROM Model__c Where (Country__c= :'SG'  OR Country__c ='Singapore' OR Country__c ='') AND Source__c = 'DWH' ];
            res.statusCode = 200; 
        }
        //Get all the models having country valid country except singapore
        else
        {
            returnObject=[SELECT Id, Name, Country__c, Branch_Code__c, Franchise_Code__c, DWH_Model_ID__c, Model_Description__c FROM Model__c Where Country__c= :countryStr AND Source__c = 'DWH'];
            res.statusCode = 200; 
        }  
        If(returnObject.size()<=0)
        {
            errorMsg='We have no Models to display for this country or Country is Invalid';  
            res.statusCode = 400; 
            errorRes.put('ErrorCode', 'Err03-SF');
            errorRes.put('Message', errorMsg);  
            errorResList.add(errorRes);
            res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
        }
         
    }
    //Catch the error If any
    catch (DmlException e)
    { 
        
        res.statusCode=400;
        errorMsg = 'A system exception has occurred, Please contact your administrator.';
        errorRes.put('ErrorCode', 'Err04-SF');
        errorRes.put('Message', errorMsg);  
        errorResList.add(errorRes);
        res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
    }
    
    
    //Return List of Models 
    if(res.statusCode==200)
    {
        res.responseBody = Blob.valueOf(JSON.serialize(returnObject));
    }
    RestContext.response = res;
    res.addHeader('Content-Type', 'application/json');
    
}
}
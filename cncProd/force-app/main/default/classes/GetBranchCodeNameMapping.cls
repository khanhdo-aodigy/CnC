//Apex class to Get All models
@RestResource(urlMapping='/GetBranchCodeNameMapping/v1/*')
global with sharing class GetBranchCodeNameMapping {
@HttpGet
//CallOut method for Expose API
global static void getBranchCodeNameMapping() 
{   
    //Get Country from request URL
    RestRequest request = RestContext.request;
    String errorMsg='';
    List<SObject>  returnObject = new List<SObject>();
    RestResponse res = RestContext.response;
        try
        {
              
            returnObject=[SELECT Name, Branch_Code__c, CV_Code__c, PC_Code__c from Branch_Code_Name_Mapping__c];
            res.statusCode = 200; 
        }
        //Catch the error If any
        catch (DmlException e)
        { 
            
            res = RestContext.response;
            res.statusCode=400;
            throw e;
        }
    
    
     //Return List of Models 
     RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(returnObject));
        res.statusCode = 200;
  
}
}
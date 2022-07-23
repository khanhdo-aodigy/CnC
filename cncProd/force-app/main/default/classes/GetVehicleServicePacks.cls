@RestResource(urlMapping='/GetVehicleServicePacks/v1/*')
global with sharing class GetVehicleServicePacks {
@HttpGet
global static List<SObject> GetVehicleServicePacks() 
{
//Get NRIC ID from the request URK here
RestRequest request = RestContext.request;
String vehicleId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
String UUID = '1234';
String Errormsg='';
Datetime startDate = system.now();
    
List<SObject>  returnObject = new List<SObject>();
List<Map<String, Object>>  returnLMapObject = new List<Map<String, Object>>();
RestResponse res = RestContext.response;

//Check if input NRIC is not blank  
If(vehicleId!='')
{
    try
    {
        Long TimeStartObj = system.currentTimeMillis();
        //Get all the registered Vehicles based upon the customer having NRIC_Passport_No__c equal to NRIC provided in request
        returnObject=[SELECT Id, Name, Item_Balance__c, Item_Description__c, Item_Expiry_Date__c, Service_Package__r.ID, 
                      Service_Package__r.Name, Service_Package__r.PACKAGE_DESCRIPTION__c, Service_Code__c,
                      Service_Package__r.ITEM_EXPIRY_DATE__c  
                      FROM Service_Package_Item__c WHERE Registered_Vehicle__c = :vehicleId 
                      AND Status__c = 'Active' 
                      and (Item_Expiry_Date__c!=: null AND Item_Expiry_Date__c >= TODAY)];
        if(returnObject.size() == 0) 
        {
            List<Registered_Vehicle__c> TempRV = [Select Name from Registered_Vehicle__c where Id = :vehicleId];
            If(TempRV.size()<=0)
            {
                Errormsg='Invalid Vehicle Id';      
                throw new DMLException(Errormsg);
            }
        }
        system.debug(LoggingLevel.INFO,'Time in MS for Select/Update Satement for Service Package: '+String.ValueOf(system.currentTimeMillis()-TimeStartObj));
    }
    //Catch the error If any
    catch (DmlException e)
    { 
         Errormsg='Invalid Vehicle Id';
         throw new DMLException(Errormsg);
    }
}
else
{
    //Throw an error If input NRIC is blank
     Errormsg='Required fields not supplied. Fields: Vehicle Id';      
    res.statusCode=400;
    throw new DMLException(Errormsg);
}    
 //Return List of registered vehicles   
return returnObject;  
}
}
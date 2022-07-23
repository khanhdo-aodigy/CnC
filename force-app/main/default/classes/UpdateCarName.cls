@RestResource(urlMapping='/UpdateCarName/v1/*')
global with sharing class UpdateCarName {
@HttpPost
global static Map<String, String> updateCarName(String vehicleId, String carName) 
{
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    Registered_Vehicle__c[] vehicleList;
    Registered_Vehicle__c vehicle;
    String ErrorCode;
    String Errormsg;
    String jsonS;
    Map<String, String> responseMap =   new Map<String, String>();
    
    
    JSONGenerator gen = JSON.createGenerator(true);
    If(vehicleId.trim()!='' && carName.trim()!='')
    {
        try
        { 
            system.debug(LoggingLevel.INFO,'Start of Select/Update Satement: '+system.currentTimeMillis());
            vehicleList = [SELECT Id FROM Registered_Vehicle__c WHERE ID = :vehicleId]; 
            
            if (vehicleList != null && vehicleList.size()>0) {
                vehicle = vehicleList[0];
                vehicle.Preferred_Car_Name__c = carName;               
                update vehicle;
                gen.writeStartObject();     
                gen.writeStringField('UId','1001'); 
                gen.writeStringField('Status','Success');      
                gen.writeEndObject();   
                jsonS = gen.getAsString();
                res.statusCode=200;
                responseMap.put('Status', 'Success');
            }
            else
            {
                Errormsg ='Invalid Vehicle Id: '+vehicleId;
                res.statusCode=400;
                responseMap.put('ErrorCode', 'Err03-SF');
                responseMap.put('Message', errorMsg);  
  
            } 
            system.debug(LoggingLevel.INFO,'End of Select/Update Satement: '+system.currentTimeMillis());
        }
        catch (DmlException e)
        { 
            errorMsg = 'A system exception has occurred, Please contact your administrator.';
            responseMap.put('ErrorCode', 'Err04-SF');
            responseMap.put('Message', errorMsg);
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            res.statusCode=400;    
        }  
    }
    else
    { 
        Errormsg='Required fields not supplied. Fields: Vehicle Id Or Car Name';
        res.statusCode=400;
        responseMap.put('ErrorCode', 'Err02-SF');
        responseMap.put('Message', errorMsg);  
    }     
    return responseMap;
}
}
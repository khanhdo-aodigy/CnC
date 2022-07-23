@RestResource(urlMapping='/GetCustomerIdentifierMB/v1/*')
global class GetCustomerIdentifierMB {

    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;  
    private static Map<String, Object> mapJSONBody = new Map<String, Object>();
    
    @HttpPost
    global static void getCustomerIdentifierMB()    
    {
        String errorMsg = '';
        List<SObject>  returnObject = new List<SObject>();
        List<Contact> contactList = new List<Contact>();
        List<Registered_Vehicle__c> regVehicleList = new List<Registered_Vehicle__c>();
        Map<String, Object>  returnMapObject = new Map<String, Object>();
        RestContext.response = res;
        Map<String, String> responseMap = new Map<String, String>();
        
        try
        {
            mapJSONBody = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
            String registrationNumber = mapJSONBody.containsKey('registrationNumber') ?  (String)mapJSONBody.get('registrationNumber')+'%' : '';
            String mobileNumber = mapJSONBody.containsKey('mobileNumber') ?  '%'+(String)mapJSONBody.get('mobileNumber') : '';
            String email = mapJSONBody.containsKey('email') ?  '%'+(String)mapJSONBody.get('email')+'%' : '';
			
            if( String.isBlank( registrationNumber ) || String.isBlank( mobileNumber ) || String.isBlank( email ) ) 
            {     
                responseMap.put('Message', 'Mandatory field(s) are missing. Please refer API doc');
                responseMap.put('ErrorCode', 'Err02-SF');
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));   
                return;
            }

            returnObject = [SELECT Account__r.NRIC_Passport_No__pc, Contact__r.NRIC_Passport_No__c 
                            FROM Registered_Vehicle__c 
                            WHERE Registration_Number__c LIKE :registrationNumber
                            AND Contact__r.MobilePhone LIKE :mobileNumber 	
                            AND Contact__r.Email LIKE :email 	  
                            AND Contact__r.IsPersonAccount = true                 
                            AND Franchise__c IN ('MBP')];
            
            returnMapObject.put('Customer',returnObject);
            res.statusCode = 200;
            //Return Customer Profile   
            if(res.statusCode==200)
            {
                res.responseBody = Blob.valueOf(JSON.serialize(returnMapObject).replace('NRIC_Passport_No__c','Identifier'));
            }
            RestContext.response = res;
            res.addHeader('Content-Type', 'application/json');
            serviceDataPool.buildServiceDataPool('GetCustomerIdentifierMB', 'GetCustomerIdentifierMB', '', req, res);
            
        }
        catch(Exception e)
        {
            responseMap.put('Message', 'A system exception has occurred, Please contact your administrator.'+e.getMessage());
            responseMap.put('ErrorCode', 'Err04-SF');
            res.statusCode = 400;
            loggerDataPool.buildLogDataPool('GetCustomerIdentifierMB v1', e);
        }
    }
}
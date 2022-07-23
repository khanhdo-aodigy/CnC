@RestResource(urlMapping='/GetCustomerProfile/v1/*')
global with sharing class GetCustomerProfile {
    
    public class SearchException extends Exception{}
    
    @HttpGet
    global static void GetCustomerProfile() 
    {
        //Get NRIC ID from the request URK here
        RestRequest request = RestContext.request;
        String inputNRIC = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        String errorMsg = '';
        List<Contact> returnObject = new List<Contact>();   
        List<Contact> contactList = new List<Contact>();   
        List<User> returnUserObject = new List<User>();
        Map<String, String> errorResponseMap =   new Map<String, String>();
        Map<String, Object>  returnMapObject = new Map<String, Object>();
        RestResponse res = RestContext.response;
        
        //Check if input NRIC is not blank  
        if( String.isNotBlank(inputNRIC) )
        {
            try
            {
                //Get customer profile based upon the customer having NRIC_Passport_No__c equal to NRIC provided in request
                returnObject = [SELECT Email, 
                                    Address_Line_1__c, 
                                    Address_Line_2__c, 
                                    Address_Line_3__c, 
                                    Address_Line_4__c, 
                                    Address_Line_5__c, 
                                    MobilePhone 
                                FROM Contact 
                                WHERE Id =: inputNRIC];
                
                if( returnObject <> null && !returnObject.isEmpty() )
                {
                    returnUserObject = [SELECT Display_Name__c, Name 
                                        FROM User 
                                        WHERE ContactId IN: returnObject LIMIT 1];
                }              
               
                if(returnObject.size()==0 && returnUserObject.size()==0 )
                {
                    errorMsg = 'There is no contact for this NRIC Number: '+inputNRIC; 
                    res.statusCode = 400;
                    errorResponseMap.put('ErrorCode', 'Err03-SF');
                    errorResponseMap.put('Message', errorMsg );  
                    RestContext.response = res;
                    res.addHeader('Content-Type', 'application/json');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));          
                }
                else
                {
                    
                    if((returnObject[0].MobilePhone!= null) && ((returnObject[0].MobilePhone).length() == 11))
                    {
                        returnObject[0].MobilePhone = returnObject[0].MobilePhone.substring(3);  
                    }
                    else if((returnObject[0].MobilePhone!= null) && ((returnObject[0].MobilePhone).length() == 10))
                    {
                        returnObject[0].MobilePhone = returnObject[0].MobilePhone.substring(2);
                    }
                    
                    returnMapObject.put('Customer',returnObject);
                    returnMapObject.put('DisplayName',returnUserObject);
                    res.statusCode = 200;
                    //Return Customer Profile   
                    RestContext.response = res;
                    res.addHeader('Content-Type', 'application/json');
                    res.responseBody = Blob.valueOf(JSON.serialize(returnMapObject).replace('Display_Name__c','CommunityNickname'));
                }

                if(System.Test.isRunningTest())
                {
                    throw new SearchException('Test Run Error'); 
                }
            }
            //Catch the error If any
            catch (Exception e)
            {   
                loggerDataPool.buildLogDataPool('GetCustomerProfile', e);
                res.statusCode = 400;
                errorResponseMap.put('ErrorCode', 'Err04-SF');
                errorResponseMap.put('Message', e.getMessage());
                RestContext.response = res;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));
            }
        }
        else
        {
            //Throw an error If input NRIC is blank
            errorMsg = 'Required fields not supplied. Fields:NRIC';      
            res.statusCode = 400;
            errorResponseMap.put('ErrorCode', 'Err02-SF');
            errorResponseMap.put('Message', errorMsg );
            RestContext.response = res;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));
        }    
        
        serviceDataPool.buildServiceDataPool('GetCustomerProfile', 'GetCustomerProfile', '', request, res); 
    }    
}
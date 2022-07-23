/** *******
 * Class Name: GetCustomerProfileBySFUserID
 * Description: (GET) RestAPI for fetching User information via
 * 				User Id in SF. User record has an NRIC value which
 * 				maps to Business contact (as of 22-07-2019).
 * 
 * Revision History
 * Developer Name			Date			Description
 * CGaylan					22-07-2019		Created.
 * 											*Please note Exception Messages should be placed in a Label or Constants class
 * TPhan                    19-01-2021      Added User_Type__c field     
******* **/ 
@RestResource(urlMapping='/GetCustomerProfileBySFUserID/v1/*')
global class GetCustomerProfileBySFUserID {
    
    public class SearchException extends Exception{}
    
    /**
     * Description: Fetch User and Contact data by User Id passed in the header.
    **/
    @HttpGet
    global static void getCustomerProfileBySFUserID()
    {
        //Get NRIC ID from the request URK here
        RestRequest request = RestContext.request;
        
        String inputUserId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        String errorMsg = '';
        List<Contact> returnObject = new List<Contact>();
        List<User> returnUserObject = new List<User>();
        Map<String, String> errorResponseMap = new Map<String, String>();
        Map<String, Object> returnMapObject = new Map<String, Object>();
        RestResponse res = RestContext.response;
        
        if( String.isNotBlank(inputUserId) )
        {
            try
            {
                returnUserObject = [SELECT Display_Name__c, Name, ContactId
                                    FROM User 
                                    WHERE Id =: inputUserId
                                    LIMIT 1];  
                
                if( returnUserObject.size() <= 0 )
                {
                    throw new SearchException('User record not found.');
                }
                
                //Get customer profile based upon the customer having NRIC_Passport_No__c equal to NRIC fetched from the User record
                returnObject = [SELECT Email, 
                                    Address_Line_1__c, 
                                    Address_Line_2__c, 
                                    Address_Line_3__c, 
                                    Address_Line_4__c, 
                                    Address_Line_5__c, 
                                    FirstName,
                                    LastName,
                                    MobilePhone,
                                    User_Type__c 
                                FROM Contact 
                                WHERE Id =: returnUserObject.get(0).ContactId 
                                LIMIT 1];
                
                
                if( returnObject.size( )<= 0 )
                {
                    errorMsg = 'There is no contact for this User Id: '+inputUserId; 
                    res.statusCode = 400;
                    errorResponseMap.put('ErrorCode', 'Err03-SF');
                    errorResponseMap.put('Message', errorMsg);  
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
                    RestContext.response = res;
                    res.addHeader('Content-Type', 'application/json');
                    res.responseBody = Blob.valueOf(JSON.serialize(returnMapObject).replace('Display_Name__c','CommunityNickname'));
                }
            }
            catch (Exception e)
            {   
                loggerDataPool.buildLogDataPool('GetCustomerProfileBySFUserID', e);
                res.statusCode=400;
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
            errorMsg = 'Required fields not supplied. Fields: UserId';      
            res.statusCode = 400;
            errorResponseMap.put('ErrorCode', 'Err02-SF');
            errorResponseMap.put('Message', errorMsg);
            RestContext.response = res;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));
        }    
      	
        serviceDataPool.buildServiceDataPool('GetCustomerProfileBySFUserID', 'GetCustomerProfileBySFUserID', '', request, res); 
    }
}
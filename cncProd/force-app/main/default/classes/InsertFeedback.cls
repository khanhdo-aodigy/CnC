/** *******
 * Description : API class to insert Feedback
 *
 * Change History:
 * Date(YYYYMMDD)       Developer                  Description
 * 20180807             C&C                        Created Initial version
 * 20200325             huynh.hung@aodigy          Added PA Migration - Phase 1 Changes
 * 20200831             khanh.do@aodigy.com        Added PA Migration - Phase 2 Changes
 * 
******* **/
@RestResource(urlMapping='/InsertFeedback/v1/*')
global with sharing class InsertFeedback {

    @HttpPost
    global static void insertFeedback( String nric, String email, String lastVisitedServiceCenter, String message, String mobile, String name, String registrationNumber, String category) 
    {   
        String errorMsg='';
        List<SObject> returnObject = new List<SObject>();
        List<Contact> contactList = new List<Contact>();
        List<Feedback__c> feedbackList = new List<Feedback__c>();
        RestResponse res = RestContext.response;
        RestContext.response = res;
        Feedback__c feedback; 
        Map<String, String> responseMap = new Map<String, String>();
        
    
        try
        {
            feedback = new Feedback__c();
            
            if( String.isNotBlank( email ) && String.isNotBlank( message ) && String.isNotBlank( mobile ) && String.isNotBlank( name ) && String.isNotBlank( category ) ) 
            {   
                if( String.isNotBlank( nric ) ) {					
                    contactList = [SELECT Id, AccountId FROM Contact WHERE NRIC_Passport_No__c = :nric AND IsPersonAccount = true];
                }

                if( contactList != null && contactList.size()>0 )
                {
                    feedback.Contact__c = contactList[0].Id ;
                    feedback.Account__c = contactList[0].AccountId;
                }
            
                feedback.Category__c = category;
                feedback.Email__c    = email;
                feedback.Message__c  = message;
                feedback.Mobile__c   = mobile;
                feedback.Name__c     = name;
                feedback.Registration_Number__c = registrationNumber;	
                feedback.Last_Visited_Service_Cent__c = lastVisitedServiceCenter;
                insert feedback;
                
                res.statusCode = 200;
                responseMap.put('Status', 'Success');         
            }
            else {
                responseMap.put('Message', 'Mandatory field(s) are missing. Please refer API doc');
                responseMap.put('ErrorCode', 'Err02-SF');
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));	
                return;
            }
            
        }
        catch (DmlException e)
        {     
            responseMap.put('Message', 'A system exception has occurred, Please contact your administrator.'+e.getMessage());
            responseMap.put('ErrorCode', 'Err04-SF');
            res.statusCode = 400;
        }    
        
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        //res.statusCode = 200;
    }
}


/*
    /services/apexrest/InsertFeedback/v1

    {
        "nric": "DUMMYNRIC1",
        "email": "LYLpa@mailinator.com",
        "lastVisitedServiceCenter": "Hello World",
        "message": "Feedback Message",
        "mobile": "9090080800",
        "name": "YL-1",
        "registrationNumber": "XYZ00091",
        "category": "Others"
    }
*/
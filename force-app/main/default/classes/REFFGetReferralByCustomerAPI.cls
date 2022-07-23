/** ******
 * Description : API Class used to retrieve Referral Count (i.e. FriendReferrals, SuccessfulReferrals) of the Referrer
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                    Description
 * 20200212             Hung@aodigy             Created Initial Version. 
 * 20200923             HS@aodigy               PA-Phase 2 : Removed the Referral count checking based on User.ContactId__c
 * 
* *******/
@RestResource(urlMapping='/GetReferralByCustomer/*')
global with sharing class REFFGetReferralByCustomerAPI {
    @HttpGet
    global static void getReferralByCustomer(){
        //Get UserId from request here
        RestRequest request = RestContext.request;
        //String userId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        //inputBrand = 'MIT'; //Testing only for brand input
        String userId = request.requestURI.substringBetween('User/','/Brand');
        String inputBrand = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        String Errormsg='';
        Map<String, String> errorRes = new Map<String, String>();   
        List<Map<String, String>> errorResList = new List<Map<String, String>>();
        Integer friendReferrals = 0;
        Integer successfulReferrals = 0;
        Map<String, Integer> returnObject = new Map<String, Integer>();
        RestResponse res = RestContext.response;
        try
        {
            /*
            Id contactId = [SELECT ContactId__c FROM User Where Id =: userId][0].ContactId__c;           

            if(!String.isBlank(contactId))
            {
                AggregateResult[] results = [SELECT COUNT(Id)num, Stage__c FROM Referral__c WHERE Referrer__c =: contactId and Brand_Picklist__c =: inputBrand Group By Stage__c];
                for(AggregateResult referral : results){
                    if(referral.get('Stage__c').equals('Opened') || referral.get('Stage__c').equals('Expiring')){ 
                        friendReferrals += (Integer)referral.get('num');
                    }
                    else if(referral.get('Stage__c').equals('SuccessfullyReferred')){ 
                        successfulReferrals += (Integer)referral.get('num');
                    }
                    
                }
            }
            */

            List<User> users = [SELECT /*ContactId__c,*/ ContactId, Contact.AccountId FROM User WHERE Id =:userId];

            if( users <> null && !users.isEmpty())
            {
                AggregateResult[] results = [SELECT COUNT(Id)num, Stage__c 
                                             FROM Referral__c 
                                             WHERE Referrer_Account__c =: users.get(0).Contact.AccountId 
                                             AND Brand_Picklist__c =: inputBrand 
                                             GROUP BY Stage__c];

                for(AggregateResult referral : results)
                {
                    if(referral.get('Stage__c').equals('Opened') || referral.get('Stage__c').equals('Expiring')){ 
                        friendReferrals += (Integer)referral.get('num');
                    }
                    else if(referral.get('Stage__c').equals('SuccessfullyReferred')){ 
                        successfulReferrals += (Integer)referral.get('num');
                    }
                    
                }
            }
            
            returnObject.put('FriendReferrals', friendReferrals);   
            returnObject.put('SuccessfulReferrals', successfulReferrals);   
            res.statusCode = 200;
        }
        catch(Exception e ){
            //Catch the error If any
            loggerDataPool.buildLogDataPool('REFFGetReferralByCustomerAPI', e);
            errorMsg = 'A system exception has occurred, Please contact your administrator.';
            errorRes.put('ErrorCode', 'Err04-SF');
            errorRes.put('Message', errorMsg);  
            errorResList.add(errorRes);
            res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
            res.statusCode=400;
        }
        
        //Return the Number of FriendReferrals and SuccessfulReferrals  
        if(res.statusCode==200)
        {
            res.responseBody = Blob.valueOf(JSON.serialize(returnObject));
        }
        RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
        serviceDataPool.buildServiceDataPool('getReferralByCustomer', 'REFFGetReferralByCustomerAPI', '', request, res);
    }
    
    
}
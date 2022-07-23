/** ******
 * Description : API Class used to retrieve Referree Information of the corresponding Referrer (i.e. Customer Contact)
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20200212             AT@aodigy           Created Initial Version. 
 * 20200311             HS@aodigy           Added PA Changes
 * 20200907             Thu@aodigy          Amended for PA-Phase2 Changes. Retain only PersonAccount checking for referral
 * 20220110             Thu@aodigy          Modified to use Referee Infor from Referral obj.
* *******/
@RestResource(urlMapping='/GetReferallByCustomerDetails/User/*/Stage/*')
 
global with sharing class REFFGetReferralByCustomerDetailsAPI {

    @HttpGet
    global static void getReferralByCustomerDetails(){

        Map<String, Object> responseMap = new Map<String, Object>();
        List<Map<String, String>> refMaps = new List<Map<String,String>>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try{
            String inputUserId = req.requestURI.substringBetween('User/','/Stage');
            String inputStage = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

            List<User> users = [SELECT ContactId, Contact.AccountId FROM User WHERE Id =:inputUserId];

            Set<String> setInputStage = new Set<String>();
            if(!inputStage.contains('Success'))
            {   
                setInputStage.add('Expiring');
                setInputStage.add('Opened');
            }
            else
            {
                setInputStage.add(inputStage);
            }
            
            if(!users.isEmpty())
            {
                List<Referral__c> refs_pa = new List<Referral__c>();
                List<Referral__c> refs_cnt = new List<Referral__c>();

                if( users[0].ContactId <> null && users[0].Contact.AccountId <> null )
                {
                    refs_pa = ReferralService.getReferralListByPersonAccountAndStage( new Set<String>{ users[0].Contact.AccountId }, setInputStage );    
                }
                               
                System.debug('@@@ refs_pa: '+refs_pa.size() +' --- ' + refs_pa);
                System.debug('@@@ refs_cnt: '+refs_cnt.size() +' --- ' + refs_cnt);
                if( refs_pa <> null && !refs_pa.isEmpty() ) {   
                    for(Referral__c ref : refs_pa) {   
                        
                        if( ref.Referrer_Account__c <> null && ref.Referee_Account__c <> null ) {
                            refMaps.add(new Map<String,String>{ 'CustomerName'      => /*ref.Referee_Account__r.Name*/ String.isNotBlank(ref.Referree__c) && String.isNotBlank(ref.Referee_Last_Name__c) ? ref.Referree__c + ' ' + ref.Referee_Last_Name__c : '',
                                                                'CustomerEmail'     => ref.Referee_Account__r.PersonEmail,
                                                                'PhoneNumber'       => /*ref.Referee_Account__r.PersonMobilePhone.right(8)*/ String.isNotBlank(ref.Referee_Mobile_Number__c) ? ref.Referee_Mobile_Number__c.right(8) : '',
                                                                'Brand'             => ref.Brand_Picklist__c,
                                                                'ReferralCreateDate'=> String.valueOf(ref.CreatedDate) });

                        }
                    }
                }
            }
            responseMap.put('referral', refMaps);

            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 200;
            responseMap.put('Status', 'Success');
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap)); 
        }
        catch(Exception ex){
            res.addHeader('Content-Type', 'application/json');
            responseMap.put('Status', 'Failed');
            responseMap.put('Message', ex.getMessage());
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap)); 
            res.statusCode = 400;
        }
        
        serviceDataPool.buildServiceDataPool('getReferralByCustomerDetails', 'REFFGetReferralByCustomerDetailsAPI', '', req, res);
        
    }


}
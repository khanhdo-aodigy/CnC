/** ******
 * Description : API Class used to retrieve the list of Sales Consultant & Default Sales Consultant
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                    Description
 * 20200212             Tho@aodigy              Created Initial Version. 
 * 20200923             HS@aodigy               PA-Phase 2 : Removed the Referral count checking based on User.ContactId__c
 * 
* *******/
@RestResource(urlMapping='/GetSalesConsultant/UserId/*/Branch/*')
global with sharing class REFFGetSalesConsultantAPI {
    
    @HttpGet
    global static void getSalesConsultantByBranch(){
        String DEFAULT_SC_ID = 'DefaultScId';
        String NAME = 'Name'; 
        Map<String, Object> responseMap = new Map<String, Object>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try{
            String inputUserId = req.requestURI.substringBetween('UserId/','/Branch');
            String inputBranch = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

            System.debug('inputUserId: ' + inputUserId);
            List<User> users = [SELECT Id, Name, ContactId, Contact.AccountId, /*ContactId__c,*/Is_Eligible_Opp_Owner__c 
                                FROM User 
                                WHERE ( (Profile.Name = 'CITPC Sales' OR Profile.Name = 'KIAPC Sales' OR Profile.Name = 'MITPC Sales') 
                                            AND Is_Eligible_Opp_Owner__c = true 
                                            AND Branch_Code__c =:inputBranch 
                                            AND IsActive = true)
                                        OR Id =:inputUserId ];
            
            String contactId;
            List<Map<String,String>> userInfos = new List<Map<String,String>>();
            
            if(!users.isEmpty()){
                for(User us : users){
                    Map<String, String> userInfo = new Map<String, String>{DEFAULT_SC_ID => us.Id, NAME => us.Name};
                        System.debug('contactId: ' + us.Id);
                    
                    if(us.Id == inputUserId){
                        // contactId = us.ContactId__c;
                        contactId = us.ContactId;
                    }
                    else{
                        userInfos.add(userInfo);    
                    }
                }
            }
            responseMap.put('ListOfSC', userInfos);
            
            String defaultSCId;
            String userName; 
            if( String.isNotBlank(contactId) ){
                List<Opportunity> opps = [ SELECT Owner.Name, Owner.Id 
                                           FROM Opportunity
                                           WHERE Contact_Person__c =: contactId
                                           ORDER BY CreatedDate DESC LIMIT 1];
                
                defaultSCId = opps.isEmpty() ? '' : opps[0].Owner.Id;
                userName    = opps.isEmpty() ? '' : opps[0].Owner.Name;                            
            }  
            responseMap.put(DEFAULT_SC_ID, defaultSCId);
            responseMap.put(NAME, userName);
            
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
        
        serviceDataPool.buildServiceDataPool('getSalesConsultantByBranch', 'REFFGetSalesConsultantAPI', '', req, res);
    }
    
}
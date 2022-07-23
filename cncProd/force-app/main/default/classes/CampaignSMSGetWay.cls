/** ******
 * Description : CampaignSMSGetWay API class to insert SMS Reply
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20160511             NAIT Admin                      Created Initial Version. 
 * 20200827             khanh.do@aodigy.com             Added PA - Phase 2 Changes
 * 
***** **/
@RestResource(urlMapping='/Campaign/*')
global without sharing class CampaignSMSGetWay {

    @HttpPost
    global static void getPost() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
     	res.responseBody = Blob.valueOf('OK');
        
        HttpResponse rese=new HttpResponse();
               
        String Mobile     = req.params.get('Mobile');
        String Type       = req.params.get('Type');
        String Message    = req.params.get('Message');
        String Timestamp  = req.params.get('Timestamp');
        String ServiceNum = req.params.get('ServiceNum');
        String respo      = 'OK';

        if (Message!=null)
        {    
            String returnMessage = 'No Key';
            String keyCampaign   = Message.Left(Message.indexOf(' '));
            String theMessage    = Message.substring(Message.indexOf(' ') + 1);
            String thephone      = Mobile;
            String thephone2     = '+'+Mobile;
            String thephone3     = Mobile.subString(2);
            
            List<Campaign> lstCampaign  = [SELECT Id FROM Campaign WHERE Campaign_Code_Key__c = :keyCampaign AND IsActive = true ORDER BY CreatedDate DESC];
            
            SMS_Reply__c smsReplyObj = new SMS_Reply__c();
            smsReplyObj.Name         = Mobile;
            smsReplyObj.Message__c   = Message;

            if (lstCampaign.size()>0){
                smsReplyObj.Campaign__c = lstCampaign[0].Id;
                smsReplyObj.Message__c  = theMessage;
                List<CampaignMember> lstCampMembers = [ SELECT Id, ContactId FROM CampaignMember WHERE CampaignID =:lstCampaign[0].Id ];
                
                if (lstCampMembers.size()>0){
                    Map<Id,CampaignMember> mcm = new Map<ID,CampaignMember>();
                    List<Id> lstCntIds = new List<ID>();

                    for (CampaignMember cmm : lstCampMembers)
                    {
                        lstCntIds.add( cmm.ContactId );
                        mcm.put( cmm.ContactId, cmm );
                    }

					System.debug(lstCntIds);
                    /** PA MIGRATION : Newly Added part-1 start ; IDEAL FLOW
                    List<Contact> lstPAContact = [SELECT Id, AccountId, Account.RecordTypeId
                                                  FROM Contact 
                                                  WHERE Id =:lstCntIds 
                                                  AND ( MobilePhone =:thephone OR MobilePhone =:thephone2 OR MobilePhone =:thephone3 )
                                                  AND IsPersonAccount = true
                                                  AND Account.RecordType.DeveloperName IN ('Customer')];
                    
                    if( lstPAContact.size() > 0 ) {
                        CampaignMember CM = mcm.get( lstPAContact[0].Id );
                        smsReplyObj.Contact__c        = lstPAContact[0].Id;         // Person Account ContactId
                        smsReplyObj.Account__c = lstPAContact[0].AccountId;  // Person Account AccountId
                    
                        CM.SMS_Status__c = 'Responded';
                        update CM;
                    }
                     PA MIGRATION : Newly Added part-1 end */

                    List<Contact> lstContact = [SELECT Id, AccountId, Account.RecordTypeId // Account__c, Account__r.RecordTypeId 
                                                FROM Contact 
                                                WHERE Id =:lstCntIds 
                                                AND ( MobilePhone =:thephone OR MobilePhone =:thephone2 OR MobilePhone =:thephone3 )
                                                AND IsPersonAccount = true];
                    if (lstContact.size()>0)
                    {
                        CampaignMember campaignMember = mcm.get( lstContact[0].Id );
                        smsReplyObj.Contact__c = lstContact[0].Id;
                        smsReplyObj.Account__c = lstContact[0].AccountId; 
                    
                        campaignMember.SMS_Status__c = 'Responded';
                        update campaignMember;
                    }
                }
            }
            
            insert smsReplyObj;
        }
    }
}
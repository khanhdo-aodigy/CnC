/** *****
 * Description : Batch class to create prospect PA from Lead
 * 
 * Change History
 * Date(YYYYMMDD)      Name        Description
 * 20200224            AT          Created Initial Version. 
 * 
** *****/
global class PABatchLeadToPAConverter implements Database.Batchable<sObject>, Database.Stateful{

    private List<String> errMsgs = new List<String>();
    Set<Id> setTargetedLeadIds = new Set<Id>();

    global PABatchLeadToPAConverter(){}

    global PABatchLeadToPAConverter( Set<Id> setOfLeadIds ){
        this.setTargetedLeadIds = setOfLeadIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        LeadSelector selector = new LeadSelector();
        // return Database.getQueryLocator( selector.getUnconvertedLead() );
        System.debug('@@@@DEBUG PABatchLeadToPAConverter >> start >> setTargetedLeadIds.size() = ' + setTargetedLeadIds.size() );
        return Database.getQueryLocator( selector.getUnconvertedLead(  ((setTargetedLeadIds<>null && !setTargetedLeadIds.isEmpty())  ? setTargetedLeadIds : null )  ) );
        //return Database.getQueryLocator( selector.getSelectiveUnconvertedLead(setTargetedLeadIds) );
    }

    global void execute(Database.BatchableContext bc, List<Lead> leads){
        System.debug('@@@@DEBUG PABatchLeadToPAConverter >> execute >> leads.size() = ' + leads.size() );

        try{
            List<String> childObjects = new List<String>{'Event_Registration__c','Share__c','ClashDeal__c','Opportunity','Invoice__c',
                                                        'Custom_Quote__c','Customer_Detail__c','Test_Drive__c','Feedback__c'};
            
            LeadSelector selector = new LeadSelector();
            Set<String> leadIds = new Set<String>();
            for(Lead ld : leads){
                leadIds.add(ld.Id);
            }

            List<Map<String, List<SObject>>> childListMaps = new List<Map<String, List<SObject>>>();
            for(String childObject : childObjects){
                childListMaps.add(selector.getSObjectLeadMap(leadIds, childObject));
            }                                            
            
            PAMigrationService.processConversion(leads, childListMaps);
        }
        catch(Exception ex){
            errMsgs.add(ex.getMessage());
        }
        
    }

    global void finish(Database.BatchableContext BC){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses              = new String[] {'hwanshyan.lim@aodigy.com'};
        mail.setToAddresses(toAddresses);
        // mail.setTargetObjectId( UserInfo.getUserId() );
    	// mail.setSaveAsActivity(false);
        String body;
        if(!errMsgs.isEmpty()){
            for(Integer i=0; i<errMsgs.size(); i++){
                body += (String.valueof(i+1)+' '+errMsgs[i]+ '\r\n');
            }
            System.debug('@@@@DEBUG PABatchLeadToPAConverter >> finish :: body = ' + body);
        }
        else{
            body = 'Success';
        }
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}
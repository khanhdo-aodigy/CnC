/** *****
 * Description : Batch Class to Update Reward Status According to Expiry Date
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name              Description
 * 20200622            KD@aodigy         Created Initial Version 
 * 
** *****/
global class CMBatchUpdateRewardStatus implements Database.Batchable<sObject>, Database.Stateful {

    private List<String> errMsgs = new List<String>();

    private Set<String> setRewardIds = new Set<String>();

    global CMBatchUpdateRewardStatus(){}
    
    global CMBatchUpdateRewardStatus( Set<String> rewardIds )
    {
        this.setRewardIds = rewardIds;
    }

    global Database.QueryLocator start(Database.BatchableContext db)
    {
        String query = ' SELECT Id, Status__c, Expiry__c, Remainder__c'
                     + ' FROM Reward__c ' 
                     + ' WHERE Expiry__c != null '
                     + ' AND Expiry__c < TODAY '
                     + ' AND Status__c = \'Valid\' '
                     + ' AND Remainder__c > 0 ';        
        
        if( setRewardIds <> null && !setRewardIds.isEmpty() ){
            query += ' AND ID IN :setRewardIds ';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext db, List<Reward__c> scope)
    {
        try
        {
            System.debug('@@@@DEBUG CMBatchUpdateRewardStatus >> execute :: scope = ' + scope.size() );
            Date today = Date.today();
            List<Reward__c> rewardsToUpdate = new List<Reward__c>();
            List<Reward_Usage__c> rewardUsageToInsert = new List<Reward_Usage__c>();
            for(Reward__c reward: scope) 
            {
                // if(reward.Expiry__c != null && reward.Expiry__c < today && reward.Status__c == 'Valid') {
                    reward.Status__c = 'Expired';
                    rewardsToUpdate.add(reward);

                    Reward_Usage__c newRewardUsage = new Reward_Usage__c();
                    newRewardUsage.RecordTypeId = RewardUsageService.getRecordTypeId('Debit');
                    newRewardUsage.Reward__c           = reward.Id;
                    newRewardUsage.Channel__c          = 'System';
                    newRewardUsage.Status__c           = 'Expired';
                    newRewardUsage.Type__c             = 'Expiry';
                    newRewardUsage.Transaction_Date__c = Date.today();
                    // newRewardUsage.Invoice_Amount__c   = reward.Remainder__c;
                    newRewardUsage.Invoice_Amount__c   = 0;
                    newRewardUsage.Credit_Amount__c    = reward.Remainder__c;
                    newRewardUsage.Order__c            = null;
                    newRewardUsage.Order_Number__c     = null;
                    rewardUsageToInsert.add(newRewardUsage);
                // }
            }

            System.debug('===== rewardsToUpdate.size = ' + rewardsToUpdate.size());
            System.debug('===== rewardsToUpdate = ' + rewardsToUpdate);
            if(rewardsToUpdate.size() > 0) {            
                update rewardsToUpdate;
            }
            
            if(rewardUsageToInsert.size() > 0) {
                insert rewardUsageToInsert;
            }
        } 
        catch(Exception ex)
        {
            System.debug('@@@ ex: '+ex.getMessage());
            errMsgs.add( ex.getCause() + ' -- ' + ex.getMessage() + ' -- ' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('CMBatchUpdateRewardStatus', ex);
        }
        
    }

    global void finish(Database.BatchableContext bc)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // String[] toAddresses = new String[] {'khanh.do@aodigy.com'};
        // mail.setToAddresses( toAddresses );
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.saveAsActivity = false;
        String body;
        if(!errMsgs.isEmpty()){
            for(Integer i = 0; i < errMsgs.size(); i++){
                body += (String.valueof(i+1)+' '+errMsgs[i]+ '\r\n');
            }
        }
        else{
            body = 'CMBatchUpdateRewardStatus Processed Successfully !!!';
        }
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
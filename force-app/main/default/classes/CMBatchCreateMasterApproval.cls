/** ******
 * Description : Batch Class for Creating Master Approval used in Write Back Process.
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20200729          TP@aodigy.com                   Created Initial Version. 
 * 
***** **/
global class CMBatchCreateMasterApproval implements Database.Batchable<sObject>
{
    private String filter = '';
    private String listViewID = '';

    public CMBatchCreateMasterApproval(String listId, String queryStr) 
    {
        System.debug('@@@@DEBUG CMBatchCreateMasterApproval :: listId = ' + listId );
        System.debug('@@@@DEBUG CMBatchCreateMasterApproval :: queryStr = ' + queryStr );

        this.filter = queryStr.containsIgnoreCase('WHERE') ? queryStr.substringAfter('WHERE') : '';
        this.listViewID = listId;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String queryFields = 'SELECT Id, Credit_Amount__c, Master_Approval__c, Source__c FROM Reward_Usage__c';
        String queryString = filter == '' ? queryFields : queryFields + ' WHERE ' + filter;
        System.debug('@@@@DEBUG CMBatchCreateMasterApproval :: Constructed query string: ' + queryString);
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext bc, List<Reward_Usage__c> rewardUsages)
    {
        List<Reward_Usage__c> afterSalesList = new List<Reward_Usage__c>();
        List<Reward_Usage__c> vehicleSalesList = new List<Reward_Usage__c>();
        
        try {
            for (Reward_Usage__c  usage: rewardUsages)
            {
                
                
                if (usage.Source__c == 'New Car Purchase' || usage.Source__c == 'Sales - Goodwill' || usage.Source__c == 'Sold Credits')
                {
                    afterSalesList.add(usage);
                }
                else 
                {
                    vehicleSalesList.add(usage);
                }
            }
            
            if (afterSalesList.size() > 0) 
            {
                createMasterApproval(afterSalesList, 'AfterSales');
            } 
            
            if (vehicleSalesList.size() > 0)
            {
                createMasterApproval(vehicleSalesList, 'VehicleSales');
            } 
        }
        catch (Exception e)
        {
            loggerDataPool.buildLogDataPool('CMBatchCreateMasterApproval', e);
        }
    }
    
    private void createMasterApproval(List<Reward_Usage__c> rewardUsages, String source)
    {
        Master_Approval__c existingMasterApproval = MasterApprovalService.getMasterApprovalByUniqueKey(String.valueOf(Date.today()) + '_' + listViewID + '_' + source);
        
        Decimal totalAmount = 0;
        for (Reward_Usage__c usage : rewardUsages)
        {
            totalAmount += usage.Credit_Amount__c;  
        }
        
        if (existingMasterApproval == null)
        { 
            Master_Approval__c newMasterApproval = new Master_Approval__c();
            // newMasterApproval.Approval_Status__c = 'Pending for Approval';
            newMasterApproval.Request_Type__c    = 'Writeback';
            newMasterApproval.Submitted_Date__c  = Date.today();
            newMasterApproval.Total_Amount__c    = totalAmount;
            newMasterApproval.Department__c      = source;
            newMasterApproval.Filtered_Criteria__c= filter;
            newMasterApproval.Unique_Key__c      = String.valueOf(Date.today()) + '_' + listViewID + '_' + source;
            
            insert newMasterApproval;
            
            updateRewardUsages(rewardUsages, newMasterApproval);
        }
        else
        {
            existingMasterApproval.Total_Amount__c = existingMasterApproval.Total_Amount__c + totalAmount; 
            update existingMasterApproval;
            
           updateRewardUsages(rewardUsages, existingMasterApproval);
        }
    }
    
    private void updateRewardUsages (List<Reward_Usage__c> rewardUsages, Master_Approval__c masterApproval)
    {
        for (Reward_Usage__c usage : rewardUsages)
        {
            usage.Master_Approval__c = masterApproval.Id;
        }
        
        update rewardUsages;
    }
     
    global void finish(Database.BatchableContext bc)
    {
        /*
        AsyncApexJob a = [SELECT Id, JobType, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CompletedDate FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'phan.thu@aodigy.com'});
        mail.setSubject('Batch Create Master Approval ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        */

        batchDataPool.buildBatchDataPool('CMBatchCreateMasterApproval', bc.getJobId());
    }
}
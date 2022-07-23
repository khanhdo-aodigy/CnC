/** ******
 * Description : Service Class for Debit Usage
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20200617             TP@aodigy.com                   Created Initial Version. * 
 * 20200903             khanh.do@aodigy.com             Added calling to CMUsageTransactionService
 * 20200904             TP@aodigy.com                   Added createAdjustment method
***** **/
public with sharing class CMDebitUsageService {
    
    public static Boolean checkRewardProfileRemainder (String rewardProfileId, Decimal creditAmount) 
    {
        Reward_Profile__c relatedRewardProfile = RewardProfileService.getRewardProfileById(rewardProfileId);
        
        return relatedRewardProfile.Total_Remainder__c >= creditAmount ? true : false;
    }

    public static Boolean checkTotalRemainder (List<Reward__c> rewards, Decimal creditAmount) 
    {
        return calculateTotalRemainder(rewards) >= creditAmount ? true: false;
    }

    public static Decimal calculateTotalRemainder (List<Reward__c> rewards) 
    {
        Decimal totalRemainder = 0;
        for (Reward__c reward : rewards)
        {
            totalRemainder += reward.Remainder__c;
        }

        return totalRemainder;
    }
    
    @AuraEnabled
    public static Boolean isAuthorizedUser(String customPermission)
    {
        return FeatureManagement.checkPermission(customPermission);
    }

    @AuraEnabled(cacheable=true)
    public static Reward__c retrieveReward(String rewardId)
    {
        return RewardService.getRewardsByRecordIds(new Set<Id>{rewardId})[0];
    }

    @AuraEnabled(cacheable=true)
    public static Reward_Profile__c retrieveRewardProfile(String rewardProfileId)
    {
        return RewardProfileService.getRewardProfileById(rewardProfileId);
    }

    @AuraEnabled
    public static List<Reward_Usage__c> createAdjustment (String rewardProfileId, Decimal amount, String requestBy, String dsaNo, String remarks)
    {
        if (!checkRewardProfileRemainder(rewardProfileId, amount)) 
        {
            throw new AuraHandledException('Adjustment Amount Cannot Greater Than Total Remainder Amount');
        }

        Reward_Profile__c rewardProfile = RewardProfileService.getRewardProfileById(rewardProfileId);
        List<Reward__c> relatedRewards  = RewardService.getRewardsByRewardProfileId(rewardProfileId, rewardProfile.Type__c);
        if (relatedRewards == null)
        {
            throw new AuraHandledException('No Valid Rewards Of Type \'' + rewardProfile.Type__c + '\' Found.');
        }
        List<Reward_Usage__c> newRewardUsages = new List<Reward_Usage__c>();
        newRewardUsages = rewardCreditDeduction(relatedRewards, amount, true);       

        if (newRewardUsages == null || newRewardUsages.isEmpty())
        {
            throw new AuraHandledException('No Reward Usages Created.');
        }

        try 
        {
            for (Reward_Usage__c newRewardUsage : newRewardUsages)
            {
                newRewardUsage.RecordTypeId               = RewardUsageService.getRecordTypeId('Debit');
                newRewardUsage.Status__c                  = 'Issued';
                newRewardUsage.Type__c                    = 'Adjustment';
                newRewardUsage.Channel__c                 = 'Finance';
                newRewardUsage.Transaction_Date__c        = Date.today();
                newRewardUsage.DSA_No__c                  = dsaNo;
                newRewardUsage.Request_By__c              = requestBy;
                newRewardUsage.Remarks__c                 = remarks;
            }

            insert newRewardUsages;
        }
        catch(Exception e)
        {
            System.debug('e cause = ' + e.getCause() + ' ' + e.getTypeName() + ' ' + e.getLineNumber());
            loggerDataPool.buildLogDataPool('CMDebitUsageService.createAdjustment', e);
            throw new AuraHandledException(e.getMessage());
        }
        
        return newRewardUsages;
    }

    @AuraEnabled
    public static /*List<Reward_Usage__c>*/ Attachment createDebitRewardUsages (String rewardProfileId, 
                                                                 Decimal invoiceAmount, 
                                                                 String invoiceNumber, 
                                                                 Decimal creditAmount, 
                                                                 Date invoiceDate, 
                                                                 Decimal outStandingAmount,
                                                                 String paymentType, 
                                                                 Decimal totalRemainderBefore)
    {
        if (creditAmount <= 0) {
            throw new AuraHandledException('Insufficient Credit');
        }

        if (creditAmount > invoiceAmount) {
            throw new AuraHandledException('Credit Amount Cannot Greater Than Invoice Amount');
        }

        if (outStandingAmount > 0 && String.isBlank(paymentType)) {
            throw new AuraHandledException('Payment Type is Required for Non-credit Amount');
        }

        List<Reward_Usage__c> newRewardUsages = new List<Reward_Usage__c>();
        Attachment newAttachment= new Attachment();
        try 
        {
            if (RewardUsageService.getDebitRewardUsagesByInvoiceNo(invoiceNumber, RewardUsageService.getRecordTypeId('Debit')) <> null)
            {
                AuraHandledException e = new AuraHandledException('Error');
                e.setMessage('Duplicated Invoice Entry');
                throw e;
            }

            if (!checkRewardProfileRemainder(rewardProfileId, creditAmount)) 
            {
                AuraHandledException e = new AuraHandledException('Error');
                e.setMessage('Credit Amount Cannot Greater Than Total Remainder Amount');
                throw e;
            }
            else 
            {
                Reward_Profile__c rewardProfile = RewardProfileService.getRewardProfileById(rewardProfileId);
                List<Reward__c> relatedRewards  = RewardService.getRewardsByRewardProfileId(rewardProfileId, rewardProfile.Type__c);
                if (relatedRewards == null)
                {
                    AuraHandledException e = new AuraHandledException('Error');
                    e.setMessage('No Valid Rewards Of Type \'' + rewardProfile.Type__c + '\' Found.');
                    throw e;
                }
                else 
                {
                    newRewardUsages = rewardCreditDeduction(relatedRewards, creditAmount, true);       

                    if (newRewardUsages == null || newRewardUsages.isEmpty())
                    {
                        AuraHandledException e = new AuraHandledException('Error');
                        e.setMessage('No Reward Usages Created.');
                        throw e;
                    }
                    else 
                    {
                        for (Reward_Usage__c newRewardUsage : newRewardUsages)
                        {
                            newRewardUsage.RecordTypeId               = RewardUsageService.getRecordTypeId('Debit');
                            newRewardUsage.Invoice_Amount__c          = invoiceAmount;
                            newRewardUsage.Autoline_Invoice_Number__c = invoiceNumber;
                            newRewardUsage.Autoline_Invoice_Date__c   = invoiceDate;
                            newRewardUsage.Status__c                  = 'Utilised';
                            newRewardUsage.Type__c                    = 'Purchase';
                            newRewardUsage.Channel__c                 = 'Retail';
                            // newRewardUsage.Transaction_Date__c        = Date.today();
                            newRewardUsage.Transaction_Date__c        = invoiceDate;
                            newRewardUsage.Payment_Type__c            = paymentType;
                            newRewardUsage.Outstanding_Payment_Amount__c = outStandingAmount;
                        }

                        insert newRewardUsages;

                        CMUsageTransactionService.processUsageTransaction(newRewardUsages);
                        
                        rewardProfile = RewardProfileService.getRewardProfileById(rewardProfileId);
                        
                        System.debug('CALL CMAttachmentService STARTS :: ');
                        newAttachment = CMAttachmentService.generateDebitUsageAttachment(rewardProfileId, totalRemainderBefore, invoiceDate, invoiceNumber, invoiceAmount, creditAmount, outStandingAmount, rewardProfile.Total_Remainder__c);
                    }
                }               
            }           
        }
        catch (Exception e) 
        {   
            System.debug('e cause = ' + e.getCause() + ' ' + e.getTypeName() + ' ' + e.getLineNumber());
            loggerDataPool.buildLogDataPool('CMDebitUsageService.createDebitRewardUsages', e);
            throw new AuraHandledException(e.getMessage());
        }
        System.debug( '**createDebitRewardUsages** newRewardUsages = ' + newRewardUsages);
        return newAttachment;  
    }

    public static List<Reward_Usage__c> rewardCreditDeduction (List<Reward__c> relatedRewards, Decimal creditAmount, Boolean isUpdate) 
    {
        List<Reward_Usage__c> returnedRewardUsages = new List<Reward_Usage__c>();
        List<Reward__c> rewardsToUpdate            = new List<Reward__c>();
        
        if (relatedRewards <> null) 
        {
            for (Reward__c reward: relatedRewards) 
            {
                if (reward.Remainder__c <= 0)
                {
                    continue;
                }

                Reward_Usage__c newRewardUsage = new Reward_Usage__c();

                if (reward.Remainder__c > creditAmount && creditAmount != 0) 
                {                                        
                    newRewardUsage.Credit_Amount__c = creditAmount;
                    newRewardUsage.Reward__c        = reward.Id;
                    newRewardUsage.Contact__c       = reward.Contact__c;
                    returnedRewardUsages.add(newRewardUsage);       
                    break;
                } 
                else if (reward.Remainder__c == creditAmount && creditAmount != 0)
                {
                    newRewardUsage.Credit_Amount__c = creditAmount;
                    newRewardUsage.Reward__c        = reward.Id;
                    newRewardUsage.Contact__c       = reward.Contact__c;
                    returnedRewardUsages.add(newRewardUsage);       
                    
                    reward.Status__c = 'Consumed';
                    rewardsToUpdate.add(reward);
                    break;
                }
                else if (reward.Remainder__c < creditAmount && creditAmount != 0)
                {
                    newRewardUsage.Credit_Amount__c = reward.Remainder__c;
                    newRewardUsage.Reward__c        = reward.Id;
                    newRewardUsage.Contact__c       = reward.Contact__c;
                    creditAmount                    = creditAmount - reward.Remainder__c;
                    returnedRewardUsages.add(newRewardUsage);

                    reward.Status__c = 'Consumed';
                    rewardsToUpdate.add(reward);
                }
                else if (creditAmount == 0) 
                {
                    break;
                }            
            }       
        }

        if (rewardsToUpdate.size() > 0 && isUpdate) 
        {
            update rewardsToUpdate;
        }
        System.debug( 'rewardCreditDeduction returnedRewardUsages = ' + returnedRewardUsages);
        return returnedRewardUsages;   
    }
}
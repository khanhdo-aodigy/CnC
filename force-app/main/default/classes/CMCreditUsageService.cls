/** ******
 * Description : Service Class for Credit Usage
 *
 * Change History:
 * Date(YYYYMMDD)        Name                           Description
 * 20200619              TP@aodigy.com                  Created Initial Version.
 * 20200626              khanh.do@aodigy.com            Changed return type and params of createRewardCreditUsage to List<Reward_Usage__c>
 * 20200709              TP@aodigy.com                  Added extendRewardExpiry method.
 * 20200903              khanh.do@aodigy.com            Added calling to CMUsageTransactionService
 * 
 ***** **/
public with sharing class CMCreditUsageService {

    public static List<Reward_Usage__c> createRewardCreditUsage( String rewardProfileId, String invoiceNumber, String creditNote, Decimal refundAmount, String refundReason, Date issuedDate) 
    {
        Id rewardUsageDebitRT_Id = RewardUsageService.getRecordTypeId('Debit');
        Id rewardUsageCreditRT_Id = RewardUsageService.getRecordTypeId('Credit');
        Map<String,Decimal> mapInvoiceTotalDebit = new Map<String,Decimal>();
        Map<String,Decimal> mapInvoiceTotalCredit = new Map<String,Decimal>();
        List<Reward_Usage__c> newRewardUsages = new List<Reward_Usage__c>();
        List<Reward_Usage__c> relatedRewardUsages = RewardUsageService.getRewardUsagesByInvoiceNo( invoiceNumber, rewardProfileId );
        List<Reward_Usage__c> lstDebitedUsages = new List<Reward_Usage__c>();
        List<Reward_Usage__c> existingRewardUsages = RewardUsageService.getRewardUsagesByCreditNote(creditNote, rewardUsageCreditRT_Id);

        System.debug('@@@@DEBUG createRewardCreditUsage :: invoiceNumber = ' + invoiceNumber + ' --- creditNote = ' + creditNote + ' --- refundAmount = ' + refundAmount );

        Decimal creditAmount;
        Decimal totalCreditedAmount = 0;
        if(!(refundAmount > 0)) {
            throw new AuraHandledException('Refund Amount Must Be Greater Than 0');
        }
        
        if(relatedRewardUsages == null) {
            // throw new AuraHandledException('No Consumed Or Valid Reward Usage Found with Entered Invoice No.');
            throw new AuraHandledException('No Debit Usage Found with Entered Invoice No.');
        }

        if (existingRewardUsages <> null) {
            throw new AuraHandledException('Duplicated Credit Note Entry.');
        }

        for(Reward_Usage__c usage : relatedRewardUsages) 
        {
            if( usage.RecordTypeId == rewardUsageDebitRT_Id && usage.Status__c == 'Utilised' ) {
                lstDebitedUsages.add( usage );
                if( mapInvoiceTotalDebit.containsKey( usage.Autoline_Invoice_Number__c ) ){
                    mapInvoiceTotalDebit.put( usage.Autoline_Invoice_Number__c , mapInvoiceTotalDebit.get( usage.Autoline_Invoice_Number__c ) + usage.Credit_Amount__c );
                }
                else{
                    mapInvoiceTotalDebit.put( usage.Autoline_Invoice_Number__c , usage.Credit_Amount__c );
                }
            }

            if( usage.RecordTypeId == rewardUsageCreditRT_Id && usage.Type__c == 'Refund' && usage.Status__c == 'Issued' ) {
                if( mapInvoiceTotalCredit.containsKey( usage.Autoline_Invoice_Number__c ) ){
                    mapInvoiceTotalCredit.put( usage.Autoline_Invoice_Number__c , mapInvoiceTotalCredit.get( usage.Autoline_Invoice_Number__c ) + usage.Credit_Amount__c );
                }
                else{
                    mapInvoiceTotalCredit.put( usage.Autoline_Invoice_Number__c , usage.Credit_Amount__c );
                }
            }
        }

        Decimal totalUtilisedCredit = mapInvoiceTotalDebit.containsKey(invoiceNumber) ? mapInvoiceTotalDebit.get(invoiceNumber) : 0;
        Decimal totalIssuedRefund = mapInvoiceTotalCredit.containsKey(invoiceNumber) ? mapInvoiceTotalCredit.get(invoiceNumber) : 0;
        Decimal totalEntitledRefundAmt = totalUtilisedCredit - totalIssuedRefund;
        System.debug('@@@@DEBUG createRewardCreditUsage :: mapInvoiceTotalDebit = ' + mapInvoiceTotalDebit );
        System.debug('@@@@DEBUG createRewardCreditUsage :: mapInvoiceTotalCredit = ' + mapInvoiceTotalCredit );
        System.debug('@@@@DEBUG createRewardCreditUsage :: totalUtilisedCredit = ' + totalUtilisedCredit );
        System.debug('@@@@DEBUG createRewardCreditUsage :: totalIssuedRefund = ' + totalIssuedRefund );
        System.debug('@@@@DEBUG createRewardCreditUsage :: totalEntitledRefundAmt = ' + totalEntitledRefundAmt );
        System.debug('@@@@DEBUG createRewardCreditUsage :: lstDebitedUsages = ' + lstDebitedUsages.size() + ' --- ' + lstDebitedUsages );

        if( refundAmount > totalEntitledRefundAmt ) {
            throw new AuraHandledException('Refund Amount Cannot Greater Than The Eligible Refund Credit Amount of ' + totalEntitledRefundAmt );
        }

        try
        {   
            List<Reward__c> lstRewardsToUpdate = new List<Reward__c>();
            for(Reward_Usage__c rewardUsage : lstDebitedUsages) 
            {
                Decimal amount_deducted = rewardUsage.Credit_Amount__c;
                Decimal amount_refunded = 0.0;
                for(Reward_Usage__c refund : rewardUsage.Refunds__r ){
                    amount_refunded += refund.Credit_Amount__c;
                }

                //Utimately it should be the same for full-refund with multiple times of partial refund
                if( amount_refunded == amount_deducted ){
                    continue;
                }

                Reward_Usage__c newRefund = new Reward_Usage__c();
                newRefund.Reward__c       = rewardUsage.Reward__c;
                newRefund.Reward_Usage__c = rewardUsage.Id;
                newRefund.Contact__c      = rewardUsage.Contact__c;
                newRefund.Channel__c      = rewardUsage.Channel__c;
                newRefund.Invoice_Amount__c = rewardUsage.Invoice_Amount__c;
                newRefund.Autoline_Invoice_Date__c = rewardUsage.Autoline_Invoice_Date__c;

                System.debug('@@@@DEBUG createRewardCreditUsage :: amount_deducted = ' +  amount_deducted);
                System.debug('@@@@DEBUG createRewardCreditUsage :: amount_refunded = ' +  amount_refunded);
                System.debug('@@@@DEBUG createRewardCreditUsage :: amount_deducted - amount_refunded = ' +  (amount_deducted - amount_refunded) );
                System.debug('@@@@DEBUG createRewardCreditUsage :: refundAmount 111 = ' +  refundAmount);
                
                if( rewardUsage.Reward__r.Status__c == 'Consumed' ){
                    lstRewardsToUpdate.add( new Reward__c(Id=rewardUsage.Reward__c,Status__c = 'Valid') );
                }
                
                if( (amount_deducted - amount_refunded) >= refundAmount ) 
                {
                    newRefund.Credit_Amount__c = refundAmount;
                    newRewardUsages.add(newRefund);
                    break;
                }
                else if( (amount_deducted - amount_refunded) < refundAmount ) 
                {                    
                    newRefund.Credit_Amount__c = amount_deducted - amount_refunded;
                    refundAmount = refundAmount - newRefund.Credit_Amount__c;
                    newRewardUsages.add(newRefund);
                    System.debug('@@@@DEBUG createRewardCreditUsage :: refundAmount 222 = ' +  refundAmount);
                }
            }
        
            System.debug('newRewardUsages after loop == ' + newRewardUsages);
            String creditRecordTypeId = RewardUsageService.getRecordTypeId('Credit');
            for(Reward_Usage__c newRewardUsage : newRewardUsages) 
            {
                newRewardUsage.RecordTypeId               = creditRecordTypeId;
                newRewardUsage.Status__c                  = 'Issued';
                newRewardUsage.Type__c                    = 'Refund';
                // newRewardUsage.Channel__c                 = 'Service';
                newRewardUsage.Credit_Note__c             = creditNote;
                newRewardUsage.Refund_Reason__c           = refundReason;
                newRewardUsage.Transaction_Date__c        = issuedDate;
                newRewardUsage.Autoline_Invoice_Number__c = invoiceNumber;
            }

            insert newRewardUsages;
            if( lstRewardsToUpdate <> null && !lstRewardsToUpdate.isEmpty() ){
                update lstRewardsToUpdate;
            }
            System.debug('newRewardUsages == ' + newRewardUsages);
            Reward_Profile__c rewardProfile = RewardProfileService.getRewardProfileById(rewardProfileId);
            System.debug('*** CMCreditUsageService.RP == ' + rewardProfile);
            System.debug('CALL CMAttachmentService STARTS :: ');
            CMAttachmentService.generateCreditUsageAttachment(rewardProfileId, issuedDate, invoiceNumber, creditNote, refundAmount, refundReason, rewardProfile.Total_Remainder__c, rewardProfile.Total_Credited_Usage__c);
            
            CMUsageTransactionService.processUsageTransaction(newRewardUsages);
            return newRewardUsages;
        }   
        catch(Exception ex) 
        {
            System.debug('ex cause = ' + ex.getCause() + ' ' + ex.getTypeName() + ' ' + ex.getLineNumber());
            loggerDataPool.buildLogDataPool('CMCreditUsageService.createRewardCreditUsage', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean isAuthorizedUser(String customPermission)
    {
        return FeatureManagement.checkPermission(customPermission);
    }
    
    @AuraEnabled(cacheable=true)
    public static Attachment retrieveAttachment(String rewardProfileId, String creditNote, Date issuedDate)
    {
        return CMAttachmentService.getAttachmentById(rewardProfileId, creditNote, issuedDate);
    }

    @AuraEnabled
    public static Reward__c extendRewardExpiry(String rewardId,
                                         Decimal creditAmount,
                                         Date newExpiryDate,
                                         String extensionReason,
                                         Date transactionDate ) 
    {
        Reward__c rewardToUpdate = new Reward__c();
        Reward_Usage__c expiredRewardUsage = new Reward_Usage__c();
        Reward_Usage__c newRewardUsage = new Reward_Usage__c();
        try
        {   
            expiredRewardUsage = RewardUsageService.getExpiredRewardUsagesByRewardIds(new Set<Id>{rewardId})[0];
            rewardToUpdate     = RewardService.getRewardsByRecordIds(new Set<Id>{rewardId})[0];

            rewardToUpdate.Extension_Credit_Amount__c = creditAmount;
            rewardToUpdate.Extension_Reason__c        = extensionReason;
            rewardToUpdate.New_Expiry_Date__c         = newExpiryDate;
            rewardToUpdate.Status__c                  = 'Provisioning';
            rewardToUpdate.Approval_Status__c         = 'Pending for Approval';

            // update rewardToUpdate;

            newRewardUsage.RecordTypeId               = RewardUsageService.getRecordTypeId('Credit');
            newRewardUsage.Status__c                  = 'Provisioning';
            newRewardUsage.Type__c                    = 'Extension';
            newRewardUsage.Channel__c                 = expiredRewardUsage.Channel__c;//'Service';
            newRewardUsage.Transaction_Date__c        = transactionDate;
            newRewardUsage.Reward__c                  = rewardToUpdate.Id;
            newRewardUsage.Contact__c                 = rewardToUpdate.Contact__c;
            newRewardUsage.Reward_Usage__c            = expiredRewardUsage.Id;
            newRewardUsage.Credit_Amount__c           = creditAmount;
            newRewardUsage.New_Expiry_Date__c         = newExpiryDate;
            newRewardUsage.Extension_Reason__c        = extensionReason;

            // insert newRewardUsage;

            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Reward__c.SObjectType, Reward_Usage__c.SObjectType } );
            uow.registerNew(newRewardUsage, Reward_Usage__c.Reward__c, rewardToUpdate);
            uow.registerDirty(rewardToUpdate);
            uow.commitWork();

        } 
        catch (Exception e)
        {
            loggerDataPool.buildLogDataPool('CMCreditUsageService.extendRewardExpiry', e);
            System.debug('@@@@DEBUG extendRewardExpiry :: err.cause = ' + e.getCause() + ' --- err.msg = ' + e.getMessage() + ' --- err.line = ' + e.getLineNumber() );
            throw new AuraHandledException(e.getMessage());
        }
        
        return rewardToUpdate;      
    }

}
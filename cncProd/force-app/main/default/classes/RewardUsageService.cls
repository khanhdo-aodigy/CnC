/** ******
 * Description : Service Class for Reward Usage object
 *  
 * Change History:
 * Date(YYYYMMDD)        Name                       Description
 * 20200617              TP@aodigy                  Created Initial Version. 
 * 
***** **/
public with sharing class RewardUsageService {

    private static RewardUsageSelector rewardUsageSelector = new RewardUsageSelector();
    
    public static Id getRecordTypeId(String recordTypeLabel) {
        return Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get(recordTypeLabel).getRecordTypeId();
    }

    public static List<Reward_Usage__c> getRewardUsagesBySetIds(Set<Id> usageIdSet) {
        return rewardUsageSelector.selectRewardUsagesByIds(usageIdSet);
    }

    public static List<Reward_Usage__c> getRewardUsagesByOrderId (String orderId, String additionalCondition) {
        return rewardUsageSelector.selectRewardUsagesByOrderId(orderId, additionalCondition);
    }

    public static List<Reward_Usage__c> getRewardUsagesByInvoiceNo (String invoiceNo, String rewardProfileId) {
        return rewardUsageSelector.selectRewardUsagesByInvoiceNo(invoiceNo, rewardProfileId);
    }

    public static List<Reward_Usage__c> getRewardUsagesByPaymentIds (Set<Id> setCreditUsagePaymentIds ) {
        return rewardUsageSelector.selectRewardUsagesByPaymentIds( setCreditUsagePaymentIds );
    }

    public static List<Reward_Usage__c> getExpiredRewardUsagesByRewardIds( Set<Id> setRewardIds ){
        return rewardUsageSelector.selectUsagesByRewardIds( setRewardIds, new Set<String>{'Expired'}, new Set<String>{'System'}, new Set<Id>{getRecordTypeId('Debit')} );
    }
    
    public static List<Reward_Usage__c> getRewardUsagesByIds(Set<Id> rewardUsageIds) {
        return rewardUsageSelector.selectRewardUsagesByIds(rewardUsageIds, null);
    }

    public static String getRecordTypeNameById(String recordTypeId) {
        return rewardUsageSelector.getRecordTypeNameById(recordTypeId);
    }

    public static List<Reward_Usage__c> getRewardUsageHistory(String recordTypeId, String contactId, String regVehId, String brand, Integer previousMonth) {
        return rewardUsageSelector.selectRewardUsageHistory(recordTypeId, contactId, regVehId, brand, previousMonth);
    }

    public static List<Reward_Usage__c> getRewardUsagesByCreditNote(String creditNote, String recordTypeId) {
        return rewardUsageSelector.selectRewardUsagesByCreditNote(creditNote, recordTypeId);
    }

    public static List<Reward_Usage__c> getDebitRewardUsagesByInvoiceNo(String invoiceNo, String recordTypeId) {
        return rewardUsageSelector.selectDebitRewardUsagesByInvoiceNo(invoiceNo, recordTypeId);
    }

    /** 
     * Note :
     * 2020901: Only applied for eShop channel transaction as of now
     **/
    public static void createPaymentForDebitUsage( List<Reward_Usage__c> lstNewRewardUsages ){
        try
        {
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Invoice__c.SObjectType, Reward_Usage__c.SObjectType } );
            
            Map<Id,Reward_Usage__c> mapNewRewardUsages = new Map<Id,Reward_Usage__c>( lstNewRewardUsages );
            List<Invoice__c> lstPaymentToInsert = new List<Invoice__c>();

            // 1 Usage = 1 Payment; Only for eShop 
            List<Reward_Usage__c> lstDebitUsages = RewardUsageSelector.selectRewardUsagesByIds( mapNewRewardUsages.KeySet(), new Set<Id>{getRecordTypeId('Debit')} );
            if( lstDebitUsages <> null && !lstDebitUsages.isEmpty() )
            {
                for( Reward_Usage__c usage : lstDebitUsages )
                {
                    if( usage.Payment__c == null && usage.Channel__c == 'eShop' )
                    {
                        Invoice__c payment = new Invoice__c();
                        payment.RecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('E_Shop_Payment_RT').getRecordTypeId(); 
                        payment.Payment_Type__c       = usage.Reward__r.Type__c;
                        payment.Net_Amount__c         = usage.Credit_Amount__c;
                        payment.Transaction_Status__c = 'Settled';
                        payment.Transaction_Type__c   = 'Purchase';
                        payment.Event__c              = 'eShop';
                        payment.Contact__c            = usage.Order__r.Contact__c;
                        payment.Account__c            = usage.Order__r.Account__c;
                        payment.Department__c         = usage.Reward__r.Branch__c;
                        payment.Brand__c              = usage.Reward__r.Brand__c;
                        payment.E_shop_OrderId__c     = usage.Order__r.OrderID__c;
                        payment.E_shop_Order__c       = usage.Order__c;
                
                        uow.registerDirty(usage, Reward_Usage__c.Payment__c, payment);
                        lstPaymentToInsert.add( payment );
                    }
                }
                
                System.debug('@@@@DEBUG createPaymentForDebitUsage :: lstPaymentToInsert = ' + lstPaymentToInsert.size() + ' --- ' + lstPaymentToInsert );
                if( lstPaymentToInsert <> null && !lstPaymentToInsert.isEmpty() ){
                    TriggerExclusion.excludeTrigger('Invoice__c', true);
                    TriggerExclusion.excludeTrigger('Reward_Usage__c', true);
                    uow.registerNew( lstPaymentToInsert );
                    uow.commitWork();
                }
            }
        }
        catch(Exception ex){
            System.debug('@@@@DEBUG createPaymentForDebitUsage :: ERROR :: err.cause = ' + ex.getCause() + ' --- err.msg = ' + ex.getMessage() + ' --- err.line = ' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('createPaymentForDebitUsage', ex);
        }
    }

    /** 
     * Note :
     * 2020901: Only applied for eShop channel transaction as of now
     **/
    public static void createPaymentForCreditUsage( List<Reward_Usage__c> lstNewRewardUsages ){
        try
        {
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Invoice__c.SObjectType, Reward_Usage__c.SObjectType } );
            
            Map<Id,Reward_Usage__c> mapNewRewardUsages = new Map<Id,Reward_Usage__c>( lstNewRewardUsages );
            List<Invoice__c> lstPaymentToInsert = new List<Invoice__c>();

            Map<Id,Invoice__c> mapDebitUsagePayments = new Map<Id,Invoice__c>();
            List<Reward_Usage__c> lstCreditUsages = RewardUsageSelector.selectRewardUsagesByIds( mapNewRewardUsages.KeySet(), new Set<Id>{getRecordTypeId('Credit')} );

            if( lstCreditUsages <> null && !lstCreditUsages.isEmpty() )
            {
                for( Reward_Usage__c usage : lstCreditUsages ) 
                {
                    if( usage.Payment__c == null && usage.Reward_Usage__c <> null && usage.Reward_Usage__r.Payment__c <> null && usage.Type__c == 'Refund' ) {
                        mapDebitUsagePayments.put( usage.Reward_Usage__r.Payment__c, null );
                    }
                }

                if( mapDebitUsagePayments <> null && !mapDebitUsagePayments.isEmpty() ) 
                {
                    mapDebitUsagePayments = new Map<Id,Invoice__c>( PaymentService.getPaymentsByIDs( mapDebitUsagePayments.KeySet() ) );
            
                    for( Reward_Usage__c usage : lstCreditUsages )
                    {
                        Invoice__c pymt = mapDebitUsagePayments.get( usage.Reward_Usage__r.Payment__c ).clone( false, false, false, false );
                        pymt.Transaction_Type__c = 'Refund';
                        pymt.Refund_Reason__c    = usage.Refund_Reason__c;
                        pymt.Net_Amount__c       = usage.Credit_Amount__c;

                        uow.registerDirty(usage, Reward_Usage__c.Payment__c, pymt);
                        lstPaymentToInsert.add( pymt );
                    }
                    
                    System.debug('@@@@DEBUG createPaymentForCreditUsage :: lstPaymentToInsert = ' + lstPaymentToInsert.size() + ' --- ' + lstPaymentToInsert );
                    if( lstPaymentToInsert <> null && !lstPaymentToInsert.isEmpty() ) {
                        TriggerExclusion.excludeTrigger('Invoice__c', true);
                        TriggerExclusion.excludeTrigger('Reward_Usage__c', true);
                        uow.registerNew( lstPaymentToInsert );
                        uow.commitWork();
                    }
                }
            }
        }
        catch(Exception ex){
            System.debug('@@@@DEBUG createPaymentForCreditUsage :: ERROR :: err.cause = ' + ex.getCause() + ' --- err.msg = ' + ex.getMessage() + ' --- err.line = ' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('createPaymentForCreditUsage', ex);
        }
    }


    public static void createDebitUsageforCNforExpiredReward( List<Reward_Usage__c> lstRewardUsages )
    {
        try
        {
            System.debug('@@@@DEBUG createDebitUsageforCNforExpiredReward :: lstRewardUsages = ' + lstRewardUsages.size() + ' --- ' + lstRewardUsages);
            System.debug('@@@@DEBUG createDebitUsageforCNforExpiredReward :: CreditUsageRtId = ' + RewardUsageService.getRecordTypeId('Credit'));
            Id creditUsageRtId = RewardUsageService.getRecordTypeId('Credit');
            List<Reward_Usage__c> lstFilteredRefundUsages = new List<Reward_Usage__c>();
            for( Reward_Usage__c refundUsage : lstRewardUsages ){
                if( refundUsage.RecordTypeId == creditUsageRtId && refundUsage.Type__c == 'Refund' && refundUsage.Reward_Status__c == 'Expired' ){
                    lstFilteredRefundUsages.add( refundUsage );
                }
            }


            System.debug('@@@@DEBUG createDebitUsageforCNforExpiredReward :: lstFilteredRefundUsages = ' + lstFilteredRefundUsages.size() + ' --- ' + lstFilteredRefundUsages);
            List<Reward__c> lstExpiredRewards= new List<Reward__c>();
            List<Reward_Usage__c> lstDebitExpiredRefundUsages = new List<Reward_Usage__c>();
            if( !lstFilteredRefundUsages.isEmpty() ){
                for( Reward_Usage__c refundUsage : lstFilteredRefundUsages ){
                    Reward_Usage__c dUsage = initExpiredRewardUsage( null, refundUsage.Reward__c, refundUsage.Credit_Amount__c );
                    lstDebitExpiredRefundUsages.add( dUsage );
                }

                if( !lstDebitExpiredRefundUsages.isEmpty() ){
                    insert lstDebitExpiredRefundUsages;
                }
            }
        }
        catch(Exception ex){
            System.debug('@@@@DEBUG createDebitUsageforCNforExpiredReward :: ERROR :: err.cause = ' + ex.getCause() + ' --- err.msg = ' + ex.getMessage() + ' --- err.line = ' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('createDebitUsageforCNforExpiredReward', ex);
        }

    }


    public static Reward_Usage__c initExpiredRewardUsage( Reward__c rewardObj, Id rewardId, Decimal expiredRefundAmt )
    {
        Reward_Usage__c newRewardUsage = new Reward_Usage__c();
        newRewardUsage.RecordTypeId        = RewardUsageService.getRecordTypeId('Debit');
        // newRewardUsage.Reward__c           = rewardObj.Id;
        newRewardUsage.Channel__c          = 'System';
        newRewardUsage.Status__c           = 'Expired';
        newRewardUsage.Type__c             = 'Expiry';
        newRewardUsage.Transaction_Date__c = Date.today();
        // newRewardUsage.Invoice_Amount__c   = rewardObj.Remainder__c;
        newRewardUsage.Invoice_Amount__c   = 0;
        // newRewardUsage.Credit_Amount__c    = rewardObj.Remainder__c;
        newRewardUsage.Order__c            = null;
        newRewardUsage.Order_Number__c     = null;

        if( rewardObj <> null ){
            newRewardUsage.Reward__c        = rewardObj.Id;
            newRewardUsage.Credit_Amount__c = rewardObj.Remainder__c;
        }
        else{
            newRewardUsage.Reward__c        = rewardId;
            newRewardUsage.Credit_Amount__c = expiredRefundAmt;
        }

        return newRewardUsage;
    }


    public static void triggerRelatedListPlatformEvent( List<Reward_Usage__c> lstRewardUsages ) {
        List<Two_Tier_Related_List__e> tieredListEvt = new List<Two_Tier_Related_List__e>();
        if( lstRewardUsages <> null && !lstRewardUsages.isEmpty() ){
            tieredListEvt.add(new Two_Tier_Related_List__e(Refresh__c = true));
        }

        List<Database.SaveResult> results = EventBus.publish(tieredListEvt);
        // Inspect publishing results
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error returned: ' + error.getStatusCode() +' - '+ error.getMessage());
                }
            }
        }        
    }
    
}
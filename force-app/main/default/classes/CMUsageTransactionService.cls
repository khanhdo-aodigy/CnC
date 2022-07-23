/** ******
 * Class Name: CMUsageTransactionService
 * Description : Service Class for Usage Transaction (Usage_Transaction__c)
 *               Only applicable for Normal Credit Deduction & Credit Refund. Channel eShop/Retail
 *
 * Change History:
 * Date(YYYYMMDD)        Name                           Description
 * 20200901              khanh.do@aodigy.com            Created Initial Version.
 * 
 ***** **/
public with sharing class CMUsageTransactionService {

    private static Id debitRecordTypeId = getRecordTypeId('Debit');
    private static Id creditRecordTypeId = getRecordTypeId('Credit');

    private static Map<String, List<Reward_Usage__c> > mapAutoInvNumToDebitUsages = new Map<String, List<Reward_Usage__c>>();
    private static Map<String, List<Reward_Usage__c> > mapEInvoiceToDebitUsages = new Map<String, List<Reward_Usage__c>>();
    private static Map<String, List<Reward_Usage__c> > mapCreditNoteToCreditUsages = new Map<String, List<Reward_Usage__c>>();   

    private static List<Usage_Transaction__c> usageTransactionToInsert = new List<Usage_Transaction__c>();
    private static List<Reward_Usage__c> rewardUsageToUpdate = new List<Reward_Usage__c>();

    public static Id getRecordTypeId(String recordTypeName) {
        return Schema.SObjectType.Usage_Transaction__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }


    public static void processUsageTransaction(List<Reward_Usage__c> rewardUsageList) {
        List<Reward_Usage__c> creditUsages = new List<Reward_Usage__c>();
        List<Reward_Usage__c> debitUsages = new List<Reward_Usage__c>();

        String creditUsageTypeId = RewardUsageService.getRecordTypeId('Credit');
        String debitUsageTypeId = RewardUsageService.getRecordTypeId('Debit');

        try
        {
            Set<Id> usageIds = new Set<Id>();
            for(Reward_Usage__c usage: rewardUsageList) {
                usageIds.add(usage.Id);
            }

            List<Reward_Usage__c> rewardUsages = RewardUsageService.getRewardUsagesBySetIds(usageIds);

            for(Reward_Usage__c usage: rewardUsages) {
                if(usage.RecordTypeId == creditUsageTypeId) {
                    creditUsages.add(usage);
                } 
                else if (usage.RecordTypeId == debitUsageTypeId) {
                    debitUsages.add(usage);
                }
            }
    
            System.debug('CMUsageTransactionService  creditUsages = ' + creditUsages);
            System.debug('CMUsageTransactionService  debitUsages = ' + debitUsages);
    
            if(!creditUsages.isEmpty()) {
                processCreditUsageTransaction(creditUsages);
            }
    
            if(!debitUsages.isEmpty()) {
                processDebitUsageTransaction(debitUsages);
            }
            
            System.debug('CMUsageTransactionService  usageTransactionToInsert = ' + usageTransactionToInsert.size() + ' --- ' + usageTransactionToInsert);
               
            ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Reward_Usage__c.SObjectType, Usage_Transaction__c.SObjectType } );

            if(!usageTransactionToInsert.isEmpty()) {
                //uow.registerNew(usageTransactionToInsert);
                insert usageTransactionToInsert;
            }

            if(!mapCreditNoteToCreditUsages.isEmpty()) {
                linkRewardUsageToUsageTransaction(usageTransactionToInsert, mapCreditNoteToCreditUsages, creditRecordTypeId, 'Credit_Note__c');
            }

            if(!mapAutoInvNumToDebitUsages.isEmpty()) {
                linkRewardUsageToUsageTransaction(usageTransactionToInsert, mapAutoInvNumToDebitUsages, debitRecordTypeId, 'Autoline_Invoice_Number__c');
            }

            if(!mapEInvoiceToDebitUsages.isEmpty()) {
                linkRewardUsageToUsageTransaction(usageTransactionToInsert, mapEInvoiceToDebitUsages, debitRecordTypeId, 'e_Invoice__c');
            }

            System.debug('CMUsageTransactionService  rewardUsageToUpdate = ' + rewardUsageToUpdate.size() + ' --- ' + rewardUsageToUpdate);
             
            if(!rewardUsageToUpdate.isEmpty()) {
               uow.registerDirty(rewardUsageToUpdate);
            }    
            uow.commitWork();
        } 
        catch (Exception e) {
            System.debug('Exception cause = ' + e.getCause() + '. Exception type ' + e.getTypeName() + '. Error at line: ' + e.getLineNumber());
            loggerDataPool.buildLogDataPool('CMUsageTransactionService.processUsageTransaction', e);
        }   
    }


    private static void processDebitUsageTransaction(List<Reward_Usage__c> rewardDebitUsageList) {
        for(Reward_Usage__c usage: rewardDebitUsageList) {
            if(usage.Channel__c == 'eShop') {
                String eInvoiceNo = usage.e_Invoice__c;
                if(String.isNotBlank(eInvoiceNo)) {
                    mapKeyFieldToUsage(mapEInvoiceToDebitUsages, eInvoiceNo, usage);               
                } 
                else {
                    System.debug('*** CMUsageTransactionService *** : ERROR: Reward Usage\'s e_Invoice__c is null');
                }
            } 
            else {
                String autoInvoiceNo = usage.Autoline_Invoice_Number__c;
                if(String.isNotBlank(autoInvoiceNo)) {
                    mapKeyFieldToUsage(mapAutoInvNumToDebitUsages, autoInvoiceNo, usage);
                } 
                else {
                    System.debug('*** CMUsageTransactionService *** : ERROR: Reward Usage\'s Autoline Invoice Number is null');
                }
            }    
        }
        System.debug('*** CMUsageTransactionService *** : mapEInvoiceToDebitUsages = ' + mapEInvoiceToDebitUsages.size() + '--' + mapEInvoiceToDebitUsages);
        System.debug('*** CMUsageTransactionService *** : mapAutoInvNumToDebitUsages = ' + mapAutoInvNumToDebitUsages.size() + '--' + mapAutoInvNumToDebitUsages);
                
        if(!mapEInvoiceToDebitUsages.isEmpty()){
            initialUsageTransaction(mapEInvoiceToDebitUsages, debitRecordTypeId);
        }
        
        if(!mapAutoInvNumToDebitUsages.isEmpty()){
            initialUsageTransaction(mapAutoInvNumToDebitUsages, debitRecordTypeId);
        }
    }


    private static void processCreditUsageTransaction(List<Reward_Usage__c> rewardCreditUsageList) {
        for(Reward_Usage__c usage: rewardCreditUsageList) {
            String creditNote = usage.Credit_Note__c;
            if(String.isNotBlank(creditNote)) {
                mapKeyFieldToUsage(mapCreditNoteToCreditUsages, creditNote, usage);                
            } 
            else {
                System.debug('*** CMUsageTransactionService *** : ERROR: Reward Usage\'s Credit_Note__c is null');
            }
        }
        
        System.debug('*** mapCreditNoteToCreditUsages *** : mapCreditNoteToCreditUsages = ' + mapCreditNoteToCreditUsages.size() + '--' + mapCreditNoteToCreditUsages);
        
        if(!mapCreditNoteToCreditUsages.isEmpty()) {
            initialUsageTransaction(mapCreditNoteToCreditUsages, creditRecordTypeId);
        }
    }


    private static void initialUsageTransaction( Map<String, List<Reward_Usage__c>> mapKeytoRewardUsages, Id recordTypeId) {
        Set<String> keyFieldValues = mapKeytoRewardUsages.keySet();
        for(String key: keyFieldValues) 
        {  
            List<Reward_Usage__c> rewardUsages = mapKeytoRewardUsages.get(key);
            Set<String> sources   = new Set<String>();
            List<Date> expiryDates = new List<Date>();
            Usage_Transaction__c usageTransaction = new Usage_Transaction__c();
            
            usageTransaction.RecordTypeId                   = recordTypeId;
            usageTransaction.Reward_Profile__c              = rewardUsages[0].Reward__r.Reward_Profile__c;
            usageTransaction.Autoline_Invoice_Number__c     = rewardUsages[0].Autoline_Invoice_Number__c;
            usageTransaction.Autoline_Invoice_Date__c       = rewardUsages[0].Autoline_Invoice_Date__c;
            usageTransaction.Invoice_Amount__c              = rewardUsages[0].Invoice_Amount__c;
            usageTransaction.Credit_Amount__c               = 0;
            
            for(Reward_Usage__c usage: rewardUsages) 
            {
                if(!String.isBlank(usage.Source__c)) {
                    sources.add(usage.Source__c);
                }
                usageTransaction.Credit_Amount__c += usage.Credit_Amount__c;
                expiryDates.add(usage.Reward_Expiry__c);
            }
            usageTransaction.Source__c = String.join( new List<String>(sources), ';');
            
            Date latestExpiryDate = getLatestExpiry(expiryDates);
            usageTransaction.Latest_Expiry_Date__c = latestExpiryDate;

            if( recordTypeId == debitRecordTypeId ) {                
                usageTransaction.Outstanding_Payment_Amount__c  = usageTransaction.Invoice_Amount__c - usageTransaction.Credit_Amount__c;
                usageTransaction.Outstanding_Payment_Type__c    = rewardUsages[0].Payment_Type__c;
            }

            usageTransaction.NLCODE__c            = rewardUsages[0].NLCODE__c;
            usageTransaction.COST__c              = rewardUsages[0].COST__c;
            usageTransaction.Location__c          = rewardUsages[0].Location__c;
            usageTransaction.Channel__c           = rewardUsages[0].Channel__c;
            usageTransaction.Contact__c           = rewardUsages[0].Contact__c;
            usageTransaction.Order__c             = rewardUsages[0].Order__c;
            usageTransaction.e_Invoice__c         = rewardUsages[0].e_Invoice__c;
            usageTransaction.e_Invoice_Date__c    = rewardUsages[0].e_Invoice_Date__c;
            usageTransaction.Transaction_Date__c  = rewardUsages[0].Transaction_Date__c;
            usageTransaction.Credit_Note__c       = rewardUsages[0].Credit_Note__c;
            
            System.debug('usageTransaction.Latest_Expiry_Date__c = ' + usageTransaction.Latest_Expiry_Date__c);
            usageTransactionToInsert.add(usageTransaction);        
        }
    }


    private static void linkRewardUsageToUsageTransaction(List<Usage_Transaction__c> trans, Map<String, List<Reward_Usage__c>> mapKeytoUsages, String recordTypeId, String keyFieldName) {
        for(Usage_Transaction__c usageTransaction: trans) 
        {
            if(usageTransaction.RecordTypeId == recordTypeId ) 
            {         
                String key = String.valueof( usageTransaction.get(keyFieldName) );
                List<Reward_Usage__c> usages = mapKeytoUsages.get(key);
                for(Reward_Usage__c rewardUsage: usages) {
                    rewardUsage.Usage_Transaction__c = usageTransaction.Id;
                    rewardUsageToUpdate.add(rewardUsage);
                }
            }
        }
    }


    private static Date getLatestExpiry(List<Date> expiryDates) {
        expiryDates.sort();
        Date latestDate = expiryDates[0];
        return latestDate;
    }


    private static void mapKeyFieldToUsage(Map<String, List<Reward_Usage__c>> mapToUpdate, String keyValue, Reward_Usage__c usage) {
        if(mapToUpdate.containsKey(keyValue)) {
            mapToUpdate.get(keyValue).add(usage);
        } 
        else {
            List<Reward_Usage__c> usages = new List<Reward_Usage__c>();
            usages.add(usage);
            mapToUpdate.put(keyValue, usages);
        }
    }
}
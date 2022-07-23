/** *****
 * Description : Service Class for Payment (i.e. Invoice__c) object
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200630            HS@aodigy            Created Initial Version 
 * 
** *****/
public with sharing class PaymentService {
    
    private static PaymentSelector payment_selector = new PaymentSelector();

    public static Id getPaymentRecordTypeId( String recordTypeName ) {
        if( Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().containsKey( recordTypeName ) ) {
            return Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get( recordTypeName ).getRecordTypeId(); 
        }
        return null;
    }


    public static List<Invoice__c> getPaymentsByIDs( Set<Id> setPaymentIds ){
        return payment_selector.selectPaymentsByIds( setPaymentIds );
    }

    public static List<Invoice__c> getPaymentsByOrderId( String orderId ){
        return payment_selector.selectPaymentsByOrderId( orderId );
    }

    public static Map<String,Invoice__c> getEshopRefundUsagePayments( Date dateFilter ){
        
        Map<String,Invoice__c> mapEShopDebitUsagePymts = new Map<String,Invoice__c>();
        List<Invoice__c> lstEShopDebitUsagePymts = new List<Invoice__c>();
        Map<Id,Reward_Usage__c> mapCreditedRewardUsages = new Map<Id,Reward_Usage__c>();
        Map<Id,Invoice__c> mapCreditedUsagePymts = new Map<Id,Invoice__c>(payment_selector.selectPaymentsByTypeAndDateFiters(new Set<Id>{getPaymentRecordTypeId('E_Shop_Payment_RT')}, 
                                                                                                                                new Set<String>{'Accessories Credit','Service Credit'}, 
                                                                                                                                    new Set<String>{'Refund'}, dateFilter) );
        
        System.debug('@@@@DEBUG getEshopRefundUsagePayments :: mapCreditedUsagePymts = ' + mapCreditedUsagePymts.size() + ' --- ' + mapCreditedUsagePymts );                                                                                                                                    
        for(Reward_Usage__c creditedUsage : RewardUsageService.getRewardUsagesByPaymentIds( mapCreditedUsagePymts.KeySet() ) ){
            mapCreditedRewardUsages.put( creditedUsage.Payment__c, creditedUsage );
        }

        for( Id key : mapCreditedUsagePymts.KeySet() ){
            if( mapCreditedRewardUsages.containsKey( key ) ){
                mapEShopDebitUsagePymts.put( mapCreditedRewardUsages.get( key ).Reward_Usage__r.Payment__c, mapCreditedUsagePymts.get( key ) );
            }
        }
        System.debug('@@@@DEBUG getEshopRefundUsagePayments :: mapEShopDebitUsagePymts = ' + mapEShopDebitUsagePymts.size() + ' --- ' + mapEShopDebitUsagePymts );
        return mapEShopDebitUsagePymts;
    }
}
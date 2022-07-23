/** ******
 * Description: InvoicePromoItem Trigger Handler
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		         Description
 * 20220413             thanh.ly@aodigy              Created Initial Version. 
** ******/
public with sharing class InvoicePromoItemTriggerHandler{

    public static void updateTargetedCommission(){
        List<Invoice_Promo_Line_Item__c> invItems = new List<Invoice_Promo_Line_Item__c>();
        invItems = [SELECT Id, Payment__c, Commission_Value__c, 
                        Payment__r.RecordType.DeveloperName, Payment__r.Transaction_Status__c, 
                        Payment__r.Sales_Agreement__c, Payment__r.Sales_Agreement__r.Targeted_Promo_Commission__c
                    FROM Invoice_Promo_Line_Item__c
                    WHERE Id IN: Trigger.new];

        if(invItems.size() > 0){
            Map<Id, Sales_Agreement__c> mapIdAndSA = new Map<Id, Sales_Agreement__c>();

            for(Invoice_Promo_Line_Item__c invItem : invItems){
                if((invItem.Payment__r.RecordType.DeveloperName == 'Sales_Targeted_Promo_Payment_RT')
                    && (invItem.Payment__r.Transaction_Status__c != 'processor_declined')
                        && (invItem.Payment__r.Sales_Agreement__c != null)){
                            
                            Sales_Agreement__c temSA = new Sales_Agreement__c();
                                            
                            if(mapIdAndSA.containsKey(invItem.Payment__r.Sales_Agreement__c)){
                                temSA = mapIdAndSA.get(invItem.Payment__r.Sales_Agreement__c);
                                temSA.Targeted_Promo_Commission__c += invItem.Commission_Value__c;
                                mapIdAndSA.put(invItem.Payment__r.Sales_Agreement__c, temSA);
                            }
                            else{
                                Decimal com = (invItem.Payment__r.Sales_Agreement__r.Targeted_Promo_Commission__c > 0) && (invItem.Payment__r.Sales_Agreement__r.Targeted_Promo_Commission__c <> null)
                                                ? (invItem.Payment__r.Sales_Agreement__r.Targeted_Promo_Commission__c + invItem.Commission_Value__c)
                                                : invItem.Commission_Value__c;

                                mapIdAndSA.put(invItem.Payment__r.Sales_Agreement__c, new Sales_Agreement__c(Id = invItem.Payment__r.Sales_Agreement__c,
                                                                                                            Targeted_Promo_Commission__c = com));
                            }
                }
            }

            update mapIdAndSA.values();
        }
                  
    }
}
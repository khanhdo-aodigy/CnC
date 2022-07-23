public with sharing class ProcessBarUtil {

    @AuraEnabled(cacheable=true)
    public static List<Form_Process_Bar__mdt> getConfigByPS(String processType){
        return [SELECT developerName, displayLabel__c, Process_Sequence_Number__c, Process_Type__c, Process_Path_Label__c,Link_to_Component__c  FROM Form_Process_Bar__mdt WHERE Process_Type__c =:processType ORDER BY Process_Sequence_Number__c ASC];
        //return new LIST<Form_Process_Bar__mdt>();
    }
}
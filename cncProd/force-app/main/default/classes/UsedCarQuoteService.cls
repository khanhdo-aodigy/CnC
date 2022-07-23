/** *****
 * Description : Service class for Used Car Quote object
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * 20220524             khanh.do@aodigy.com              Created Initial Version
 * 
** *****/
public with sharing class UsedCarQuoteService {

    private static UsedCarQuoteSelector selector = new UsedCarQuoteSelector();

    public static Used_Car_Quote__c getUsedCarQuoteById(Id quoteId) {
        List<Used_Car_Quote__c> quoteList = getQuotesBySetIds(new Set<Id>{quoteId});
        return quoteList.isEmpty() ? null : quoteList[0];
    }

    public static List<Used_Car_Quote__c> getQuotesBySetIds(Set<Id> setQuoteIds) {
        List<Used_Car_Quote__c> quoteList = selector.getQuotesBySetIds(setQuoteIds);
        return quoteList;
    }

    public static List<Used_Car_Quote__c> getOpenQuotesByChassisNoAndVehicleNo(String chassisNo, String vehicleNo, String additionalConditions) {
        List<Used_Car_Quote__c> quoteList = selector.getOpenQuotesByChassisNoAndVehicleNo(chassisNo, vehicleNo, additionalConditions);
        return quoteList;
    }

    public static ID getMFRecordTypeId() {       
        if(Schema.SObjectType.Used_Car_Quote__c.getRecordTypeInfosByDeveloperName().containsKey('MF_Quote')) {
            return Schema.SObjectType.Used_Car_Quote__c.getRecordTypeInfosByDeveloperName().get('MF_Quote').getRecordTypeId();
        }
        return null;
    }

    public static ID getMBRecordTypeId() {
        
        if(Schema.SObjectType.Used_Car_Quote__c.getRecordTypeInfosByDeveloperName().containsKey('MB_Quote')) {
            return Schema.SObjectType.Used_Car_Quote__c.getRecordTypeInfosByDeveloperName().get('MB_Quote').getRecordTypeId();
        }
        return null;
    }

    public static ID getRecordTypeId(String quoteId) {
        Used_Car_Quote__c quote = getUsedCarQuoteById(quoteId);
        System.debug('Record Type Id: ' + quote.recordTypeId);
        return quote.recordTypeId;   
    }

    public static ID getQuoteRecTypeIdByUserProfile(String profileName) {
        if(profileName == 'MB Purchaser') {
            return getMBRecordTypeId();
        } else if(profileName == 'MF Purchaser'){
            return getMFRecordTypeId();
        }
        return null;
    }

}
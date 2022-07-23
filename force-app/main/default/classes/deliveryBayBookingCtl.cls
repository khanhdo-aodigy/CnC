public with sharing class deliveryBayBookingCtl {
    public class MainResponseWrapper {
        @AuraEnabled public sObject currentDeliverySlot { get; set; }
        @AuraEnabled public List<SObject> availableServiceCategory { get; set; }
    }

    public class SearchResponseWrapper {
        @AuraEnabled public List<SObject> offDays { get; set; }
        @AuraEnabled public List<SObject> otherDeliverySlots { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static SearchResponseWrapper doSearchRecords(String recordId, String startDate, String endDate) {
        //system.debug('-----------------Constructing Main Wrapper-----------------');
        SearchResponseWrapper returnWrap = new SearchResponseWrapper();
        string additionalCondition = ' AND Status__c =\'Booked\'';

        //Get the relevant records
        returnWrap.otherDeliverySlots = getRecords('Delivery_Bay_Booking__c','Service_Centre__c',recordId, additionalCondition); //Need to add range of date
        returnWrap.offDays = getRecords('Service_Centre_Off_Day__c','Service_Centre__c',recordId,'');
        return returnWrap;
    }

    @AuraEnabled(cacheable=true)
    public static MainResponseWrapper doGetInformation(String recordId) {
        //system.debug('-----------------Constructing Main Wrapper-----------------');
        MainResponseWrapper returnWrap = new MainResponseWrapper();

        //Get the object field Names + Label
        returnWrap.currentDeliverySlot = getRecords('Delivery_Bay_Booking__c','ID',recordId,'')[0];
        
		String franchise = (String) returnWrap.currentDeliverySlot.get('FranchiseCode__c');
        system.debug('************' + franchise + '***************');
        system.debug('returnWrap.currentDeliverySlot ' + returnWrap.currentDeliverySlot);
        string additionalCondition = 'AND Franchise__c includes (\''+ franchise + '\') AND Active__c = TRUE'; //Need to add FranchiseCode__c from currentDeliverySlot

        returnWrap.availableServiceCategory = getRecords('Service_Category__c','Category__c','Delivery Bay', additionalCondition); //Need to add active or inactive
        return returnWrap;
    }

    @AuraEnabled
    public static void cancelRecord(String recordId) {
        Delivery_Bay_Booking__c deliveryRecord = [SELECT Id, Status__c FROM Delivery_Bay_Booking__c WHERE ID =:recordId];
        deliveryRecord.Status__c = 'Cancelled';
        
        try {
            update deliveryRecord;
        } catch(Exception e) {
            throw e;
        }
    }

    @AuraEnabled
    public static void updateRecord(String recordId, string selectedDate, string timeslot, integer duration, String serviceCenterId, integer roomNo) {
        
        Delivery_Bay_Booking__c deliveryRecord = [SELECT Id, Service_Centre__c,  Status__c, Delivery_Date__c, Start_Time__c, Duration_Minutes__c  FROM Delivery_Bay_Booking__c WHERE ID =:recordId];
        
        String[] strTimeSplit = timeslot.split(':'); 
        Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]), 0, 0);
        Date deliveryDate = Date.valueOf(selectedDate.split('T')[0]);

        deliveryRecord.Status__c = 'Booked';
        deliveryRecord.Service_Centre__c = serviceCenterId;
        deliveryRecord.Duration_Minutes__c = duration/60000;
        deliveryRecord.Start_Time__c = startTime;
        deliveryRecord.Delivery_Date__c = deliveryDate;
        deliveryRecord.Room_No__c = roomNo;
        
        try {
            update deliveryRecord;
        } catch(Exception e) {
            throw e;
        }
        
    }

    @AuraEnabled
    public static string rebookRecord(String recordId) {
        //Update existing record
        Delivery_Bay_Booking__c deliveryRecord = [SELECT Id, MB_Sales_Agreement__c, Sales_Agreement__c, Status__c FROM Delivery_Bay_Booking__c WHERE ID =:recordId];
        deliveryRecord.Status__c = 'Cancelled';

        //Create new record
        Delivery_Bay_Booking__c newSlot = new Delivery_Bay_Booking__c(MB_Sales_Agreement__c = deliveryRecord.MB_Sales_Agreement__c, Sales_Agreement__c = deliveryRecord.Sales_Agreement__c);
        
        try {
            insert newSlot;
            update deliveryRecord;
        } catch(Exception e) {
            throw e;
        }

        string newRecordId = newSlot.Id;
        return newRecordId;
    }

    private static List<sObject> getRecords(String objectName, String conditionField, String conditionValue, String additionalCondition) 
    {
        String mainQueryCondition = conditionField + ' = ' + '\'' + conditionValue + '\'';

        if(additionalCondition != null && String.isNotBlank(additionalCondition)) 
        {
            mainQueryCondition += ' ' + additionalCondition;
        }

        List<SObject> result = ADGLIB_UtilityHelper.getSObjectRecords(objectName, mainQueryCondition, false); 
        return result;
    }

}
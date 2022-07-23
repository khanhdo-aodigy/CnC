public class DeliveryBayBookingExpired_Schedulable implements Database.Batchable<sObject>, Schedulable {
    
    public static String scheduleIt() {        
        return System.schedule('DeliveryBayBookingExpired_Schedulable', '0 0 0 * * ? *', new DeliveryBayBookingExpired_Schedulable());
    }
    
    public void execute(SchedulableContext cx){
        Database.executeBatch( new DeliveryBayBookingExpired_Schedulable());
    }
    
    public Database.QueryLocator start(Database.BatchableContext db){
        Date TODAY = System.today();
        return Database.getQueryLocator([SELECT Id, Status__c FROM Delivery_Bay_Booking__c Where Status__c = 'Booked' AND Delivery_Date__c <= :TODAY]);
    }
    
    public void execute(Database.BatchableContext db, List<Delivery_Bay_Booking__c> scope){
        if(!scope.isEmpty()){	
            DeliveryBayBookings.setExpriedForDBB(scope);
        }
    }
    
    public void finish(Database.BatchableContext db){
    }
    
}
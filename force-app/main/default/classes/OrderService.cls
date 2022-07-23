/** ******
 * Description : Service Class for Custom Order object
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                    Description
 * 20200608              TP                     Created Initial Version. 
***** **/
public with sharing class OrderService {
    
    private static OrderSelector orderSelector = new OrderSelector();

    public static Order__c getOrder(String orderId) {
        return orderSelector.selectById(orderId);
    }

    public static Order__c getOrderByOrderNo (String orderNumber) {
        return orderSelector.selectByOrderNo(orderNumber);
    }

    public static Id getRecordTypeId(String recordTypeLabel) {
        return Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get(recordTypeLabel).getRecordTypeId();
    }
}
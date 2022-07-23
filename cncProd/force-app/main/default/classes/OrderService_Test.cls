/*******
 * Description : Test class for OrderService.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200708             TP     Created Initial Version 
*******/

@isTest
private class OrderService_Test 
{
	@testSetup
    static void setUp()
    {
        Account acct = Test_DataFactory.createAccount(true, 'Company');
        Contact con = Test_DataFactory.createContact(true, 'Test', 'Test', acct.Id);
        
        Order__c order = Test_DataFactory.createOrder(Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('C_C_E_Shop').getRecordTypeId());
        order.Shop__c = 'KIA';
        order.Contact__c = con.Id;
        insert order;
    }
    
    @isTest
    static void Test_getOrder()
    {
        Order__c order = [Select id from Order__c];
        OrderService.getOrder(order.Id);
    }
    
    @isTest
    static void Test_getOrderByOrderNo()
    {
        Order__c order = [Select Name from Order__c];
        OrderService.getOrderByOrderNo(order.Name);
    }
    
    @isTest
    static void Test_getRecordTypeId()
    {
       OrderService.getRecordTypeId('E_Shop_Payment_RT');
    }
}
/*******
 * Description : Test class for OrderSelector.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200708             TP     Created Initial Version 
*******/

@isTest
private class OrderSelector_Test 
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
    static void Test_selectByEshopOrderID()
    {
        Contact con = [Select Id from Contact];
        Order__c order = [Select OrderID__c from Order__c];
        OrderSelector sel = new OrderSelector();
        sel.selectByEshopOrderID(order.OrderID__c, con.Id);
    }
    
    @isTest
    static void Test_getOrderRtByDeveloperName()
    {
       OrderSelector sel = new OrderSelector();
       sel.getOrderRtByDeveloperName();
    }
    
    @isTest
    static void Test_selectById()
    {
       Order__c order = [Select Id from Order__c];
       OrderSelector sel = new OrderSelector();
       sel.selectById(order.Id);
    }
    
    @isTest
    static void Test_selectByOrderNo()
    {
       Order__c order = [Select Name from Order__c];
       OrderSelector sel = new OrderSelector();
       sel.selectByOrderNo(order.Name);
    }
}
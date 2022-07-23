@isTest
public class updateNricAutomationTrigger_Test {
    @testSetup
    public static void createData(){
        Test.startTest();
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getName());
        Contact con = Test_DataFactory.createContact(false, 'fname', 'lname', acc.Id);
        con.NRIC_Passport_No__c = '12345ASDFG';
        con.Contact_Update_Source__c = 'API';
        con.MobilePhone = '653456789';
        insert con;
        Test.stopTest();
    }

    @isTest
    public static void testUpdateTrigger(){
        Test.startTest();
            Contact con = [Select Id, NRIC_Passport_No__c, MobilePhone From Contact LIMIT 1];
            con.NRIC_Passport_No__c = '12345ASDFH';
            con.MobilePhone = '653456788';
            update con;
        Test.stopTest();
        System.assertNotEquals([Select LastNRICUpdated__c From Contact Where FirstName= 'fname' AND  LastName = 'lname'].LastNRICUpdated__c, null);
    }
    
    @isTest
    public static void testUpdateTrigger1(){
        Test.startTest();
            Contact con = [Select Id, NRIC_Passport_No__c, MobilePhone, FirstName From Contact LIMIT 1];
            con.FirstName = null;
            con.MobilePhone = '653456781';
            update con;
        Test.stopTest();
        //System.assertNotEquals([Select LastNRICUpdated__c From Contact Where FirstName= 'fname' AND  LastName = 'lname'].LastNRICUpdated__c, null);
    }

}
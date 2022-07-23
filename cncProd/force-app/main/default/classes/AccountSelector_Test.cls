@isTest
public class AccountSelector_Test {
    @testSetup
    public static void createData(){
        Account acc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        acc.PersonEmail = 'test@test.com';
        update acc;
    }
    
    @isTest
    public static void test(){
        AccountSelector accSelector = new AccountSelector();
        System.assertNotEquals(null, accSelector.getSObjectType());
        System.assertNotEquals(0, accSelector.getSObjectFieldList().size());
        System.assertNotEquals(null, accSelector.getEditableAccountFields().size());
    }
    @isTest
    public static void testGetPersonAccountListByIds(){
        AccountSelector accSelector = new AccountSelector();
        Account acc = [Select Id, PersonContactId From Account LIMIT 1];
        
        System.assertNotEquals(0, accSelector.getPersonAccountListByIds(new Set<String>{acc.Id} , new Set<String>{acc.PersonContactId}, 'Customer').size());
    }
    
    @isTest
    public static void testGetPersonAccountListByIdsOrEmails(){
        AccountSelector accSelector = new AccountSelector();
        Account acc = [Select Id, PersonContactId, PersonEmail From Account LIMIT 1];
        
        System.assertNotEquals(0, accSelector.getPersonAccountListByIdsOrEmails(new Set<String>{acc.Id} , new Set<String>{acc.PersonContactId},
                                                                        new Set<String>{acc.PersonEmail},'Customer').size());
    }
    
    @isTest
    private static void testGetAccountRecordTypeMap(){        
        AccountSelector selector = new AccountSelector();
        Map<String,RecordType> results = selector.getAccountRecordTypeMap();
    }
}
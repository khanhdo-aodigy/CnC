@isTest
public class ADGLIB_UtilityHelper_Test {

    @TestSetup
    static void makeData(){
        Account acc = new Account();
        acc.Name = 'TestAccount '+String.valueOf(Math.random()).substring(2, 6) ;
        acc.Phone='9988998899';
        insert acc;
    }

    @isTest
    static void testIsSandbox(){
        Boolean testResult = ADGLIB_UtilityHelper.isSandbox();
        System.assertNotEquals(null, testResult);
    }

    @isTest
    static void testGetQueryFactoryByObject(){
        ADGLIB_QueryFactory testObject = ADGLIB_UtilityHelper.getQueryFactoryByObject('Account', true);
        System.assertNotEquals(null, testObject);
    }

    @isTest
    static void testGetSObjectFieldListByObj(){
        List<Schema.SObjectField> testFieldList = ADGLIB_UtilityHelper.getSObjectFieldListByObj('Account');
        system.assertNotEquals(0, testFieldList.size());
    }

    @isTest
    static void testFindObjectNameFromRecordIdPrefix(){
        String testResult= ADGLIB_UtilityHelper.findObjectNameFromRecordIdPrefix('003123456789111345');
        System.assertEquals('Contact', testResult);

    }

    @isTest
    static void testGenerateAllFieldStr(){
        String testResult = ADGLIB_UtilityHelper.generateAllFieldStr('Account');
        System.assertNotEquals(null, testResult);
    }

    @isTest
    static void testGetSObjectRecords(){

        List<sObject> testAccountList = ADGLIB_UtilityHelper.getSObjectRecords('Account','', true);
        system.assertNotEquals(0, testAccountList.size());
    }


}
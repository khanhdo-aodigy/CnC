/** *****
 * Description : Test Class for Transactions.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200708            KH@aodigy            Created Initial Version 
 * 
** *****/
@isTest
private class TransactionsTest {

    @TestSetup
    static void makeData(){
        
        List<Account_Mapping__c> lstAcctMapping = new List<Account_Mapping__c>();
        String strDummyInput = 'A;MITCV::C;CITPC::F;CITCV::J;MITPC::K;KIAPC::S;KIACV';
        for( String dummy : strDummyInput.split('::') ){
            List<String> lstDummyValues = dummy.split(';');
            lstAcctMapping.add( Test_DataFactory.createAccountMapping( false, 'Accessories Credit', 'ANC', lstDummyValues.get(0), lstDummyValues.get(1) ) );
        }

        if( !lstAcctMapping.isEmpty() ){
            insert lstAcctMapping;
        }

        Account paObj = Test_DataFactory.createPerson(false, 'TestPersonAccount', 'Customer');
        paObj.NRIC_Passport_No__pc = 'TestCNT123NRIC';
        insert paObj;
        paObj = [SELECT Id, PersonContactId FROM Account WHERE Id =:paObj.Id ];

        Registered_Vehicle__c rvObj = Test_DataFactory.createRegVehicle(false, 'TestRV123', 'CCK', 'KIAPC', 'TestRV123', paObj.PersonContactId);
        rvObj.Chasis_Number__c = 'TestRV123ChassisNumber';
        insert rvObj;
    }
    
    @isTest
    private static void testBypassTrigger() {
        System.Test.startTest();
         	TriggerExclusion.excludeTrigger( 'Transaction__c', true );
            Test_DataFactory.createTransaction( true, 'ANC', 'K', 'TestRV123', 'TestRV123ChassisNumber', 'TestCNT123NRIC');        
        	TriggerExclusion.excludeTrigger( 'Transaction__c', false );
        System.Test.stopTest();
        System.assertEquals( 1, ([SELECT ID FROM Transaction__c ]).size());
    }
    
	@isTest
    private static void testOnInsert() {
        System.Test.startTest();
            Test_DataFactory.createTransaction( true, 'ANC', 'K', 'TestRV123', 'TestRV123ChassisNumber', 'TestCNT123NRIC');        
        System.Test.stopTest();
        System.assert( ([SELECT ID FROM Transaction__c ]).size() == 1 );
    }
    
    @isTest
    private static void testOnUpdate() {
        Test_DataFactory.createTransaction( true, 'ANN', 'K', 'TestRV123', 'TestRV123ChassisNumber', 'TestCNT123NRIC');   
        System.Test.startTest();
            Transaction__c trans = [SELECT Id, SRC__c FROM Transaction__c LIMIT 1];
            trans.SRC__c = 'ANC';
            update trans; 
        System.Test.stopTest();
        System.assert( ([SELECT ID FROM Transaction__c ]).size() == 1 ); 
    }
}
/** *****
 * Description : Test Class for AccountUtil.cls
 * 
 * Change History
 * Date(YYYYMMDD)      Name        Description
 * 20200405            HS          Created Initial Version. 
 * 
** *****/
@isTest
private  class AccountUtil_Test {
    
    @TestSetup
    static void makeData(){
        
        List<Account> lstPersonAccount = new List<Account>();
        for( Integer count = 0 ; count < 5 ; count++ ) {
            lstPersonAccount.add( Test_DataFactory.createPA(false, 'TEST_Prospect_'+count, 'test' + count + '@prospect.com', 'Prospect'));        	
            lstPersonAccount.add( Test_DataFactory.createPA(false, 'TEST_Customer_'+count, 'test' + count + '@customer.com', 'Customer'));
        }

        System.debug('@@@@DEBUG --- lstPersonAccount = ' + lstPersonAccount );
        if( !lstPersonAccount.isEmpty() ){
            TriggerExclusion.excludeTrigger( 'Account' , true );
            insert lstPersonAccount;
        }
    }

    
    @isTest
    static void accountUtilTM() {

        System.Test.startTest();

            List<Account> lstCustomerAcct = new List<Account>();
            List<Account> lstProspectAcct = new List<Account>();
            // List<Account> lstEShpCustAcct = new List<Account>();
            Set<String> setAccountIds = new Set<String>();
            for( Account acct : [SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, PersonContactId FROM Account])
            {
                if( acct.RecordTypeId == AccountUtil.getCustomerRecordTypeId() ){
                    System.assert( AccountUtil.isCustomer( acct.RecordTypeId, acct.RecordType.DeveloperName ) );
                    lstCustomerAcct.add( acct );
                }

                if( acct.RecordTypeId == AccountUtil.getProspectRecordTypeId() ){
                    System.assert( AccountUtil.isProspect( acct.RecordTypeId, acct.RecordType.DeveloperName ) );
                    lstProspectAcct.add( acct );
                }
                setAccountIds.add( acct.Id );
            }

            System.assertEquals( 5 ,lstCustomerAcct.size() );
            if( !lstCustomerAcct.isEmpty() ){
                System.assert( AccountUtil.getCustomerRecordById( String.valueOf(lstCustomerAcct.get(0).Id) ) <> null );
                System.assert( AccountUtil.getSinglePersonAccountById( String.valueOf(lstCustomerAcct.get(0).Id) ) <> null );
                System.assert( AccountUtil.getSinglePersonAccountByContactId( String.valueOf(lstCustomerAcct.get(0).PersonContactId) ) <> null );
            }

            System.assertEquals( 5 ,lstProspectAcct.size() );
            if( !lstProspectAcct.isEmpty() ){
                System.assert( AccountUtil.getProspectRecordById( String.valueOf(lstProspectAcct.get(0).Id) ) <> null );
            }

            Set<String> setEmails = new Set<String>();
            setEmails.add('emailADG@testing.com');
            System.assert( AccountUtil.getCustomerListByEmails( setEmails ).isEmpty() );
            System.assert( AccountUtil.getProspectListByEmails( setEmails ).isEmpty() );


            //Test createProspectPA
            List<Account> lstOfProspects = new List<Account>();
            for( Integer count = 100 ; count < 103 ; count++ ) {
                lstOfProspects.add( Test_DataFactory.createPerson( false, 'TEST_Prospect_'+count, 'Prospect'));
            }
            System.debug('testing--- lstOfProspects = ' + lstOfProspects.size() + ' ---- ' + lstOfProspects );

            //Test createProspect
            Account singleProspect = Test_DataFactory.createPerson( false , 'TestSingleProspect', 'Prospect');
            System.assert( AccountUtil.createProspect( singleProspect ) <> null );
            System.assert( singleProspect.Id <> null );
            System.assert( singleProspect.RecordTypeId == AccountUtil.getProspectRecordTypeId() );

            //Test createUniqueString
            System.assert( String.isNotBlank( AccountUtil.createUniqueString() ) );
        System.Test.stopTest();
    }
    
    @isTest
    private static void testGetBusinessAccountRecordTypeId() {
        Account businessAcc = Test_DataFactory.createAccount(true, 'Test Business Account');
        businessAcc = [SELECT Id, RecordTypeId FROM Account WHERE Id = :businessAcc.Id LIMIT 1];
        System.assertEquals(businessAcc.RecordTypeId, AccountUtil.getBusinessAccountRecordTypeId());
    }
    @isTest
    private static void testCreateListProspects() {
        //Test createProspectPA
        List<Account> lstOfProspects = new List<Account>();
        for( Integer count = 100 ; count < 103 ; count++ ) {
            lstOfProspects.add( Test_DataFactory.createPerson( false, 'TEST_Prospect_'+count, 'Prospect'));
        }
        System.assert( AccountUtil.createListProspects( lstOfProspects ) <> null );
        Set<String> setEmails = new Set<String>();
            setEmails.add('emailADG@testing.com');
            System.assert( AccountUtil.getCustomerListByEmails( setEmails ).isEmpty() );
            System.assert( AccountUtil.getProspectListByEmails( setEmails ).isEmpty() );
    }
     @isTest
    private static void testGetPAByEmails() {
        //Test createProspectPA
        Account acc  = Test_DataFactory.createPerson( false, 'TEST_Prospect_', 'Prospect');
        acc.PersonEmail = 'hung@testing.com';
        insert acc;

        System.assert( AccountUtil.getPersonAccountByEmail( 'hung@testing.com' ) <> null);
    }
    
    @isTest
    private static void testUpdatePA() 
    {
        Account pA = Test_DataFactory.createPerson( false, 'TEST_Prospect_', 'Prospect');
        pA.PersonEmail = 'test@gmail.com';
        insert pA;
        AccountUtil.PAWrapper pAWrapper = new AccountUtil.PAWrapper('Mr.', 'Test', 'Last', 'Test Last', 'S123456H', '81234567', System.today(),
                                                                    'Scret St', '', '', 'Singapore 123456' , null, 'Singapore', 
                                                                    true, null, 'Customer', null, null, null);
        // User u = [SELECT Id from User where Id = '005O0000006zM8L'];
        // System.runAs(u) {
           AccountUtil.updatePA(pAWrapper, pA.Id);
        // }
    }
    
    @isTest
    private static void testCreateProfiling() {
        Account cust = Test_DataFactory.createPA(true, 'Jerry-RA', 'jerry@test.com', 'Customer');
        AccountUtil.createProfiling('RA_Person_Account_Profiling_RT', cust);
    }
        
    @isTest
    private static void testGetRecordTypeIdByName() {
        Id result = AccountUtil.getRecordTypeIdByName('Customer');
        System.assertNotEquals(null, result);        
        
        Id result1 = AccountUtil.getRecordTypeIdByName('NonRealCustomer');
        System.assertEquals(null, result1);
    }
    
    @isTest
    private static void testUpsertRACustomer() {
        AccountUtil.RACustomerWrapper wrapper = new AccountUtil.RACustomerWrapper('Khanh', 'Do', 'khanh@test.com', '6599007689', true);
        AccountUtil.upsertRACustomer(wrapper, 'Prospect'); //insert Prospect
        
        AccountUtil.RACustomerWrapper newWrapper = new AccountUtil.RACustomerWrapper('Khanh', 'Do', 'khanh@test.com', '6599006789', false);
        AccountUtil.upsertRACustomer(newWrapper, 'Customer'); //update created Prospect
    }
    
}
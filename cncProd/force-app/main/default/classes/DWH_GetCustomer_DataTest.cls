/***************************************************
 * Class Name: DWH_GetCustomer_DataTest
 * Description: Test class for Customer Full and Partial Sync.
 * 				Refactored previous class due to seeAllData = true
 ***************************************************/ 
@isTest
private class DWH_GetCustomer_DataTest {
    //Custom Setting data prep.
    @testSetUp
    static void createData(){

        Account act = Test_DataFactory.createAccount(true, 'testAccountDWH');
        Contact cnt = Test_DataFactory.createContact(false, 'testContact1', 'DWH', String.valueOf(act.Id));
        cnt.DWH_Contact_ID__c = '971091';
        insert cnt;

        Account paCustomer = Test_DataFactory.createPerson(false, 'testPACustomer1', 'Customer');
        paCustomer.DWH_Contact_ID__c  = '971091';
        paCustomer.DWH_Contact_ID__pc = '971091';
        insert paCustomer;

        Test.startTest();
        //API Gateway Settings
        global_var__c gVar = new global_var__c(APIGateway_url__c='https://www.test.com',
                                               APIGateway_key__c='testKey');
        upsert gVar;
        
        //DWH Last Run date
        DWH_last_run_date__c sv = new DWH_last_run_date__c();
        sv.DWH_import_date__c = Date.today();
        sv.Customer_StartPage__c = 0;
        sv.Customer_NumberOfPages__c = 25;
        upsert sv;
        Test.stopTest();
    }
    
    /***********************************************
     * Method Name: testPositivePartialSync
     * Description: Partial Sync Positive Test Run
     ***********************************************/
    static testMethod void testPositivePartialSync(){
        
        List<Contact> lstContacts = [SELECT Id, DWH_Contact_ID__c FROM Contact WHERE IsPersonAccount = false ];
        List<Account> lstPACustomer = [SELECT Id, DWH_Contact_ID__c FROM Account WHERE IsPersonAccount = true AND RecordType.Name = 'Customer' ];
        System.assert( !lstContacts.isEmpty() && lstContacts.size() == 1 );
        System.assert( !lstPACustomer.isEmpty() && lstPACustomer.size() == 1 );
        System.debug('testing---111lstContacts='+lstContacts.size() + ' --- ' + lstContacts);
        System.debug('testing---111lstPACustomer='+lstPACustomer.size() + ' --- ' + lstPACustomer);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HTTPMocker('DWH_GetCustomer_Data', true));
            DWH_GetCustomer_Data.ContactC st = new DWH_GetCustomer_Data.ContactC('NRICTEST','Dr','TanTest','FName','',
                                                                    'M','80001234','',DateTime.now(),'test@test.com',
                                                                   '','','','',
                                                                    '','Singapore','Singapore','','159930',
                                                                    '','False','96239','Test Salutation',
                                                                    '96239','CCS01','281135',
                                                                    '','','','Private');
            //System.schedule('Test Get Customer01', '0 0 0 ? * * *', new DWH_GetCustomer_Data());
            DWH_GetCustomer_Data xJob = new DWH_GetCustomer_Data();
            xJob.execute(null);
        Test.stopTest();
        
        lstContacts = [SELECT Id, DWH_Contact_ID__c FROM Contact WHERE IsPersonAccount = false ];
        lstPACustomer = [SELECT Id, DWH_Contact_ID__c FROM Account WHERE IsPersonAccount = true AND RecordType.Name = 'Customer' ];
        System.debug('testing---222lstContacts='+lstContacts.size() + ' --- ' + lstContacts);
        System.debug('testing---222lstPACustomer='+lstPACustomer.size() + ' --- ' + lstPACustomer);
        System.assert( !lstContacts.isEmpty() && lstContacts.size() == 3 );
        System.assert( !lstPACustomer.isEmpty() && lstPACustomer.size() == 3 );

        //Assertion here
    }
    
    /***********************************************
     * Method Name: testPositiveFullSync
     * Description: Full Sync Positive Test Run
     ***********************************************/
    static testMethod void testPositiveFullSync(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HTTPMocker('DWH_GetAllCustomer_Data', true));
            DWH_GetAllCustomer_Data.ContactC st = new DWH_GetAllCustomer_Data.ContactC('NRICTEST','Dr','TanTest','FName','',
                                                                    'M','80001234','',DateTime.now(),'test@test.com',
                                                                   '','','','',
                                                                    '','Singapore','Singapore','','159930',
                                                                    '','False','96239','Test Salutation',
                                                                    '96239','CCS01','281135',
                                                                    '','','','Private');
            System.schedule('Test Get Customer02', '0 0 0 ? * * *', new DWH_GetAllCustomer_Data());
        Test.stopTest();
        
        //Assertion here
    }

    @isTest
    static void exeTestRunTM(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HTTPMocker('DWH_GetCustomer_Data', true));
            DWH_GetCustomer_Data.exeTestRun(null); 
        Test.stopTest();
    }
}
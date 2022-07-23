//test class for AutoLineSplitContact
//To be deleted
@isTest
private class AutoLineSplitContactTest {
    //Custom Setting data prep.
    @testSetUp
    static void createData(){
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
        sv.NumRecords__c = '5000';
        upsert sv;
        
        //Create Account
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName());
        
        //Create Contact
        Contact con = Test_DataFactory.createContact(false, 'FName', 'LName', acc.Id);
        con.DWH_Contact_ID__c = '281135';
        insert con;
        Test.stopTest();
    }
    
    
    //Test Sync
    static testMethod void testSplit(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HTTPMocker('DWH_GetAllCustomer_Data', true));
        AutoLineSplitContact.ContactC st = new AutoLineSplitContact.ContactC('NRICTEST','Dr','TanTest','FName','',
                                                                    'M','80001234','',DateTime.now(),'test@test.com',
                                                                   '','','','',
                                                                    '','Singapore','Singapore','','159930',
                                                                    '','False','96239','Test Salutation',
                                                                    '96239','CCS01','281135',
                                                                    '','','','Private');
        System.schedule('Test Get AutoLineSplitContact', '0 0 0 ? * * *', new AutoLineSplitContact());
        Test.stopTest();
        
        //Assert Here
    }
}
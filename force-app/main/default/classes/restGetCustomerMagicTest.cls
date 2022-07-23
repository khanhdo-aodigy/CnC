/****************************************
 * Class Name: restGetCustomerMagicTest
 * Description: Test class for restGetCustomerMagic
 ****************************************/
@isTest
private class restGetCustomerMagicTest {
    //Create Initial Test data
    @testSetup
    static void createData(){
        Test.startTest();
        String nricVal = 'TESTNR1';

        //Create Business Account
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName());
        
        //Create Business contact
        Contact con = Test_DataFactory.createContact(false, 'First', 'Last', acc.Id);
        con.NRIC__c = nricVal;
        con.NRIC_Passport_No__c = nricVal;
        con.MobilePhone = '6580000000';
        insert con;
        
        //Create Registered Vehicle
        Registered_Vehicle__c rv =  Test_DataFactory.createregVehicle(false, 'test', 'CCK', 'KIAPC', 'SLTEST01X', con.Id);
        rv.MagicCustomer__c = 'RTEST';
        insert rv;
        Test.stopTest();
    }
    
    
    //Positive Test Scenario
    static testMethod void testRestPositive(){
        Test.startTest();
        String reqURI = '/services/apexrest/GetCustomerMagic/v1/SLTEST01X' ; 
        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 200);
        restGetCustomerMagic.getCustomerMagic();
        Test.stopTest();
        
        //Assert
    }
    
    //Negative Test Scenario - Missing Vehicle Number as Param
    static testMethod void testRestNegativeMissing(){
        Test.startTest();
        //Missing Param - Vehicle Number
        String reqURI = '/services/apexrest/GetCustomerMagic/v1/' ; 
        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 400);
        restGetCustomerMagic.getCustomerMagic();
        Test.stopTest();
        
        //Assert
    }
    
    //Negative Test Scenario - Car Reg Num not found
    static testMethod void testRestNegativeRegNum(){
        Test.startTest();
        //Missing Param - Vehicle Number
        String reqURI = '/services/apexrest/GetCustomerMagic/v1/XX' ; 
        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 400);
        restGetCustomerMagic.getCustomerMagic();
        Test.stopTest();
        
        //Assert
    }
}
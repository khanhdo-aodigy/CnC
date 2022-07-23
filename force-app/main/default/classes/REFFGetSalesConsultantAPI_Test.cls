@isTest
private with sharing class REFFGetSalesConsultantAPI_Test {
    @TestSetup
    static void createData(){

            Account acc = Test_DataFactory.createAccount(true, 'Test');
            Contact con = Test_DataFactory.createContact(true, 'contact', 'test', acc.Id);
            con.NRIC_Passport_No__c = 'S12315031993';  
            con.mobilePhone = String.valueOf('6584636');
            con.Source__c = 'DWH';
			con.AccountId = acc.Id;
            update con;
            system.debug('@@@ con: '+con);

            Profile endUserProfile = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
            User endUser = Test_DataFactory.createUserWithProfileID(false,'re','re','test@force.com',endUserProfile.id);
            //endUser.nric__c = 'zsdfzsdd';   
            endUser.contactId = con.id;
            //endUser.contactId__c = con.Id;    
            endUser.Account_Activation_Random_Number__c = '504503';
            endUser.isValid__c = false;
            insert endUser; 
            system.debug('@@@ endUser: '+endUser);

            Opportunity opp = Test_DataFactory.createOpportunity(false, 'test', null);
            opp.Contact_Person__c = con.Id;
            insert opp;        
        }

    @isTest 
    private static void testPositive()
    {
        User us = [SELECT Id, Name/*, ContactId__c*/ FROM User WHERE LastName = 're' LIMIT 1];
        system.debug('@@@ us: '+us);

        String reqURI = '/services/apexrest/REFFGetSalesConsultantAPI/UserId/'+us.Id+'/Branch/CCK'; 
        Test_DataFactory.createReqSF( reqURI, 'GET', null, null, 200);
        Test.startTest();
        REFFGetSalesConsultantAPI.getSalesConsultantByBranch();
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Service_Data_Pool__c]);
    } 
}
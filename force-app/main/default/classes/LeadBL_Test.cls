@isTest(seeAllData=false)
public class LeadBL_Test {
     @TestSetup
    static void makeData(){
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
    
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                     timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        Account a;
        Lead lead;
        System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
            insert a;
            lead = Test_DataFactory.createLead(false,'Aodigy','Huynh');
            lead.Account__c = a.Id;
            lead.Street = 'test';
            lead.State = 'test';
            lead.PostalCode = 'test';
            lead.Country = 'test';
            lead.Latitude = 0.000000;
            lead.Longitude = 0.000000;
            // lead.GeocodeAccuracy = '';
            insert lead;
        }
    }
    @isTest
    static void testLeadChange(){
        Test.startTest();	
        Lead lead = [Select Id, Email from Lead Where LastName = 'Huynh' And Company='Aodigy'];
        lead.Email = 'TestAodigy' + String.valueOf(Math.random()).substring(2, 6) + '@gmail.com';
        update lead;
        lead = [Select Id, Email, Account__c From Lead Where LastName = 'Huynh' And Company='Aodigy'];          
        Account pAcc = [Select Id, PersonEmail from Account WHERE Id =: lead.Account__c];
        Test.stopTest();
        System.assertEquals(pAcc.PersonEmail, lead.Email);
        
    }


    @isTest
    static void testLeadUpload(){

        List<Lead> lstLead = new List<Lead>();
        Test.startTest();	
            for( Integer count = 0 ; count < 10 ; count ++ ){
                Lead tempLd = Test_DataFactory.createLead(false, 'TESTJCC', 'TestLead'+count);
                tempLd.Street = 'test';
                tempLd.City = 'test';
                tempLd.State = 'test';
                tempLd.Country = 'test';
                tempLd.PostalCode = 'test';
                lstLead.add( tempLd );
            }
            insert lstLead;
        Test.stopTest();

        System.assert( ([SELECT Id FROM Lead WHERE Account__c != null AND Id IN:lstLead]).size() == 10 );
        
    }

}
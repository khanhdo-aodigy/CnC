/** *****
 * Description : Test Class for ContactDedupBatch.cls
 * 
 * Change History
 * Date(YYYYMMDD)      Name        Description
 * 20200414            HS          Created Initial Version. 
 * 
** *****/
@isTest
private class ContactDedupBatchTest {

    @TestSetup
    static void makeData(){
        
        Integer count = 20;
        
        Account tempAccount = Test_DataFactory.createAccount(true, 'TestAccountZZZ');

        List<Contact> lstRightContacts = new List<Contact>();
        List<Contact> lstWrongContacts = new List<Contact>();

        for( Integer i = 0 ; i < count ; i++ ){
            Contact goodContact = Test_DataFactory.createContact(false, 'GOODCONTACT_'+i, 'TEST'+i, String.valueOf(tempAccount.Id) );
            goodContact.NRIC_Passport_No__c = 'NRICTEST'+i;
            lstRightContacts.add( goodContact );
        }
        if( !lstRightContacts.isEmpty() ){
            insert lstRightContacts;
        }

        for( Integer i = 0 ; i < lstRightContacts.size() ; i++ ){
            Contact badContact = Test_DataFactory.createContact(false, 'BADCONTACT_'+i, 'TEST'+i, String.valueOf(tempAccount.Id) );
            badContact.NRIC_Passport_No__c = 'NRICTEST'+i;
            badContact.Is_Duplicated__c = true;
            badContact.Device__c = 'BADDEVICE'+i;
            badContact.Primary_Contact_Id__c = String.valueOf( lstRightContacts.get(0).Id );
            lstWrongContacts.add( badContact );
        }
        if( !lstWrongContacts.isEmpty() ){
            insert lstWrongContacts;
        }


        List<Opportunity> lstOppotunities = new List<Opportunity>();
        for( Integer j = 0 ; j < lstWrongContacts.size() ; j++ ) {
            Opportunity oppo = Test_DataFactory.createOpportunity( false, 'OPPO_TEST_'+j, tempAccount.Id);
            oppo.Contact_Person__c = lstWrongContacts.get( j ).Id;
            lstOppotunities.add( oppo );
        }
        if( !lstOppotunities.isEmpty()){
            insert lstOppotunities;
        }


        List<Test_Drive__c> lstTestDrives = new List<Test_Drive__c>();
        for( Integer k = 0 ; k < lstOppotunities.size() ; k++ ){
            Test_Drive__c td = Test_DataFactory.createTestDrive( false, String.valueOf( lstOppotunities.get(k).Id ) );
            td.Prospect__c = lstOppotunities.get(k).Contact_Person__c;
            lstTestDrives.add( td );
        }
        if( !lstTestDrives.isEmpty() ){
            insert lstTestDrives;
        }
                

    }

    @isTest
    static void contactDedupBatchTM() {

        List<Contact> lstBadContacts = [SELECT ID, Email, Primary_Contact_Id__c FROM Contact WHERE IsPersonAccount = false AND FirstName LIKE 'BAD%' AND Is_Duplicated__c = true AND Primary_Contact_Id__c != null];
        Set<String> setBadCntIds = new Set<String>();
        Set<String> setGoodCntIds = new Set<String>(); 
        for( Contact cnt : lstBadContacts ){
            setBadCntIds.add( String.valueOf( cnt.Id ) );
            setGoodCntIds.add( String.valueOF( cnt.Primary_Contact_Id__c ) );
        }

        if( !lstBadContacts.isEmpty() )
        {
            //Create Portal User - Start
            UserRole role = new UserRole(name = 'TEST ROLE');
            Database.insert(role);

            User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = role.Id,
                                            emailencodingkey='UTF-8', lastname='TestingPU', languagelocalekey='en_US', 
                                                localesidkey='en_US', profileId = UserInfo.getProfileId(), 
                                                    timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
            
            List<Account> lstPAs = new List<Account>();
            System.runAs(userWithRole)
            {
                String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
                
                for( Integer w = 0 ; w < lstBadContacts.size() ; w++ ){
                    Account pa = new Account( RecordTypeId = recordTypeId, FirstName = 'TPAFN'+w, LastName = 'TPALN'+w, PersonEmail = lstBadContacts.get(w).Email );
                    lstPAs.add( pa );
                }
                if( !lstPAs.isEmpty() ){
                    Database.insert(lstPAs);
                }
            }
            lstPAs = [SELECT ID, FirstName, LastName, PersonEmail, PersonContactId FROM Account WHERE ID IN :lstPAs];

            List<Profile> lstProfile = [SELECT Id FROM Profile WHERE Name = 'End User' LIMIT 1];
            if(!lstProfile.isEmpty() )
            {   
                List<User> lstUser = new List<User>();
                for( Integer y = 0 ; y < lstPAs.size() ; y++ )
                {
                    user usr = Test_DataFactory.createUserWithProfileID( false, 'BAD'+y, 'TEST'+y, lstPAs.get(y).PersonEmail, lstProfile.get(0).Id );
                    usr.NRIC__c       = 'NRICTEST'+y;
                    usr.ContactId__c  = ( y < lstBadContacts.size() ) ? lstBadContacts.get(y).Id : usr.ContactId__c;
                    usr.ContactId     = lstPAs.get(y).PersonContactId;
                    usr.isValid__c    = true;
                    lstUser.add( usr );
                }
                if( !lstUser.isEmpty() ){
                    insert lstUser;
                }
            }
        }
        //Create Portal User - End

        System.Test.startTest();
            ContactDedupBatch cJob = new ContactDedupBatch( setBadCntIds , null , null );
            Database.executeBatch( cJOb , 100 );

            cJob = new ContactDedupBatch();
            Database.executeBatch( cJOb , 100 );
        System.Test.stopTest();

        for( Contact cnt : [SELECT Id, Name, (SELECT ID FROM Opportunities__r), (SELECT ID FROM Test_Drives__r) 
                            FROM Contact WHERE ID IN :setGoodCntIds] ){
            
            System.assert( !cnt.Opportunities__r.isEmpty() );
            System.assert( !cnt.Test_Drives__r.isEmpty() );
        }

        for( Contact cnt : [SELECT Id, Name, (SELECT ID FROM Opportunities__r), (SELECT ID FROM Test_Drives__r) 
                            FROM Contact WHERE ID IN :setBadCntIds] ){
            
            System.assert( cnt.Opportunities__r.isEmpty() );
            System.assert( cnt.Test_Drives__r.isEmpty() );
        }
    }
    

}
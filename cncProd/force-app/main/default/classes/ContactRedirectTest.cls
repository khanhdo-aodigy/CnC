/****************************************
 * Class Name: ContactRedirectTest
 * Description: Test class for ContactRedirect
 * 				controller.
****************************************/ 
@isTest
private class ContactRedirectTest {
    //create initial test data
    @testSetUp
    static void createData(){
        String adminId = [SELECT Id 
                          FROM Profile 
                          WHERE Name='System Administrator' LIMIT 1].Id;
        List<NewOverride__c> nOverList = new List<NewOverride__c>();
        nOverList.add( new NewOverride__c(AllowNew__c = false, 
                                          SetUpOwnerId=UserInfo.getOrganizationId()) );
        //System Administrator
        nOverList.add( new NewOverride__c(AllowNew__c = true, 
                                          SetUpOwnerId = adminId ) );
        insert nOverList;
        
        String lName = UserInfo.getLastName();
        Account acc = Test_DataFactory.createAccount(true, lName);
        Contact con = Test_DataFactory.createContact(true, lName, lname, acc.Id);
    }
    
    //Test page access for Non Admin
    static testMethod void testLeadCreate(){
        Test.startTest();
        //run as System Administrator
        User u = [SELECT Id 
                  FROM User 
                  WHERE IsActive=true
                  AND Profile.Name='System Administrator' 
                  LIMIT 1];
        if(u!=null){
            System.runAs(u){
                //set current page to the VF Page override
                PageReference pf = Page.LeadRedirect; 
                Test.setCurrentPage(pf);
                
                Contact ld = [SELECT Id, Name FROM Contact LIMIT 1];
                ApexPages.StandardController sc = new ApexPages.StandardController(ld);
                ContactRedirect xl = new ContactRedirect(sc); 
                xl.redirectToError();
            }
        }
        Test.stopTest();
    }
    
    //Test page access for Non Admin
    static testMethod void testLeadNotAdmin(){
        Test.startTest();
        User u = Test_DataFactory.createUser(false, 'TestUSR', 'talia13');
        u.ProfileId = [SELECT Id 
                       FROM Profile 
                       WHERE Name LIKE '%MIT%' 
                       LIMIT 1].Id;
        insert u;
        Contact ld = [SELECT Id, Name 
                      FROM Contact LIMIT 1];
        if(u!=null){
            System.runAs(u){
                //set current page to the VF Page override
                PageReference pf = Page.LeadRedirect; 
                Test.setCurrentPage(pf);
                
                ApexPages.StandardController sc = new ApexPages.StandardController(ld);
                ContactRedirect xl = new ContactRedirect(sc); 
                xl.redirectToError();
            }
        }
        Test.stopTest();
    }
}
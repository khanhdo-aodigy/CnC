@isTest
private class ServiceContactLookupTest {
    @testSetUp
    static void createData()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'name', 'Prospect');
        personAcc.PersonEmail = 'xyzmail@mail.com';
        personAcc.Phone = '6591234567';
        insert personAcc;    
        personAcc = [SELECT Id, PersonContactId, PersonEmail FROM Account WHERE IsPersonAccount = true LIMIT 1];
        Contact personCon = [SELECT Id FROM Contact WHERE Id =: personAcc.PersonContactId];
        personCon.MobilePhone = '6591234567';
        update personCon;
    }
    
    static testMethod void testRedirect(){
        Test.startTest();
        PageReference pf = Page.ServiceContactLookup; 
        Test.setCurrentPage(pf);
        ApexPages.currentPage().getParameters().put('phone','991234567');
        
        ServiceContactLookup sc = new ServiceContactLookup();
        sc.getContactFromPhone();
        
        System.assert(ApexPages.currentPage().getURL() != null );
        Test.stopTest();
    }
}
/** *****
 * Description : Test Class for SalesOpportunityService class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210110             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class SalesOpportunityServiceTest {
    private static String scEmail = 'jimmy@salesconsultant.com';
    @testSetup
    private static void setup() {
        Account personAcc = Test_DataFactory.createPA(true, 'RA-Testing', 'ra@testing.com', 'Prospect');
        Sales_Opportunity__c salesOpp = Test_DataFactory.createSalesOpp(true, personAcc.Id, 'Open', 'Jimmy', scEmail, '6599999');
    }
    
    @isTest
    private static void testGetAllSalesOpportunitiesByAccountIds(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Sales_Opportunity__c> results = SalesOpportunityService.getAllSalesOpportunitiesByAccountIds(new Set<Id>{acc.Id});
        System.assertEquals(1, results.size());
    }
    
    @isTest
    private static void tesGetOpenSalesOppoByAcctIdAndScEmail(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Sales_Opportunity__c result = SalesOpportunityService.getOpenSalesOppoByAcctIdAndScEmail(acc.Id, scEmail);
        System.assertNotEquals(null, result);
    }
    
    @isTest
    private static void testUpsertSalesOppByAccIdAndSCEmail_OpplExistsButScEmailNull_UpdateRAInfo(){
        String scEmail = 'alice.ra@test.com';
        String scName = 'Alice';
        String scMobile = '6577777';
        
        Account personAcc = Test_DataFactory.createPA(true, 'RA-Testing', 'alice.ra@test.com' , 'Prospect');
        Sales_Opportunity__c salesOpp = Test_DataFactory.createSalesOpp(true, personAcc.Id, 'Open', 'Jimmy', null, '65323232');
        
        Sales_Opportunity__c result = SalesOpportunityService.upsertSalesOppByAccIdAndSCEmail(personAcc, '', scName, scMobile);
        System.assertEquals(scName, result.Salesman_Name__c);
        System.assertEquals(scMobile, result.Salesman_Mobile__c);
    }
    
    @isTest
    private static void testUpsertSalesOppByAccIdAndSCEmail_OppNotExist_CreateNewOpp(){
        String scEmail = 'mimi@test.com';
        String scName = 'Alice';
        String scMobile = '6577777';
        Account personAcc = Test_DataFactory.createPA(true, 'RA-Testing', 'ra@testing.com', 'Prospect');
        Sales_Opportunity__c result = SalesOpportunityService.upsertSalesOppByAccIdAndSCEmail(personAcc, scEmail, scName, scMobile, null);
    }

    @isTest
    private static void testUpdateSalesOpptListByIdsAndStatus(){
        String scEmail = 'mimi@test1.com';
        String scName = 'Alice1';
        String scMobile = '6577771';
        Account personAcc = Test_DataFactory.createPA(true, 'RA-Testing1', 'ra@testing.com' ,'Prospect');        

        Sales_Opportunity__c result = SalesOpportunityService.upsertSalesOppByAccIdAndSCEmail(personAcc, scEmail, scName, scMobile, null);

        SalesOpportunityService.updateSalesOpptListByIdsAndStatus(new Set<ID>{result.Id}, 'Booked');
    }
    
	@isTest
    private static void testUpsertSalesOppByAccId() {
        Account acc = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        delete SalesOpportunityService.getOpenSalesOppoByAcctIdAndScEmail(acc.Id, scEmail);

        Test.startTest();
        Sales_Opportunity__c salesOpp = SalesOpportunityService.upsertSalesOppByAccId(acc, 'Open');
		Test.stopTest();
        System.assertNotEquals(null, salesOpp);
    }
}
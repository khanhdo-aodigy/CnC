/** *****
 * Description : Test Class for SalesOpportunitySelector
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210110             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class SalesOpportunitySelectorTest {
    private static String scEmail = 'jimmy@salesconsultant.com';
    @testSetup
    private static void setup() {
        Account personAcc = Test_DataFactory.createPA(true, 'RA-Testing', 'ra@testing.com', 'Prospect');
		Sales_Opportunity__c salesOpp = Test_DataFactory.createSalesOpp(true, personAcc.Id, 'Open', 'Jimmy', scEmail, '6599999');
    }
    
    @isTest
    private static void testGetSalesOpportunitiesByAccountIds(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SalesOpportunitySelector selector = new SalesOpportunitySelector();
        List<Sales_Opportunity__c> results = selector.getSalesOpportunitiesByAccountIds(new Set<Id>{acc.Id}, new Set<String>{scEmail}, new Set<String>{'Open'});
        System.assertEquals(1, results.size());
    }
    
    @isTest
    private static void testUpdateSalesOpptListByIdsAndStatus(){
        String scEmail = 'mimi@test1.com';
        String scName = 'Alice1';
        String scMobile = '6577771';
        Account personAcc = Test_DataFactory.createPA(true, 'RA-Testing1', 'cat@ra1.com', 'Prospect');        
        
        Sales_Opportunity__c result = SalesOpportunityService.upsertSalesOppByAccIdAndSCEmail(personAcc, scEmail, scName, scMobile);
        SalesOpportunitySelector selector = new SalesOpportunitySelector();
        selector.updateSalesOpptListByIdsAndStatus(new Set<ID>{result.Id}, 'Booked');
    }

}
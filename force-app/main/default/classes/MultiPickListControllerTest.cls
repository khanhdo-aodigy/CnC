@isTest
private class MultiPickListControllerTest {
    @isTest(SeeAllData=true) static void testgetPiklistValues(){
      	String casefieldname = 'Case_Type__c';
        String recordtype = 'Enquiry and Request';
        List<String> sVars = MultiPickListController.getPiklistValues(casefieldname,recordtype);  
        System.assertNotEquals(null, sVars);
    }
}
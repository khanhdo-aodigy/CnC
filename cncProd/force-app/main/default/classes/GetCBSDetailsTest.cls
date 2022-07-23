@isTest
private class GetCBSDetailsTest {

    @isTest(SeeAllData=true) static void testinitialMethod(){
        Test.setMock(HttpCalloutMock.class, new externalMock());
        List<String> bookingIDs = new List<String>();
        String values = '151133' + ',' + 'P';
        bookingIDs.add(values);        
		List<String> sVars = GetCBSDetails.initialMethod(bookingIDs);  
        System.assertNotEquals(null, sVars);
    }
        
}
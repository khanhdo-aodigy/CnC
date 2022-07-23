@isTest
private class GetServiceBookingDetailsTest {

    
     @isTest static void testcalloutToExternal(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new externalMock());
        String res = GetServiceBookingDetails.calloutToExternal('151133', 'P');  
        
         //response null. no assert.
        Test.stopTest();
    
    }
}
@isTest
private class GetPostalAddrControllerTest {
    
     @isTest static void testgetAddr(){
        String sVars = GetPostalAddrController.getAddr('520942');    
		System.debug('@@@'+sVars);        
         
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new externalMock());
        
        String res = GetPostalAddrController.getAddr('123456');
        
         //response null. no assert.
        Test.stopTest();
    
    }
    
}
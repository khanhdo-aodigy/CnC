@isTest
private class ExtractCBSCreatedList_Test {

    @isTest
    	static void CBSCreateListTest(){
         Test.startTest();
        List<String> vehicles = new List<String>();
  		List<Case> CaseRecs = new List<Case>();
        List<String> values = New List<String>();
        
                        Test.setMock(HttpCalloutMock.class, new externalMock());

                    ExtractCBSCreatedList sh1 = new ExtractCBSCreatedList();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Extract CBS Created List', sch, sh1); 
           
            Test.stopTest();
        }
}
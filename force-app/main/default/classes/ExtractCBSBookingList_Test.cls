@isTest
private class ExtractCBSBookingList_Test {

    @isTest
    	static void CBSBookingListTest(){
         Test.startTest();
        List<String> vehicles = new List<String>();
  		List<Case> CaseRecs = new List<Case>();
        List<String> values = New List<String>();
        
        ExtractCBSBookingList sh1 = new ExtractCBSBookingList();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Extract CBS Created List', sch, sh1); 
           
            Test.stopTest();
        }
}
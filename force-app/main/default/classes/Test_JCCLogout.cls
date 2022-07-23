@IsTest public with sharing class Test_JCCLogout {
    @IsTest(SeeAllData=true) 
    public static void testlogoutfunction() {
    	// Instantiate a new controller with all parameters in the page

        PageReference pref = Page.JccLogoutReturn;
        Test.setCurrentPage(pref);
        Test.startTest();
        JCCLogout controller = new JCCLogout();
		PageReference logoutPageRef = controller.logoutReturnfunction();
		//System.assertEquals(logoutPageRef.getUrl(),'https://scsit.cyclecarriage.com/feature/Login/Logout'); 
    }
}
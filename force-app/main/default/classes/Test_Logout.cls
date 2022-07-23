@IsTest public with sharing class Test_Logout {
@IsTest(SeeAllData=true) 
    public static void testlogoutfunction() {
    	// Instantiate a new controller with all parameters in the page

        PageReference pref = Page.JccLogout;
        Test.setCurrentPage(pref);
        Test.startTest();
        Logout controller = new Logout();
		PageReference logoutPageRef = controller.logoutfunction();
		//System.assertEquals(logoutPageRef.getUrl(),'/secur/singlelogout.jsp?retUrl=https%3A%2F%2Fpartcopy-digitalmvp-digmvpuat-devjcc.cs5.force.com%2Fendusers%2FJccLogoutreturn'); 
    }
}
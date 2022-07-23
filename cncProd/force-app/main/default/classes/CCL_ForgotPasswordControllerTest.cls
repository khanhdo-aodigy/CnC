@isTest
private class CCL_ForgotPasswordControllerTest {
	@isTest
    static void test_ForgotPasswordController() {
        PageReference pref = Page.CCL_ForgotPasswordPage;      
        pref.getParameters().put('eventName','returnToLoginPage');
        pref.getParameters().put('pageRef', '/startURL');
        Test.setCurrentPage(pref);
        
        Test.startTest();
        CCL_ForgotPasswordController controller = new CCL_ForgotPasswordController();
        controller.eventAction();
        Test.stopTest();
    }
}
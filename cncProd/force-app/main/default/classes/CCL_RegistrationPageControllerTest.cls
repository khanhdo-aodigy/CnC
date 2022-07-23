@isTest
private class CCL_RegistrationPageControllerTest {
	@isTest
    static void test_RegistrationPageController() {
        PageReference pref = Page.CCL_RegistrationPage;      
        pref.getParameters().put('eventName','returnToLogin');
        pref.getParameters().put('pageRef', '/startURL');
        Test.setCurrentPage(pref);
        
        Test.startTest();
        CCL_RegistrationPageController controller = new CCL_RegistrationPageController();
        controller.eventAction();
        Test.stopTest();
    }
}
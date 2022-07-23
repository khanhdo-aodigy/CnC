@isTest
private class CCL_LoginPageControllerTest {
	@isTest
    static void test_LoginPageController() {
        PageReference pref = Page.CCL_LoginPage;      
        pref.getParameters().put('eventName','login');
        pref.getParameters().put('pageRef', '/startURL');
        Test.setCurrentPage(pref);
        
        Test.startTest();
        CCL_LoginPageController controller = new CCL_LoginPageController();
        controller.eventAction();
        Test.stopTest();
    }
}
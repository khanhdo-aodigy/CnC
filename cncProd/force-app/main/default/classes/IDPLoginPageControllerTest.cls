/** ******
 * Description: Test class for IDPLoginPageController.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210816          TPhan@aodigy.com    Created Initial Version. 
** ******/
@isTest
private class IDPLoginPageControllerTest 
{
    @isTest
    static void test_IDPLoginPageController()
    {       
        PageReference pref = Page.IDP_SignUpPage;      
        pref.getParameters().put('eventName','login');
        pref.getParameters().put('pageRef', '/startURL');
        Test.setCurrentPage(pref);
        
        Test.startTest();
        IDPLoginPageController controller = new IDPLoginPageController();
        controller.eventAction();
        Test.stopTest();
    }
}
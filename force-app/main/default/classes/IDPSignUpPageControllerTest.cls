/** ******
 * Description: Test class for IDPSignUpPageController.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210816          TPhan@aodigy.com    Created Initial Version. 
** ******/
@isTest
private class IDPSignUpPageControllerTest 
{
    @isTest
    static void test_IDPSignUpPageController()
    {       
        PageReference pref = Page.IDP_SignUpPage;      
        pref.getParameters().put('eventName','verifyUserSuccess');
        pref.getParameters().put('pageRef', '/startURL');
        Test.setCurrentPage(pref);
        
        Test.startTest();
        IDPSignUpPageController controller = new IDPSignUpPageController();
        controller.eventAction();
        Test.stopTest();
    }
}
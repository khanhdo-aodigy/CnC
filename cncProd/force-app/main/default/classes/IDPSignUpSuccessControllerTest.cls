/** ******
 * Description: Test class for IDPSignUpSuccessController.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210816          TPhan@aodigy.com    Created Initial Version. 
** ******/
@isTest
private class IDPSignUpSuccessControllerTest
{
    @isTest
    static void test_IDPLoginPageController()
    {       
        PageReference pref = Page.IDP_SignUpPage;      
        pref.getParameters().put('msg','/startURL');
        Test.setCurrentPage(pref);
        
        Test.startTest();
        IDPSignUpSuccessController controller = new IDPSignUpSuccessController();
        controller.doBack();
        Test.stopTest();
    }
}
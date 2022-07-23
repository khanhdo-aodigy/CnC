/** ******
 * Description: Test class for IDPForgotPasswordController.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210816          TPhan@aodigy.com    Created Initial Version. 
** ******/
@isTest
private class IDPForgotPasswordControllerTest 
{
    @isTest
    static void test_validateAndRedirect()
    {       
        PageReference pref = Page.ForgotPassword;      
        pref.getParameters().put('isForgot=','false');
        Test.setCurrentPage(pref);
        
        Test.startTest();
        IDPForgotPasswordController controller = new IDPForgotPasswordController();
        controller.validateAndRedirect();
        Test.stopTest();
    }

    @isTest
    static void test_eventAction()
    {       
        PageReference pref = Page.ForgotPassword;      
        pref.getParameters().put('eventName','backFromConfirmation');
        Test.setCurrentPage(pref);
        
        Test.startTest();
        IDPForgotPasswordController controller = new IDPForgotPasswordController();
        controller.eventAction();
        Test.stopTest();
    }
}
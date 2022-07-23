@isTest
private class ReCaptchaControllerTest 
{
    @IsTest 
    static void testReCaptchaControllerTest() 
    {
        PageReference pref = Page.ReCaptcha;      
        pref.getParameters().put('lexOrigin', 'abc');

        System.Test.startTest();
    	ReCaptchaController controller = new ReCaptchaController();
        String lexOrigin = controller.lexOrigin;
        System.Test.stopTest();
    }

}
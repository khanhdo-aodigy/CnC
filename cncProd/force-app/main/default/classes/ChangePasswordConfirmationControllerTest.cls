@IsTest 
private class ChangePasswordConfirmationControllerTest 
{
    @IsTest 
    static void testChangePasswordConfirmationController_Web() 
    {
    	// Instantiate a new controller with all parameters in the page
        PageReference pref = Page.ChangePasswordConfirmation;      
        pref.getParameters().put('channel','web');
        System.Test.setCurrentPage(pref);

        System.Test.startTest();
    	ChangePasswordConfirmationController controller = new ChangePasswordConfirmationController();
		controller.InvalidAppRequest();
    	//System.assertEquals(pr.getUrl(),returnToLogin.getUrl()); 
        controller.returnToLogin();
        System.Test.stopTest();
    }

    @IsTest 
    static void testChangePasswordConfirmationController_Mobile() 
    {
    	// Instantiate a new controller with all parameters in the page
        PageReference pref = Page.ChangePasswordConfirmation;      
        System.Test.setCurrentPage(pref);

        System.Test.startTest();
    	ChangePasswordConfirmationController controller = new ChangePasswordConfirmationController();
		controller.InvalidAppRequest();
        controller.returnToLogin();
        System.Test.stopTest();
    }
}
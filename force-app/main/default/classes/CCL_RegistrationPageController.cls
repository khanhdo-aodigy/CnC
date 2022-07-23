/** ******
 * Description: Controller class for CCL_RegistrationPage.page
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                   Description
 * 20210923             khanh.do@aodigy.com    Created Initial Version. 
** ******/
public class CCL_RegistrationPageController {
    public CCL_RegistrationPageController(){}
    
	public PageReference eventAction() 
    {
        String eventName = Apexpages.currentPage().getParameters().get('eventName');
        PageReference pg;
        
        switch on eventName {
            when 'returnToLogin' 
            {
                pg = new PageReference(Label.CCL_RedirectURL);
            }
            when 'returnToHomePage' {
                String pageRef = Apexpages.currentPage().getParameters().get('pageRef');
                pg =  new PageReference(pageRef);
            }

        }
        
        System.debug('@@@@DEBUG CCL_RegistrationPageController :: afterSignupSuccess =  ' + pg);
        pg.setRedirect(true);
        return pg;
    }
}
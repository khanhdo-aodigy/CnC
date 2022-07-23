/** ******
 * Description: Controller class for CCL_ForgotPasswordPage.page
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                   Description
 * 20211006             khanh.do@aodigy.com    Created Initial Version. 
** ******/

public class CCL_ForgotPasswordController {

    public CCL_ForgotPasswordController() {}

    public PageReference eventAction() 
    {
        String eventName = Apexpages.currentPage().getParameters().get('eventName');
        PageReference pg;
        
        switch on eventName {

            when 'returnToLoginPage'{
                String pageRef = Apexpages.currentPage().getParameters().get('pageRef');
                pg = new PageReference(pageRef);
                pg.setRedirect(true);
            }
        }        

        return pg;
    }
}
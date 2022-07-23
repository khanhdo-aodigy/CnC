/** ******
 * Description: Controller class for CCL_ChangePasswordSuccess.page
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                   Description
 * 20210923             khanh.do@aodigy.com    Created Initial Version. 
** ******/
public class CCL_ChangePasswordSuccessController {
    public DateTime timestamp {get;set;}
    public CCL_ChangePasswordSuccessController() {        
        timestamp = system.now();
    }
    
    public PageReference returnToLogin()
    {
       PageReference pr = new PageReference(Label.CCL_RedirectURL);
       pr.setRedirect(true);
       return pr;
    }
    
}
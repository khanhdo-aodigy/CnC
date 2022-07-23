/** ******
 * Description: Controller class for CCL_LoginPage.page
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                   Description
 * 20210921             khanh.do@aodigy.com    Created Initial Version. 
** ******/

global class CCL_LoginPageController 
{
    public CCL_LoginPageController() 
    {
        System.debug('@@@@DEBUG CCL_LoginPageController :: startURL = ' + Apexpages.currentPage().getParameters().get('startURL'));
    }

    public PageReference eventAction() 
    {
        String eventName = Apexpages.currentPage().getParameters().get('eventName');
        PageReference pg;
        
        switch on eventName {
            when 'login' 
            {
                String pageRef = Apexpages.currentPage().getParameters().get('pageRef');
                pg =  new PageReference(pageRef);
                pg.setRedirect(true);
            }
        }        
        System.debug('@@@@DEBUG CCL_LoginPageController :: returnedURL ='  + pg);

        return pg;
    }
}
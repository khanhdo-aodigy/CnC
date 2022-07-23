/** ******
 * Description: Controller class for IDP_LoginPage.page
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210624          TPhan@aodigy.com    Created Initial Version. 
** ******/

global class IDPLoginPageController 
{
    public IDPLoginPageController() 
    {
        System.debug('@@@@DEBUG IDPLoginPageController :: startURL = ' + Apexpages.currentPage().getParameters().get('startURL'));
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
        System.debug('@@@@DEBUG IDPLoginPageController :: returnedURL ='  + pg);

        return pg;
    }
}
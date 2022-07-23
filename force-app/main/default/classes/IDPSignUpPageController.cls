/** ******
 * Description: Controller class for IDP_SignUpPage.page
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210624          TPhan@aodigy.com    Created Initial Version. 
** ******/
global class IDPSignUpPageController 
{
    public IDPSignUpPageController()
    {
        System.debug('@@@@DEBUG IDPSignUpPageController :: startURL = ' + Apexpages.currentPage().getParameters().get('msg'));
    } 

    public PageReference eventAction() 
    {
        String eventName = Apexpages.currentPage().getParameters().get('eventName');
        PageReference pg;
        
        switch on eventName {
            when 'verifyUserSuccess' 
            {
                String pageRef = Apexpages.currentPage().getParameters().get('pageRef');
                pg = new PageReference('/IDP_SignUpSuccess');
                pg.getParameters().put('msg',pageRef);
                pg.setRedirect(true);
            }
        }        
        System.debug('@@@@DEBUG IDPSignUpPageController :: afterSignupSuccess =  ' + pg);

        return pg;
    }
}
/** ******
 * Description: Controller class for IDP_SignUpSuccess.page
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210624          TPhan@aodigy.com    Created Initial Version. 
** ******/

global class IDPSignUpSuccessController
{
    public IDPSignUpSuccessController() {}

    public PageReference doBack() 
    {
        String pageRef = Apexpages.currentPage().getParameters().get('msg');
        PageReference pg = new PageReference(pageRef);
        pg.setRedirect(true);
        System.debug('@@@@DEBUG IDPSignUpSuccessController :: returnedURL = ' + pg);
        return pg;
    }
}
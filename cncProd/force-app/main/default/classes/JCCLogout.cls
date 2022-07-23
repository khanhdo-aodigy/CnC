public class JCCLogout {

    public PageReference logoutReturnfunction()
    {
        //String returnURL= ApexPages.currentPage().getParameters().get('ReturnURL');
        PageReference pageRef = new PageReference('https://www.cyclecarriage.com/sg/feature/Login/Logout');
        pageRef.setRedirect(true);
        return pageRef;

    }
}
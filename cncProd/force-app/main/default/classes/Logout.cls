public class Logout {

    public PageReference logoutfunction()
    {
        PageReference pageRef = new PageReference('/secur/singlelogout.jsp?retUrl=https://jccl-community.force.com/endusers/endusers/JccLogoutreturn');
        pageRef.setRedirect(true);
        return pageRef;

    }
}
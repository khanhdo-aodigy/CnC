@isTest
private class EditUserControllerTest {
    @isTest
    private static void testEditUserController() {
        CustomPermission cusPermission = [SELECT Id FROM CustomPermission WHERE DeveloperName = 'Edit_User' LIMIT 1];
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'KIAPC Sales Manager' LIMIT 1]; 

        User testUser = new User();
        testUser.Alias = 'test123';
        testUser.Email='test123@noemail.com';
        testUser.Emailencodingkey='UTF-8';
        testUser.FirstName='Panda';
        testUser.Lastname='Testing';
        testUser.Languagelocalekey='en_US';
        testUser.Localesidkey='en_US';
        testUser.ProfileId = profile.Id;
        testUser.Country='United States';
        testUser.Timezonesidkey='America/Los_Angeles';
        testUser.Username='test01@noemail.com';
        insert testUser;
        
        //Assign Custom Permission for User via Permission Set
        PermissionSet ps = new PermissionSet();
        ps.Name = 'Edit_User_Test';
        ps.Label = 'Edit User';
        insert ps;
        
        SetupEntityAccess setupEntityAccess = new SetupEntityAccess();
        setupEntityAccess.ParentId = ps.Id;
        setupEntityAccess.SetupEntityId = cusPermission.Id;
        insert setupEntityAccess;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = UserInfo.getUserId();
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        ApexPages.StandardController userController = new ApexPages.StandardController(testUser);
        EditUserController extensionController  = new EditUserController(userController);
        
        extensionController.checkPermission();
        extensionController.save();
        extensionController.cancel();
    }
}
@isTest
private class DocuSignSigningGroupUsersTest {
	@isTest
    private static void testConstructor() {
        List<DocuSignSigningGroupUserDetail> users = new List<DocuSignSigningGroupUserDetail> {new DocuSignSigningGroupUserDetail('Test','Test@Example.com')};
        DocuSignSigningGroupUsers o = new DocuSignSigningGroupUsers(users);
        system.assertEquals(1, o.users.size());
        system.assertEquals('Test', o.users[0].username);
        system.assertEquals('Test@Example.com', o.users[0].email);
    }
}
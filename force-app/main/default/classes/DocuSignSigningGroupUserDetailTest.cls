@isTest
private class DocuSignSigningGroupUserDetailTest {
	@isTest
    private static void testConstructor() {
        DocuSignSigningGroupUserDetail o = new DocuSignSigningGroupUserDetail('Test', 'Test@Example.com');
        system.assertEquals('Test', o.username);
        system.assertEquals('Test@Example.com', o.email);
    }
}
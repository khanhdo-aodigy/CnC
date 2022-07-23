@isTest
private class DocusignSignHereTabDetailTest {
	@istest
    private static void test() {
        DocusignSignHereTabDetail o = new DocusignSignHereTabDetail('//s1//', '1', '2', '20', null);
        system.assertEquals('true', o.anchorIgnoreIfNotPresent);
        system.assertEquals('//s1//', o.anchorString);
        system.assertEquals('1', o.recipientId);
        system.assertEquals('active', o.status);
        system.assertEquals('2', o.tabId);
        system.assertEquals('signHere', o.tabType);
        system.assertEquals('20', o.anchorXOffset);
        system.assertEquals(null, o.anchorYOffset);
    }
}
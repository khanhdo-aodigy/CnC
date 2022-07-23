@isTest
private class DocusignDateSignedTabDetailTest {
	@isTest
    private static void test() {
        DocusignDateSignedTabDetail o = new DocusignDateSignedTabDetail('//d1//', '1', '2', '20', null);
        system.assertEquals('true', o.anchorIgnoreIfNotPresent);
        system.assertEquals('//d1//', o.anchorString);
        system.assertEquals('1', o.recipientId);
        system.assertEquals('active', o.status);
        system.assertEquals('2', o.tabId);
        system.assertEquals('signHere', o.tabType);
        system.assertEquals('20', o.anchorXOffset);
        system.assertEquals(null, o.anchorYOffset);
    }
}
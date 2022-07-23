@isTest
private class DocusignSignHereTabsTest {
	@isTest
    private static void test() {
        DocusignSignHereTabDetail a = new DocusignSignHereTabDetail('//s1//', '1', '2');
        DocusignSignHereTabDetail b = new DocusignSignHereTabDetail('//s1//', '1', '2');
        DocusignSignHereTabDetail c = new DocusignSignHereTabDetail('//s1//', '1', '2');
        List<DocusignSignHereTabDetail> signHereTabs = new List<DocusignSignHereTabDetail>{a,b,c};
        DocusignSignHereTabs o = new DocusignSignHereTabs(signHereTabs);
        system.assertEquals(3, o.signHereTabs.size());
    }
}
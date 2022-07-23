@isTest
private class DocusignTabsTest {
	@isTest
    private static void test_MF() {
        DocusignSignHereTabDetail a = new DocusignSignHereTabDetail('//s1//', '1', '2', '20', null);
        DocusignSignHereTabDetail b = new DocusignSignHereTabDetail('//s1//', '1', '2', '20', null);
        DocusignSignHereTabDetail c = new DocusignSignHereTabDetail('//s1//', '1', '2', '20', null);
        List<DocusignSignHereTabDetail> signHereTabs = new List<DocusignSignHereTabDetail>{a,b,c};
        DocusignTabs o = new DocusignTabs(signHereTabs);
        system.assertEquals(3, o.signHereTabs.size());
    }

    @isTest
    private static void test_MB() {
        DocusignSignHereTabDetail a = new DocusignSignHereTabDetail('//s1//', '1', '2', '20', null);
        DocusignSignHereTabDetail b = new DocusignSignHereTabDetail('//s1//', '1', '2', '20', null);
        DocusignDateSignedTabDetail d1 = new DocusignDateSignedTabDetail('//d1//', '1', '2', '20', null);
        List<DocusignSignHereTabDetail> signHereTabs = new List<DocusignSignHereTabDetail>{a,b};
        List<DocusignDateSignedTabDetail> dateSignedTabs = new List<DocusignDateSignedTabDetail>{d1};
        DocusignTabs o = new DocusignTabs(signHereTabs, dateSignedTabs);
        System.assertEquals(2, o.signHereTabs.size());
        System.assertEquals(1, o.dateSignedTabs.size());
    }

    @isTest
    private static void test_Contructor_No_Param() {
        DocusignTabs o = new DocusignTabs();
        System.assertNotEquals(null, o);
    }
}
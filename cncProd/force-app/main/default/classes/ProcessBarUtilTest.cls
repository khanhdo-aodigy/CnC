@isTest
private class ProcessBarUtilTest {
    
    @isTest
    private static void test() {
        list<Form_Process_Bar__mdt> metas = ProcessBarUtil.getConfigByPS('DigitalSalesAgreement');
        system.assertNotEquals(0, metas.size());
    }
}
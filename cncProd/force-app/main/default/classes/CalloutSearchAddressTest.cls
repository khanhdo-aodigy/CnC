@isTest
private class CalloutSearchAddressTest {
	
    @isTest
    private static void test() {
        Test.setMock(HttpCalloutMock.class, new CalloutSearchAddressMockResponse());
        Test.startTest();
        CalloutSearchAddress o = new CalloutSearchAddress();
        map<string, object> results = o.getAddressByPostalCode('320001');
        Test.stopTest();
        system.assertEquals('1 SAINT GEORGE ROAD HDB-KALLANG/WHAMPOA SINGAPORE 320001', results.get('ADDRESS'));
    }
    
    @isTest
    private static void test_nullPostalCode() {
        CalloutSearchAddress o = new CalloutSearchAddress();
        try {
        	map<string, object> results = o.getAddressByPostalCode(null);    
        } catch (Exception e) {
            system.assertEquals('Postal Code is empty', e.getMessage());
        }
    }
}
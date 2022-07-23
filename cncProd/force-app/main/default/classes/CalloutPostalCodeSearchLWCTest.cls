@isTest
private class CalloutPostalCodeSearchLWCTest {
	
    @isTest
    private static void test() {
        Test.setMock(HttpCalloutMock.class, new CalloutSearchAddressMockResponse());
        Test.startTest();
        map<string, object> results = CalloutPostalCodeSearchLWC.searchAddressByPostalCode('320001');
        Test.stopTest();
        system.assertEquals('1 SAINT GEORGE ROAD HDB-KALLANG/WHAMPOA SINGAPORE 320001', results.get('ADDRESS'));
    }
    
    @isTest
    private static void test_nullPostalCode() {
        try {
        	map<string, object> results = CalloutPostalCodeSearchLWC.searchAddressByPostalCode(null);    
        } catch (Exception e) {
            system.assertEquals('Postal Code is empty', e.getMessage());
        }
    }
}
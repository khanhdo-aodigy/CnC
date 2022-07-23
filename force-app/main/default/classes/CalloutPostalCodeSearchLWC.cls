public with sharing class CalloutPostalCodeSearchLWC {

    @AuraEnabled(cacheable = true)
    public static map<String, Object> searchAddressByPostalCode(String postalCode) {
        CalloutSearchAddress callOut = new CalloutSearchAddress();
        map<String, Object> response = callOut.getAddressByPostalCode(postalCode);
        system.debug(response);
        return response;

    }
}
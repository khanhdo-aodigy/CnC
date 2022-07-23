public class CalloutSearchAddress {

    /** 
      Sample success response
      {
        "BUILDING": "HDB-KALLANG/WHAMPOA",
        "LONGTITUDE": "103.86163080083",
        "ADDRESS": "1 SAINT GEORGE'S ROAD HDB-KALLANG/WHAMPOA SINGAPORE 320001",
        "LONGITUDE": "103.86163080083",
        "POSTAL": "320001",
        "X": "31150.867174594703",
        "Y": "33960.6747342702",
        "SEARCHVAL": "HDB-KALLANG/WHAMPOA",
        "ROAD_NAME": "SAINT GEORGE'S ROAD",
        "BLK_NO": "1",
        "LATITUDE": "1.3234026369407"
      }
     */

    private String environment { get; set; }
    static String className = 'CalloutSearchAddress';
    private ADGLIB_CalloutUtils calloutRequest;
    private CalloutAPI__mdt callOutConfig;

    public CalloutSearchAddress() {
        environment = ADGLIB_UtilityHelper.isSandbox() == true ? 'SANDBOX' : 'PRODUCTION';

        try {
            ADGLIB_QueryFactory querySelector = ADGLIB_UtilityHelper.getQueryFactoryByObject('CalloutAPI__mdt', true);
            querySelector.setCondition('Environment__c = :environment AND CalloutClassName__c = :className');
            callOutConfig = (CalloutAPI__mdt) Database.query(querySelector.toSOQL()) [0]; //This should alway return 1 if not we default to the first record
            calloutRequest = new ADGLIB_CalloutUtils();
        } catch(Exception e) {
            system.debug('Error: There is no configuration data of the API callout.' + e.getMessage());
        }
    }


    public map<String, Object> getAddressByPostalCode(String postal) {
        map<String, Object> mapJsonDataReturn = new map<String, Object> ();

        if (postal == null) {
            throw new CalloutException('Postal Code is empty');
        }

        calloutRequest.setReqEndpoint(callOutConfig.Endpoint__c + '/' + callOutConfig.ActionURI__c + '?PostalCode=' + postal)
        .setReqMethod(callOutConfig.MethodType__c)
        .setHeader('Content-Type', 'application/json')
        .setHeader('apikey', callOutConfig.APIKey__c)
        .setTimeout((Integer) callOutConfig.TimeOutLimit__c);

        calloutRequest.send();

        if (calloutRequest.rep.getStatusCode() != 200) {
            throw new CalloutException(calloutRequest.rep.getBody());
        }

        mapJsonDataReturn = (map<String, Object>) JSON.deserializeUntyped(calloutRequest.rep.getBody());


        return mapJsonDataReturn;

    }

}
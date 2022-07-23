public class VSMS_CallOutToDeleteSOAcc {
    
    //static final String API_KEY = '7BC2818E-4971-4D4B-8925-58884B4E80d9';
    //static final Integer TIME_OUT = 120000;
    //static final String END_POINT = 'https://api.stg.cyclecarriage.com/vSMS/salesorder_accs/delete?';
    
    static VSMSCallout__mdt apiCallout = [SELECT APIKey__c, Endpoint__c, TimeOut__c, Method__c from VSMSCallout__mdt WHERE MasterLabel = 'VSMSCallout_Delete'];
    
    public static List<String> DebugLogsListSuccess = New List<String>();
    public static List<String> DebugLogsListError = New List<String>();
    public class CalloutException extends Exception {}    
    
    @future(callout=true)
    public static void callOutToVSMSToDeleteSOAcc (String uniqueBRCD, String FRCD, String sONo, String lineNo) {
        
        String endPoint = apiCallout.Endpoint__c + 'uniquebrcd=' + uniqueBRCD + '&frncd=' + FRCD + '&sono=' + sONo + '&lineno=' + lineNo;
        Http http = new Http();
        HttpRequest calloutUtil = new HttpRequest();
        calloutUtil.setMethod(apiCallout.Method__c);
        calloutUtil.setTimeout((Integer)apiCallout.TimeOut__c);
        calloutUtil.setHeader('Accept', 'application/json');
        calloutUtil.setHeader('Content-Type', 'application/json');
        calloutUtil.setHeader('apikey', apiCallout.APIKey__c);
        calloutUtil.setEndpoint(endPoint);
        
        try {
            HttpResponse res = http.send(callOutUtil);
            if (res.getStatusCode() == 200) {
                DebugLogsListSuccess.add('SA Accessory has been deleted/updated on VSMS ');
            }
            System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody());
            DebugLogsListError.add('Error: ' + res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody());
            serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc', '', calloutUtil, res);
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            loggerDataPool.buildLogDataPool('VSMS_CallOutToDeleteSOAcc.callOutToVSMSToDeleteSOAcc', e);
            throw new CalloutException ('false');
        }
        
        DebugLogs.getDebugLogs('VSMS_Callout',DebugLogsListSuccess,DebugLogsListError);
    }
}
public class VSMS_CallOutToUpdateStatus {
    static VSMSCallout__mdt apiCallout = [SELECT APIKey__c, Endpoint__c, TimeOut__c, Method__c from VSMSCallout__mdt WHERE MasterLabel = 'VSMSCallout_Upsert'];
    
    public static List<String> DebugLogsListSuccess = New List<String>();
    public static List<String> DebugLogsListError = New List<String>();
    public class CalloutException extends Exception {}    

    @future(callout = true)
    public static void callOutToUpdateStatus (Id saId) {
        
        Http http = new Http();
        HttpRequest calloutUtil = new HttpRequest();
        calloutUtil.setMethod(apiCallout.Method__c);
        calloutUtil.setTimeout((Integer)apiCallout.TimeOut__c);
        calloutUtil.setHeader('Accept', 'application/json');
        calloutUtil.setHeader('Content-Type', 'application/json');
        calloutUtil.setHeader('apikey', apiCallout.APIKey__c);
        calloutUtil.setEndpoint(apiCallout.Endpoint__c);
        
        if (saId == null) {
            return;
        }
        
        try {
            String reqBody = VSMS_SalesAgrmntMappingSalesOrder.generateRequestBody(saId, true);       
            if (reqBody == 'error') {
                throw new CalloutException('false -- request body error');
            } else {
                calloutUtil.setBody(reqBody);
                HttpResponse res = http.send(calloutUtil); 
                //System.debug('Update SA STATUS to VSMS');
                if (res.getStatusCode() == 200) {
                     DebugLogsListSuccess.add('SO STATUS has been updated to vSMS');     
                } else {
                    System.debug(res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody());
                    DebugLogsListError.add('Error:' + res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody());
                }
                DebugLogs.getDebugLogs('VSMS_Callout',DebugLogsListSuccess,DebugLogsListError);
                serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_CallOutToUpdateStatus', '', calloutUtil, res);
            }  
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            loggerDataPool.buildLogDataPool('VSMS_Callout', e);
            throw new CalloutException('false -- exception error'); 
        }
    } 
}
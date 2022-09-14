/** *****
 * Description : Common class to perform callout to getsAsia for different operations
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                     Ticket                         Description
 * 20220818             HS@aodigy.com         US-Ship-000027              Created Initial Version. 
 * 20220824             phan.thu@aodigy.com   US-Ship-000027              Added invokeApiCallToGetResponse, generateSeqNo, generateHttpRequestPayloadForResponseAPI methods
** *****/
public class VS_HttpCalloutUtil 
{   
    private final static String DOC_TYPE = 'RESR';

    /**
	 * Details : To invoke getsAsia API
	 * @param {serializedReqBody} :	String of request body payload
     * @param {referenceId} : Primary record reference ID 
     */
    public static ResponseWrapper invokeApiCall(String serializedReqBody, String referenceId, String type) 
    {
        String errMsg           = '';
        Http http               = new Http();
        HttpRequest req         = new HttpRequest();
        ResponseWrapper wrapper = new ResponseWrapper();
        HttpResponse res;

        req.setMethod('POST');
        req.setEndpoint('callout:getsAsia');
        req.setHeader('Content-Type','application/json; charset=utf-8');
        req.setHeader('service-name','CRFDirectSubmission');
        req.setHeader('xbs-api-key','{!$Credential.Password}');
        req.setTimeout(120000);
        req.setBody(serializedReqBody.replaceAll('"date_Z":', '"date":'));

        res = http.send(req);    
        
        serviceDataPool.ServiceDataPoolWrapper serviceWrapper = new serviceDataPool.ServiceDataPoolWrapper('getsAsiaCallout-' + type, 'VS_HttpCalloutUtil', referenceId, req, res);

        wrapper.res                    = res;
        wrapper.serviceDataPoolWrapper = serviceWrapper;

        return wrapper;
    }

    /**
     * Details : To invoke Response API
     * @param {serializedReqBody} :	String of request body payload
     * @param {referenceId} : Primary record reference ID 
     */
    public static ResponseWrapper invokeApiCallToGetResponse(String serializedReqBody, String referenceId)
    {
        String errMsg           = '';
        Http http               = new Http();
        HttpRequest req         = new HttpRequest();
        ResponseWrapper wrapper = new ResponseWrapper();
        HttpResponse res;

        req.setMethod('POST');
        req.setEndpoint('callout:getsAsia');
        req.setHeader('Content-Type','application/json; charset=utf-8');
        req.setHeader('service-name','CRFReceiveResponse');
        req.setHeader('xbs-api-key','{!$Credential.Password}');
        req.setTimeout(120000);
        req.setBody(serializedReqBody);

        res = http.send(req);       
        
        serviceDataPool.ServiceDataPoolWrapper serviceWrapper = new serviceDataPool.ServiceDataPoolWrapper('getsAsiaCalloutToResponseAPI', 'VS_HttpCalloutUtil', referenceId, req, res);

        wrapper.res                    = res;
        wrapper.serviceDataPoolWrapper = serviceWrapper;

        return wrapper;
    }

    /**
     * Details : Generate Request Payload for Response API
     * @param {transactionId} :	Transaction Id returned from getsAsia
     */

    public static String generateHttpRequestPayloadForResponseAPI(String transactionId)
    {
        RequestWrapper req = new RequestWrapper();

        req.messageType   = DOC_TYPE;
        req.documentType  = DOC_TYPE;
        req.transactionId = transactionId;

        return JSON.serialize(req);
    }

    /**
     * Details : To generate Seq No
     */
    public static Integer generateSeqNo()
    {
        List<Inward_Declaration__c> todayExistingInwardDecs = InwardDeclarationService.getTodayExistingInwardDeclarations();

        return todayExistingInwardDecs.get(0)?.Inward_Declaration_Seq_No__c <> null ? Integer.valueOf(todayExistingInwardDecs.get(0)?.Inward_Declaration_Seq_No__c) + 1 : 1;  
    }

    public class ResponseWrapper
    {
        public HttpResponse res;
        public serviceDataPool.ServiceDataPoolWrapper serviceDataPoolWrapper;
    }

    private class RequestWrapper
    {
        public String messageType;
        public String documentType;
        public String transactionId;
    }
}
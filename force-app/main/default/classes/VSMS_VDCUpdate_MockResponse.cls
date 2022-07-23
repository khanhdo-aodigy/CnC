@isTest
global with sharing class VSMS_VDCUpdate_MockResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if (request.getBody().contains('VEMCCNO_SUCCESS')) {
            
            response.setBody('{"VEM_CCNO":"VEMCCNO_SUCCESS","VEM_ORGCCNO":"0119-5047524","VEM_BRM_LOCCD":"SGD","VEM_BRM_UNIQUEBRCD":"CCLCCKSGDCCK003","VEM_VEHICLETYPE":"PC","VEM_FRN_FRNCD":"KIAPC","VEM_MYM_MODELCD":"CER1.6AEXG333","VEM_MYM_MODELYEAR":"2018-06-01T00:00:00","VEM_MCM_COLORCD":"ABP","VEM_MTM_TRIMCD":"WK","VEM_PONO":"KIAPC0120190002","VEM_PRODNMONTH":"2019-01-01T00:00:00","VEM_YEAROFMFG":"2019","VEM_REGREQNO":null,"VEM_REGREQDT":null,"VEM_REGREQBY":null,"VEM_REGDT":null,"VEM_ETADT":"2019-06-12T00:00:00","VEM_DELIVERYREQNO":null,"VEM_DELIVERYREQDT":null,"VEM_DELIVERYREQBY":null,"VEM_DELIVERYDT":"2020-03-18T00:00:00"}');
            response.setStatusCode(200);
        } else if (request.getBody().contains('VEMCCNO_FAIL')) {
            response.setBody('{"error":"{"Message":"Save Failed!"}"}');
            response.setStatusCode(400);
        } else {
            throw new VSMSException('TEST VSMS EXCEPTION');
        }
        return response;
    }

    public class VSMSException extends Exception{}
}
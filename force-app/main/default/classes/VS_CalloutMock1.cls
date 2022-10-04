global class VS_CalloutMock1 implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        String resBody = '{"status":"S001","message":"Transaction: 2022090716172437 created successfully.","data":{"date":"2022-09-07T08:17:24.761+00:00","documentRefNo":"2022090716172437","transactionId":2022090716172437,"status":"Draft Created."}}';
        String resBody1 = '{"status":"S001","message":"Response for the transaction id: 2022090712403358","data":[{"Response":{"SenderID":"","RecipientID":"","RegulatoryFilingType":"INPDEC","RegulatoryFilingDesc":"Import Declaration","CustomerRefNo1":"KIAPC","GeTSRefNo":"2022090712403358","Status":"Draft Created","StatusDesc":"Draft Created","DraftCreatedDateTime":"2022-09-07 12:40:36","TotalDuty":"0","TotalDutyCurrencyCode":"SGD","TotalTax":"0","TotalTaxCurrencyCode":"SGD","BrokerUEN":"","BrokerName":"","LastUpdateStaus":"2022-09-07 12:40:36","Remarks":[{"unique_ref_no":{"date":"20220907","seq":"1"},"header":[{"field_name":"Declaration Indicator","description":"Declaration Indicator is required and must be true."}],"transport":[{"field_name":"IN Loading Port","description":"IN Loading Port is not found in Singapore Customs Port Codes list."}],"summary":[{"field_name":"No of Items","description":"No of Items is required and must be greater than zero."}]}]}}]}';
        response.setStatusCode(200);
        if (request.getHeader('service-name') == 'CRFDirectSubmission'){
            response.setBody(resBody);
        }
        else if (request.getHeader('service-name') == 'CRFReceiveResponse') {
            response.setBody(resBody1);
        }
        return response;
    }
}
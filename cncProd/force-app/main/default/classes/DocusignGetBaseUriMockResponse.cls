@isTest
public with sharing class DocusignGetBaseUriMockResponse implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse respond = new HttpResponse();
        respond.setHeader('Content-Type', 'application/json');
        respond.setBody('{"sub":"c0331450-4277-4697-adc1-8afb7c2478b9","name":"Aaron Cycle","given_name":"Aaron","family_name":"Cycle","created":"2019-08-27T08:33:19.53","email":"a.aodigy@gmail.com","accounts":[{"account_id":"1b031c3d-4437-4807-a579-64d44f9e9b30","is_default":false,"account_name":"Aodigy Asia Pacific Pte Ltd","base_uri":"https://demo.docusign.net"},{"account_id":"bee1e3b0-2576-4df4-a794-7f51e96a9d0a","is_default":false,"account_name":"Aaron Cycle","base_uri":"https://demo.docusign.net"},{"account_id":"7ff318cb-0f56-425f-b617-56f7cdfcb1e4","is_default":false,"account_name":"Cycle & Carriage","base_uri":"https://demo.docusign.net"},{"account_id":"1bb2b796-c7a0-4d1c-a36a-dafd4d0a8e17","is_default":true,"account_name":"Aodigy Asia Pacific Pte. Ltd.","base_uri":"https://demo.docusign.net"},{"account_id":"edfbc09d-1dd9-4467-b66a-6773057d6567","is_default":false,"account_name":"Aodigy Asia Pacific Pte. Ltd.","base_uri":"https://demo.docusign.net"}]}');
        respond.setStatusCode(200);
        return respond;
    }
}
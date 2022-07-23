@isTest
private class Test_ServiceDataPool {
    @istest
    private static void testbatch(){
        Test.StartTest();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.addParameter('test', 'test');
        req.requestURI = 'test.salesforce.com';
        req.requestBody = Blob.valueOf('test');
        RestResponse res = new RestResponse();
        res.responseBody = Blob.valueOf('test');
        res.statusCode = 200;
       
        serviceDataPool.buildServiceDataPool('testService', 'serviceDataPool', '123',req,res);
        
        
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        HttpResponse httpres = new HttpResponse();
        httpreq.setMethod('GET');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpreq.setEndpoint('test.salesforce.com');
        httpreq.setHeader('Content-Length', '12338');      
        httpreq.setBody('test');
        httpres.setStatusCode(200);
        httpres.setBodyAsBlob(Blob.valueOf('test'));
        serviceDataPool.buildServiceDataPoolHttp('testService', 'serviceDataPool', '123',httpreq, httpres);
        Test.StopTest();
    }
    
    @istest
    private static void testBuildListServiceDataPoolHttp(){
        Test.StartTest();
        
        Http h = new Http();
        HttpRequest httpreq = new HttpRequest();
        HttpResponse httpres = new HttpResponse();
        httpreq.setMethod('GET');
        httpreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpreq.setEndpoint('test.salesforce.com');
        httpreq.setHeader('Content-Length', '12338');      
        httpreq.setBody('test');
        httpres.setStatusCode(200);
        httpres.setBodyAsBlob(Blob.valueOf('test'));
        
        serviceDataPool.ServiceDataPoolWrapper wrapper1 = new serviceDataPool.ServiceDataPoolWrapper('testService', 'serviceDataPool', '123',httpreq, httpres);
        serviceDataPool.ServiceDataPoolWrapper wrapper2 = new serviceDataPool.ServiceDataPoolWrapper('testService', 'serviceDataPool', '456',httpreq, httpres);
        List<serviceDataPool.ServiceDataPoolWrapper> lstWrapper = new List<serviceDataPool.ServiceDataPoolWrapper>{wrapper1, wrapper2};
        serviceDataPool.buildListServiceDataPoolHttp(lstWrapper);
        Test.StopTest();
    }
    
    
}
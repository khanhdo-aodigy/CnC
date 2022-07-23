@isTest global class TestHttpGenerator implements HttpCalloutMock {
    
    public Integer statusCode;
    public String  Body;
    
     public TestHttpGenerator(Integer statusCode,String Body){
        this.statusCode = statusCode;
        this.Body=Body;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(this.Body);
        res.setStatusCode(this.statusCode);
        return res;
             
    }
}
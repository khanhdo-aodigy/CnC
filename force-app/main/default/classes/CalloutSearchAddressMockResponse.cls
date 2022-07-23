@isTest
public class CalloutSearchAddressMockResponse implements HttpCalloutMock {
	
    public HTTPResponse respond(HTTPRequest req) {
        string body = '{"BUILDING": "HDB-KALLANG/WHAMPOA", "LONGTITUDE": "103.86163080083",' +
            		'"ADDRESS": "1 SAINT GEORGE ROAD HDB-KALLANG/WHAMPOA SINGAPORE 320001", "LONGITUDE": "103.86163080083",' +
        			'"POSTAL": "320001", "X": "31150.867174594703", "Y": "33960.6747342702", "SEARCHVAL": "HDB-KALLANG/WHAMPOA",' +
        			'"ROAD_NAME": "SAINT GEORGE ROAD", "BLK_NO": "1", "LATITUDE": "1.3234026369407"}';
        HttpResponse respond = new HttpResponse();
        respond.setHeader('Content-Type', 'application/json');
        respond.setBody(body);
        respond.setStatusCode(200);
        return respond;
    }
}
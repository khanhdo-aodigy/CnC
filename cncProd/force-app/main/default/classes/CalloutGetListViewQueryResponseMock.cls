@isTest
public class CalloutGetListViewQueryResponseMock implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest req) {
        	String body = '{"query" : "SELECT Name, RecordType.Name, Reward__r.Name, Brand__c, Credit_Amount__c, toLabel(Status__c), toLabel(Channel__c), Source__c, Transaction_Date__c, CreatedBy.Name, COST__c, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, Reward__c, CreatedBy.Id, CreatedById FROM Reward_Usage__c WHERE RecordTypeId = \'012O0000000TZz3\' AND Status__c = \'Expired\' AND Type__c = \'Expiry\' AND (Brand__c = null OR Brand__c = \'KIA\')" }';
            HttpResponse respond = new HttpResponse();
            respond.setHeader('Content-Type', 'application/json');
            respond.setBody(body);
            respond.setStatusCode(200);
            return respond;
	}
}
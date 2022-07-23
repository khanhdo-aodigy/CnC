@isTest 
private class Test_restMBProspect 
{

	@isTest
	private static void testMBProspect() 
	{

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/upsertMBProspect';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

		string body = '{"PromotionName": "PromoA","EventType": "Test Drive","CustomerName": "Peter","MobileNumber": "90998789","EmailAddress": "Peter@gmail.com","PreferredSC": "Collin","TradeIn": "Yes","DateOfBirth": "2020-07-30","TestDriveModel": "Merc","TestDriveDateTime": "2020-06-30T02:20:00.000Z","AddressLine1": "Blk 430 Hougang Av","AddressLine2": "06-8796","AddressLine3": "543921","AddressLine4": "st 21","PostalCode": "543222","CurrentVehicleNumber": "SKP123K","DateTimeOfSubmission": "2020-07-30T02:20:00.000Z","SpareTextField1": "A","SpareTextField2": "B","SpareTextField3": "C","SpareTextField4": "D","SpareTextField5": "E","SpareTextField6": "F","SpareNumberField1": 5,"SpareNumberField2": 4,"SpareDateField1": "2020-08-30","SpareDateField2": "2020-09-30"}';
        req.requestBody = Blob.valueOf(body);
		restMBProspect.doPost();
		restMBProspect.createMBProspect();

	}
}
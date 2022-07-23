@isTest 
private class Test_restDigitalPayment 
{
	@isTest
	private static void testPayment() 
	{
		Order__c c = new Order__c();
		c.OrderID__c = 'Entity-123456';
		c.E_shop_Order_Number__c = 'NUM12345';		
		c.Transaction_Date__c = Date.today();
		c.eInvoice__c = 'INV124';
		c.eInvoice_URL__c = 'www.google.com';
		c.eInvoice_Date__c = Date.today();
		insert c;


        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/DigitalPayment';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

		string body = '{"VehicleRegistrationNumber":"SMA630Y","EshopOrderId":"Entity-123456","EshopOrderNumber":"ABC123456","Branch":"CCF","SiteName":"CIT","TransactionStatus":"submitted_for_settlement","TransactionID":"3x4fbwdz","MaskedCCNo":"**** **** **** 4585","CardType":"Visa","Event":"E-shop","TransactionAmountBySource":48.0}';
        req.requestBody = Blob.valueOf(body);
		restDigitalPayment.doPost();
		restDigitalPayment.createNewPayment();
	}
    
    @isTest
    private static void testCreateRAPayment_happyPath() {
        Account personAcc = Test_DataFactory.createPerson(true, 'RA-Testing', 'Prospect');
        Person_Account_Profiling__c profiling = Test_DataFactory.createPAProfiling(true, personAcc.Id, 'MB_Person_Account_Profiling_RT');
        Used_Car_Vehicle_Stock__c vehicleStock = Test_DataFactory.createSoldUsedCar(true, personAcc.Id, 'STOCK-001', 'OIYG1','AUDI' ,'F1');
    	Sales_Opportunity__c salesOpp = Test_DataFactory.createSalesOpp(true, personAcc.Id, 'Open', 'Dummy-SC', 'dummy.sc@ra.com', '65343434');
        
        Datetime apptDatetime = Datetime.now().addDays(7);
        String location = 'Cycle & Carriage Service Centre - Sin Ming,600 Sin Ming Avenue, Singapore 575733';
        Vehicle_Stock_Reservation__c reservation = Test_DataFactory.createReservation(true, personAcc.Id, apptDatetime, location, 1000, salesOpp.Id,  vehicleStock.Id);
        
        String reservationNo = [SELECT Name
                                FROM Vehicle_Stock_Reservation__c
                                WHERE Id = :reservation.Id].Name;
        
        String reqBody = '{'+
                        '  "ReservationNumber": "'+ reservationNo +'",'+
                        '  "Event": "RA",'+
                        '  "CardType": "Visa",'+
                        '  "MaskedCCNo": "** ** ** 9876",'+
                        '  "NetAmount": 1000,'+
                        '  "TransactionID": "TRANS0098",'+
                        '  "TransactionStatus": "submitted_for_settlement",'+
                        '  "SiteName": "RA",'+
                        '  "Branch": "RA"'+
                        '}';
        Test.startTest();
        String reqURI = '/DigitalPayment/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        restDigitalPayment.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreateRAPayment_invalidReservationNo_errorReturned() {
        String reservationNo = 'DUMMY1';
        String reqBody = '{'+
                        '  "ReservationNumber": "'+ reservationNo +'",'+
                        '  "Event": "RA",'+
                        '  "CardType": "Visa",'+
                        '  "MaskedCCNo": "** ** ** 9876",'+
                        '  "NetAmount": 1000,'+
                        '  "TransactionID": "TRANS0098",'+
                        '  "TransactionStatus": "submitted_for_settlement",'+
                        '  "SiteName": "RA",'+
                        '  "Branch": "RA"'+
                        '}';
        Test.startTest();
        String reqURI = '/DigitalPayment/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        restDigitalPayment.doPost();
        Test.stopTest();
    }
}
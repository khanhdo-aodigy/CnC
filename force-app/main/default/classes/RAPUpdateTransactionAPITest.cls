/** *****
 * Description : Test Class for RAPUpdateTransactionAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                        Description
 * 20220425             tan.nguyen@aodigy.com       Created Initial Version. 
 * 
** *****/

@isTest
private class RAPUpdateTransactionAPITest {
    @TestSetup
    private static void setUp(){
        String profileId = [SELECT Id FROM Profile WHERE Name =: 'MB Purchaser'].Id;
        User testUser = Test_DataFactory.createUserWithProfileID(true, 'Mike', 'Pence', 'test@gmail.com', profileId);
        testUser.Purchaser_Code__c = 'PC123123';
        update testUser;
        System.debug(testUser);

        Used_Car_Quote__c testQuote = new Used_Car_Quote__c();
        testQuote.Chassis_No__c = '12321';
        testQuote.Vehicle_No__c = 'AB423nv';
        testQuote.Intended_Deregistration_Date__c = Date.today();
        testQuote.Customer_ID_Type__c = Used_Car_Quote__c.Customer_ID_Type__c.getDescribe().getPicklistValues()[1].getValue();
        testQuote.Customer_NRIC__c = 'HIHI';
        testQuote.Status__c = 'Open';
        testQuote.recordTypeId = UsedCarQuoteService.getMBRecordTypeId();
        testQuote.OwnerId = testUser.Id;
        insert testQuote;

        System.debug(testQuote.Customer_ID_Type__c);
    }

    @isTest 
    private static void testUpdateTransaction_Success() {
        String reqBody = '{"ChassisNo" : "12321", "VehicleNo": "AB423nv", "PurchaserCode" : "PC123123" ,"TransactionDetails": {"PurchasePrice": 700000, "PurchaseDate" : "2022-05-01", "CarHandoverDate": "2022-04-22", "DocNo": "ABr234"}}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateTransaction/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAPUpdateTransactionAPI.doPost();
        Test.stopTest();
    }

    @isTest
    private static void testUpdateTransaction_invalidPurchaserCode() {
        String reqBody = '{"ChassisNo" : "12321", "VehicleNo": "AB423nv","PurchaserCode" : "PC789789", "TransactionDetails": {"PurchasePrice": 700000, "PurchaseDate" : "2022-05-01", "CarHandoverDate": "2022-04-22", "DocNo": "ABr234"}}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateTransaction/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAPUpdateTransactionAPI.doPost();
        Test.stopTest();
    }

    @isTest
    private static void testUpdateTransaction_moreThanOnePurchaser() {
        String profileId = [SELECT Id FROM Profile WHERE Name =: 'MB Purchaser'].Id;
        User testUser = Test_DataFactory.createUserWithProfileID(true, 'Don', 'Trump', 'test123@gmail.com', profileId);
        testUser.Purchaser_Code__c = 'PC123123';
        update testUser;
        String reqBody = '{"ChassisNo" : "12321", "VehicleNo": "AB423nv","PurchaserCode" : "PC123123", "TransactionDetails": {"PurchasePrice": 700000, "PurchaseDate" : "2022-05-01", "CarHandoverDate": "2022-04-22", "DocNo": "ABr234"}}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateTransaction/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAPUpdateTransactionAPI.doPost();
        Test.stopTest();
    }

    @isTest
    private static void testUpdateTransaction_inValidProfile() {
        User testUser = Test_DataFactory.createUser(true, 'Hil', 'Clin');
        testUser.Purchaser_Code__c = 'PC0123';
        update testUser;
        String reqBody = '{"ChassisNo" : "12321", "VehicleNo": "AB423nv","PurchaserCode" : "PC0123", "TransactionDetails": {"PurchasePrice": 700000, "PurchaseDate" : "2022-05-01", "CarHandoverDate": "2022-04-22", "DocNo": "ABr234"}}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateTransaction/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAPUpdateTransactionAPI.doPost();
        Test.stopTest();
    }

    @isTest
    private static void testUpdateTransaction_missingField() {
        String reqBody = '{"ChassisNo" : "12321", "VehicleNo": "zxcad", "TransactionDetails": {"PurchasePrice": 700000, "PurchaseDate" : "2022-05-01", "CarHandoverDate": "2022-04-22", "DocNo": ""}}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateTransaction/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAPUpdateTransactionAPI.doPost();
        Test.stopTest();
    }

    @isTest 
    private static void testUpdateTransaction_noActiveQuotation() {
        Used_Car_Quote__c testQuote = [SELECT Id FROM Used_Car_Quote__c];
        testQuote.Status__c = 'Closed';
        update testQuote;
        String reqBody = '{"ChassisNo" : "12321", "VehicleNo": "AB423nv", "PurchaserCode" : "PC123123", "TransactionDetails": {"PurchasePrice": 700000, "PurchaseDate" : "2022-05-01", "CarHandoverDate": "2022-04-22", "DocNo": "ABr234"}}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateTransaction/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAPUpdateTransactionAPI.doPost();
        Test.stopTest();
    }
    
    @isTest 
    private static void testUpdateTransaction_exception() {
        String reqBody = '"ChassisNo" : "123123", "VehicleNo": "AB423nv", "TransactionDetails": {"PurchasePrice": 700000, "PurchaseDate" : "2022-05-01", "CarHandoverDate": "2022-04-22", "DocNo": "ABr234"}';
        Test.startTest();
        String reqURI = '/UsedCarQuote/updateTransaction/*';
        Test_DataFactory.createReqSF(reqURI, 'POST', reqBody, null, 200);
        RAPUpdateTransactionAPI.doPost();
        Test.stopTest();
    }
}
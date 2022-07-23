/** *****
 * Description : Test Class for RA_PriceAlertAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210310             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
public class RA_PriceAlertAPITest {
    private static String stockNumber = 'STOCK001';
    
	@testSetup
    private static void createTestData(){
        RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();
        RA_GlobalVar.Default_RA_OwnerId__c = UserInfo.getUserId();
        RA_GlobalVar.APIGateway_URL__c     = 'www.urltothehell.com';
        RA_GlobalVar.APIGateway_Key__c     = 'myKey';
        upsert RA_GlobalVar;
        
        Used_Car_Vehicle_Stock__c stock = Test_DataFactory.createOpenUsedCar(true, stockNumber, 'SG001AK', 'AUDI','L1');
    }
    
    @isTest
    private static void testPriceAlert_newProspect_Success() {
        String reqBody = '{'+
                        '  "FirstName": "ChuChoChamKam",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6599996666,'+
                        '  "Email": "chutrochamkam@gmail.com",'+
                        '  "DocNo": "'+stockNumber+'",'+
                        '  "SCName": "Mimi RA-SC",'+
                        '  "SCEmail": "mimi.sc@ra.com",'+
                        '  "SCMobile": 6598765432,'+
                        '  "ConsentForMarketingRA": true'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/PriceAlert/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_PriceAlertAPI.createRAPriceAlert();
        Test.stopTest();
    }
    
    @isTest
    private static void testPriceAlert_InvalidRequestBody_ExceptionThrown() {
        String reqBody = '{'+
                        '  "FirstName": "ChuChoChamKam",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6599996666abc,'+
                        '  "Email": "chutrochamkam@gmail.com",'+
                        '  "DocNo": "'+stockNumber+'",'+
                        '  "SCName": "Mimi RA-SC",'+
                        '  "SCEmail": "mimi.sc@ra.com",'+
                        '  "SCMobile": 6598765432,'+
                        '  "ConsentForMarketingRA": true'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/PriceAlert/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_PriceAlertAPI.createRAPriceAlert();
        Test.stopTest();
    }
    
    @isTest
    private static void testPriceAlert_InvalidDocNo_ErrMessageThrown() {
        String reqBody = '{'+
                        '  "FirstName": "ChuChoChamKam",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6599996666,'+
                        '  "Email": "chutrochamkam@gmail.com",'+
                        '  "DocNo": "001",'+
                        '  "SCName": "Mimi RA-SC",'+
                        '  "SCEmail": "mimi.sc@ra.com",'+
                        '  "SCMobile": 6598765432,'+
                        '  "ConsentForMarketingRA": true'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/PriceAlert/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_PriceAlertAPI.createRAPriceAlert();
        Test.stopTest();
    }
    
    @isTest
    private static void testPriceAlert_MissingRequiredFields_ErrMessageThrown() {
        String reqBody = '{'+
                        '  "FirstName": "  ",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6599996666,'+
                        '  "Email": "chutrochamkam@gmail.com",'+
                        '  "DocNo": "'+stockNumber+'",'+
                        '  "SCName": "Mimi RA-SC",'+
                        '  "SCEmail": "mimi.sc@ra.com",'+
                        '  "SCMobile": 6598765432,'+
                        '  "ConsentForMarketingRA": true'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/PriceAlert/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_PriceAlertAPI.createRAPriceAlert();
        Test.stopTest();
    }
    
    @isTest
    private static void testPriceAlert_InvalidCustomerMobile_ErrMessageThrown() {
        String reqBody = '{'+
                        '  "FirstName": "ChuChoChamKam",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 8499996666,'+
                        '  "Email": "chutrochamkam@gmail.com",'+
                        '  "DocNo": "'+stockNumber+'",'+
                        '  "SCName": "Mimi RA-SC",'+
                        '  "SCEmail": "mimi.sc@ra.com",'+
                        '  "SCMobile": 6598765432,'+
                        '  "ConsentForMarketingRA": true'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/PriceAlert/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_PriceAlertAPI.createRAPriceAlert();
        Test.stopTest();
    }
    
    @isTest
    private static void testPriceAlert_InvalidCustomerEmail_ErrMessageThrown() {
        String reqBody = '{'+
                        '  "FirstName": "ChuChoChamKam",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6599996666,'+
                        '  "Email": "chutrochamkam.com",'+
                        '  "DocNo": "'+stockNumber+'",'+
                        '  "SCName": "Mimi RA-SC",'+
                        '  "SCEmail": "mimi.sc@ra.com",'+
                        '  "SCMobile": 6598765432,'+
                        '  "ConsentForMarketingRA": true'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/PriceAlert/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_PriceAlertAPI.createRAPriceAlert();
        Test.stopTest();
    }
    
    @isTest
    private static void testPriceAlert_InvalidSCMobile_ErrMessageThrown() {
        String reqBody = '{'+
                        '  "FirstName": "ChuChoChamKam",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6599996666,'+
                        '  "Email": "chutrochamkam@gmail.com",'+
                        '  "DocNo": "'+stockNumber+'",'+
                        '  "SCName": "Mimi RA-SC",'+
                        '  "SCEmail": "mimi.sc@ra.com",'+
                        '  "SCMobile": 65987,'+
                        '  "ConsentForMarketingRA": true'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/PriceAlert/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_PriceAlertAPI.createRAPriceAlert();
        Test.stopTest();
    }
    
    @isTest
    private static void testPriceAlert_InvalidSCEmail_ErrMessageThrown() {
        String reqBody = '{'+
                        '  "FirstName": "ChuChoChamKam",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6599996666,'+
                        '  "Email": "chutrochamkam@gmail.com",'+
                        '  "DocNo": "'+stockNumber+'",'+
                        '  "SCName": "Mimi RA-SC",'+
                        '  "SCEmail": "mimi.ra.com",'+
                        '  "SCMobile": 6598765432,'+
                        '  "ConsentForMarketingRA": true'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/PriceAlert/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_PriceAlertAPI.createRAPriceAlert();
        Test.stopTest();
    }
}
/** *****
 * Description : Test Class for RAMakeViewAppointmentAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210110             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class RAMakeViewAppointmentAPITest {
    private static String stockNumber = 'STOCK001';
    
    @testSetup
    private static void setupData() {
        Used_Car_Vehicle_Stock__c stock = Test_DataFactory.createOpenUsedCar(true, stockNumber, 'SG-OIYG1', 'AUDI', 'A001');
         
        RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();
        RA_GlobalVar.Default_RA_OwnerId__c = UserInfo.getUserId();
        RA_GlobalVar.APIGateway_URL__c     = 'www.urltothehell.com';
        RA_GlobalVar.APIGateway_Key__c     = 'myKey';
        upsert RA_GlobalVar;
    }
    
	@isTest
    private static void testCreate_happyPath() {        
        String reqBody ='{'+
                        '  "FirstName": "MeoMeo",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6596552945,'+
                        '  "Email": "meomeo@ratest.com",'+
                        '  "Appointment": "26/12/2021",'+
                        '  "Location": "Cycle & Carriage Service Centre - Sin Ming,600 Sin Ming Avenue, Singapore 575733",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiLee",'+
                        '  "SCEmail": "mimi.sc@RA.com",'+
                        '  "SCMobile": 659876543,'+
                       				'  "ConsentForMarketingRA": true'+

                        '}';
        Test.startTest();
        String reqURI = '/ViewAppointment/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAMakeViewAppointmentAPI.insertAppointment();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_missingRequiredField_errorReturned() {        
        String reqBody ='{'+
                        '  "FirstName": "MeoMeo",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6596552945,'+
                        '  "Email": " ",'+
                        '  "Appointment": "26/12/2021",'+
                        '  "Location": "Cycle & Carriage Service Centre - Sin Ming,600 Sin Ming Avenue, Singapore 575733",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiLee",'+
                        '  "SCEmail": "mimi.sc@RA.com",'+
                       				'  "ConsentForMarketingRA": true,'+

                        '  "SCMobile": 659876543'+
                        '}';
        Test.startTest();
        String reqURI = '/ViewAppointment/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAMakeViewAppointmentAPI.insertAppointment();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_invalidDocNo_errorReturned() {        
        String reqBody ='{'+
                        '  "FirstName": "SJ",'+
                        '  "LastName": "Neo",'+
                        '  "Mobile": 6596552945,'+
                        '  "Email": "Neo@gmail.com",'+
                        '  "Appointment": "26/12/2020",'+
                        '  "Location": "Cycle & Carriage Service Centre - Sin Ming,600 Sin Ming Avenue, Singapore 575733",'+
                        '  "DocNo": "FAKE001",'+
                        '  "SCName": "John",'+
                        '  "SCEmail": "John@RA.com",'+
                       				'  "ConsentForMarketingRA": true,'+

                        '  "SCMobile": 659876543'+
                        '}';
        Test.startTest();
        String reqURI = '/ViewAppointment/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAMakeViewAppointmentAPI.insertAppointment();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_invalidMobilePrefix_errorReturned() {        
        String reqBody ='{'+
                        '  "FirstName": "MeoMeo",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 8496552945,'+
                        '  "Email": "test@ra.com",'+
                        '  "Appointment": "26/12/2021",'+
                        '  "Location": "Cycle & Carriage Service Centre - Sin Ming,600 Sin Ming Avenue, Singapore 575733",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiLee",'+
                        '  "SCEmail": "mimi.sc@RA.com",'+
                       				'  "ConsentForMarketingRA": true,'+

                        '  "SCMobile": 659876543'+
                        '}';
        Test.startTest();
        String reqURI = '/ViewAppointment/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAMakeViewAppointmentAPI.insertAppointment();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_invalidMobile_exceptionThrown() {        
        String reqBody ='{'+
                        '  "FirstName": "MeoMeo",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 659655gffsy,'+
                        '  "Email": "test@ra.com",'+
                        '  "Appointment": "26/12/2021",'+
                        '  "Location": "Cycle & Carriage Service Centre - Sin Ming,600 Sin Ming Avenue, Singapore 575733",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiLee",'+
                        '  "SCEmail": "mimi.sc@RA.com",'+
                       				'  "ConsentForMarketingRA": true,'+

                        '  "SCMobile": 659876543'+
                        '}';
        Test.startTest();
        String reqURI = '/ViewAppointment/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAMakeViewAppointmentAPI.insertAppointment();
        Test.stopTest();
    }

}
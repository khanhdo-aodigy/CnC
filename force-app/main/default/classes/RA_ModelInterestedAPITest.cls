/** *****
 * Description : Test Class for RA_ModelInterestedAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210310             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
public class RA_ModelInterestedAPITest {
	private static String stockNumber = 'STOCK001';
    
	@testSetup
    private static void createTestData(){
        RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();
        RA_GlobalVar.Default_RA_OwnerId__c = UserInfo.getUserId();
        RA_GlobalVar.APIGateway_URL__c     = 'www.urltothehell.com';
        RA_GlobalVar.APIGateway_Key__c     = 'myKey';
        upsert RA_GlobalVar;
    }
    
    @isTest
    private static void testModelInterested_newProspect_Success() {
        String reqBody = '{'+
                        '  "FirstName": "ChickToiNghiep",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6588886666,'+
                        '  "Email": "chicktoinghiep@gmail.com",'+
                        '  "ConsentForMarketingRA": true,'+
                        '  "MakeModel": ['+
                        '    {'+
                        '      "Make": "Mercedes-Benz",'+
                        '      "Model": "GLC200"'+
                        '    },'+
                        '    {'+
                        '      "Make": "BMW",'+
                        '      "Model": "320I"'+
                        '    }'+
                        '  ]'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/ModelInterested/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_ModelInterestedAPI.createRAModelInterested();
        Test.stopTest();
    }
    
    @isTest
    private static void testModelInterested_invalidRequestBody_ExceptionThrown() {
        String reqBody = 
                        '  "FirstName": "ChickToiNghiep",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 658888ABC,'+
                        '  "Email": "chicktoinghiep@gmail.com",'+
                        '  "ConsentForMarketingRA": true,'+
                        '  "MakeModel": ['+
                        '    {'+
                        '      "Make": "Mercedes-Benz",'+
                        '      "Model": "GLC200"'+
                        '    },'+
                        '    {'+
                        '      "Make": "BMW",'+
                        '      "Model": "320I"'+
                        '    }'+
                        '  ]'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/ModelInterested/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_ModelInterestedAPI.createRAModelInterested();
        Test.stopTest();
    }
    
    @isTest
    private static void testModelInterested_InvalidCustomerMobile_ErrMessageReturned() {
        String reqBody = '{'+
                        '  "FirstName": "ChickToiNghiep",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 658888,'+
                        '  "Email": "chicktoinghiep@gmail.com",'+
                        '  "ConsentForMarketingRA": true,'+
                        '  "MakeModel": ['+
                        '    {'+
                        '      "Make": "Mercedes-Benz",'+
                        '      "Model": "GLC200"'+
                        '    },'+
                        '    {'+
                        '      "Make": "BMW",'+
                        '      "Model": "320I"'+
                        '    }'+
                        '  ]'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/ModelInterested/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_ModelInterestedAPI.createRAModelInterested();
        Test.stopTest();
    }
    
    @isTest
    private static void testModelInterested_InvalidCustomerEmail_ErrMessageReturned() {
        String reqBody = '{'+
                        '  "FirstName": "ChickToiNghiep",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6588889999,'+
                        '  "Email": "chicktoinghiep.com",'+
                        '  "ConsentForMarketingRA": true,'+
                        '  "MakeModel": ['+
                        '    {'+
                        '      "Make": "Mercedes-Benz",'+
                        '      "Model": "GLC200"'+
                        '    },'+
                        '    {'+
                        '      "Make": "BMW",'+
                        '      "Model": "320I"'+
                        '    }'+
                        '  ]'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/ModelInterested/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_ModelInterestedAPI.createRAModelInterested();
        Test.stopTest();
    }
    
    @isTest
    private static void testModelInterested_MissingMakeModel_ErrMessageReturned() {
        String reqBody = '{'+
                        '  "FirstName": "ChickToiNghiep",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6588889999,'+
                        '  "Email": "chicktoinghiep@gmail.com",'+
                        '  "ConsentForMarketingRA": true,'+
                        '  "MakeModel": []'+
                        '}';
        Test.startTest();
        String reqURI = '/RA/ModelInterested/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RA_ModelInterestedAPI.createRAModelInterested();
        Test.stopTest();
    }
}
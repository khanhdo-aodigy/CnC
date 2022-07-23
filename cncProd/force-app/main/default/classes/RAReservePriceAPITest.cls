/** *****
 * Description : Test Class for RAReservePriceAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210118             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class RAReservePriceAPITest {
	private static String stockNumber = 'STOCK001';
    
    @testSetup
    private static void setupData() {
        Used_Car_Vehicle_Stock__c stock = Test_DataFactory.createOpenUsedCar(true, stockNumber, 'SG-OIYG1', 'AUDI', 'A2');
         
        RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();
        RA_GlobalVar.Default_RA_OwnerId__c = UserInfo.getUserId();
        RA_GlobalVar.APIGateway_URL__c     = 'www.urltothehell.com';
        RA_GlobalVar.APIGateway_Key__c     = 'myKey';
        upsert RA_GlobalVar;
    }
    
	@isTest
    private static void testCreate_happyPath() {        
        String reqBody = '{'+
                        '  "FirstName": "Vu",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6501151055,'+
                        '  "Email": "cat1055@ratest.com",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiFake",'+
                        '  "SCEmail": "oliviapark1@ra.com",'+
                        '  "SCMobile": 6583487544,'+
                        '  "IsPromo" : true,'+
                        '  "Deposit": 500,'+
                        '  "VehiclePriceFinancingDiscount": -500,'+
                        '  "VehiclePriceInsuranceDiscount": -500,'+
                        '  "VehiclePriceTradeInDiscount": -500,'+
                        '  "VehiclePricePromoDiscount": -1500,'+
                        '  "VehiclePriceTotal": 799000,'+
                        '  "CarFinancingDownpayment": 38500,'+
                        '  "CarFinancingLoadAmount": 60000,'+
                        '  "CarFinancingInterestRate": 2.1,'+
                        '  "CarFinancingLoanTerm": 84,'+
                        '  "CarFinancingMonthlyInstallment": 1345,'+
                        '  "UpfrontDownpayment": 38500,'+
                        '  "UpfrontFirstMonthlyInstallment": 1345,'+
                        '  "UpfrontTransferFee": 25,'+
                        '  "UpfrontRoadTax": -745,'+
                        '  "UpfrontPaymentTotal": 40610,'+
                                   	'  "Location": "Singapore",'+
                       	'  "Appointment": "26/12/2020",'+
           				'  "ConsentForMarketingRA": true,'+
                        '  "AddOn": ['+
                        '    {'+
                        '      "AddOnName": "3D Floor Mats 5 Piece Set",'+
                        '      "AddonPrice": -150'+
                        '    },'+
                        '    {'+
                        '      "AddOnName": "3M shield glass",'+
                        '      "AddonPrice": -250'+
                        '    }'+
                        '  ]'+
                        '}';
        Test.startTest();
        String reqURI = '/ReservePrice/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAReservePriceAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_missingRequiredField_errorReturned() {        
        String reqBody = '{'+
                        '  "FirstName": "LovelyCat",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6501151055,'+
                        '  "Email": "",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiFake",'+
                        '  "SCEmail": "oliviapark1@ra.com",'+
                        '  "SCMobile": 6583487544,'+
                        '  "IsPromo" : true,'+
                        '  "Deposit": 500,'+
                        '  "VehiclePriceFinancingDiscount": -500,'+
                        '  "VehiclePriceInsuranceDiscount": -500,'+
                        '  "VehiclePriceTradeInDiscount": -500,'+
                        '  "VehiclePricePromoDiscount": -1500,'+
                        '  "VehiclePriceTotal": 799000,'+
                        '  "CarFinancingDownpayment": 38500,'+
                        '  "CarFinancingLoadAmount": 60000,'+
                        '  "CarFinancingInterestRate": 2.1,'+
                        '  "CarFinancingLoanTerm": 84,'+
                        '  "CarFinancingMonthlyInstallment": 1345,'+
                        '  "UpfrontDownpayment": 38500,'+
                        '  "UpfrontFirstMonthlyInstallment": 1345,'+
                        '  "UpfrontTransferFee": 25,'+
                        '  "UpfrontRoadTax": -745,'+
                        '  "UpfrontPaymentTotal": 40610,'+
                                   	'  "Location": "Singapore",'+
                       	'  "Appointment": "26/12/2020",'+

           				'  "ConsentForMarketingRA": true,'+
                        '  "AddOn": ['+
                        '    {'+
                        '      "AddOnName": "3D Floor Mats 5 Piece Set",'+
                        '      "AddonPrice": -150'+
                        '    },'+
                        '    {'+
                        '      "AddOnName": "3M shield glass",'+
                        '      "AddonPrice": -250'+
                        '    }'+
                        '  ]'+
                        '}';
        Test.startTest();
        String reqURI = '/ReservePrice/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAReservePriceAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_invalidMobilePrefix_errorReturned() {        
        String reqBody = '{'+
                        '  "FirstName": "LovelyCat",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 8401151055,'+
                        '  "Email": "cat1055@ratest.com",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiFake",'+
                        '  "SCEmail": "oliviapark1@ra.com",'+
                        '  "SCMobile": 6583487544,'+
                        '  "IsPromo" : true,'+
                        '  "Deposit": 500,'+
                        '  "VehiclePriceFinancingDiscount": -500,'+
                        '  "VehiclePriceInsuranceDiscount": -500,'+
                        '  "VehiclePriceTradeInDiscount": -500,'+
                        '  "VehiclePricePromoDiscount": -1500,'+
                        '  "VehiclePriceTotal": 799000,'+
                        '  "CarFinancingDownpayment": 38500,'+
                        '  "CarFinancingLoadAmount": 60000,'+
                        '  "CarFinancingInterestRate": 2.1,'+
                        '  "CarFinancingLoanTerm": 84,'+
                        '  "CarFinancingMonthlyInstallment": 1345,'+
                        '  "UpfrontDownpayment": 38500,'+
                        '  "UpfrontFirstMonthlyInstallment": 1345,'+
                        '  "UpfrontTransferFee": 25,'+
                        '  "UpfrontRoadTax": -745,'+
                        '  "UpfrontPaymentTotal": 40610,'+
                       	'  "Location": "Singapore",'+
                                   	'  "Appointment": "26/12/2020",'+
           				'  "ConsentForMarketingRA": true,'+
                        '  "AddOn": ['+
                        '    {'+
                        '      "AddOnName": "3D Floor Mats 5 Piece Set",'+
                        '      "AddonPrice": -150'+
                        '    },'+
                        '    {'+
                        '      "AddOnName": "3M shield glass",'+
                        '      "AddonPrice": -250'+
                        '    }'+
                        '  ]'+
                        '}';
        Test.startTest();
        String reqURI = '/ReservePrice/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAReservePriceAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_invalidDocNo_errorReturned() {        
        String reqBody = '{'+
                        '  "FirstName": "LovelyCat",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6501151055,'+
                        '  "Email": "cat1055@ratest.com",'+
                        '  "DocNo": "NoneExistStock",'+
                        '  "SCName": "MimiFake",'+
                        '  "SCEmail": "oliviapark1@ra.com",'+
                        '  "SCMobile": 6583487544,'+
                        '  "IsPromo" : true,'+
                        '  "Deposit": 500,'+
                        '  "VehiclePriceFinancingDiscount": -500,'+
                        '  "VehiclePriceInsuranceDiscount": -500,'+
                        '  "VehiclePriceTradeInDiscount": -500,'+
                        '  "VehiclePricePromoDiscount": -1500,'+
                        '  "VehiclePriceTotal": 799000,'+
                        '  "CarFinancingDownpayment": 38500,'+
                        '  "CarFinancingLoadAmount": 60000,'+
                        '  "CarFinancingInterestRate": 2.1,'+
                        '  "CarFinancingLoanTerm": 84,'+
                        '  "CarFinancingMonthlyInstallment": 1345,'+
                        '  "UpfrontDownpayment": 38500,'+
                        '  "UpfrontFirstMonthlyInstallment": 1345,'+
                        '  "UpfrontTransferFee": 25,'+
                        '  "UpfrontRoadTax": -745,'+
                        '  "UpfrontPaymentTotal": 40610,'+
                        '  "Location": "Singapore",'+
                       	'  "Appointment": "26/12/2020",'+
            '  "ConsentForMarketingRA": true,'+
                        '  "AddOn": ['+
                        '    {'+
                        '      "AddOnName": "3D Floor Mats 5 Piece Set",'+
                        '      "AddonPrice": -150'+
                        '    },'+
                        '    {'+
                        '      "AddOnName": "3M shield glass",'+
                        '      "AddonPrice": -250'+
                        '    }'+
                        '  ]'+
                        '}';
        Test.startTest();
        String reqURI = '/ReservePrice/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RAReservePriceAPI.doPost();
        Test.stopTest();
    }
}
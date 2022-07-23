/** *****
 * Description : Test Class for RASendPriceDetailAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                 Description
 * 20210118             khanh.do@aodigy      Created Initial Version. 
 * 
** *****/
@isTest
private class RASendPriceDetailAPITest {
	private static String stockNumber = 'STOCK001';
    
    @testSetup
    private static void setupData() {
        Used_Car_Vehicle_Stock__c stock = Test_DataFactory.createOpenUsedCar(true, stockNumber, 'SG-001', 'AUDI', 'F1');
        
        RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();
        RA_GlobalVar.Default_RA_OwnerId__c = UserInfo.getUserId();
        RA_GlobalVar.APIGateway_URL__c     = 'www.urltothehell.com';
        RA_GlobalVar.APIGateway_Key__c     = 'myKey';
        upsert RA_GlobalVar;
    }
    
    @isTest
    private static void testCreate_happyPath() {        
        String reqBody = '{'+
                        '  "FirstName": "LovelyCat",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6501151055,'+
                        '  "Email": "cat1055@ratest.com",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiFake",'+
                        '  "SCEmail": "oliviapark1@ra.com",'+
                        '  "SCMobile": 6583487544,'+
                        '  "IsPromo" : true,'+
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
        String reqURI = '/PriceDetail/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RASendPriceDetailAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_misingRequiredField_errorReturned() {        
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
        String reqURI = '/PriceDetail/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RASendPriceDetailAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_invalidMobilePrefix_errorReturned() {        
        String reqBody = '{'+
                        '  "FirstName": "LovelyCat",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6501151055,'+
                        '  "Email": "cat1055@ratest.com",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiFake",'+
                        '  "SCEmail": "oliviapark1@ra.com",'+
                        '  "SCMobile": 8483487544,'+
                        '  "IsPromo" : true,'+
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
        String reqURI = '/PriceDetail/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RASendPriceDetailAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_invalidDocNo_errorReturned() {        
        String reqBody = '{'+
                        '  "FirstName": "LovelyCat",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 6501151055,'+
                        '  "Email": "cat1055@ratest.com",'+
                        '  "DocNo": "FAKE",'+
                        '  "SCName": "MimiFake",'+
                        '  "SCEmail": "oliviapark1@ra.com",'+
                        '  "SCMobile": 6583487544,'+
                        '  "IsPromo" : true,'+
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
        String reqURI = '/PriceDetail/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RASendPriceDetailAPI.doPost();
        Test.stopTest();
    }
    
    @isTest
    private static void testCreate_invalidMobile_exceptionThrown() {        
        String reqBody = '{'+
                        '  "FirstName": "LovelyCat",'+
                        '  "LastName": "RA-Testing",'+
                        '  "Mobile": 650agbd1055,'+
                        '  "Email": "cat1055@ratest.com",'+
                        '  "DocNo": "' + stockNumber + '",'+
                        '  "SCName": "MimiFake",'+
                        '  "SCEmail": "oliviapark1@ra.com",'+
                        '  "SCMobile": 6583487544,'+
                        '  "IsPromo" : true,'+
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
        String reqURI = '/PriceDetail/insert/*'; 
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        RASendPriceDetailAPI.doPost();
        Test.stopTest();
    }
}
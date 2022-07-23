@isTest
private class UsedCarQuoteTriggerTest {
    @testSetup
    private static void setup() {
        global_var__c test = new global_var__c();
        test.APIGateway_url__c = 'https://www.test.com';
        test.SageMakerAPIKey__c = '123456789';
        upsert test;
        
        Used_Car_Quote__c quote1 = new Used_Car_Quote__c();
        quote1.Chassis_No__c = '12321';
        quote1.Vehicle_No__c = 'AB423nv';
        quote1.Intended_Deregistration_Date__c = Date.today();
        quote1.Customer_ID_Type__c = Used_Car_Quote__c.Customer_ID_Type__c.getDescribe().getPicklistValues()[1].getValue();
        quote1.Customer_NRIC__c = 'HIHI';
        quote1.recordTypeId = UsedCarQuoteService.getMFRecordTypeId();
        insert quote1;
    }
        
    @isTest
    private static void testOnlyActiveQuoteCanBeUpdated() {
        Used_Car_Quote__c quote = [ SELECT Id, Name
                                    FROM Used_Car_Quote__c
                                    WHERE Status__c = 'Open'
                                    LIMIT 1
                                  ];
        
        quote.Status__c = 'Closed';
        update quote;
        Test.startTest();
        try{
        	quote.Purchaser_Quote__c = 200000;
        	update quote;            
        } catch (Exception ex) {}
        Test.stopTest();
    }
    
    @isTest
    private static void testOnRPAErrorReturn() {
        Used_Car_Quote__c quote = [ SELECT Id, Name, Status__c
                                    FROM Used_Car_Quote__c
                                    WHERE Status__c = 'Open'
                                    LIMIT 1
                                  ];        
        quote.RPA_Error__c = 'Something went wrong';
        update quote;
        quote = [ SELECT Id, Status__c FROM Used_Car_Quote__c
                  WHERE Id = :quote.Id
                  LIMIT 1
                ];
        System.assertEquals('Failed', quote.Status__c);
    }
    
    @isTest
    private static void testOnFetchVehicleDetailsSuccessfully() {
        Used_Car_Quote__c quote = [ SELECT Id, Name
                                    FROM Used_Car_Quote__c
                                    WHERE Status__c = 'Open'
                                    LIMIT 1
                                  ];        
        quote.Vehicle_Make__c = 'KIA'; 
        quote.Chassis_No__c = '0001ABC';
        update quote; 
    }
    
    @isTest
    private static void testCalculateRemainingDays() {
        Used_Car_Quote__c quote = [ SELECT Id, Remaining_COE__c
                                    FROM Used_Car_Quote__c
                                    WHERE Status__c = 'Open'
                                    LIMIT 1
                                  ];   
        quote.Intended_Deregistration_Date__c = Date.newInstance(2022, 6, 28);
        quote.COE_Expiry_Date__c = Date.newInstance(2032, 6 ,23);
        update quote;
        quote = [ SELECT Id, Remaining_COE__c FROM Used_Car_Quote__c
                  WHERE Id = :quote.Id
                  LIMIT 1
                ];  
        System.assertEquals('9 Year(s) 11 Month(s) 26 Day(s)', quote.Remaining_COE__c);
        
        quote.Intended_Deregistration_Date__c = Date.newInstance(2021, 12, 31);
        quote.COE_Expiry_Date__c = Date.newInstance(2022, 1, 1);
        update quote;
        quote = [ SELECT Id, Remaining_COE__c FROM Used_Car_Quote__c
                  WHERE Id = :quote.Id
                  LIMIT 1
                ]; 
        System.assertEquals('0 Year(s) 0 Month(s) 1 Day(s)', quote.Remaining_COE__c);
        
        quote.Intended_Deregistration_Date__c = Date.newInstance(2020, 2, 20);
        quote.COE_Expiry_Date__c = Date.newInstance(2022, 3, 15);
        update quote;
        quote = [ SELECT Id, Remaining_COE__c FROM Used_Car_Quote__c
                  WHERE Id = :quote.Id
                  LIMIT 1
                ]; 
        System.assertEquals('2 Year(s) 0 Month(s) 23 Day(s)', quote.Remaining_COE__c);
    }

}
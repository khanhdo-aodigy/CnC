/** *****
 * Description : Test Class for RA_UpdateModelAlertBatch job
 * 
 * Change History
 * Date(YYYYMMDD)       Name                  Description
 * 20210325             khanh.do@aodigy       Created Initial Version. 
 * 
** *****/
@isTest
private class RA_UpdateModelAlertBatchTest {
    
    @isTest
    private static void testCreateStaging() {
        Test.startTest();
        	Used_Car_Vehicle_Stock__c vehStockA1 = Test_DataFactory.createOpenUsedCar(true, 'UCVS00A1', 'SG00A1', 'AUDI', 'A1');
        	Used_Car_Vehicle_Stock__c vehStockA11 = Test_DataFactory.createOpenUsedCar(true, 'UCVS00A11', 'SG00A11', 'AUDI', 'A1');
        	Used_Car_Vehicle_Stock__c vehStockA12 = Test_DataFactory.createOpenUsedCar(true, 'UCVS00A12', 'SG00A12', 'AUDI', 'A1');
            Used_Car_Vehicle_Stock__c vehStockA2 = Test_DataFactory.createOpenUsedCar(true, 'UCVS00A2', 'SG00A2', 'AUDI', 'A2');
        
            Account personAccA = Test_DataFactory.createPerson(true, 'Bear', 'Prospect');
            Sales_Opportunity__c salesOppA = Test_DataFactory.createSalesOpp(true, personAccA.Id, 'Open', 'RA-SC', 'piggy.sc@ra.com', '6588887777');
            
        	Model_Alert_Subscription__c modelAlertA = Test_DataFactory.createRAModelAlert(true, personAccA.Id, salesOppA.Id, Date.today().addDays(30), 'Open');
            Model_Subscribed__c subscribedA1 = Test_DataFactory.createRAModelSubscribed(true, modelAlertA.Id, 'AUDI', 'A1');
            Model_Subscribed__c subscribedA2 = Test_DataFactory.createRAModelSubscribed(true, modelAlertA.Id, 'AUDI', 'A2');
        
        	Account personAccB = Test_DataFactory.createPerson(true, 'DuckDuck', 'Prospect');
            Sales_Opportunity__c salesOppB = Test_DataFactory.createSalesOpp(true, personAccB.Id, 'Open', 'RA-SC', 'kitty.sc@ra.com', '6588887771');
        	
        	Model_Alert_Subscription__c modelAlertB = Test_DataFactory.createRAModelAlert(true, personAccB.Id, salesOppB.Id, Date.today().addDays(30), 'Open');
            Model_Subscribed__c subscribedB = Test_DataFactory.createRAModelSubscribed(true, modelAlertB.Id, 'AUDI', 'A1');

        	Database.executeBatch(new RA_UpdateModelAlertBatch(null, null, 'TODAY'));
        Test.stopTest();
        Integer result = [ SELECT Id
                           FROM Model_Subscribed_Staging__c                                       
                         ].size();
        System.assertEquals(7, result);
    }
    
    @isTest
    private static void testUpdateModelAlertStatus() {
        Test.startTest();
        	
            Account personAcc = Test_DataFactory.createPerson(true, 'Bear', 'Prospect');
            Sales_Opportunity__c salesOpp = Test_DataFactory.createSalesOpp(true, personAcc.Id, 'Open', 'RA-SC', 'piggy.sc@ra.com', '6588887777');
    		
        	
            Used_Car_Vehicle_Stock__c vehStockA3 = Test_DataFactory.createOpenUsedCar(true, 'UCVS00A3', 'SG00A3', 'AUDI', 'A3');
            Model_Alert_Subscription__c expiredTodayModelAlert = Test_DataFactory.createRAModelAlert(true, personAcc.Id, salesOpp.Id, Date.today(), 'Open');
            Model_Subscribed__c expiredTodaySubscribed = Test_DataFactory.createRAModelSubscribed(true, expiredTodayModelAlert.Id, 'AUDI', 'A3');
                
        	Database.executeBatch(new RA_UpdateModelAlertBatch(null, null, 'TODAY'));
        Test.stopTest();
        Model_Alert_Subscription__c result = [ SELECT Id, Subscription_Status__c
                                               FROM Model_Alert_Subscription__c
                                               WHERE Id = :expiredTodayModelAlert.Id
                                             ];
        System.assertEquals('Completed', result.Subscription_Status__c);
    }
}
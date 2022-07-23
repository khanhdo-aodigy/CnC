/** *****
 * Description : Test Class for RA_UpdatePriceAlertBatch job
 * 
 * Change History
 * Date(YYYYMMDD)       Name                  Description
 * 20210319             khanh.do@aodigy       Created Initial Version. 
 * 
** *****/
@isTest
private class RA_UpdatePriceAlertBatchTest {
    private static Double oldPrice = 5000;
    private static Double newPrice = 3500;
    
	@testSetup
    private static void createData() {
        Account pa = Test_DataFactory.createPA(true, 'Bear', 'bear@test.com', 'Prospect');
    	Used_Car_Vehicle_Stock__c usedCar = Test_DataFactory.createOpenUsedCar(false,'UCVS001', 'SG001','AUDI', 'A001');
        usedCar.Listing_Price__c = oldPrice;
        insert usedCar;
        Price_Alert_for_Non_MF__c priceAlert = Test_DataFactory.createRAPriceAlert(true, pa.Id, usedCar.Id, 'Open');
    }
    
    @isTest
    private static void testVehicleSold() {
        Test.startTest();
            Used_Car_Vehicle_Stock__c usedCar = [ SELECT Id, Vehicle_Status__c
                                                  FROM Used_Car_Vehicle_Stock__c
                                                  LIMIT 1
                                                ];

            insert new Used_Car_Vehicle_Stock__History(ParentId = usedCar.Id, Field = 'Vehicle_Status__c' );
        	insert new Used_Car_Vehicle_Stock__History(ParentId = usedCar.Id, Field = 'Vehicle_Status__c');
            Database.executeBatch(new RA_UpdatePriceAlertBatch(null, 'TODAY'));
        Test.stopTest();
    }
    
    @isTest
    private static void testVehiclePriceChange() {
        Test.startTest();
            Used_Car_Vehicle_Stock__c usedCar = [ SELECT Id, Listing_Price__c
                                                  FROM Used_Car_Vehicle_Stock__c
                                                  LIMIT 1
                                                ];

            insert new Used_Car_Vehicle_Stock__History(ParentId = usedCar.Id, Field = 'Listing_Price__c');
        	insert new Used_Car_Vehicle_Stock__History(ParentId = usedCar.Id, Field = 'Vehicle_Status__c');
            insert new Used_Car_Vehicle_Stock__History(ParentId = usedCar.Id, Field = 'Listing_Price__c');
        	 Price_Alert_for_Non_MF__c priceAlert = [ SELECT Id, Previous_Price__c, Latest_Price__c, Vehicle_Stock_Status__c
                                                       FROM Price_Alert_for_Non_MF__c
                                                       WHERE Used_Car_Vehicle_Stock__c = :usedCar.Id
                                                       LIMIT 1
                                                    ];
        Database.executeBatch(new RA_UpdatePriceAlertBatch(new Set<Id>{priceAlert.Id}, 'TODAY'));
        Test.stopTest();
        
       
    }
    
    @isTest
    private static void testNoChangeHasBeenMade() {
        Test.startTest();
            Database.executeBatch(new RA_UpdatePriceAlertBatch());
        Test.stopTest();
    }
}
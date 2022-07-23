@isTest
public class Test_batchDataPool {
    @istest public static void testbatch(){  
        
        Id batchprocessid = Database.executeBatch( new BatchToReReserveStockReservation('BatchToReReserveStockReservation'));
        test.startTest();
        batchDataPool.buildBatchDataPool('BatchToReReserveStockReservation', batchprocessid);
        test.stopTest();
        
    }
    
    
}
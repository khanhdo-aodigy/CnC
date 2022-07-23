@isTest
public class Test_loggerDataPool {
    @istest 
    public static void test_buildLogDataPool(){
        Exception e = new dmlException();
        test.startTest();
        loggerDataPool.buildLogDataPool('Test', e);
        test.stopTest();
    }
}
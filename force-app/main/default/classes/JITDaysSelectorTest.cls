/**
 * Description: test class for JITDaysSelector class
 * Created By: Van Thanh (thanh.ly@aodigy.com)
 * History
 * =================================================================================================================================================================================================================
 *          DATE:                                      BY::                                            CHANGELOG
 *      12 August 2022                                 Van Thanh                                       Create Initial
 *    
 * =================================================================================================================================================================================================================
 */
@isTest
private class JITDaysSelectorTest {
    @TestSetup
    static void setup(){
        JIT_Day__c jitDay = Test_DataFactory.createJITDay(true, '12/08/22', 'KIAPC');
    }

    @isTest
    static void selectById_Test(){
        JIT_Day__c jitDay = [SELECT Id FROM JIT_Day__c LIMIT 1];
        JITDaysSelector js = new JITDaysSelector();
        js.selectById(jitDay.Id);
    }

    @isTest
    static void selectByJITDate_Test(){
        JIT_Day__c jitDay = [SELECT JIT_Date__c FROM JIT_Day__c LIMIT 1];
        JITDaysSelector js = new JITDaysSelector();
        js.selectByJITDate(jitDay.JIT_Date__c);
    }
}
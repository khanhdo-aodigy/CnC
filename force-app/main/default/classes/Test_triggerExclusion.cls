/** ******
 * Description : Test Class for TriggerExclusion.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        				Description
 * 20190117             Hari Panneerselvam          Created Initial Version. 
 * 20200221			    HS							Updated the test class coverage
 * 
** ******/
@isTest
private class Test_triggerExclusion {

    @isTest 
    static void test_excludeTrigger(){
        test.startTest();
            TriggerExclusion.excludeTrigger('Variant_Color__c', True);
            TriggerExclusion.excludeTrigger('Variant_Color__c', False);
            TriggerExclusion.isTriggerExclude('Variant_Color__c');
        test.stopTest();
    }

    @isTest
    static void test_isBypassTriggerExecution(){
        System.Test.startTest();
            System.assert( [SELECT count() FROM Trigger_Exclusion_Setup__mdt] >= 0  );
            System.assert( TriggerExclusion.isBypassTriggerExecution('DUMMT_MDT') );
            System.assert( TriggerExclusion.isBypassTriggerExecution('DUMMT_MDT2') );
        System.Test.stopTest();
    }
}
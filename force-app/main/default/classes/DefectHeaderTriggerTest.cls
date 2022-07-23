@isTest
private class DefectHeaderTriggerTest {
    @testSetup
    static void setUp() {
        Defect_Header__c dh = new Defect_Header__c(Status__c = 'New',
                                                   Service_Center__c = 'Alexandra');
        insert dh;
    }
    @isTest
    static void Test_beforeUpdate_Success_RectifiedDateTimeNotNull() {
        Defect_Header__c dh = [SELECT Id, Rectified_Date_Time__c, Time_taken_to_rectify__c FROM Defect_Header__c LIMIT 1];
        Test.startTest();
        dh.Rectified_Date_Time__c = DateTime.newInstance(2020, 10, 27, 9, 30, 0);
        update dh;
        Test.stopTest();
        dh = [SELECT Id, Rectified_Date_Time__c, Time_taken_to_rectify__c FROM Defect_Header__c LIMIT 1];
        System.assertNotEquals(null, dh.Time_taken_to_rectify__c);
    }
    @isTest
    static void Test_beforeUpdate_Success_RectifiedDateTimeNull() {
        Defect_Header__c dh = [SELECT Id, Rectified_Date_Time__c, Time_taken_to_rectify__c FROM Defect_Header__c LIMIT 1];
        dh.Rectified_Date_Time__c = DateTime.newInstance(2020, 10, 27, 9, 30, 0);
        update dh;
        Test.startTest();
        dh.Rectified_Date_Time__c = null;
        update dh;
        Test.stopTest();
        dh = [SELECT Id, Rectified_Date_Time__c, Time_taken_to_rectify__c FROM Defect_Header__c LIMIT 1];
        System.assertEquals(0, dh.Time_taken_to_rectify__c);
    }

    @isTest
    static void Test_beforeUpdate_Success_AcknowledgementDate_NotNull() {
        Defect_Header__c dh = [SELECT Id, Customer_Acknowledgement_Date__c, SLA_Hours__c FROM Defect_Header__c LIMIT 1];
        Test.startTest();
		dh.Customer_Acknowledgement_Date__c = DateTime.newInstance(2020, 10, 27, 9, 30, 0);
        update dh;
        dh = [SELECT Id, Customer_Acknowledgement_Date__c, SLA_Hours__c FROM Defect_Header__c LIMIT 1];
        System.assertNotEquals(null, dh.SLA_Hours__c);
        Test.stopTest();
    }

    @isTest
    private static void testBypassTrigger() {
        Defect_Header__c dh = [SELECT Id, Customer_Acknowledgement_Date__c, SLA_Hours__c FROM Defect_Header__c LIMIT 1];
        TriggerExclusion.excludeTrigger('Defect_Header__c', true);
		dh.Customer_Acknowledgement_Date__c = DateTime.newInstance(2020, 10, 27, 9, 30, 0);
        update dh;
        TriggerExclusion.excludeTrigger('Defect_Header__c', false);
    }
}
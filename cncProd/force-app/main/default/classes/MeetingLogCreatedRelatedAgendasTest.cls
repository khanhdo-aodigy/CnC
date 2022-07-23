@IsTest
public class MeetingLogCreatedRelatedAgendasTest 
{
    static testMethod void testMeetingLogCreatedAgendas()
    {
        Test.startTest();
        
        Meeting_Log_V2__c meetingLogs = new Meeting_Log_V2__c();
        meetingLogs.Location__c = 'Location1';
        meetingLogs.Type_of_Meeting_Logs__c = 'Morning Briefing';
        meetingLogs.Location__c = 'Kia Showroom1';
        insert meetingLogs;
        
        Meeting_Log_V2__c meetingLogs1 = new Meeting_Log_V2__c();
        meetingLogs1.Location__c = 'Location2';
        meetingLogs1.Type_of_Meeting_Logs__c = 'Debrief';
        meetingLogs1.Location__c = 'Kia Showroom2';
        insert meetingLogs1;
        
        Meeting_Log_V2__c meetingLogs2 = new Meeting_Log_V2__c();
        meetingLogs2.Location__c = 'Location3';
        meetingLogs2.Type_of_Meeting_Logs__c = 'Biweekly Sales Marketing';
        meetingLogs2.Location__c = 'Kia Showroom3';
        insert meetingLogs2;

        Test.stopTest();
        
    }
}